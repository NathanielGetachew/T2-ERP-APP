import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/money_parser.dart';
import '../../../core/widgets/safe_back_button.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../application/material_providers.dart';
import '../data/material_repository.dart';
import '../domain/rental_material.dart';

class MaterialEditorScreen extends ConsumerStatefulWidget {
  const MaterialEditorScreen({super.key, this.materialId});
  final String? materialId;

  @override
  ConsumerState<MaterialEditorScreen> createState() =>
      _MaterialEditorScreenState();
}

class _MaterialEditorScreenState extends ConsumerState<MaterialEditorScreen> {
  final _category = TextEditingController(text: 'Panel');
  final _name = TextEditingController();
  final _price = TextEditingController();
  final _stock = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  RentalMaterial? _material;
  bool _active = true;
  bool _loadingMaterial = false;
  bool _allowPop = false;

  bool get isEditing => widget.materialId != null;

  bool get _hasUnsavedChanges {
    if (_material == null) {
      return _category.text.trim() != 'Panel' ||
          _name.text.trim().isNotEmpty ||
          _price.text.trim().isNotEmpty ||
          _stock.text.trim().isNotEmpty;
    }
    return _category.text.trim() != _material!.category ||
        _name.text.trim() != _material!.name ||
        _price.text.trim() != _formatPrice(_material!.pricePerDay) ||
        _stock.text.trim() != (_material!.totalStock?.toString() ?? '') ||
        _active != _material!.isActive;
  }

  String _formatPrice(int minorUnits) {
    final birr = minorUnits ~/ 100;
    final santim = (minorUnits % 100).toString().padLeft(2, '0');
    return '$birr.$santim';
  }

  @override
  void initState() {
    super.initState();
    if (widget.materialId != null) {
      _loadMaterial();
    }
  }

  Future<void> _loadMaterial() async {
    setState(() => _loadingMaterial = true);
    final material = await ref
        .read(materialRepositoryProvider)
        .getById(widget.materialId!);
    if (!mounted) {
      return;
    }
    if (material != null) {
      _material = material;
      _category.text = material.category;
      _name.text = material.name;
      final birr = material.pricePerDay ~/ 100;
      final santim = (material.pricePerDay % 100).toString().padLeft(2, '0');
      _price.text = '$birr.$santim';
      _stock.text = material.totalStock?.toString() ?? '';
      _active = material.isActive;
    }
    setState(() => _loadingMaterial = false);
  }

  @override
  void dispose() {
    _category.dispose();
    _name.dispose();
    _price.dispose();
    _stock.dispose();
    super.dispose();
  }

  String? _required(String? value, String message) =>
      value == null || value.trim().isEmpty ? message : null;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final l10n = AppLocalizations.of(context)!;
    int price;
    int? stock;
    try {
      price = parseEtbMinorUnits(_price.text);
      if (_stock.text.trim().isNotEmpty) {
        stock = int.parse(_stock.text.trim());
      }
      if (stock != null && stock < 0) {
        throw const FormatException();
      }
    } catch (_) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.invalidNumber)));
      return;
    }
    final controller = ref.read(materialEditorProvider.notifier);
    try {
      if (_material == null) {
        await controller.create(
          category: _category.text,
          name: _name.text,
          pricePerDay: price,
          totalStock: stock,
        );
      } else {
        await controller.updateMaterial(
          _material!.copyWith(
            category: _category.text,
            name: _name.text,
            pricePerDay: price,
            totalStock: stock,
            isActive: _active,
          ),
        );
      }
      if (mounted) {
        context.pushReplacement('/materials');
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      final message = error is DuplicateMaterialException
          ? l10n.duplicateMaterial
          : l10n.saveMaterialError;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _handleBack() async {
    if (!_hasUnsavedChanges) {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/');
      }
      return;
    }
    final l10n = AppLocalizations.of(context)!;
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.discardChangesTitle),
        content: Text(l10n.discardChangesMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.keepEditing),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.discardChanges),
          ),
        ],
      ),
    );
    if (discard != true || !mounted) {
      return;
    }
    _allowPop = true;
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final existingCategories = ref
        .watch(materialsProvider)
        .maybeWhen(
          data: (items) =>
              {'Panel', ...items.map((item) => item.category)}.toList(),
          orElse: () => ['Panel'],
        );
    if (_loadingMaterial) {
      return PopScope(
        canPop: _allowPop,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            _handleBack();
          }
        },
        child: const Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }
    return PopScope(
      canPop: _allowPop || !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _handleBack();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(isEditing ? l10n.editMaterial : l10n.addMaterial),
          leading: SafeBackButton(onPressed: _handleBack),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Autocomplete<String>(
                initialValue: TextEditingValue(text: _category.text),
                optionsBuilder: (value) => existingCategories.where(
                  (option) =>
                      option.toLowerCase().contains(value.text.toLowerCase()),
                ),
                onSelected: (value) {
                  _category.text = value;
                  setState(() {});
                },
                fieldViewBuilder:
                    (context, controller, focusNode, onSubmitted) {
                      controller.text = _category.text;
                      return TextFormField(
                        controller: controller,
                        focusNode: focusNode,
                        onChanged: (value) {
                          _category.text = value;
                          setState(() {});
                        },
                        decoration: InputDecoration(labelText: l10n.category),
                        validator: (value) =>
                            _required(value, l10n.categoryRequired),
                      );
                    },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _name,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(labelText: l10n.materialName),
                validator: (value) => _required(value, l10n.nameRequired),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _price,
                onChanged: (_) => setState(() {}),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: l10n.pricePerDay,
                  suffixText: 'ETB',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.priceRequired;
                  }
                  try {
                    if (parseEtbMinorUnits(value) <= 0) {
                      return l10n.priceMustBePositive;
                    }
                  } on FormatException {
                    return l10n.invalidNumber;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _stock,
                onChanged: (_) => setState(() {}),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: '${l10n.stock} (${l10n.optional})',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return null;
                  }
                  final parsed = int.tryParse(value.trim());
                  return parsed == null || parsed < 0
                      ? l10n.stockMustBeNonNegative
                      : null;
                },
              ),
              if (isEditing)
                SwitchListTile(
                  title: Text(l10n.active),
                  value: _active,
                  onChanged: (value) => setState(() => _active = value),
                ),
              const SizedBox(height: 24),
              FilledButton(onPressed: _save, child: Text(l10n.save)),
            ],
          ),
        ),
      ),
    );
  }
}
