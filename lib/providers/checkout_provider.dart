import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../api_collection/eeasy_rfid_api.dart';
import '../models/product.dart';
import '../util/data.dart';

class CheckoutProvider extends ChangeNotifier {
  List<Product> products = [];

  Future<int> populateCheckoutProductsFromTags(List<String> tags) async {
    products = [];
    Fluttertoast.showToast(msg: 'Checkout Products : ${tags.length}');
    for (String tag in tags) {
      if (AppData.epcProductMap.containsKey(tag)) {
        products.add(AppData.epcProductMap[tag]!);
      } else {
        var resp = await RfidAPICollection.getProductFromEPC(tag);
        if (resp.data != null) {
          AppData.epcProductMap.addAll({tag: resp.data!});
          products.add(resp.data!);
        } else {
          ///Fluttertoast.showToast(msg: '$tag : ${resp.statusCode} : ${resp.reasonPhrase}');
        }
      }
    }
    return 1;
    ///notifyListeners();
  }
}
