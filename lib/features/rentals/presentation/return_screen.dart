import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/clock_provider.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/safe_back_button.dart';
import '../../../features/billing/rental_billing.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../application/rental_providers.dart';
import '../domain/rental.dart';

class ReturnScreen extends ConsumerStatefulWidget {
  const ReturnScreen({super.key, required this.rentalId});

  final String rentalId;

  @override
  ConsumerState<ReturnScreen> createState() => _ReturnScreenState();
}

class _ReturnScreenState extends ConsumerState<ReturnScreen> {
  final _quantities = <String, int>{};
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
    final details = ref.watch(rentalDetailProvider(widget.rentalId));
    return Scaffold(
      appBar: AppBar(
        leading: const SafeBackButton(),
        title: Text(l10n.returnMaterials),
      ),
      body: details.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text(error.toString())),
        data: (item) {
          if (item == null) return Center(child: Text(l10n.rentalNotFound));
          final lines = item.lines
              .where((line) => line.outstandingQuantity > 0)
              .toList();
          for (final line in lines) {
            _quantities.putIfAbsent(line.id, () => line.outstandingQuantity);
          }
          final now = ref.read(clockProvider).now();
          final previews = lines
              .map(
                (line) => _ReturnPreview(
                  line: line,
                  quantity: _quantities[line.id] ?? 0,
                  days: billableDays(
                    item.rental.rentedAt,
                    now,
                    localOffset: DateTime.now().timeZoneOffset,
                  ),
                ),
              )
              .toList();
          final selected = previews
              .where((preview) => preview.quantity > 0)
              .toList();
          final total = selected.fold<int>(
            0,
            (sum, preview) => sum + preview.amount,
          );
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              Text(
                l10n.nowLocked,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(_formatDateTime(context, now)),
              const SizedBox(height: 16),
              ...lines.map(
                (line) => _ReturnLineCard(
                  key: ValueKey('return_line_${line.id}'),
                  line: line,
                  preview: previews.firstWhere(
                    (preview) => preview.line.id == line.id,
                  ),
                  onQuantityChanged: (quantity) =>
                      setState(() => _quantities[line.id] = quantity),
                  onReturnAll: () => setState(
                    () => _quantities[line.id] = line.outstandingQuantity,
                  ),
                  onClear: () => setState(() => _quantities[line.id] = 0),
                ),
              ),
              TextField(
                controller: _noteController,
                minLines: 2,
                maxLines: 4,
                decoration: InputDecoration(labelText: l10n.returnNoteOptional),
              ),
              const SizedBox(height: 16),
              Text(
                '${l10n.totalToPay}: ${formatEtb(total)}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              FilledButton(
                key: const ValueKey('return_confirm_button'),
                onPressed: selected.isEmpty
                    ? null
                    : () => _confirm(item, selected, now, total),
                child: Text(l10n.confirmReturn),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _confirm(
    RentalDetails details,
    List<_ReturnPreview> selected,
    DateTime returnedAt,
    int total,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.confirmReturn),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${l10n.returnDateTime}: '
                '${_formatDateTime(dialogContext, returnedAt)}',
              ),
              const SizedBox(height: 8),
              ...selected.map((preview) {
                final remaining =
                    preview.line.outstandingQuantity - preview.quantity;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${preview.line.materialNameSnapshot}: '
                        '${preview.quantity} · ${formatEtb(preview.amount)}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        l10n.remainingOutAfterReturn(remaining),
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(dialogContext).colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 8),
              Text('${l10n.totalToPay}: ${formatEtb(total)}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      final receipt = await ref
          .read(returnControllerProvider.notifier)
          .recordReturn(
            rentalId: details.rental.id,
            lines: selected
                .map(
                  (preview) => ReturnLineInput(
                    rentalItemId: preview.line.id,
                    quantity: preview.quantity,
                  ),
                )
                .toList(),
            note: _noteController.text,
          );
      if (!mounted) return;
      context.push(
        '/rentals/${details.rental.id}/return-summary',
        extra: receipt,
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.returnSaveError)));
    }
  }
}

class _ReturnPreview {
  const _ReturnPreview({
    required this.line,
    required this.quantity,
    required this.days,
  });

  final RentalLine line;
  final int quantity;
  final int days;

  int get amount => quantity == 0
      ? 0
      : returnLineAmount(
          quantity: quantity,
          pricePerDaySnapshot: line.pricePerDaySnapshot,
          days: days,
        );
}

class _ReturnLineCard extends StatefulWidget {
  const _ReturnLineCard({
    super.key,
    required this.line,
    required this.preview,
    required this.onQuantityChanged,
    required this.onReturnAll,
    required this.onClear,
  });

  final RentalLine line;
  final _ReturnPreview preview;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onReturnAll;
  final VoidCallback onClear;

  @override
  State<_ReturnLineCard> createState() => _ReturnLineCardState();
}

class _ReturnLineCardState extends State<_ReturnLineCard> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.preview.quantity}');
  }

  @override
  void didUpdateWidget(covariant _ReturnLineCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.preview.quantity != widget.preview.quantity) {
      if (_controller.text != '${widget.preview.quantity}') {
        _controller.text = '${widget.preview.quantity}';
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTextChange(String value) {
    final parsed = int.tryParse(value.trim());
    if (parsed != null) {
      final clamped = parsed.clamp(0, widget.line.outstandingQuantity);
      widget.onQuantityChanged(clamped);
    } else if (value.trim().isEmpty) {
      widget.onQuantityChanged(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final remainingAfter =
        widget.line.outstandingQuantity - widget.preview.quantity;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.line.materialNameSnapshot,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(l10n.rentedQuantity(widget.line.quantity)),
            Text(l10n.alreadyReturnedQuantity(widget.line.quantityReturned)),
            Text(l10n.outstandingQuantity(widget.line.outstandingQuantity)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer
                    .withAlpha(50),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                l10n.returningOfRemaining(
                  remainingAfter,
                  widget.preview.quantity,
                  widget.line.outstandingQuantity,
                ),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  key: ValueKey('return_decrease_${widget.line.id}'),
                  onPressed: widget.preview.quantity > 0
                      ? () => widget.onQuantityChanged(
                          widget.preview.quantity - 1,
                        )
                      : null,
                  icon: const Icon(Icons.remove),
                ),
                SizedBox(
                  width: 64,
                  child: TextField(
                    controller: _controller,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    style: Theme.of(context).textTheme.titleLarge,
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 4,
                      ),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: _onTextChange,
                  ),
                ),
                IconButton(
                  key: ValueKey('return_increase_${widget.line.id}'),
                  onPressed:
                      widget.preview.quantity < widget.line.outstandingQuantity
                      ? () => widget.onQuantityChanged(
                          widget.preview.quantity + 1,
                        )
                      : null,
                  icon: const Icon(Icons.add),
                ),
                const SizedBox(width: 8),
                TextButton(
                  key: ValueKey('return_all_${widget.line.id}'),
                  onPressed: widget.onReturnAll,
                  child: Text(l10n.returnAll),
                ),
                TextButton(
                  key: ValueKey('return_clear_${widget.line.id}'),
                  onPressed: widget.onClear,
                  child: Text(l10n.clear),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              l10n.linePreview(
                formatEtb(widget.preview.amount),
                widget.preview.days,
                formatEtb(widget.line.pricePerDaySnapshot),
              ),
            ),
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
