import 'dart:convert';

import 'package:eeasy_rfid/pages/settings/providers/settings_logs_provider.dart';
import 'package:eeasy_rfid/util/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';

class SettingsProvider extends ChangeNotifier {

  List<int> selectedAntennas = [3];

  bool initValuesSet = false;

  Map<int, int> powerMap = {1 : 30, 2 : 30, 3 : 30, 4 : 30};

  Map<int, int> antennaValueMap = {
    1 : 1,
    2 : 2,
    3 : 4,
    4 : 8,
    5 : 16,
    6 : 32,
    7 : 64,
    8 : 128
  };

  setInitValues(BuildContext context) async {
    /*var x = await Constants.methodChannel.invokeMethod('setInitValues', {});
    var _antennaVal = x['antennaValue'];
    Fluttertoast.showToast(msg: 'FINAL DATA : $x : $_antennaVal');
    selectedAntennas = [];
    if(_antennaVal == 1) {
      selectedAntennas.add(1);
    }
    if(_antennaVal == 2) {
      selectedAntennas.add(2);
    }
    if(_antennaVal == 4) {
      selectedAntennas.add(3);
    }
    if(_antennaVal == 3) {
      selectedAntennas.add(1);
      selectedAntennas.add(2);
    }
    if(_antennaVal == 7) {
      selectedAntennas.add(1);
      selectedAntennas.add(2);
      selectedAntennas.add(3);
    }*/
    await Constants.methodChannel.invokeMethod('setAntenna', {"antennas" : selectedAntennas});
    await Constants.methodChannel.invokeMethod('setPower', {'powerMap' : powerMap});
    initValuesSet = true;
    await Hive.initFlutter();
    var box = await Hive.openBox('logs');
    box.add('${DateTime.now()} : SA : $selectedAntennas ..... PM');
    notifyListeners();
  }

  setAntennaNumber(BuildContext context) async {
    Constants.methodChannel.invokeMethod('setAntenna', {"antennas" : selectedAntennas});
    var box = await Hive.openBox('logs');
    box.add('${DateTime.now()} : SA : $selectedAntennas ..... PM');
  }

  addAntenna(int antennaNo, BuildContext context) {
    selectedAntennas.add(antennaNo);
    selectedAntennas = List.from(selectedAntennas);
    setAntennaNumber(context);
    notifyListeners();
  }

  removeAntenna(int antennaNo, BuildContext context) {
    selectedAntennas.remove(antennaNo);
    selectedAntennas = List.from(selectedAntennas);
    setAntennaNumber(context);
    notifyListeners();
  }

  setPowerMap(int antennaNo, int power, BuildContext context) async {
    powerMap[antennaNo] = power;
    Constants.methodChannel.invokeMethod('setPower', {'powerMap' : powerMap});
    var box = await Hive.openBox('logs');
    box.add('${DateTime.now()} : SA : $selectedAntennas ..... PM : ${jsonEncode(powerMap)}');
    //Provider.of<SettingsLogsProvider>(context, listen: false).addLog('${DateTime.now()} : SA : $selectedAntennas ..... PM : ${jsonEncode(powerMap)}');
    notifyListeners();
  }

}