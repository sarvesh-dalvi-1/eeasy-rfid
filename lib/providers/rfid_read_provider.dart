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

  init(BuildContext context) {
    Timer.periodic(const Duration(seconds: 2), (timer) {
      final newTags = tags..sort();
      final newTempTags = tempTags..sort();
      tempTags = [];
      //Fluttertoast.showToast(msg: 'Length : ${newTempTags.length}');
      if (!listEquals(newTags, newTempTags)) {
        tags = newTempTags.toList();
        Provider.of<CheckoutProvider>(context, listen: false)
            .populateCheckoutProductsFromTags(tags);
        notifyListeners();
      }
    });
    Constants.rfidReaderEventChannel.receiveBroadcastStream().listen((event) {
      // Fluttertoast.showToast(msg: 'Received event : $event');
      if (((event as String).length == 24) && (!tempTags.contains(event))) {
        tempTags.add(event);
      }
    });
    Constants.methodChannel.invokeMethod('readTags').then((value) {
      Fluttertoast.showToast(msg: 'Read tags Init : $value');         /// 0 : success     eslse : error
    });
    /* Timer.periodic(const Duration(seconds: 3), (timer) {
        tags = [];
      });
    Constants.rfidReaderEventChannel.receiveBroadcastStream().listen((event) {
      if((event as String).length == 24) {
        if(!tags.contains(event)) {
          tags.add(event);
          tags.sort((a,b) => a.toLowerCase().compareTo(b.toLowerCase()));
          notifyListeners();
        }
      }
    }); */
  }
}
