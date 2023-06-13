import 'package:eeasy_rfid/api_collection/eeasy_rfid_api.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert';

import '../models/session.dart';


class SessionProvider extends ChangeNotifier {
  SessionModel? sessionModel;
  static bool loading = false;
  getSessionDetails(Map data) async {
    setLoading(true);
    var response = await RfidAPICollection.getSessionId(data);
    if (response.statusCode == 200) {
      var jsonObject = json.decode(response.body);
      SessionModel data = SessionModel.fromJson(jsonObject);
      sessionModel = data;
      (await SharedPreferences.getInstance()).setString('sessionId', sessionModel!.data.sessionId);
      setLoading(false);
      notifyListeners();
      return true;
    } else {
      Fluttertoast.showToast(msg: "Session Not Created: ${json.decode(response.body)['data']}");
      setLoading(false);
      return false;
    }
  }

  setLoading(bool value) {
    loading = value;
    notifyListeners();
  }
}
