import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_am.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('am'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'T2 Rental'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @amharic.
  ///
  /// In en, this message translates to:
  /// **'Amharic'**
  String get amharic;

  /// No description provided for @phase0Message.
  ///
  /// In en, this message translates to:
  /// **'Foundation setup is ready.'**
  String get phase0Message;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose language'**
  String get chooseLanguage;

  /// No description provided for @materials.
  ///
  /// In en, this message translates to:
  /// **'Materials'**
  String get materials;

  /// No description provided for @addMaterial.
  ///
  /// In en, this message translates to:
  /// **'Add material'**
  String get addMaterial;

  /// No description provided for @editMaterial.
  ///
  /// In en, this message translates to:
  /// **'Edit material'**
  String get editMaterial;

  /// No description provided for @searchMaterials.
  ///
  /// In en, this message translates to:
  /// **'Search materials'**
  String get searchMaterials;

  /// No description provided for @showInactive.
  ///
  /// In en, this message translates to:
  /// **'Show inactive'**
  String get showInactive;

  /// No description provided for @noMaterials.
  ///
  /// In en, this message translates to:
  /// **'No materials found.'**
  String get noMaterials;

  /// No description provided for @materialsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load materials.'**
  String get materialsLoadError;

  /// No description provided for @pricePerDay.
  ///
  /// In en, this message translates to:
  /// **'Price per day'**
  String get pricePerDay;

  /// No description provided for @stock.
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get stock;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @materialName.
  ///
  /// In en, this message translates to:
  /// **'Material name or variant'**
  String get materialName;

  /// No description provided for @categoryRequired.
  ///
  /// In en, this message translates to:
  /// **'Category is required.'**
  String get categoryRequired;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required.'**
  String get nameRequired;

  /// No description provided for @priceRequired.
  ///
  /// In en, this message translates to:
  /// **'Price is required.'**
  String get priceRequired;

  /// No description provided for @priceMustBePositive.
  ///
  /// In en, this message translates to:
  /// **'Price must be greater than zero.'**
  String get priceMustBePositive;

  /// No description provided for @stockMustBeNonNegative.
  ///
  /// In en, this message translates to:
  /// **'Stock cannot be negative.'**
  String get stockMustBeNonNegative;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'optional'**
  String get optional;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @invalidNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid non-negative number with up to two decimals.'**
  String get invalidNumber;

  /// No description provided for @duplicateMaterial.
  ///
  /// In en, this message translates to:
  /// **'A material with this category and name already exists.'**
  String get duplicateMaterial;

  /// No description provided for @saveMaterialError.
  ///
  /// In en, this message translates to:
  /// **'Could not save material.'**
  String get saveMaterialError;

  /// No description provided for @customers.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get customers;

  /// No description provided for @addCustomer.
  ///
  /// In en, this message translates to:
  /// **'Add customer'**
  String get addCustomer;

  /// No description provided for @editCustomer.
  ///
  /// In en, this message translates to:
  /// **'Edit customer'**
  String get editCustomer;

  /// No description provided for @searchCustomers.
  ///
  /// In en, this message translates to:
  /// **'Search customers'**
  String get searchCustomers;

  /// No description provided for @showArchived.
  ///
  /// In en, this message translates to:
  /// **'Show archived'**
  String get showArchived;

  /// No description provided for @noCustomers.
  ///
  /// In en, this message translates to:
  /// **'No customers found.'**
  String get noCustomers;

  /// No description provided for @customersLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load customers.'**
  String get customersLoadError;

  /// No description provided for @archived.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get archived;

  /// No description provided for @customerProfile.
  ///
  /// In en, this message translates to:
  /// **'Customer profile'**
  String get customerProfile;

  /// No description provided for @customerNotFound.
  ///
  /// In en, this message translates to:
  /// **'Customer not found.'**
  String get customerNotFound;

  /// No description provided for @rentalHistory.
  ///
  /// In en, this message translates to:
  /// **'Rental history'**
  String get rentalHistory;

  /// No description provided for @noRentalHistory.
  ///
  /// In en, this message translates to:
  /// **'No rental history yet.'**
  String get noRentalHistory;

  /// No description provided for @archiveCustomer.
  ///
  /// In en, this message translates to:
  /// **'Archive customer'**
  String get archiveCustomer;

  /// No description provided for @reactivateCustomer.
  ///
  /// In en, this message translates to:
  /// **'Reactivate customer'**
  String get reactivateCustomer;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @addressRequired.
  ///
  /// In en, this message translates to:
  /// **'Address is required.'**
  String get addressRequired;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @idPhotoFront.
  ///
  /// In en, this message translates to:
  /// **'Front ID photo'**
  String get idPhotoFront;

  /// No description provided for @idPhotoBack.
  ///
  /// In en, this message translates to:
  /// **'Back ID photo'**
  String get idPhotoBack;

  /// No description provided for @photoPrivacyNote.
  ///
  /// In en, this message translates to:
  /// **'Stored privately on this device.'**
  String get photoPrivacyNote;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get takePhoto;

  /// No description provided for @retakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get retakePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get chooseFromGallery;

  /// No description provided for @photoSaveError.
  ///
  /// In en, this message translates to:
  /// **'Could not save the photo.'**
  String get photoSaveError;

  /// No description provided for @photoCaptureError.
  ///
  /// In en, this message translates to:
  /// **'Could not capture the photo.'**
  String get photoCaptureError;

  /// No description provided for @cameraPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Camera permission was denied.'**
  String get cameraPermissionDenied;

  /// No description provided for @frontPhotoRequired.
  ///
  /// In en, this message translates to:
  /// **'A front ID photo is required.'**
  String get frontPhotoRequired;

  /// No description provided for @possibleDuplicate.
  ///
  /// In en, this message translates to:
  /// **'Possible duplicate'**
  String get possibleDuplicate;

  /// No description provided for @existingCustomersFound.
  ///
  /// In en, this message translates to:
  /// **'Existing possible matches were found.'**
  String get existingCustomersFound;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @openExisting.
  ///
  /// In en, this message translates to:
  /// **'Open existing'**
  String get openExisting;

  /// No description provided for @continueSaving.
  ///
  /// In en, this message translates to:
  /// **'Continue saving'**
  String get continueSaving;

  /// No description provided for @saveCustomerError.
  ///
  /// In en, this message translates to:
  /// **'Could not save customer.'**
  String get saveCustomerError;

  /// No description provided for @phoneLengthError.
  ///
  /// In en, this message translates to:
  /// **'Phone must contain 7 to 15 digits.'**
  String get phoneLengthError;

  /// No description provided for @phoneCharactersError.
  ///
  /// In en, this message translates to:
  /// **'Phone may contain only digits, spaces, +, and -.'**
  String get phoneCharactersError;

  /// No description provided for @discardChangesTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get discardChangesTitle;

  /// No description provided for @replacePhoto.
  ///
  /// In en, this message translates to:
  /// **'Replace photo'**
  String get replacePhoto;

  /// No description provided for @discardChangesMessage.
  ///
  /// In en, this message translates to:
  /// **'Your unsaved changes will be lost.'**
  String get discardChangesMessage;

  /// No description provided for @discardChanges.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discardChanges;

  /// No description provided for @keepEditing.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get keepEditing;

  /// No description provided for @retakeFrontPhoto.
  ///
  /// In en, this message translates to:
  /// **'Retake front photo'**
  String get retakeFrontPhoto;

  /// No description provided for @addBackPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add back photo'**
  String get addBackPhoto;

  /// No description provided for @retakeBackPhoto.
  ///
  /// In en, this message translates to:
  /// **'Retake back photo'**
  String get retakeBackPhoto;

  /// No description provided for @replacePhotoTitle.
  ///
  /// In en, this message translates to:
  /// **'Replace photo?'**
  String get replacePhotoTitle;

  /// No description provided for @replacePhotoMessage.
  ///
  /// In en, this message translates to:
  /// **'The current photo will be kept in history.'**
  String get replacePhotoMessage;

  /// No description provided for @photoReplaced.
  ///
  /// In en, this message translates to:
  /// **'Photo replaced.'**
  String get photoReplaced;

  /// No description provided for @photoReplacementError.
  ///
  /// In en, this message translates to:
  /// **'Could not replace the photo.'**
  String get photoReplacementError;

  /// No description provided for @rentals.
  ///
  /// In en, this message translates to:
  /// **'Rentals'**
  String get rentals;

  /// No description provided for @searchRentals.
  ///
  /// In en, this message translates to:
  /// **'Search by customer or rental number'**
  String get searchRentals;

  /// No description provided for @returned.
  ///
  /// In en, this message translates to:
  /// **'Returned'**
  String get returned;

  /// No description provided for @partiallyReturned.
  ///
  /// In en, this message translates to:
  /// **'Partially returned'**
  String get partiallyReturned;

  /// No description provided for @voided.
  ///
  /// In en, this message translates to:
  /// **'Voided'**
  String get voided;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @noRentals.
  ///
  /// In en, this message translates to:
  /// **'No rentals found.'**
  String get noRentals;

  /// No description provided for @estimate.
  ///
  /// In en, this message translates to:
  /// **'Estimate'**
  String get estimate;

  /// No description provided for @newRental.
  ///
  /// In en, this message translates to:
  /// **'New rental'**
  String get newRental;

  /// No description provided for @activeRentals.
  ///
  /// In en, this message translates to:
  /// **'Active rentals'**
  String get activeRentals;

  /// No description provided for @itemsCurrentlyOut.
  ///
  /// In en, this message translates to:
  /// **'Items currently out'**
  String get itemsCurrentlyOut;

  /// No description provided for @customer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customer;

  /// No description provided for @addNewCustomer.
  ///
  /// In en, this message translates to:
  /// **'Add new customer'**
  String get addNewCustomer;

  /// No description provided for @customerRequired.
  ///
  /// In en, this message translates to:
  /// **'Select a customer.'**
  String get customerRequired;

  /// No description provided for @material.
  ///
  /// In en, this message translates to:
  /// **'Material'**
  String get material;

  /// No description provided for @materialRequired.
  ///
  /// In en, this message translates to:
  /// **'Select a material.'**
  String get materialRequired;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @quantityRequired.
  ///
  /// In en, this message translates to:
  /// **'Quantity must be at least 1.'**
  String get quantityRequired;

  /// No description provided for @addMaterialLine.
  ///
  /// In en, this message translates to:
  /// **'Add material line'**
  String get addMaterialLine;

  /// No description provided for @totalPerDay.
  ///
  /// In en, this message translates to:
  /// **'Total per day'**
  String get totalPerDay;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @notesOptional.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get notesOptional;

  /// No description provided for @duplicateMaterialLine.
  ///
  /// In en, this message translates to:
  /// **'This material is already in the rental.'**
  String get duplicateMaterialLine;

  /// No description provided for @atLeastOneLine.
  ///
  /// In en, this message translates to:
  /// **'Add at least one material line.'**
  String get atLeastOneLine;

  /// No description provided for @stockWarning.
  ///
  /// In en, this message translates to:
  /// **'Stock warning'**
  String get stockWarning;

  /// No description provided for @requested.
  ///
  /// In en, this message translates to:
  /// **'Requested'**
  String get requested;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @continueAnyway.
  ///
  /// In en, this message translates to:
  /// **'Continue anyway'**
  String get continueAnyway;

  /// No description provided for @rentalDetails.
  ///
  /// In en, this message translates to:
  /// **'Rental details'**
  String get rentalDetails;

  /// No description provided for @rentalNotFound.
  ///
  /// In en, this message translates to:
  /// **'Rental not found.'**
  String get rentalNotFound;

  /// No description provided for @rentalDate.
  ///
  /// In en, this message translates to:
  /// **'Rental date'**
  String get rentalDate;

  /// No description provided for @daysSoFar.
  ///
  /// In en, this message translates to:
  /// **'Days so far'**
  String get daysSoFar;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @outstanding.
  ///
  /// In en, this message translates to:
  /// **'Outstanding'**
  String get outstanding;

  /// No description provided for @estimateIfReturnedToday.
  ///
  /// In en, this message translates to:
  /// **'Estimate if returned today'**
  String get estimateIfReturnedToday;

  /// No description provided for @returnComingNext.
  ///
  /// In en, this message translates to:
  /// **'Return (coming next)'**
  String get returnComingNext;

  /// No description provided for @viewCustomer.
  ///
  /// In en, this message translates to:
  /// **'View customer'**
  String get viewCustomer;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['am', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'am':
      return AppLocalizationsAm();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
