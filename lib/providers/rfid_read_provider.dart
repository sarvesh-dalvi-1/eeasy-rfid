import 'dart:async';

import 'package:eeasy_rfid/providers/app_state_provider.dart';
import 'package:eeasy_rfid/providers/checkout_provider.dart';
import 'package:eeasy_rfid/providers/door_status_provider.dart';
import 'package:eeasy_rfid/util/constants.dart';
import 'package:eeasy_rfid/util/data.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

class RfidReadProvider extends ChangeNotifier {
  List<String> tempTags = [];

  List<List<String>> listOfList = [];
  List<String> finalList = [];


  List<String> recordedTags = [];    /// Display when recording mode is on
  List<String> tagsRemoved = [];     /// This will store all the tags that are removed after recording
  List<String> finalRecordedTags = [];    /// Store the final recorded data here

  int count = 0;

  init() {

    count = 0;

    Constants.rfidReaderEventChannel.receiveBroadcastStream().listen((event) {
      if (((event as String).length == 24) && (!tempTags.contains(event))) {
        tempTags.add(event);
      }
    });

    Constants.methodChannel.invokeMethod('readTags').then((value) {
      //Fluttertoast.showToast(msg: 'Read tags Init : $value');         /// 0 : success     eslse : error
    });

    Timer.periodic(const Duration(seconds: 2), (_) {

      if(Provider.of<AppStateProvider>(Constants.navigatorKey.currentContext!, listen: false).isRecordingOn) {

        listOfList.add(tempTags);
        if(listOfList.length > 3) {
          listOfList.removeAt(0);
        }

        for(int i=0;i<listOfList.length; i++) {
          for(int j=0; j<listOfList[i].length; j++) {
            if(!finalList.contains(listOfList[i][j])) {
              finalList.add(listOfList[i][j]);
            }
          }
        }
        if(!listEquals(finalList..sort(), recordedTags..sort())) {
          recordedTags = finalList.toList();
        }

        finalRecordedTags = recordedTags.toList();

        notifyListeners();

        tempTags = [];
        finalList = [];

      }

      if((Provider.of<DoorStatusProvider>(Constants.navigatorKey.currentContext!, listen: false).safeToCallDoorStatusCheck == true) && count % 4 == 0) {
        Provider.of<DoorStatusProvider>(Constants.navigatorKey.currentContext!, listen: false).checkDoorStatus();
      }

      count ++;

    });
  }



  Future<List<String>> singlePopulate() async {
    /// Checks the current fridge state on call and will return the list of tags removed from fridge

    listOfList = [];
    finalList = [];
    recordedTags = [];

    tempTags = [];
    await Future.delayed(const Duration(milliseconds: 500));
    listOfList.add(tempTags);
    tempTags = [];
    await Future.delayed(const Duration(milliseconds: 500));
    listOfList.add(tempTags);
    tempTags = [];
    await Future.delayed(const Duration(milliseconds: 500));
    listOfList.add(tempTags);

    for(int i=0;i<listOfList.length; i++) {
      for(int j=0; j<listOfList[i].length; j++) {
        if(!finalList.contains(listOfList[i][j])) {
          finalList.add(listOfList[i][j]);
        }
      }
    }

    recordedTags = finalList.toList();

    List<String> temp = [];

    for(int i=0;i<finalRecordedTags.length;i++) {
      if(!recordedTags.contains(finalRecordedTags[i])) {
        temp.add(finalRecordedTags[i]);
      }
    }

    tagsRemoved = temp.toList();

    return tagsRemoved;

  }


  populateFinalRecTags() {
    finalRecordedTags = recordedTags.toList();
    notifyListeners();
  }


  reset() {
    finalRecordedTags = recordedTags.toList();
    listOfList = [];
    tagsRemoved = [];
    count = 0;
    finalList = [];
  }

}
