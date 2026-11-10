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

  @override
  String get voidRental => 'Void rental';

  @override
  String get voidReturn => 'Void return';

  @override
  String get voidReason => 'Reason for voiding';

  @override
  String get voidReasonRequired => 'Enter at least 5 characters.';

  @override
  String get voidRentalWarning =>
      'Voiding hides this rental from totals and frees its stock. This cannot be undone.';

  @override
  String get voidReturnWarning =>
      'Voiding removes this return from earned totals and restores its outstanding quantity.';

  @override
  String get voidConfirm => 'Confirm void';

  @override
  String get voidSuccess => 'Voided successfully.';

  @override
  String get voidError => 'Could not void this record.';

  @override
  String voidedOn(Object date, Object reason) {
    return 'Voided on $date: $reason';
  }

  @override
  String get voidedFilter => 'Voided';

  @override
  String get voidAndRecreate => 'Void and recreate';

  @override
  String get recreateWarning =>
      'Some original materials are no longer active or available and will be skipped.';

  @override
  String recreateNote(Object rentalNumber) {
    return 'Replaces $rentalNumber';
  }

  @override
  String get auditHistory => 'Audit history';

  @override
  String get noAuditHistory => 'No audit history.';

  @override
  String voidedAmount(Object amount) {
    return 'Voided: $amount';
  }

  @override
  String voidedReturnReason(Object reason) {
    return 'Voided: $reason';
  }

  @override
  String get backupAndRestore => 'Backup & restore';

  @override
  String lastBackup(Object date) {
    return 'Last backup: $date';
  }

  @override
  String get neverBackedUp => 'Never backed up';

  @override
  String get backupDataWarning =>
      'Back up your data. This backup contains customer ID photos; store it safely.';

  @override
  String get backupOlderWarning => 'Your last backup is more than 7 days old.';

  @override
  String get createBackup => 'Create backup';

  @override
  String get restoreFromBackup => 'Restore from backup';

  @override
  String get backupPassword => 'Backup password';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get passwordMinimum => 'Use at least 8 characters.';

  @override
  String get passwordMismatch => 'Passwords do not match.';

  @override
  String get passwordCannotRecover =>
      'This password cannot be recovered. If you lose it, the backup cannot be opened.';

  @override
  String get backupPhotoWarning =>
      'The backup contains customers\' ID photos. Store it safely.';

  @override
  String get backupProgress => 'Preparing encrypted backup…';

  @override
  String get restoreProgress => 'Restoring encrypted backup…';

  @override
  String get backupCreated => 'Encrypted backup created.';

  @override
  String get backupRestored => 'Backup restored successfully.';

  @override
  String get backupError => 'Backup failed. Your current data was not changed.';

  @override
  String get restoreError =>
      'Restore failed. Your current data was not changed.';

  @override
  String get restoreReplaceWarning =>
      'Restore replaces all current data. This cannot be undone.';

  @override
  String restoreSummary(
    Object customers,
    Object date,
    Object materials,
    Object rentals,
    Object returns,
    Object schema,
  ) {
    return 'Backup from $date\nCustomers: $customers\nMaterials: $materials\nRentals: $rentals\nReturns: $returns\nDatabase version: $schema';
  }

  @override
  String currentDataCounts(Object customers, Object rentals) {
    return 'Current data: $customers customers, $rentals rentals';
  }

  @override
  String get typeRestore => 'Type RESTORE to continue';

  @override
  String get restoreConfirmation => 'RESTORE';

  @override
  String get selectBackup => 'Select a .t2backup file';

  @override
  String get backupFileInvalid => 'This file is not a valid T2 Rental backup.';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get openBackupFolder => 'Choose backup file';

  @override
  String get homeBackupReminder => 'Back up your data';

  @override
  String get backupNeverWarning => 'No backup has been created yet.';

  @override
  String get backupShareFailed =>
      'The backup was created, but sharing did not complete. You can find it in temporary storage.';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get thisMonth => 'This month';

  @override
  String get lastMonth => 'Last month';

  @override
  String get last3Months => 'Last 3 months';

  @override
  String get thisYear => 'This year';

  @override
  String get customRange => 'Custom range';

  @override
  String get selectDateRange => 'Select date range';

  @override
  String get earnedRevenue => 'Earned revenue';

  @override
  String previousMonthRevenue(Object amount) {
    return 'Previous month: $amount';
  }

  @override
  String get revenueTrend => 'Revenue trend (last 12 months)';

  @override
  String get averageDuration => 'Average rental duration';

  @override
  String durationDays(Object days) {
    return '$days days';
  }

  @override
  String get durationTrend => 'Duration trend (last 6 months)';

  @override
  String get noCompletedRentals => 'No completed rentals in this period';

  @override
  String get mostRentedMaterials => 'Most rented materials';

  @override
  String get unitDays => 'Unit-days';

  @override
  String get timesRented => 'Times rented';

  @override
  String get totalQuantity => 'Total quantity';

  @override
  String get showAll => 'Show all';

  @override
  String get showLess => 'Show less';

  @override
  String get currentlyOut => 'Currently out';

  @override
  String get units => 'units';

  @override
  String longRunningRentals(Object days) {
    return 'Long-running rentals (≥ $days days)';
  }

  @override
  String get noLongRunning => 'No long-running rentals';

  @override
  String get newCustomers => 'New customers';

  @override
  String get returningCustomers => 'Returning customers';

  @override
  String get topByRevenue => 'Top by revenue';

  @override
  String get topByRentals => 'Top by rentals';

  @override
  String get longRunningThreshold => 'Long-running threshold (days)';

  @override
  String get invalidThreshold => 'Enter a number between 1 and 365';

  @override
  String get noData => 'No data available';

  @override
  String get estimateDisclaimer =>
      'Running estimate if active rentals are returned today';

  @override
  String get periodSummary => 'Period summary';

  @override
  String get noMaterialsRented => 'No materials rented in this period';

  @override
  String get noCustomersInPeriod => 'No customers in this period';

  @override
  String get noActiveRentals => 'No active rentals';

  @override
  String rentedReturnedStillOut(
    Object rented,
    Object returned,
    Object stillOut,
  ) {
    return 'Rented $rented | Returned $returned | Still out $stillOut';
  }

  @override
  String returningOfRemaining(
    Object remaining,
    Object returning,
    Object total,
  ) {
    return 'Returning $returning of $total | $remaining will remain out';
  }

  @override
  String remainingOutAfterReturn(Object count) {
    return '$count will remain out';
  }

  @override
  String get itemsCurrentlyHeld => 'Items currently held';

  @override
  String get noItemsHeld => 'No items currently held';

  @override
  String get returnItems => 'Return items';

  @override
  String get selectCustomerToReturn => 'Select customer to return items';

  @override
  String get noCustomersHoldingItems => 'No customers currently hold items';

  @override
  String unitsHeld(Object count) {
    return '$count units held';
  }

  @override
  String get returnMore => 'Return more';

  @override
  String get backToCustomer => 'Back to customer';

  @override
  String get adjustAllocation => 'Adjust allocation';

  @override
  String get resetAllocation => 'Reset to oldest first';

  @override
  String batchOfItems(Object count) {
    return 'Batch of $count items';
  }

  @override
  String get batchReturnSummary => 'Batch return summary';

  @override
  String get stillHeldAfterReturn => 'Items still held by customer';

  @override
  String get allReturnedNoHeld =>
      'All items returned — customer holds no materials';

  @override
  String daysSoFarCount(Object days) {
    return '$days days so far';
  }

  @override
  String allocationErrorTotalMismatch(Object allocated, Object total) {
    return 'Allocated total ($allocated) must equal $total';
  }

  @override
  String allocationErrorExceedsLine(Object max) {
    return 'Cannot exceed line outstanding of $max';
  }

  @override
  String fromRental(Object rentalNumber) {
    return 'From $rentalNumber';
  }
}
