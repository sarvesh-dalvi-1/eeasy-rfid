import 'dart:convert';

import 'package:eeasy_rfid/providers/rfid_read_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../Models/user_settings.dart';
import '../api_collection/eeasy_rfid_api.dart';
import '../util/constants.dart';

class AppStateProvider extends ChangeNotifier {

  String? transactionId;

  UserSettingsModel? userSettings;

  bool isRecordingOn = true;

  setIsRecordingOn(bool value, BuildContext context) {
    Fluttertoast.showToast(msg: 'Recording set to : $value');
    if(isRecordingOn == true) {
      Provider.of<RfidReadProvider>(context, listen: false).populateFinalRecTags();
      Navigator.push(context, CupertinoPageRoute(builder: (_) => Material(
          child: SafeArea(
              child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Start shopping', style: TextStyle(fontSize: 16)),
                        const SizedBox(height: 15),
                        ElevatedButton(
                            onPressed: () {
                              paymentProcess(context, false, 10000, 3).then((value) {
                                if(value['error'] == true) {
                                  Fluttertoast.showToast(msg: value['message']);
                                }
                                else {
                                  Constants.methodChannel.invokeMethod('openDoor', {}).then((value) {
                                    Navigator.pop(context);
                                  });
                                }
                              });
                            },
                            child: const Text('Proceed')
                        )
                      ]
                  )
              )
          )
      ))
    );
    }
    isRecordingOn = value;
    notifyListeners();
  }

  setUserSettings(UserSettingsModel value) {
    userSettings = value;
    notifyListeners();
  }


  Future<Map<String, dynamic>> paymentProcess(BuildContext context, bool txnStatusToggle, int totalAmount, int transType) async {

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
    var initAuthResp = await Constants.methodChannel.invokeMethod('vfiInitAuth', temp);
    await Fluttertoast.showToast(msg: 'Init Auth : ${initAuthResp['VFI_RespCode']} : ${initAuthResp['VFI_RespMess']}', toastLength: Toast.LENGTH_LONG);
    respCode = initAuthResp['VFI_RespCode'];
    respMess = initAuthResp['VFI_RespMess'];
    if(initAuthResp['VFI_RespCode'] == '000' || initAuthResp['VFI_RespCode'] == '00') {
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

    await Future.delayed(const Duration(seconds: 2));
    var getAuthResp = await Constants.methodChannel.invokeMethod('vfiGetAuth', temp);
    await Fluttertoast.showToast(msg: 'Get Auth : ${getAuthResp['VFI_RespCode']} : ${getAuthResp['VFI_RespMess']}');

    return {
      'error' : true,
      'code' : respCode,
      'message' : respMess
    };

  }

}