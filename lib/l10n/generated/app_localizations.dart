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

  /// No description provided for @thisMonthsRevenue.
  ///
  /// In en, this message translates to:
  /// **'This month\'s revenue'**
  String get thisMonthsRevenue;

  /// No description provided for @earnedFromReturns.
  ///
  /// In en, this message translates to:
  /// **'Earned from returns'**
  String get earnedFromReturns;

  /// No description provided for @returnAction.
  ///
  /// In en, this message translates to:
  /// **'Return'**
  String get returnAction;

  /// No description provided for @returnMaterials.
  ///
  /// In en, this message translates to:
  /// **'Return materials'**
  String get returnMaterials;

  /// No description provided for @returnAll.
  ///
  /// In en, this message translates to:
  /// **'Return all'**
  String get returnAll;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @nowLocked.
  ///
  /// In en, this message translates to:
  /// **'Now (locked)'**
  String get nowLocked;

  /// No description provided for @rentedQuantity.
  ///
  /// In en, this message translates to:
  /// **'Rented: {quantity}'**
  String rentedQuantity(Object quantity);

  /// No description provided for @alreadyReturnedQuantity.
  ///
  /// In en, this message translates to:
  /// **'Already returned: {quantity}'**
  String alreadyReturnedQuantity(Object quantity);

  /// No description provided for @outstandingQuantity.
  ///
  /// In en, this message translates to:
  /// **'Outstanding: {quantity}'**
  String outstandingQuantity(Object quantity);

  /// No description provided for @linePreview.
  ///
  /// In en, this message translates to:
  /// **'{days} days × {price} = {amount}'**
  String linePreview(Object amount, Object days, Object price);

  /// No description provided for @totalToPay.
  ///
  /// In en, this message translates to:
  /// **'Total to pay'**
  String get totalToPay;

  /// No description provided for @confirmReturn.
  ///
  /// In en, this message translates to:
  /// **'Confirm return'**
  String get confirmReturn;

  /// No description provided for @returnDateTime.
  ///
  /// In en, this message translates to:
  /// **'Return date/time'**
  String get returnDateTime;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @returnSummary.
  ///
  /// In en, this message translates to:
  /// **'Return summary'**
  String get returnSummary;

  /// No description provided for @backToRental.
  ///
  /// In en, this message translates to:
  /// **'Back to rental'**
  String get backToRental;

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get backToHome;

  /// No description provided for @returnHistory.
  ///
  /// In en, this message translates to:
  /// **'Return history'**
  String get returnHistory;

  /// No description provided for @noReturnHistory.
  ///
  /// In en, this message translates to:
  /// **'No returns recorded yet.'**
  String get noReturnHistory;

  /// No description provided for @earnedSoFar.
  ///
  /// In en, this message translates to:
  /// **'Earned so far'**
  String get earnedSoFar;

  /// No description provided for @outstandingEstimate.
  ///
  /// In en, this message translates to:
  /// **'Outstanding estimate'**
  String get outstandingEstimate;

  /// No description provided for @finalTotal.
  ///
  /// In en, this message translates to:
  /// **'Final total'**
  String get finalTotal;

  /// No description provided for @totalForThisReturn.
  ///
  /// In en, this message translates to:
  /// **'Total for this return'**
  String get totalForThisReturn;

  /// No description provided for @remainingOutstanding.
  ///
  /// In en, this message translates to:
  /// **'Remaining outstanding'**
  String get remainingOutstanding;

  /// No description provided for @runningEstimate.
  ///
  /// In en, this message translates to:
  /// **'Running estimate'**
  String get runningEstimate;

  /// No description provided for @returnNoteOptional.
  ///
  /// In en, this message translates to:
  /// **'Return note (optional)'**
  String get returnNoteOptional;

  /// No description provided for @returnValidation.
  ///
  /// In en, this message translates to:
  /// **'Select at least one quantity to return.'**
  String get returnValidation;

  /// No description provided for @returnSaveError.
  ///
  /// In en, this message translates to:
  /// **'Could not record the return.'**
  String get returnSaveError;

  /// No description provided for @returnDateTimeValue.
  ///
  /// In en, this message translates to:
  /// **'Return date/time: {value}'**
  String returnDateTimeValue(Object value);

  /// No description provided for @returnHistoryLine.
  ///
  /// In en, this message translates to:
  /// **'{date} · {material} · {quantity} units · {days} days · {amount}'**
  String returnHistoryLine(
    Object amount,
    Object date,
    Object days,
    Object material,
    Object quantity,
  );

  /// No description provided for @summaryLine.
  ///
  /// In en, this message translates to:
  /// **'{quantity} returned · {days} days · {price} · {amount}'**
  String summaryLine(Object amount, Object days, Object price, Object quantity);

  /// No description provided for @voidRental.
  ///
  /// In en, this message translates to:
  /// **'Void rental'**
  String get voidRental;

  /// No description provided for @voidReturn.
  ///
  /// In en, this message translates to:
  /// **'Void return'**
  String get voidReturn;

  /// No description provided for @voidReason.
  ///
  /// In en, this message translates to:
  /// **'Reason for voiding'**
  String get voidReason;

  /// No description provided for @voidReasonRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter at least 5 characters.'**
  String get voidReasonRequired;

  /// No description provided for @voidRentalWarning.
  ///
  /// In en, this message translates to:
  /// **'Voiding hides this rental from totals and frees its stock. This cannot be undone.'**
  String get voidRentalWarning;

  /// No description provided for @voidReturnWarning.
  ///
  /// In en, this message translates to:
  /// **'Voiding removes this return from earned totals and restores its outstanding quantity.'**
  String get voidReturnWarning;

  /// No description provided for @voidConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm void'**
  String get voidConfirm;

  /// No description provided for @voidSuccess.
  ///
  /// In en, this message translates to:
  /// **'Voided successfully.'**
  String get voidSuccess;

  /// No description provided for @voidError.
  ///
  /// In en, this message translates to:
  /// **'Could not void this record.'**
  String get voidError;

  /// No description provided for @voidedOn.
  ///
  /// In en, this message translates to:
  /// **'Voided on {date}: {reason}'**
  String voidedOn(Object date, Object reason);

  /// No description provided for @voidedFilter.
  ///
  /// In en, this message translates to:
  /// **'Voided'**
  String get voidedFilter;

  /// No description provided for @voidAndRecreate.
  ///
  /// In en, this message translates to:
  /// **'Void and recreate'**
  String get voidAndRecreate;

  /// No description provided for @recreateWarning.
  ///
  /// In en, this message translates to:
  /// **'Some original materials are no longer active or available and will be skipped.'**
  String get recreateWarning;

  /// No description provided for @recreateNote.
  ///
  /// In en, this message translates to:
  /// **'Replaces {rentalNumber}'**
  String recreateNote(Object rentalNumber);

  /// No description provided for @auditHistory.
  ///
  /// In en, this message translates to:
  /// **'Audit history'**
  String get auditHistory;

  /// No description provided for @noAuditHistory.
  ///
  /// In en, this message translates to:
  /// **'No audit history.'**
  String get noAuditHistory;

  /// No description provided for @voidedAmount.
  ///
  /// In en, this message translates to:
  /// **'Voided: {amount}'**
  String voidedAmount(Object amount);

  /// No description provided for @voidedReturnReason.
  ///
  /// In en, this message translates to:
  /// **'Voided: {reason}'**
  String voidedReturnReason(Object reason);

  /// No description provided for @backupAndRestore.
  ///
  /// In en, this message translates to:
  /// **'Backup & restore'**
  String get backupAndRestore;

  /// No description provided for @lastBackup.
  ///
  /// In en, this message translates to:
  /// **'Last backup: {date}'**
  String lastBackup(Object date);

  /// No description provided for @neverBackedUp.
  ///
  /// In en, this message translates to:
  /// **'Never backed up'**
  String get neverBackedUp;

  /// No description provided for @backupDataWarning.
  ///
  /// In en, this message translates to:
  /// **'Back up your data. This backup contains customer ID photos; store it safely.'**
  String get backupDataWarning;

  /// No description provided for @backupOlderWarning.
  ///
  /// In en, this message translates to:
  /// **'Your last backup is more than 7 days old.'**
  String get backupOlderWarning;

  /// No description provided for @createBackup.
  ///
  /// In en, this message translates to:
  /// **'Create backup'**
  String get createBackup;

  /// No description provided for @restoreFromBackup.
  ///
  /// In en, this message translates to:
  /// **'Restore from backup'**
  String get restoreFromBackup;

  /// No description provided for @backupPassword.
  ///
  /// In en, this message translates to:
  /// **'Backup password'**
  String get backupPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @passwordMinimum.
  ///
  /// In en, this message translates to:
  /// **'Use at least 8 characters.'**
  String get passwordMinimum;

  /// No description provided for @passwordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get passwordMismatch;

  /// No description provided for @passwordCannotRecover.
  ///
  /// In en, this message translates to:
  /// **'This password cannot be recovered. If you lose it, the backup cannot be opened.'**
  String get passwordCannotRecover;

  /// No description provided for @backupPhotoWarning.
  ///
  /// In en, this message translates to:
  /// **'The backup contains customers\' ID photos. Store it safely.'**
  String get backupPhotoWarning;

  /// No description provided for @backupProgress.
  ///
  /// In en, this message translates to:
  /// **'Preparing encrypted backup…'**
  String get backupProgress;

  /// No description provided for @restoreProgress.
  ///
  /// In en, this message translates to:
  /// **'Restoring encrypted backup…'**
  String get restoreProgress;

  /// No description provided for @backupCreated.
  ///
  /// In en, this message translates to:
  /// **'Encrypted backup created.'**
  String get backupCreated;

  /// No description provided for @backupRestored.
  ///
  /// In en, this message translates to:
  /// **'Backup restored successfully.'**
  String get backupRestored;

  /// No description provided for @backupError.
  ///
  /// In en, this message translates to:
  /// **'Backup failed. Your current data was not changed.'**
  String get backupError;

  /// No description provided for @restoreError.
  ///
  /// In en, this message translates to:
  /// **'Restore failed. Your current data was not changed.'**
  String get restoreError;

  /// No description provided for @restoreReplaceWarning.
  ///
  /// In en, this message translates to:
  /// **'Restore replaces all current data. This cannot be undone.'**
  String get restoreReplaceWarning;

  /// No description provided for @restoreSummary.
  ///
  /// In en, this message translates to:
  /// **'Backup from {date}\nCustomers: {customers}\nMaterials: {materials}\nRentals: {rentals}\nReturns: {returns}\nDatabase version: {schema}'**
  String restoreSummary(
    Object customers,
    Object date,
    Object materials,
    Object rentals,
    Object returns,
    Object schema,
  );

  /// No description provided for @currentDataCounts.
  ///
  /// In en, this message translates to:
  /// **'Current data: {customers} customers, {rentals} rentals'**
  String currentDataCounts(Object customers, Object rentals);

  /// No description provided for @typeRestore.
  ///
  /// In en, this message translates to:
  /// **'Type RESTORE to continue'**
  String get typeRestore;

  /// No description provided for @restoreConfirmation.
  ///
  /// In en, this message translates to:
  /// **'RESTORE'**
  String get restoreConfirmation;

  /// No description provided for @selectBackup.
  ///
  /// In en, this message translates to:
  /// **'Select a .t2backup file'**
  String get selectBackup;

  /// No description provided for @backupFileInvalid.
  ///
  /// In en, this message translates to:
  /// **'This file is not a valid T2 Rental backup.'**
  String get backupFileInvalid;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// No description provided for @openBackupFolder.
  ///
  /// In en, this message translates to:
  /// **'Choose backup file'**
  String get openBackupFolder;

  /// No description provided for @homeBackupReminder.
  ///
  /// In en, this message translates to:
  /// **'Back up your data'**
  String get homeBackupReminder;

  /// No description provided for @backupNeverWarning.
  ///
  /// In en, this message translates to:
  /// **'No backup has been created yet.'**
  String get backupNeverWarning;

  /// No description provided for @backupShareFailed.
  ///
  /// In en, this message translates to:
  /// **'The backup was created, but sharing did not complete. You can find it in temporary storage.'**
  String get backupShareFailed;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get thisMonth;

  /// No description provided for @lastMonth.
  ///
  /// In en, this message translates to:
  /// **'Last month'**
  String get lastMonth;

  /// No description provided for @last3Months.
  ///
  /// In en, this message translates to:
  /// **'Last 3 months'**
  String get last3Months;

  /// No description provided for @thisYear.
  ///
  /// In en, this message translates to:
  /// **'This year'**
  String get thisYear;

  /// No description provided for @customRange.
  ///
  /// In en, this message translates to:
  /// **'Custom range'**
  String get customRange;

  /// No description provided for @selectDateRange.
  ///
  /// In en, this message translates to:
  /// **'Select date range'**
  String get selectDateRange;

  /// No description provided for @earnedRevenue.
  ///
  /// In en, this message translates to:
  /// **'Earned revenue'**
  String get earnedRevenue;

  /// No description provided for @previousMonthRevenue.
  ///
  /// In en, this message translates to:
  /// **'Previous month: {amount}'**
  String previousMonthRevenue(Object amount);

  /// No description provided for @revenueTrend.
  ///
  /// In en, this message translates to:
  /// **'Revenue trend (last 12 months)'**
  String get revenueTrend;

  /// No description provided for @averageDuration.
  ///
  /// In en, this message translates to:
  /// **'Average rental duration'**
  String get averageDuration;

  /// No description provided for @durationDays.
  ///
  /// In en, this message translates to:
  /// **'{days} days'**
  String durationDays(Object days);

  /// No description provided for @durationTrend.
  ///
  /// In en, this message translates to:
  /// **'Duration trend (last 6 months)'**
  String get durationTrend;

  /// No description provided for @noCompletedRentals.
  ///
  /// In en, this message translates to:
  /// **'No completed rentals in this period'**
  String get noCompletedRentals;

  /// No description provided for @mostRentedMaterials.
  ///
  /// In en, this message translates to:
  /// **'Most rented materials'**
  String get mostRentedMaterials;

  /// No description provided for @unitDays.
  ///
  /// In en, this message translates to:
  /// **'Unit-days'**
  String get unitDays;

  /// No description provided for @timesRented.
  ///
  /// In en, this message translates to:
  /// **'Times rented'**
  String get timesRented;

  /// No description provided for @totalQuantity.
  ///
  /// In en, this message translates to:
  /// **'Total quantity'**
  String get totalQuantity;

  /// No description provided for @showAll.
  ///
  /// In en, this message translates to:
  /// **'Show all'**
  String get showAll;

  /// No description provided for @showLess.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get showLess;

  /// No description provided for @currentlyOut.
  ///
  /// In en, this message translates to:
  /// **'Currently out'**
  String get currentlyOut;

  /// No description provided for @units.
  ///
  /// In en, this message translates to:
  /// **'units'**
  String get units;

  /// No description provided for @longRunningRentals.
  ///
  /// In en, this message translates to:
  /// **'Long-running rentals (≥ {days} days)'**
  String longRunningRentals(Object days);

  /// No description provided for @noLongRunning.
  ///
  /// In en, this message translates to:
  /// **'No long-running rentals'**
  String get noLongRunning;

  /// No description provided for @newCustomers.
  ///
  /// In en, this message translates to:
  /// **'New customers'**
  String get newCustomers;

  /// No description provided for @returningCustomers.
  ///
  /// In en, this message translates to:
  /// **'Returning customers'**
  String get returningCustomers;

  /// No description provided for @topByRevenue.
  ///
  /// In en, this message translates to:
  /// **'Top by revenue'**
  String get topByRevenue;

  /// No description provided for @topByRentals.
  ///
  /// In en, this message translates to:
  /// **'Top by rentals'**
  String get topByRentals;

  /// No description provided for @longRunningThreshold.
  ///
  /// In en, this message translates to:
  /// **'Long-running threshold (days)'**
  String get longRunningThreshold;

  /// No description provided for @invalidThreshold.
  ///
  /// In en, this message translates to:
  /// **'Enter a number between 1 and 365'**
  String get invalidThreshold;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noData;

  /// No description provided for @estimateDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Running estimate if active rentals are returned today'**
  String get estimateDisclaimer;

  /// No description provided for @periodSummary.
  ///
  /// In en, this message translates to:
  /// **'Period summary'**
  String get periodSummary;

  /// No description provided for @noMaterialsRented.
  ///
  /// In en, this message translates to:
  /// **'No materials rented in this period'**
  String get noMaterialsRented;

  /// No description provided for @noCustomersInPeriod.
  ///
  /// In en, this message translates to:
  /// **'No customers in this period'**
  String get noCustomersInPeriod;

  /// No description provided for @noActiveRentals.
  ///
  /// In en, this message translates to:
  /// **'No active rentals'**
  String get noActiveRentals;

  /// No description provided for @rentedReturnedStillOut.
  ///
  /// In en, this message translates to:
  /// **'Rented {rented} | Returned {returned} | Still out {stillOut}'**
  String rentedReturnedStillOut(
    Object rented,
    Object returned,
    Object stillOut,
  );

  /// No description provided for @returningOfRemaining.
  ///
  /// In en, this message translates to:
  /// **'Returning {returning} of {total} | {remaining} will remain out'**
  String returningOfRemaining(Object remaining, Object returning, Object total);

  /// No description provided for @remainingOutAfterReturn.
  ///
  /// In en, this message translates to:
  /// **'{count} will remain out'**
  String remainingOutAfterReturn(Object count);

  /// No description provided for @itemsCurrentlyHeld.
  ///
  /// In en, this message translates to:
  /// **'Items currently held'**
  String get itemsCurrentlyHeld;

  /// No description provided for @noItemsHeld.
  ///
  /// In en, this message translates to:
  /// **'No items currently held'**
  String get noItemsHeld;

  /// No description provided for @returnItems.
  ///
  /// In en, this message translates to:
  /// **'Return items'**
  String get returnItems;

  /// No description provided for @selectCustomerToReturn.
  ///
  /// In en, this message translates to:
  /// **'Select customer to return items'**
  String get selectCustomerToReturn;

  /// No description provided for @noCustomersHoldingItems.
  ///
  /// In en, this message translates to:
  /// **'No customers currently hold items'**
  String get noCustomersHoldingItems;

  /// No description provided for @unitsHeld.
  ///
  /// In en, this message translates to:
  /// **'{count} units held'**
  String unitsHeld(Object count);

  /// No description provided for @returnMore.
  ///
  /// In en, this message translates to:
  /// **'Return more'**
  String get returnMore;

  /// No description provided for @backToCustomer.
  ///
  /// In en, this message translates to:
  /// **'Back to customer'**
  String get backToCustomer;

  /// No description provided for @adjustAllocation.
  ///
  /// In en, this message translates to:
  /// **'Adjust allocation'**
  String get adjustAllocation;

  /// No description provided for @resetAllocation.
  ///
  /// In en, this message translates to:
  /// **'Reset to oldest first'**
  String get resetAllocation;

  /// No description provided for @batchOfItems.
  ///
  /// In en, this message translates to:
  /// **'Batch of {count} items'**
  String batchOfItems(Object count);

  /// No description provided for @batchReturnSummary.
  ///
  /// In en, this message translates to:
  /// **'Batch return summary'**
  String get batchReturnSummary;

  /// No description provided for @stillHeldAfterReturn.
  ///
  /// In en, this message translates to:
  /// **'Items still held by customer'**
  String get stillHeldAfterReturn;

  /// No description provided for @allReturnedNoHeld.
  ///
  /// In en, this message translates to:
  /// **'All items returned — customer holds no materials'**
  String get allReturnedNoHeld;

  /// No description provided for @daysSoFarCount.
  ///
  /// In en, this message translates to:
  /// **'{days} days so far'**
  String daysSoFarCount(Object days);

  /// No description provided for @allocationErrorTotalMismatch.
  ///
  /// In en, this message translates to:
  /// **'Allocated total ({allocated}) must equal {total}'**
  String allocationErrorTotalMismatch(Object allocated, Object total);

  /// No description provided for @allocationErrorExceedsLine.
  ///
  /// In en, this message translates to:
  /// **'Cannot exceed line outstanding of {max}'**
  String allocationErrorExceedsLine(Object max);

  /// No description provided for @fromRental.
  ///
  /// In en, this message translates to:
  /// **'From {rentalNumber}'**
  String fromRental(Object rentalNumber);
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
