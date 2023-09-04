import 'package:eeasy_rfid/pages/settings/providers/settings_provider.dart';
import 'package:eeasy_rfid/util/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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