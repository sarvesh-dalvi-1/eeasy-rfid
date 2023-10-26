import 'dart:convert';

import 'package:eeasy_rfid/pages/start_shopping/start_shopping_page.dart';
import 'package:eeasy_rfid/providers/rfid_read_provider.dart';
import 'package:eeasy_rfid/util/streams.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../Models/user_settings.dart';
import '../api_collection/eeasy_rfid_api.dart';
import '../util/constants.dart';
import 'door_status_provider.dart';

class AppStateProvider extends ChangeNotifier {

  String? transactionId;

  UserSettingsModel? userSettings;

  bool isRecordingOn = true;

  setIsRecordingOn(bool value, BuildContext context) {
    if(isRecordingOn == true) {
      Provider.of<RfidReadProvider>(context, listen: false).populateFinalRecTags();
      Navigator.pushReplacement(context, CupertinoPageRoute(builder: (_) => const StartShoppingPage()));
    }
    isRecordingOn = value;
    notifyListeners();
  }

  setUserSettings(UserSettingsModel value) {
    userSettings = value;
    notifyListeners();
  }


  Future<Map<String, dynamic>> paymentProcess(BuildContext context, bool txnStatusToggle, int totalAmount, int transType, {bool notifyInitAuthSuccess = false}) async {

    String respCode = '';
    String respMess = '';

    var resp = await RfidAPICollection.getUserSettings();

    if(resp.statusCode != 200) {
      return {
        'error' : true,
        'code' : 0,
        'message' : 'Unable to fetch user settings'
      };
    }

    Provider.of<AppStateProvider>(context, listen: false).userSettings = UserSettingsModel.fromMap(jsonDecode(resp.body)['data']);

    var initResp = await Constants.methodChannel.invokeMethod('vfiInit', Provider.of<AppStateProvider>(context, listen: false).userSettings!.appToAppData?.toMap() as Map<String, String>);
    await Fluttertoast.showToast(msg: 'Init : ${initResp['VFI_RespCode']} : ${initResp['VFI_RespMess']}');
    Map<String, String> temp = Provider.of<AppStateProvider>(context, listen: false).userSettings!.appToAppData?.toMap();
    temp.addAll({'transaction_type' : transType.toString()});
    temp.addAll({'transaction_amount' : totalAmount.toString()});
    temp.addAll({'payment_step' : "1"});
    temp.addAll({'cash_amount' : '0'});
    var initAuthResp = await Constants.methodChannel.invokeMethod('vfiInitAuth', temp);
    await Fluttertoast.showToast(msg: 'Init Auth : ${initAuthResp['VFI_RespCode']} : ${initAuthResp['VFI_RespMess']}', toastLength: Toast.LENGTH_LONG);
    respCode = initAuthResp['VFI_RespCode'];
    respMess = initAuthResp['VFI_RespMess'];
    if(initAuthResp['VFI_RespCode'] == '000' || initAuthResp['VFI_RespCode'] == '00') {
      if(notifyInitAuthSuccess == true) {
        AppStreams.initAuthStatusStreamController.sink.add(0);
      }
      await Future.delayed(const Duration(seconds: 2));
      var getAuthResp = await Constants.methodChannel.invokeMethod('vfiGetAuth', temp);
      await Fluttertoast.showToast(msg: 'Get Auth : ${getAuthResp['VFI_RespCode']} : ${getAuthResp['VFI_RespMess']}');
      respCode = getAuthResp['VFI_RespCode'];
      respMess = getAuthResp['VFI_RespMess'];
      if(getAuthResp['VFI_RespCode'] == '000' || getAuthResp['VFI_RespCode'] == '00') {
        if(txnStatusToggle) {
          await Future.delayed(const Duration(seconds: 2));
          var txnStatusResp = await Constants.methodChannel.invokeMethod('vfiTxnStatus', temp);
          await Fluttertoast.showToast(msg: 'Txn Status : ${txnStatusResp['VFI_RespCode']} : ${txnStatusResp['VFI_RespMess']}', toastLength: Toast.LENGTH_LONG);
          respCode = txnStatusResp['VFI_RespCode'];
          respMess = txnStatusResp['VFI_RespMess'];
          if(txnStatusResp['VFI_RespCode'] == '000' || txnStatusResp['VFI_RespCode'] == '00') {
            return {
              'error' : false,
              'code' : respCode,
              'message' : respMess
            };
          }
        }
        else {
          return {
            'error' : false,
            'code' : respCode,
            'message' : respMess
          };
        }
      }
    }

    if(notifyInitAuthSuccess == true) {
      if(initAuthResp['VFI_RespCode'] != '000' && initAuthResp['VFI_RespCode'] != '00') {
        AppStreams.initAuthStatusStreamController.sink.add(1);
      }
    }

    return {
      'error' : true,
      'code' : respCode,
      'message' : respMess
    };

  }

  Future<Map<String, dynamic>> paymentProcess1(BuildContext context, bool txnStatusToggle, int totalAmount, int transType) async {

    String respCode = '';
    String respMess = '';

    var resp = await RfidAPICollection.getUserSettings();

    if(resp.statusCode != 200) {
      return {
        'error' : true,
        'code' : 0,
        'message' : 'Unable to fetch user settings'
      };
    }

    Provider.of<AppStateProvider>(context, listen: false).userSettings = UserSettingsModel.fromMap(jsonDecode(resp.body)['data']);

    var initResp = await Constants.methodChannel.invokeMethod('vfiInit', Provider.of<AppStateProvider>(context, listen: false).userSettings!.appToAppData?.toMap() as Map<String, String>);
    await Fluttertoast.showToast(msg: 'Init : ${initResp['VFI_RespCode']} : ${initResp['VFI_RespMess']}');
    Map<String, String> temp = Provider.of<AppStateProvider>(context, listen: false).userSettings!.appToAppData?.toMap();
    temp.addAll({'transaction_type' : transType.toString()});
    temp.addAll({'transaction_amount' : totalAmount.toString()});
    temp.addAll({'cash_amount' : '0'});
    temp.addAll({'payment_step' : "2"});

    await Future.delayed(const Duration(seconds: 2));
    var initAuthResp = await Constants.methodChannel.invokeMethod('vfiInitAuth', temp);
    await Fluttertoast.showToast(msg: 'Init Auth : ${initAuthResp['VFI_RespCode']} : ${initAuthResp['VFI_RespMess']}', toastLength: Toast.LENGTH_LONG);
    respCode = initAuthResp['VFI_RespCode'];
    respMess = initAuthResp['VFI_RespMess'];
    if(initAuthResp['VFI_RespCode'] == '000' || initAuthResp['VFI_RespCode'] == '00') {
      await Future.delayed(const Duration(seconds: 2));
      var getAuthResp = await Constants.methodChannel.invokeMethod('vfiGetAuth', temp);
      await Fluttertoast.showToast(msg: 'Get Auth : ${getAuthResp['VFI_RespCode']} : ${getAuthResp['VFI_RespMess']}');
      if(getAuthResp['VFI_RespCode'] == '000' || getAuthResp['VFI_RespCode'] == '00') {
        return {
          'error' : false,
          'code' : respCode,
          'message' : respMess
        };
      }
    }

    return {
      'error' : true,
      'code' : respCode,
      'message' : respMess
    };

  }

}