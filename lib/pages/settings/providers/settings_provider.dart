import 'package:eeasy_rfid/util/constants.dart';
import 'package:flutter/cupertino.dart';

class SettingsProvider extends ChangeNotifier {

  List<int> selectedAntennas = [3];

  bool initValuesSet = false;

  Map<int, int> powerMap = {1 : 30, 2 : 30, 3 : 30, 4 : 30};


  setInitValues() async {
    Constants.methodChannel.invokeMethod('setAntenna', {"antennas" : selectedAntennas});
    Constants.methodChannel.invokeMethod('setPower', {'powerMap' : powerMap});
    initValuesSet = true;
    notifyListeners();
  }

  setAntennaNumber() {
    Constants.methodChannel.invokeMethod('setAntenna', {"antennas" : selectedAntennas});
  }

  addAntenna(int antennaNo) {
    selectedAntennas.add(antennaNo);
    selectedAntennas = List.from(selectedAntennas);
    setAntennaNumber();
    notifyListeners();
  }

  removeAntenna(int antennaNo) {
    selectedAntennas.remove(antennaNo);
    selectedAntennas = List.from(selectedAntennas);
    setAntennaNumber();
    notifyListeners();
  }

  setPowerMap(int antennaNo, int power) {
    powerMap[antennaNo] = power;
    Constants.methodChannel.invokeMethod('setPower', {'powerMap' : powerMap});
    notifyListeners();
  }

}