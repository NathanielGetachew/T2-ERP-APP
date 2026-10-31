// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'T2 Rental';

  @override
  String get home => 'Home';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get amharic => 'Amharic';

  @override
  String get phase0Message => 'Foundation setup is ready.';

  @override
  String get chooseLanguage => 'Choose language';

  @override
  String get materials => 'Materials';

  @override
  String get addMaterial => 'Add material';

  @override
  String get editMaterial => 'Edit material';

  @override
  String get searchMaterials => 'Search materials';

  @override
  String get showInactive => 'Show inactive';

  @override
  String get noMaterials => 'No materials found.';

  @override
  String get materialsLoadError => 'Could not load materials.';

  @override
  String get pricePerDay => 'Price per day';

  @override
  String get stock => 'Stock';

  @override
  String get inactive => 'Inactive';

  @override
  String get category => 'Category';

  @override
  String get materialName => 'Material name or variant';

  @override
  String get categoryRequired => 'Category is required.';

  @override
  String get nameRequired => 'Name is required.';

  @override
  String get priceRequired => 'Price is required.';

  @override
  String get priceMustBePositive => 'Price must be greater than zero.';

  @override
  String get stockMustBeNonNegative => 'Stock cannot be negative.';

  @override
  String get optional => 'optional';

  @override
  String get active => 'Active';

  @override
  String get save => 'Save';

  @override
  String get invalidNumber =>
      'Enter a valid non-negative number with up to two decimals.';

  @override
  String get duplicateMaterial =>
      'A material with this category and name already exists.';

  @override
  String get saveMaterialError => 'Could not save material.';
}
