import 'package:states_rebuilder/states_rebuilder.dart';

final isDarkMode = RM.inject<bool>(
  () => true,
  persist: () => PersistState(
    key: '__themeData__',
    fromJson: (json) => json == '1',
    toJson: (themeData) => themeData ? '1' : '0',
  ),
);
