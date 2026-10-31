// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Amharic (`am`).
class AppLocalizationsAm extends AppLocalizations {
  AppLocalizationsAm([String locale = 'am']) : super(locale);

  @override
  String get appTitle => 'T2 Rental';

  @override
  String get home => 'መነሻ';

  @override
  String get settings => 'ቅንብሮች';

  @override
  String get language => 'ቋንቋ';

  @override
  String get english => 'እንግሊዝኛ';

  @override
  String get amharic => 'አማርኛ';

  @override
  String get phase0Message => 'የመሠረት ዝግጅቱ ተጠናቋል።';

  @override
  String get chooseLanguage => 'ቋንቋ ይምረጡ';

  @override
  String get materials => 'ቁሳቁሶች';

  @override
  String get addMaterial => 'ቁሳቁስ ይጨምሩ';

  @override
  String get editMaterial => 'ቁሳቁስ ያርትዑ';

  @override
  String get searchMaterials => 'ቁሳቁሶችን ይፈልጉ';

  @override
  String get showInactive => 'የቦዘኑትን አሳይ';

  @override
  String get noMaterials => 'ምንም ቁሳቁስ አልተገኘም።';

  @override
  String get materialsLoadError => 'ቁሳቁሶችን መጫን አልተቻለም።';

  @override
  String get pricePerDay => 'የቀን ዋጋ';

  @override
  String get stock => 'ክምችት';

  @override
  String get inactive => 'ቦዝኗል';

  @override
  String get category => 'ምድብ';

  @override
  String get materialName => 'የቁሳቁስ ስም ወይም ዓይነት';

  @override
  String get categoryRequired => 'ምድብ ያስፈልጋል።';

  @override
  String get nameRequired => 'ስም ያስፈልጋል።';

  @override
  String get priceRequired => 'ዋጋ ያስፈልጋል።';

  @override
  String get priceMustBePositive => 'ዋጋው ከዜሮ መብለጥ አለበት።';

  @override
  String get stockMustBeNonNegative => 'ክምችት አሉታዊ ሊሆን አይችልም።';

  @override
  String get optional => 'አማራጭ';

  @override
  String get active => 'ንቁ';

  @override
  String get save => 'አስቀምጥ';

  @override
  String get invalidNumber => 'እስከ ሁለት የዐሥርዮሽ አሃዞች ያለው ትክክለኛ ቁጥር ያስገቡ።';

  @override
  String get duplicateMaterial => 'በዚህ ምድብና ስም ያለ ቁሳቁስ አለ።';

  @override
  String get saveMaterialError => 'ቁሳቁሱን ማስቀመጥ አልተቻለም።';
}
