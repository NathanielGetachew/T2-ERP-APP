import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../core/widgets/safe_back_button.dart';
import '../../../core/utils/money.dart';
import '../../customers/application/customer_providers.dart';
import '../../customers/domain/customer.dart';
import '../../materials/application/material_providers.dart';
import '../../materials/domain/rental_material.dart';
import '../application/rental_providers.dart';
import '../domain/rental.dart';
import '../domain/rental_repository.dart';
import '../domain/rental_number.dart';

class RentalEditorScreen extends ConsumerStatefulWidget {
  const RentalEditorScreen({super.key, this.recreateFrom});

  final RentalDetails? recreateFrom;

  @override
  ConsumerState<RentalEditorScreen> createState() => _RentalEditorScreenState();
}

class _RentalEditorScreenState extends ConsumerState<RentalEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  String? _customerId;
  String? _materialId;
  final _quantityController = TextEditingController(text: '1');
  final _lines = <RentalLineDraft>[];
  String? _error;
  bool _recreateSkipped = false;

  @override
  void initState() {
    super.initState();
    final source = widget.recreateFrom;
    if (source != null) {
      _customerId = source.rental.customerId;
      unawaited(_prepareRecreate(source));
    }
  }

  Future<void> _prepareRecreate(RentalDetails source) async {
    final materials = await ref.read(materialsProvider.future);
    final lines = <RentalLineDraft>[];
    var skipped = false;
    for (final sourceLine in source.lines) {
      RentalMaterial? material;
      for (final item in materials) {
        if (item.id == sourceLine.materialId) {
          material = item;
          break;
        }
      }
      final available = material == null
          ? null
          : await ref
                .read(rentalRepositoryProvider)
                .availableStock(material.id);
      if (material == null ||
          !material.isActive ||
          (available != null && available < sourceLine.quantity)) {
        skipped = true;
        continue;
      }
      lines.add(
        RentalLineDraft(
          materialId: sourceLine.materialId,
          quantity: sourceLine.quantity,
        ),
      );
    }
    if (!mounted) return;
    setState(() {
      _lines
        ..clear()
        ..addAll(lines);
      _recreateSkipped = skipped;
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (widget.recreateFrom != null && _notesController.text.isEmpty) {
      _notesController.text = l10n.recreateNote(
        formatRentalNumber(widget.recreateFrom!.rental.rentalNumber),
      );
    }
    final customers = ref.watch(customersProvider);
    final materials = ref.watch(materialsProvider);
    return PopScope(
      canPop: _customerId == null && _lines.isEmpty,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop && mounted) {
          final discard = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(l10n.discardChangesTitle),
              actions: [
                TextButton(
                  onPressed: () => context.pop(false),
                  child: Text(l10n.cancel),
                ),
                FilledButton(
                  onPressed: () => context.pop(true),
                  child: Text(l10n.discardChanges),
                ),
              ],
            ),
          );
          if (discard == true && context.mounted) {
            context.pop();
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: const SafeBackButton(),
          title: Text(l10n.newRental),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              customers.when(
                loading: () => const LinearProgressIndicator(),
                error: (error, stack) => Text(error.toString()),
                data: (items) => DropdownButtonFormField<String>(
                  key: const ValueKey('rental_customer_field'),
                  initialValue: _customerId,
                  decoration: InputDecoration(labelText: l10n.customer),
                  items: items
                      .where((customer) => customer.isActive)
                      .map(
                        (customer) => DropdownMenuItem(
                          value: customer.id,
                          child: Text(customer.fullName),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _customerId = value),
                  validator: (value) =>
                      value == null ? l10n.customerRequired : null,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                key: const ValueKey('rental_customer_search_field'),
                onChanged: (value) =>
                    ref.read(customerSearchQueryProvider.notifier).state =
                        value,
                decoration: InputDecoration(
                  labelText: l10n.searchCustomers,
                  prefixIcon: const Icon(Icons.search),
                ),
              ),
              OutlinedButton(
                key: const ValueKey('rental_add_customer_button'),
                onPressed: () async {
                  final customer = await context.push<Customer>(
                    '/customers/new',
                    extra: (Customer _) {},
                  );
                  if (!context.mounted) {
                    return;
                  }
                  if (customer != null) {
                    setState(() => _customerId = customer.id);
                  }
                },
                child: Text(l10n.addNewCustomer),
              ),
              const SizedBox(height: 16),
              materials.when(
                loading: () => const LinearProgressIndicator(),
                error: (error, stack) => Text(error.toString()),
                data: (items) => DropdownButtonFormField<String>(
                  key: const ValueKey('rental_material_field'),
                  initialValue: _materialId,
                  decoration: InputDecoration(labelText: l10n.material),
                  items: items
                      .where((material) => material.isActive)
                      .map(
                        (material) => DropdownMenuItem(
                          value: material.id,
                          child: Text(
                            '${material.category} - ${material.name} (${formatEtb(material.pricePerDay)})',
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _materialId = value),
                  validator: (value) =>
                      value == null ? l10n.materialRequired : null,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const ValueKey('rental_quantity_field'),
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l10n.quantity),
                validator: (value) {
                  final quantity = int.tryParse(value ?? '');
                  return quantity == null || quantity < 1
                      ? l10n.quantityRequired
                      : null;
                },
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                key: const ValueKey('rental_add_line_button'),
                onPressed: _addLine,
                child: Text(l10n.addMaterialLine),
              ),
              if (_lines.isNotEmpty) ...[
                const SizedBox(height: 12),
                if (widget.recreateFrom != null && _recreateSkipped)
                  Text(
                    l10n.recreateWarning,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ..._effectiveLines(materials.valueOrNull).asMap().entries.map(
                  (entry) => ListTile(
                    title: Text(
                      _materialName(
                        entry.value.materialId,
                        materials.valueOrNull,
                      ),
                    ),
                    subtitle: Text('${l10n.quantity}: ${entry.value.quantity}'),
                    trailing: IconButton(
                      tooltip: l10n.remove,
                      onPressed: () =>
                          setState(() => _lines.removeAt(entry.key)),
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ),
                ),
                Text(
                  '${l10n.totalPerDay}: ${formatEtb(_totalPerDay(materials.valueOrNull))}',
                ),
              ],
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(labelText: l10n.notesOptional),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 24),
              FilledButton(
                key: const ValueKey('rental_save_button'),
                onPressed: _save,
                child: Text(l10n.save),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addLine() {
    if (_materialId == null) {
      return;
    }
    final quantity = int.tryParse(_quantityController.text);
    if (quantity == null || quantity < 1) {
      return;
    }
    if (_lines.any((line) => line.materialId == _materialId)) {
      setState(
        () => _error = AppLocalizations.of(context)!.duplicateMaterialLine,
      );
      return;
    }
    setState(() {
      _lines.add(RentalLineDraft(materialId: _materialId!, quantity: quantity));
      _error = null;
    });
  }

  String _materialName(String id, List<RentalMaterial>? items) {
    if (items == null) {
      return id;
    }
    for (final material in items) {
      if (material.id == id) {
        return '${material.category} - ${material.name}';
      }
    }
    return id;
  }

  int _totalPerDay(List<RentalMaterial>? items) {
    if (items == null) {
      return 0;
    }
    return _effectiveLines(items).fold<int>(0, (total, line) {
      for (final material in items) {
        if (material.id == line.materialId) {
          return total + material.pricePerDay * line.quantity;
        }
      }
      return total;
    });
  }

  Future<void> _save() async {
    final lines = _effectiveLines(ref.read(materialsProvider).valueOrNull);
    if (!_formKey.currentState!.validate() || lines.isEmpty) {
      setState(
        () => _error = _lines.isEmpty
            ? AppLocalizations.of(context)!.atLeastOneLine
            : null,
      );
      return;
    }
    try {
      final result = await ref
          .read(rentalEditorProvider.notifier)
          .createRental(
            customerId: _customerId!,
            lines: lines,
            notes: _notesController.text,
          );
      if (mounted) {
        context.pushReplacement('/rentals/${result.rental.id}');
      }
    } on StockAvailabilityException catch (error) {
      if (!mounted) return;
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.stockWarning),
          content: Text(
            '${AppLocalizations.of(context)!.requested}: ${error.requested}\n'
            '${AppLocalizations.of(context)!.available}: ${error.available}',
          ),
          actions: [
            TextButton(
              onPressed: () => context.pop(false),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            FilledButton(
              onPressed: () => context.pop(true),
              child: Text(AppLocalizations.of(context)!.continueAnyway),
            ),
          ],
        ),
      );
      if (confirm == true && mounted) {
        await _saveWithOverride();
      }
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    }
  }

  Future<void> _saveWithOverride() async {
    final lines = _effectiveLines(ref.read(materialsProvider).valueOrNull);
    try {
      final result = await ref
          .read(rentalEditorProvider.notifier)
          .createRental(
            customerId: _customerId!,
            lines: lines,
            notes: _notesController.text,
            stockOverrideConfirmed: true,
          );
      if (mounted) context.pushReplacement('/rentals/${result.rental.id}');
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    }
  }

  List<RentalLineDraft> _effectiveLines(List<RentalMaterial>? materials) {
    if (materials == null) return _lines;
    final activeIds = materials
        .where((material) => material.isActive)
        .map((material) => material.id)
        .toSet();
    return _lines.where((line) => activeIds.contains(line.materialId)).toList();
  }
}
