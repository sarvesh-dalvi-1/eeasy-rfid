import 'package:eeasy_rfid/util/constants.dart';
import 'package:flutter/material.dart';

class RfidInitProvider extends ChangeNotifier {

  bool? isTcpConnected;

  connectTcp() async {
    var resp = await Constants.methodChannel.invokeMethod('connectTCP');
    if(resp == true) {
      isTcpConnected = true;
    }
    else {
      isTcpConnected = false;
    }
    notifyListeners();
  }

}