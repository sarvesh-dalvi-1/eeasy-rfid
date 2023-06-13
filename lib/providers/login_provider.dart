import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Models/user_settings.dart';
import '../api_collection/eeasy_rfid_api.dart';
import 'app_state_provider.dart';

class LoginProvider extends ChangeNotifier {
  bool loading = false;
  bool isTablet = true;
  static String currencyCode = '';
  static int decimalPlace = 0;


  Map<String, String> headers = {"Content-type": "application/json"};

  Future logIn(Map loginData, BuildContext context) async {
    setLoading(true);
    try {
      var response = await RfidAPICollection.login(loginData);
      if (response.statusCode == 200) {
        var jsonObject = json.decode(response.body);
        await setPermissions(jsonObject['servicePermission']);
        if (jsonObject['data'] != null) {
          try {
            print('Here : ${jsonObject["data"]}');
            (await SharedPreferences.getInstance()).setString('token', jsonObject["data"]);
            (await SharedPreferences.getInstance()).setString('userInfo/email', jsonObject["userInfo"]["email"]);
            (await SharedPreferences.getInstance()).setString('userInfo/name', jsonObject["userInfo"]["name"]);
            currencyCode = jsonObject['userInfo']['currency_code'];
            decimalPlace = jsonObject['userInfo']['decimal_place'];
            if (jsonObject['sessionData'].length > 0) {
              (await SharedPreferences.getInstance()).setString('sessionId', jsonObject['sessionData']['session_id']);
            } else {
              (await SharedPreferences.getInstance()).remove('sessionId');
            }
          }
          catch(e,trace) {
            Fluttertoast.showToast(msg: e.toString());
          }
          var resp = await RfidAPICollection.getUserSettings();
          if(resp.statusCode != 200) {
            setLoading(false);
            Fluttertoast.showToast(
                msg: resp.reasonPhrase ?? '',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 3,
                textColor: Colors.white,
                fontSize: 16.0);
            return false;
          }
          else {
            var decodedResponse = jsonDecode(resp.body);
            if(decodedResponse['status'] == true) {
              Provider.of<AppStateProvider>(context, listen: false).userSettings = UserSettingsModel.fromMap(decodedResponse['data']);
            }
            else {
              setLoading(false);
              Fluttertoast.showToast(
                  msg: jsonObject['data'],
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 3,
                  textColor: Colors.white,
                  fontSize: 16.0);
              return false;
            }
          }
          setLoading(false);
          return true;
        } else {
          setLoading(false);
          Fluttertoast.showToast(
              msg: jsonObject['message'],
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 3,
              backgroundColor: Colors.redAccent,
              textColor: Colors.white,
              fontSize: 16.0);
          return false;
        }
      } else if (response.statusCode == 500) {
        setLoading(false);
        Fluttertoast.showToast(
            msg: "Internal Server Error",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 3,
            backgroundColor: Colors.redAccent,
            textColor: Colors.white,
            fontSize: 16.0);
        return false;
      }
      setLoading(false);
      Fluttertoast.showToast(
          msg: "${response.statusCode} Server Connection Closed",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 3,
          backgroundColor: Colors.redAccent,
          textColor: Colors.white,
          fontSize: 16.0);
      return false;
    } on SocketException catch (e) {
      print(e.toString());
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  setLoading(bool value) {
    loading = value;
    notifyListeners();
  }

  setDeviceType(bool value) {
    isTablet = value;
  }

  setPermissions(List<dynamic> permissionsList) async {
    for (var permission in permissionsList) {
      (await SharedPreferences.getInstance()).remove(permission['service_name']);
      (await SharedPreferences.getInstance()).setString(
        permission['service_name'],
        permission['permission_status'].toString(),
      );
    }
  }
}
