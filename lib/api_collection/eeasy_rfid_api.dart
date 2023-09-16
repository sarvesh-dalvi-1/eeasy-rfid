import 'dart:convert';

import 'package:eeasy_rfid/models/api_response.dart';
import 'package:eeasy_rfid/models/product.dart';

import 'package:http/http.dart' as http;

class RfidAPICollection {

  static const String authToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6ImpvaG5fc2Ftc3VuZ0BlZWFzeS5jbyIsIm5hbWUiOiJTYW1zdW5nIEpvaG4iLCJ1c2VyX2lkIjozOCwicm9sZSI6NSwic2VyaWFsX251bWJlciI6ImI1N2I3ZDNkMTJkOWU1ZDMiLCJpYXQiOjE2ODEyMDA2Njl9.1NfFbBrDaStc-YJDBh2OouTXjgdRZp09SyVn0VG56BY';
  static const String userSettingsAuthToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6Im1pa2VAY2FycmVmb3VyLmNvbSIsIm5hbWUiOiJNaWtlICAgIiwidXNlcl9pZCI6MTg3LCJyb2xlIjo1LCJzZXJpYWxfbnVtYmVyIjoiYjI2NzI2NzNiYmU0NDEwMiIsImlhdCI6MTY5NDg1NTc2NH0.4LUxRTSGOCHA2gmyS4xj3xOrHDD5l4QePJiCFF3x5TA';


  static Future<http.Response> getUserSettings() async {
    var response = await http.get(Uri.parse('https://bankfab.marshal-me.com/smepos/posStaff/configuration'), headers: {"Content-type": "application/json", "Authorization": "Bearer $userSettingsAuthToken"});
    return response;
  }

  static Future<APIResponse<Product?>> getProductFromEPC(String epc) async {
    var resp = await http.get(Uri.parse('https://bankfab.marshal-me.com/smepos/posStaff/posProductsDetailsByRFID?rfid=$epc'), headers: {
    "Authorization": "Bearer $authToken"
    });
    if(resp.statusCode == 200) {
      var decodedResp = jsonDecode(resp.body);
      if(decodedResp['status'] == true) {
        return APIResponse(data: Product.fromMap(decodedResp['data']));
      }
      else {
        return APIResponse(data: null, error: true, reasonPhrase: decodedResp['message']);
      }
    }
    else {
      return APIResponse(data: null, error: true, statusCode: resp.statusCode, reasonPhrase: resp.reasonPhrase ?? 'Unknown error occurred while fetching products');
    }
  }

}