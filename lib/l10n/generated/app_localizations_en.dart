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

  @override
  String get customers => 'Customers';

  @override
  String get addCustomer => 'Add customer';

  @override
  String get editCustomer => 'Edit customer';

  @override
  String get searchCustomers => 'Search customers';

  @override
  String get showArchived => 'Show archived';

  @override
  String get noCustomers => 'No customers found.';

  @override
  String get customersLoadError => 'Could not load customers.';

  @override
  String get archived => 'Archived';

  @override
  String get customerProfile => 'Customer profile';

  @override
  String get customerNotFound => 'Customer not found.';

  @override
  String get rentalHistory => 'Rental history';

  @override
  String get noRentalHistory => 'No rental history yet.';

  @override
  String get archiveCustomer => 'Archive customer';

  @override
  String get reactivateCustomer => 'Reactivate customer';

  @override
  String get fullName => 'Full name';

  @override
  String get address => 'Address';

  @override
  String get addressRequired => 'Address is required.';

  @override
  String get phone => 'Phone';

  @override
  String get notes => 'Notes';

  @override
  String get idPhotoFront => 'Front ID photo';

  @override
  String get idPhotoBack => 'Back ID photo';

  @override
  String get photoPrivacyNote => 'Stored privately on this device.';

  @override
  String get takePhoto => 'Take photo';

  @override
  String get retakePhoto => 'Retake';

  @override
  String get chooseFromGallery => 'Choose from gallery';

  @override
  String get photoSaveError => 'Could not save the photo.';

  @override
  String get photoCaptureError => 'Could not capture the photo.';

  @override
  String get cameraPermissionDenied => 'Camera permission was denied.';

  @override
  String get frontPhotoRequired => 'A front ID photo is required.';

  @override
  String get possibleDuplicate => 'Possible duplicate';

  @override
  String get existingCustomersFound => 'Existing possible matches were found.';

  @override
  String get cancel => 'Cancel';

  @override
  String get openExisting => 'Open existing';

  @override
  String get continueSaving => 'Continue saving';

  @override
  String get saveCustomerError => 'Could not save customer.';

  @override
  String get phoneLengthError => 'Phone must contain 7 to 15 digits.';

  @override
  String get phoneCharactersError =>
      'Phone may contain only digits, spaces, +, and -.';

  @override
  String get discardChangesTitle => 'Discard changes?';

  @override
  String get replacePhoto => 'Replace photo';

  @override
  String get discardChangesMessage => 'Your unsaved changes will be lost.';

  @override
  String get discardChanges => 'Discard';

  @override
  String get keepEditing => 'Keep editing';

  @override
  String get retakeFrontPhoto => 'Retake front photo';

  @override
  String get addBackPhoto => 'Add back photo';

  @override
  String get retakeBackPhoto => 'Retake back photo';

  @override
  String get replacePhotoTitle => 'Replace photo?';

  @override
  String get replacePhotoMessage =>
      'The current photo will be kept in history.';

  @override
  String get photoReplaced => 'Photo replaced.';

  @override
  String get photoReplacementError => 'Could not replace the photo.';

  @override
  String get rentals => 'Rentals';

  @override
  String get searchRentals => 'Search by customer or rental number';

  @override
  String get returned => 'Returned';

  @override
  String get partiallyReturned => 'Partially returned';

  @override
  String get voided => 'Voided';

  @override
  String get all => 'All';

  @override
  String get noRentals => 'No rentals found.';

  @override
  String get estimate => 'Estimate';

  @override
  String get newRental => 'New rental';

  @override
  String get activeRentals => 'Active rentals';

  @override
  String get itemsCurrentlyOut => 'Items currently out';

  @override
  String get customer => 'Customer';

  @override
  String get addNewCustomer => 'Add new customer';

  @override
  String get customerRequired => 'Select a customer.';

  @override
  String get material => 'Material';

  @override
  String get materialRequired => 'Select a material.';

  @override
  String get quantity => 'Quantity';

  @override
  String get quantityRequired => 'Quantity must be at least 1.';

  @override
  String get addMaterialLine => 'Add material line';

  @override
  String get totalPerDay => 'Total per day';

  @override
  String get remove => 'Remove';

  @override
  String get notesOptional => 'Notes (optional)';

  @override
  String get duplicateMaterialLine => 'This material is already in the rental.';

  @override
  String get atLeastOneLine => 'Add at least one material line.';

  @override
  String get stockWarning => 'Stock warning';

  @override
  String get requested => 'Requested';

  @override
  String get available => 'Available';

  @override
  String get continueAnyway => 'Continue anyway';

  @override
  String get rentalDetails => 'Rental details';

  @override
  String get rentalNotFound => 'Rental not found.';

  @override
  String get rentalDate => 'Rental date';

  @override
  String get daysSoFar => 'Days so far';

  @override
  String get status => 'Status';

  @override
  String get outstanding => 'Outstanding';

  @override
  String get estimateIfReturnedToday => 'Estimate if returned today';

  @override
  String get returnComingNext => 'Return (coming next)';

  @override
  String get viewCustomer => 'View customer';

  @override
  String get thisMonthsRevenue => 'This month\'s revenue';

  @override
  String get earnedFromReturns => 'Earned from returns';

  @override
  String get returnAction => 'Return';

  @override
  String get returnMaterials => 'Return materials';

  @override
  String get returnAll => 'Return all';

  @override
  String get clear => 'Clear';

  @override
  String get nowLocked => 'Now (locked)';

  @override
  String rentedQuantity(Object quantity) {
    return 'Rented: $quantity';
  }

  @override
  String alreadyReturnedQuantity(Object quantity) {
    return 'Already returned: $quantity';
  }

  @override
  String outstandingQuantity(Object quantity) {
    return 'Outstanding: $quantity';
  }

  @override
  String linePreview(Object amount, Object days, Object price) {
    return '$days days × $price = $amount';
  }

  @override
  String get totalToPay => 'Total to pay';

  @override
  String get confirmReturn => 'Confirm return';

  @override
  String get returnDateTime => 'Return date/time';

  @override
  String get confirm => 'Confirm';

  @override
  String get returnSummary => 'Return summary';

  @override
  String get backToRental => 'Back to rental';

  @override
  String get backToHome => 'Back to Home';

  @override
  String get returnHistory => 'Return history';

  @override
  String get noReturnHistory => 'No returns recorded yet.';

  @override
  String get earnedSoFar => 'Earned so far';

  @override
  String get outstandingEstimate => 'Outstanding estimate';

  @override
  String get finalTotal => 'Final total';

  @override
  String get totalForThisReturn => 'Total for this return';

  @override
  String get remainingOutstanding => 'Remaining outstanding';

  @override
  String get runningEstimate => 'Running estimate';

  @override
  String get returnNoteOptional => 'Return note (optional)';

  @override
  String get returnValidation => 'Select at least one quantity to return.';

  @override
  String get returnSaveError => 'Could not record the return.';

  @override
  String returnDateTimeValue(Object value) {
    return 'Return date/time: $value';
  }

  @override
  String returnHistoryLine(
    Object amount,
    Object date,
    Object days,
    Object material,
    Object quantity,
  ) {
    return '$date · $material · $quantity units · $days days · $amount';
  }

  @override
  String summaryLine(
    Object amount,
    Object days,
    Object price,
    Object quantity,
  ) {
    return '$quantity returned · $days days · $price · $amount';
  }
}
