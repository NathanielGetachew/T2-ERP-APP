import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/dashboard_models.dart';

enum MaterialSortOption { unitDays, timesRented, totalQuantity }

class MostRentedMaterialsCard extends StatefulWidget {
  const MostRentedMaterialsCard({super.key, required this.materials});

  final List<MaterialRentalMetric> materials;

  @override
  State<MostRentedMaterialsCard> createState() =>
      _MostRentedMaterialsCardState();
}

class _MostRentedMaterialsCardState extends State<MostRentedMaterialsCard> {
  MaterialSortOption _sortOption = MaterialSortOption.unitDays;
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final sorted = List<MaterialRentalMetric>.from(widget.materials);
    sorted.sort((a, b) {
      switch (_sortOption) {
        case MaterialSortOption.unitDays:
          final comp = b.unitDays.compareTo(a.unitDays);
          if (comp != 0) return comp;
          return a.name.compareTo(b.name);
        case MaterialSortOption.timesRented:
          final comp = b.timesRented.compareTo(a.timesRented);
          if (comp != 0) return comp;
          return a.name.compareTo(b.name);
        case MaterialSortOption.totalQuantity:
          final comp = b.totalQuantity.compareTo(a.totalQuantity);
          if (comp != 0) return comp;
          return a.name.compareTo(b.name);
      }
    });

    final visible = _showAll ? sorted : sorted.take(5).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.mostRentedMaterials,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SegmentedButton<MaterialSortOption>(
                segments: [
                  ButtonSegment(
                    value: MaterialSortOption.unitDays,
                    label: Text(l10n.unitDays),
                  ),
                  ButtonSegment(
                    value: MaterialSortOption.timesRented,
                    label: Text(l10n.timesRented),
                  ),
                  ButtonSegment(
                    value: MaterialSortOption.totalQuantity,
                    label: Text(l10n.totalQuantity),
                  ),
                ],
                selected: {_sortOption},
                onSelectionChanged: (values) {
                  setState(() {
                    _sortOption = values.first;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
            if (sorted.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  l10n.noMaterialsRented,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              )
            else ...[
              for (var i = 0; i < visible.length; i++) ...[
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    radius: 14,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    child: Text(
                      '${i + 1}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    '${visible[i].category} ${visible[i].name}'.trim(),
                  ),
                  trailing: Text(
                    _formatValue(visible[i], l10n),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (i < visible.length - 1) const Divider(height: 1),
              ],
              if (sorted.length > 5) ...[
                const SizedBox(height: 8),
                Center(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _showAll = !_showAll;
                      });
                    },
                    child: Text(_showAll ? l10n.showLess : l10n.showAll),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  String _formatValue(MaterialRentalMetric item, AppLocalizations l10n) {
    switch (_sortOption) {
      case MaterialSortOption.unitDays:
        return '${item.unitDays} ${l10n.unitDays}';
      case MaterialSortOption.timesRented:
        return '${item.timesRented} ×';
      case MaterialSortOption.totalQuantity:
        return '${item.totalQuantity} ${l10n.units}';
    }
  }
}
