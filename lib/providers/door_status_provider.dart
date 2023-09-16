import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../util/constants.dart';

class DoorStatusProvider extends ChangeNotifier {

  bool isDoorOpenOld = false;
  bool isDoorOpen = false;

  init() {
    Timer.periodic(const Duration(seconds: 1), (timer) async {
      var x = await Constants.methodChannel.invokeMethod('doorStatus', {});
      isDoorOpenOld = isDoorOpen;
      isDoorOpen = x;
      notifyListeners();
    });
  }

}