import 'package:flutter/cupertino.dart';

import '../Models/user_settings.dart';

class AppStateProvider extends ChangeNotifier {

  String? transactionId;

  UserSettingsModel? userSettings;

  setUserSettings(UserSettingsModel value) {
    userSettings = value;
    notifyListeners();
  }

}