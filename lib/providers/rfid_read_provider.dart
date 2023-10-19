import 'dart:async';

import 'package:eeasy_rfid/providers/app_state_provider.dart';
import 'package:eeasy_rfid/providers/checkout_provider.dart';
import 'package:eeasy_rfid/providers/door_status_provider.dart';
import 'package:eeasy_rfid/util/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

class RfidReadProvider extends ChangeNotifier {
  List<String> tempTags = [];

  List<List<String>> listOfList = [];
  List<String> finalList = [];


  List<String> recordedTags = [];    /// Display when recording mode is on
  List<String> tagsRemoved = [];     /// This will store all the tags that are removed after recording
  List<String> finalRecordedTags = [];    /// Store the final recorded data here


  int tagsScanned = 0;

  init(BuildContext context) {

    Constants.rfidReaderEventChannel.receiveBroadcastStream().listen((event) {
      if (((event as String).length == 24) && (!tempTags.contains(event))) {
        tempTags.add(event);
      }
    });

    Constants.methodChannel.invokeMethod('readTags').then((value) {
      //Fluttertoast.showToast(msg: 'Read tags Init : $value');         /// 0 : success     eslse : error
    });

    Timer.periodic(const Duration(seconds: 2), (_) {

      tagsScanned = tempTags.length;
      //Fluttertoast.showToast(msg: 'Temp tags : ${tempTags.length}');
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
        //Fluttertoast.showToast(msg: 'List updated !!!');
        recordedTags = finalList.toList();
        //notifyListeners();
      }

      //tagsRemoved = [];

      List<String> temp = [];

      for(int i=0;i<finalRecordedTags.length;i++) {
        if(!recordedTags.contains(finalRecordedTags[i])) {
          temp.add(finalRecordedTags[i]);
        }
      }

      tagsRemoved = temp.toList();

      Provider.of<CheckoutProvider>(context, listen: false).populateCheckoutProductsFromTags(tagsRemoved);

      if(Provider.of<DoorStatusProvider>(context, listen: false).safeToCallDoorStatusCheck == true) {
        Provider.of<DoorStatusProvider>(context, listen: false).checkDoorStatus();
      }


      if(Provider.of<AppStateProvider>(context, listen: false).isRecordingOn) {
        finalRecordedTags = recordedTags.toList();
      }

      notifyListeners();

      tempTags = [];
      finalList = [];
    });
  }


  populateFinalRecTags() {
    finalRecordedTags = recordedTags.toList();
    notifyListeners();
  }

}
