import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../api_collection/eeasy_rfid_api.dart';
import '../models/product.dart';
import '../util/data.dart';

class CheckoutProvider extends ChangeNotifier {

  List<Product> products = [];

  populateCheckoutProductsFromTags(List<String> tags) async {
    products = [];
    for(String tag in tags) {
      if(Data.epcProductMap.containsKey(tag)) {
        products.add(Data.epcProductMap[tag]!);
      }
      else{
        var resp = await RfidAPICollection.getProductFromEPC(tag);
        if(resp.data != null) {
          Data.epcProductMap.addAll({tag : resp.data!});
          products.add(resp.data!);
        }
        else {
          Fluttertoast.showToast(msg: '$tag : ${resp.statusCode} : ${resp.reasonPhrase}');
        }
      }
    }
  }

}