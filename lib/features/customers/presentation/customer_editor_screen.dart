import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/services/image_capture_service.dart';
import '../../../core/services/image_storage_service.dart';
import '../../../core/widgets/safe_back_button.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../application/customer_providers.dart';
import '../domain/customer.dart';
import '../domain/customer_validation.dart';

enum _DuplicateChoice { continueSaving, openExisting }

class CustomerEditorScreen extends ConsumerStatefulWidget {
  const CustomerEditorScreen({super.key, this.customerId});

  final String? customerId;

  @override
  ConsumerState<CustomerEditorScreen> createState() =>
      _CustomerEditorScreenState();
}

class _CustomerEditorScreenState extends ConsumerState<CustomerEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();
  final _newlySavedPaths = <String>[];
  Customer? _customer;
  String? _frontPath;
  String? _backPath;
  bool _loading = false;
  bool _allowPop = false;

  bool get isEditing => widget.customerId != null;

  bool get _hasUnsavedChanges {
    if (_customer == null) {
      return _nameController.text.trim().isNotEmpty ||
          _addressController.text.trim().isNotEmpty ||
          _phoneController.text.trim().isNotEmpty ||
          _notesController.text.trim().isNotEmpty ||
          _frontPath != null ||
          _backPath != null;
    }
    return _nameController.text.trim() != _customer!.fullName ||
        _addressController.text.trim() != _customer!.address ||
        _phoneController.text.trim() != (_customer!.phone ?? '') ||
        _notesController.text.trim() != (_customer!.notes ?? '') ||
        _frontPath != _customer!.idPhotoFrontPath ||
        _backPath != _customer!.idPhotoBackPath;
  }

  @override
  void initState() {
    super.initState();
    if (widget.customerId != null) {
      _loadCustomer();
    }
  }

  Future<void> _loadCustomer() async {
    setState(() => _loading = true);
    final customer = await ref
        .read(customerRepositoryProvider)
        .getById(widget.customerId!);
    if (!mounted) {
      return;
    }
    if (customer != null) {
      _customer = customer;
      _nameController.text = customer.fullName;
      _addressController.text = customer.address;
      _phoneController.text = customer.phone ?? '';
      _notesController.text = customer.notes ?? '';
      _frontPath = customer.idPhotoFrontPath;
      _backPath = customer.idPhotoBackPath;
    }
    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _captureFront({required ImageSource source}) async {
    final image = await _pick(source);
    if (image == null) {
      return;
    }
    await _saveCapturedImage(image, isFront: true);
  }

  Future<void> _captureBack({required ImageSource source}) async {
    final image = await _pick(source);
    if (image == null) {
      return;
    }
    await _saveCapturedImage(image, isFront: false);
  }

  Future<XFile?> _pick(ImageSource source) async {
    try {
      final service = ref.read(imageCaptureServiceProvider);
      return source == ImageSource.camera
          ? await service.takePhoto()
          : await service.chooseFromGallery();
    } on ImageCaptureException catch (error) {
      if (mounted) {
        _showMessage(
          error.permissionDenied
              ? AppLocalizations.of(context)!.cameraPermissionDenied
              : AppLocalizations.of(context)!.photoCaptureError,
        );
      }
      return null;
    }
  }

  Future<void> _saveCapturedImage(XFile image, {required bool isFront}) async {
    try {
      final path = await ref
          .read(imageStorageServiceProvider)
          .saveCustomerImage(image);
      _newlySavedPaths.add(path);
      if (!mounted) {
        return;
      }
      setState(() {
        if (isFront) {
          _frontPath = path;
        } else {
          _backPath = path;
        }
      });
    } catch (_) {
      if (mounted) {
        _showMessage(AppLocalizations.of(context)!.photoSaveError);
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final frontPath = _frontPath;
    if (frontPath == null || frontPath.trim().isEmpty) {
      _showMessage(AppLocalizations.of(context)!.frontPhotoRequired);
      return;
    }
    final l10n = AppLocalizations.of(context)!;
    final duplicates = await ref
        .read(customerRepositoryProvider)
        .findPossibleDuplicates(
          fullName: _nameController.text,
          address: _addressController.text,
          phone: _phoneController.text,
          excludingId: _customer?.id,
        );
    if (!mounted) {
      return;
    }
    if (duplicates.isNotEmpty) {
      final choice = await showDialog<_DuplicateChoice>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.possibleDuplicate),
          content: Text(
            '${l10n.existingCustomersFound}\n\n${duplicates.map((item) => item.fullName).join('\n')}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.pop(context, _DuplicateChoice.openExisting),
              child: Text(l10n.openExisting),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.pop(context, _DuplicateChoice.continueSaving),
              child: Text(l10n.continueSaving),
            ),
          ],
        ),
      );
      if (choice == _DuplicateChoice.openExisting) {
        if (mounted) {
          context.pushReplacement('/customers/${duplicates.first.id}');
        }
        return;
      }
      if (choice != _DuplicateChoice.continueSaving) {
        return;
      }
    }
    try {
      final controller = ref.read(customerEditorProvider.notifier);
      final customer = _customer == null
          ? await controller.createCustomer(
              fullName: _nameController.text,
              address: _addressController.text,
              phone: _phoneController.text,
              notes: _notesController.text,
              idPhotoFrontPath: frontPath,
              idPhotoBackPath: _backPath,
            )
          : await controller.updateCustomer(
              _customer!.copyWith(
                fullName: _nameController.text,
                address: _addressController.text,
                phone: _phoneController.text.trim().isEmpty
                    ? null
                    : _phoneController.text,
                notes: _notesController.text.trim().isEmpty
                    ? null
                    : _notesController.text,
                idPhotoFrontPath: frontPath,
                idPhotoBackPath: _backPath,
              ),
            );
      _newlySavedPaths.clear();
      if (mounted) {
        context.pushReplacement('/customers/${customer.id}');
      }
    } catch (error) {
      await _deleteNewOrphans();
      if (!mounted) {
        return;
      }
      _showMessage(l10n.saveCustomerError);
    }
  }

  Future<void> _deleteNewOrphans() async {
    final storage = ref.read(imageStorageServiceProvider);
    for (final path in _newlySavedPaths) {
      await storage.deleteOrphan(path);
    }
    _newlySavedPaths.clear();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
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
    final discard = await _confirmDiscard();
    if (!discard || !mounted) {
      return;
    }
    _allowPop = true;
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/');
    }
  }

  Future<bool> _confirmDiscard() async {
    final l10n = AppLocalizations.of(context)!;
    return await showDialog<bool>(
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
        ) ??
        false;
  }

  String? _nameError(String? value) => value == null || value.trim().isEmpty
      ? AppLocalizations.of(context)!.nameRequired
      : null;

  String? _addressError(String? value) => value == null || value.trim().isEmpty
      ? AppLocalizations.of(context)!.addressRequired
      : null;

  String? _phoneError(String? value) {
    final error = validateCustomerPhone(value);
    if (error == null) {
      return null;
    }
    return error.contains('7 to 15')
        ? AppLocalizations.of(context)!.phoneLengthError
        : AppLocalizations.of(context)!.phoneCharactersError;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_loading) {
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
          title: Text(isEditing ? l10n.editCustomer : l10n.addCustomer),
          leading: SafeBackButton(onPressed: _handleBack),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _nameController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(labelText: l10n.fullName),
                validator: _nameError,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(labelText: l10n.address),
                validator: _addressError,
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: '${l10n.phone} (${l10n.optional})',
                ),
                keyboardType: TextInputType.phone,
                validator: _phoneError,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: '${l10n.notes} (${l10n.optional})',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              Text(
                l10n.idPhotoFront,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(l10n.photoPrivacyNote),
              const SizedBox(height: 8),
              _PhotoPreview(
                path: _frontPath,
                storage: ref.read(imageStorageServiceProvider),
              ),
              Wrap(
                spacing: 12,
                children: [
                  OutlinedButton.icon(
                    key: const ValueKey('customer_front_photo_button'),
                    onPressed: () => _captureFront(source: ImageSource.camera),
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: Text(
                      _frontPath == null ? l10n.takePhoto : l10n.retakePhoto,
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _captureFront(source: ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_outlined),
                    label: Text(l10n.chooseFromGallery),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                '${l10n.idPhotoBack} (${l10n.optional})',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              _PhotoPreview(
                path: _backPath,
                storage: ref.read(imageStorageServiceProvider),
              ),
              Wrap(
                spacing: 12,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _captureBack(source: ImageSource.camera),
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: Text(l10n.takePhoto),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _captureBack(source: ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_outlined),
                    label: Text(l10n.chooseFromGallery),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              FilledButton(
                key: const ValueKey('customer_save_button'),
                onPressed: _save,
                child: Text(l10n.save),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhotoPreview extends StatelessWidget {
  const _PhotoPreview({required this.path, required this.storage});

  final String? path;
  final ImageStorageService storage;

  @override
  Widget build(BuildContext context) {
    if (path == null) {
      return const SizedBox(
        height: 120,
        child: Center(child: Icon(Icons.badge_outlined, size: 48)),
      );
    }
    return FutureBuilder(
      future: storage.resolve(path!),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(
            height: 120,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return SizedBox(
          height: 160,
          child: Image.file(snapshot.data!, fit: BoxFit.contain),
        );
      },
    );
  }
}
