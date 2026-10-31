import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/money.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../application/material_providers.dart';

class MaterialsScreen extends ConsumerStatefulWidget {
  const MaterialsScreen({super.key});

  @override
  ConsumerState<MaterialsScreen> createState() => _MaterialsScreenState();
}

class _MaterialsScreenState extends ConsumerState<MaterialsScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final materials = ref.watch(materialsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.materials)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: l10n.searchMaterials,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                        icon: const Icon(Icons.clear),
                      ),
              ),
            ),
          ),
          SwitchListTile(
            title: Text(l10n.showInactive),
            value: ref.watch(showInactiveMaterialsProvider),
            onChanged: (value) =>
                ref.read(showInactiveMaterialsProvider.notifier).state = value,
          ),
          Expanded(
            child: materials.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text(l10n.materialsLoadError)),
              data: (items) {
                final query = _searchController.text.trim().toLowerCase();
                final filtered = items.where((item) {
                  return query.isEmpty ||
                      item.category.toLowerCase().contains(query) ||
                      item.name.toLowerCase().contains(query);
                }).toList();
                if (filtered.isEmpty) {
                  return Center(child: Text(l10n.noMaterials));
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final material = filtered[index];
                    return Card(
                      child: ListTile(
                        enabled: material.isActive,
                        minVerticalPadding: 12,
                        title: Text('${material.category} · ${material.name}'),
                        subtitle: Text(
                          '${l10n.pricePerDay}: ${formatEtb(material.pricePerDay)}'
                          '${material.totalStock == null ? '' : '\n${l10n.stock}: ${material.totalStock}'}',
                        ),
                        trailing: material.isActive
                            ? null
                            : Text(
                                l10n.inactive,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                              ),
                        onTap: () =>
                            context.go('/materials/edit?id=${material.id}'),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/materials/new'),
        icon: const Icon(Icons.add),
        label: Text(l10n.addMaterial),
      ),
    );
  }
}
