import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/clock_provider.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/safe_back_button.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../billing/rental_billing.dart';
import '../application/rental_providers.dart';
import '../domain/rental.dart';
import '../domain/rental_number.dart';
import '../domain/rental_repository.dart';

class CustomerReturnScreen extends ConsumerStatefulWidget {
  const CustomerReturnScreen({super.key, required this.customerId});

  final String customerId;

  @override
  ConsumerState<CustomerReturnScreen> createState() =>
      _CustomerReturnScreenState();
}

class _CustomerReturnScreenState extends ConsumerState<CustomerReturnScreen> {
  // MaterialId -> total quantity entered
  final _materialQuantities = <String, int>{};

  // MaterialId -> whether manual allocation is toggled on
  final _manualAllocationToggles = <String, bool>{};

  // MaterialId -> (rentalItemId -> allocated quantity)
  final _manualSplits = <String, Map<String, int>>{};

  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final heldAsync = ref.watch(customerHeldItemsProvider(widget.customerId));
    final now = ref.watch(clockProvider).now();
    final theme = Theme.of(context);
    final offset = DateTime.now().timeZoneOffset;

    return Scaffold(
      appBar: AppBar(
        leading: const SafeBackButton(),
        title: Text(l10n.returnMaterials),
      ),
      body: heldAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text(err.toString())),
        data: (held) {
          if (held.materials.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 64,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.noItemsHeld,
                      style: theme.textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    OutlinedButton(
                      onPressed: () => context.pop(),
                      child: Text(l10n.cancel),
                    ),
                  ],
                ),
              ),
            );
          }

          // Compute allocations for each material
          final allAllocations = <ReturnAllocationLine>[];
          final validationErrors = <String>[];

          for (final mat in held.materials) {
            final enteredQty = _materialQuantities[mat.materialId] ?? 0;
            if (enteredQty <= 0) continue;

            final isManual = _manualAllocationToggles[mat.materialId] ?? false;
            if (isManual) {
              final splits = _manualSplits[mat.materialId] ?? {};
              final error = validateManualAllocation(
                lines: mat.lines,
                splits: splits,
                expectedTotal: enteredQty,
              );
              if (error != null) {
                validationErrors.add('${mat.materialName}: $error');
              } else {
                final customLines = buildAllocationLinesFromCustomSplits(
                  lines: mat.lines,
                  splits: splits,
                  returnedAtUtc: now,
                  localOffset: offset,
                );
                allAllocations.addAll(customLines);
              }
            } else {
              final autoLines = allocateReturnQuantityOldestFirst(
                lines: mat.lines,
                quantityToReturn: enteredQty,
                returnedAtUtc: now,
                localOffset: offset,
              );
              allAllocations.addAll(autoLines);
            }
          }

          final grandTotal = allAllocations.fold<int>(
            0,
            (sum, a) => sum + a.amount,
          );
          final hasItemsEntered = allAllocations.isNotEmpty;
          final isValid = hasItemsEntered && validationErrors.isEmpty;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
            children: [
              // Customer header
              Row(
                children: [
                  CircleAvatar(
                    child: Text(
                      held.customerName.isNotEmpty
                          ? held.customerName[0].toUpperCase()
                          : '?',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          held.customerName,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          l10n.unitsHeld(held.totalUnitsHeld),
                          style: TextStyle(color: theme.colorScheme.outline),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Locked date/time banner
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock_clock_outlined, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '${l10n.nowLocked}: ${_formatDateTime(context, now)}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Material cards
              ...held.materials.map((mat) {
                final currentQty = _materialQuantities[mat.materialId] ?? 0;
                final isManual =
                    _manualAllocationToggles[mat.materialId] ?? false;
                final splits = _manualSplits[mat.materialId] ?? {};

                // Allocations for this material preview
                List<ReturnAllocationLine> matAllocations = [];
                if (currentQty > 0) {
                  if (isManual) {
                    matAllocations = buildAllocationLinesFromCustomSplits(
                      lines: mat.lines,
                      splits: splits,
                      returnedAtUtc: now,
                      localOffset: offset,
                    );
                  } else {
                    matAllocations = allocateReturnQuantityOldestFirst(
                      lines: mat.lines,
                      quantityToReturn: currentQty,
                      returnedAtUtc: now,
                      localOffset: offset,
                    );
                  }
                }

                return _MaterialReturnCard(
                  key: ValueKey('mat_card_${mat.materialId}'),
                  material: mat,
                  quantity: currentQty,
                  isManual: isManual,
                  splits: splits,
                  allocations: matAllocations,
                  l10n: l10n,
                  onQuantityChanged: (qty) {
                    setState(() {
                      _materialQuantities[mat.materialId] = qty;
                      // When quantity changes in manual mode, clear manual toggle
                      if (isManual) {
                        _manualAllocationToggles[mat.materialId] = false;
                      }
                    });
                  },
                  onToggleManual: () {
                    setState(() {
                      final newManual = !isManual;
                      _manualAllocationToggles[mat.materialId] = newManual;
                      if (newManual) {
                        // Pre-populate manual splits with oldest-first allocation
                        final autoLines = allocateReturnQuantityOldestFirst(
                          lines: mat.lines,
                          quantityToReturn: currentQty,
                          returnedAtUtc: now,
                          localOffset: offset,
                        );
                        final newSplits = <String, int>{};
                        for (final l in autoLines) {
                          newSplits[l.rentalItemId] = l.quantity;
                        }
                        _manualSplits[mat.materialId] = newSplits;
                      }
                    });
                  },
                  onSplitChanged: (rentalItemId, splitQty) {
                    setState(() {
                      final currentSplits = Map<String, int>.from(
                        _manualSplits[mat.materialId] ?? {},
                      );
                      currentSplits[rentalItemId] = splitQty;
                      _manualSplits[mat.materialId] = currentSplits;
                    });
                  },
                );
              }),
              const SizedBox(height: 16),
              // Notes
              TextField(
                controller: _noteController,
                minLines: 2,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: l10n.returnNoteOptional,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              // Validation errors
              if (validationErrors.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: validationErrors.map((e) {
                      return Text(
                        e,
                        style: TextStyle(
                          color: theme.colorScheme.onErrorContainer,
                          fontSize: 13,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              // Grand total bar
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.totalToPay,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    Text(
                      formatEtb(grandTotal),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Confirm button
              FilledButton(
                key: const ValueKey('customer_return_confirm_button'),
                onPressed: isValid
                    ? () =>
                          _confirmAndSave(held, allAllocations, grandTotal, now)
                    : null,
                child: Text(l10n.confirmReturn),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _confirmAndSave(
    CustomerHeldItems held,
    List<ReturnAllocationLine> allocations,
    int grandTotal,
    DateTime returnedAt,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(l10n.confirmReturn),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${l10n.customer}: ${held.customerName}'),
              Text(
                '${l10n.returnDateTime}: ${_formatDateTime(dialogCtx, returnedAt)}',
              ),
              const Divider(height: 20),
              ...allocations.map((a) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${formatRentalNumber(a.rentalNumber)} · ${a.materialName}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${a.quantity} units · ${a.days} days · ${formatEtb(a.pricePerDaySnapshot)} = ${formatEtb(a.amount)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(dialogCtx).colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const Divider(height: 20),
              Text(
                '${l10n.totalToPay}: ${formatEtb(grandTotal)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      final receipt = await ref
          .read(customerReturnControllerProvider.notifier)
          .recordCustomerReturn(
            customerId: held.customerId,
            allocations: allocations,
            note: _noteController.text.trim().isEmpty
                ? null
                : _noteController.text.trim(),
          );
      if (!mounted) return;
      context.push('/customer-return/batch/${receipt.batchId}', extra: receipt);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e is RentalValidationException ? e.message : l10n.returnSaveError,
          ),
        ),
      );
    }
  }
}

/// Card for entering return quantity for one material, previewing allocation,
/// and optionally adjusting the allocation per-line.
class _MaterialReturnCard extends StatefulWidget {
  const _MaterialReturnCard({
    super.key,
    required this.material,
    required this.quantity,
    required this.isManual,
    required this.splits,
    required this.allocations,
    required this.l10n,
    required this.onQuantityChanged,
    required this.onToggleManual,
    required this.onSplitChanged,
  });

  final CustomerHeldMaterial material;
  final int quantity;
  final bool isManual;
  final Map<String, int> splits;
  final List<ReturnAllocationLine> allocations;
  final AppLocalizations l10n;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onToggleManual;
  final void Function(String rentalItemId, int qty) onSplitChanged;

  @override
  State<_MaterialReturnCard> createState() => _MaterialReturnCardState();
}

class _MaterialReturnCardState extends State<_MaterialReturnCard> {
  late final TextEditingController _qtyController;

  @override
  void initState() {
    super.initState();
    _qtyController = TextEditingController(text: '${widget.quantity}');
  }

  @override
  void didUpdateWidget(covariant _MaterialReturnCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.quantity != widget.quantity) {
      if (_qtyController.text != '${widget.quantity}') {
        _qtyController.text = '${widget.quantity}';
      }
    }
  }

  @override
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = widget.l10n;
    final mat = widget.material;
    final remainingAfter = mat.totalOutstanding - widget.quantity;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Material name and total outstanding
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    mat.materialName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '${l10n.outstanding}: ${mat.totalOutstanding}',
                  style: TextStyle(
                    color: theme.colorScheme.outline,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Returning banner
            if (widget.quantity > 0)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withAlpha(80),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  l10n.returningOfRemaining(
                    remainingAfter,
                    widget.quantity,
                    mat.totalOutstanding,
                  ),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            // Stepper and input row
            Row(
              children: [
                IconButton(
                  key: ValueKey('decrease_${mat.materialId}'),
                  onPressed: widget.quantity > 0
                      ? () => widget.onQuantityChanged(widget.quantity - 1)
                      : null,
                  icon: const Icon(Icons.remove),
                ),
                SizedBox(
                  width: 64,
                  child: TextField(
                    key: ValueKey('qty_input_${mat.materialId}'),
                    controller: _qtyController,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    style: theme.textTheme.titleLarge,
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 4,
                      ),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) {
                      final parsed = int.tryParse(val.trim());
                      if (parsed != null) {
                        widget.onQuantityChanged(
                          parsed.clamp(0, mat.totalOutstanding),
                        );
                      } else if (val.trim().isEmpty) {
                        widget.onQuantityChanged(0);
                      }
                    },
                  ),
                ),
                IconButton(
                  key: ValueKey('increase_${mat.materialId}'),
                  onPressed: widget.quantity < mat.totalOutstanding
                      ? () => widget.onQuantityChanged(widget.quantity + 1)
                      : null,
                  icon: const Icon(Icons.add),
                ),
                const SizedBox(width: 8),
                TextButton(
                  key: ValueKey('all_${mat.materialId}'),
                  onPressed: () =>
                      widget.onQuantityChanged(mat.totalOutstanding),
                  child: Text(l10n.all),
                ),
                TextButton(
                  key: ValueKey('clear_${mat.materialId}'),
                  onPressed: () => widget.onQuantityChanged(0),
                  child: Text(l10n.clear),
                ),
              ],
            ),
            // Allocation preview or manual editor
            if (widget.quantity > 0) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.isManual
                        ? l10n.adjustAllocation
                        : 'Allocation (oldest first)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  TextButton.icon(
                    key: ValueKey('toggle_manual_${mat.materialId}'),
                    onPressed: widget.onToggleManual,
                    icon: Icon(
                      widget.isManual ? Icons.restart_alt : Icons.tune,
                      size: 16,
                    ),
                    label: Text(
                      widget.isManual
                          ? l10n.resetAllocation
                          : l10n.adjustAllocation,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
              if (!widget.isManual)
                // Oldest-first preview
                ...widget.allocations.map((a) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${formatRentalNumber(a.rentalNumber)}: ${a.quantity} units · ${a.days}d · ${formatEtb(a.pricePerDaySnapshot)}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        Text(
                          formatEtb(a.amount),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                })
              else
                // Manual split inputs
                ...mat.lines.map((line) {
                  final splitQty = widget.splits[line.rentalItemId] ?? 0;
                  final days = billableDays(
                    line.rentedAt,
                    DateTime.now().toUtc(),
                    localOffset: DateTime.now().timeZoneOffset,
                  );
                  final lineAmt = splitQty * line.pricePerDaySnapshot * days;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${formatRentalNumber(line.rentalNumber)} (max ${line.outstandingQuantity})',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${formatEtb(line.pricePerDaySnapshot)}/day · $days days = ${formatEtb(lineAmt)}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: theme.colorScheme.outline,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 60,
                          child: TextFormField(
                            key: ValueKey('split_input_${line.rentalItemId}'),
                            initialValue: '$splitQty',
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 6,
                                horizontal: 4,
                              ),
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (val) {
                              final p = int.tryParse(val.trim()) ?? 0;
                              widget.onSplitChanged(line.rentalItemId, p);
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ],
        ),
      ),
    );
  }
}

String _formatDateTime(BuildContext context, DateTime value) {
  final locale = Localizations.localeOf(context).toLanguageTag();
  return DateFormat.yMd(locale).add_jm().format(value.toLocal());
}
