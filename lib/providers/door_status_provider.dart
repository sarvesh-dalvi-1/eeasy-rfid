import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../util/constants.dart';

class DoorStatusProvider extends ChangeNotifier {

  bool safeToCallDoorStatusCheck = false;

  bool isDoorOpenOld = false;
  bool isDoorOpen = false;

  StreamController<int> doorCloseDetectedStream = StreamController();

  checkDoorStatus() async {
      var x = await Constants.methodChannel.invokeMethod('doorStatus', {});
      Fluttertoast.showToast(msg: 'Live door status : $x');
      isDoorOpenOld = isDoorOpen;
      isDoorOpen = x;
      if((isDoorOpenOld != isDoorOpen) && (isDoorOpen == false)) {
        doorCloseDetectedStream.sink.add(1);
      }
  }

}