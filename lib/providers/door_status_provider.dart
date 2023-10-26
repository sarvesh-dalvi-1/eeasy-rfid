import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../util/constants.dart';
import '../util/streams.dart';

class DoorStatusProvider extends ChangeNotifier {

  bool safeToCallDoorStatusCheck = false;

  bool isDoorOpenOld = false;
  bool isDoorOpen = false;



  checkDoorStatus() async {
      var x = await Constants.methodChannel.invokeMethod('doorStatus', {});
      //Fluttertoast.showToast(msg: 'Live door status : $x');
      isDoorOpenOld = isDoorOpen;
      isDoorOpen = x;
      if((isDoorOpenOld != isDoorOpen) && (isDoorOpen == false)) {
        AppStreams.doorCloseDetectedStreamController.sink.add(1);
      }
  }

}