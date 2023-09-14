import 'dart:async';

import 'package:eeasy_rfid/providers/checkout_provider.dart';
import 'package:eeasy_rfid/util/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class RfidReadProvider extends ChangeNotifier {
  List<String> tempTags = [];
  List<String> tags = [];

  List<List<String>> listOfList = [];
  List<String> finalList = [];

  int tagsScanned = 0;

  bool isInverseLogic = false;

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
      if(!listEquals(finalList..sort(), tags..sort())) {
        //Fluttertoast.showToast(msg: 'List updated !!!');
        tags = finalList.toList();
        Provider.of<CheckoutProvider>(context, listen: false).populateCheckoutProductsFromTags(tags);
        //notifyListeners();
      }
      notifyListeners();
      tempTags = [];
      finalList = [];
    });
  }


  setIsInverseLogic(bool isInverseLogic) {
    this.isInverseLogic = isInverseLogic;
  }

}
