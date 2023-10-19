import 'package:eeasy_rfid/pages/settings/providers/settings_provider.dart';
import 'package:eeasy_rfid/util/constants.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

class RfidInitProvider extends ChangeNotifier {

  bool? isTcpConnected;

  connectTcp() async {

    var box = await Hive.openBox('config');
    String? ip;
    if(box.values.isNotEmpty) {
      ip = box.get('ip').toString();
    }
    var resp = await Constants.methodChannel.invokeMethod('connectTCP', {"ip" : ip ?? ''});
    if(resp == true) {
      isTcpConnected = true;
    }
    else {
      isTcpConnected = false;
    }
    notifyListeners();
  }

}