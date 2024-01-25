import 'dart:async';

import 'package:eeasy_rfid/pages/home/home.dart';
import 'package:eeasy_rfid/providers/app_state_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../../providers/door_status_provider.dart';
import '../../util/constants.dart';
import '../../util/streams.dart';
import '../../widgets/appbar.dart';

class StartShoppingPage extends StatefulWidget {
  const StartShoppingPage({Key? key}) : super(key: key);

  @override
  State<StartShoppingPage> createState() => _StartShoppingPageState();
}

class _StartShoppingPageState extends State<StartShoppingPage> {

  int state = 0;   /// 0 -> Start shopping button   1 -> Loading    2 -> Animation

  late StreamSubscription<int> subscription;

  @override
  void initState() {
    subscription = AppStreams.initAuthStatusStream.listen(_fun);
    super.initState();
  }


  @override
  void dispose() {
    _cancelSubscription();
    super.dispose();
  }


  _fun(event) {
    if(event == 1 && state == 1) {
      setState(() {
        state = 0;
      });
    }
    if(event == 0 && state == 1) {
      setState(() {
        state = 2;
      });
    }
  }

  _cancelSubscription() async {
    await subscription.cancel();
  }

  @override
  Widget build(BuildContext context) {

    return Material(
        child: SafeArea(
            child: Column(
                children: [
                  const CAppbar(hasSettingsButton: true, hasInverseButton: true),
                  Expanded(
                    child: Center(
                      child: Center(
                        child: state == 0 ? ElevatedButton(
                            onPressed: () {
                              setState(() { state = 1; });
                              Future.delayed(const Duration(seconds: 1)).then((value) async {
                                Provider.of<AppStateProvider>(context, listen: false).paymentProcess(context, false, 10000, 3, notifyInitAuthSuccess: true).then((value) {
                                  if(value['error'] == true) {
                                    Fluttertoast.showToast(msg: value['message']);
                                  }
                                  else {
                                    Fluttertoast.showToast(msg: 'Pre Auth Resp : ${value['error']} : ${value['code']}');
                                    Constants.methodChannel.invokeMethod('openDoor', {}).then((value) {
                                      Fluttertoast.showToast(msg: 'Open Door resp : $value');
                                      Navigator.push(context, CupertinoPageRoute(builder: (_) => const HomePage()));
                                      Future.delayed(const Duration(seconds: 4), () {
                                        Provider.of<DoorStatusProvider>(context, listen: false).safeToCallDoorStatusCheck = true;
                                      });
                                    });
                                  }
                                });
                              });
                            },
                            style: ElevatedButton.styleFrom(fixedSize: Size(MediaQuery.of(context).size.width * 0.3, MediaQuery.of(context).size.height * 0.35), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), backgroundColor: const Color(0xff172F5D)),
                            child: const Text('START SHOPPING', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white))
                        ) : state == 1 ? const Center(child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              height: 80, width: 80,
                                child: CircularProgressIndicator()
                            ),
                          ],
                        )) : Center(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 50.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Lottie.asset('assets/start_shopping.json', height: MediaQuery.of(context).size.height * 0.4, fit: BoxFit.cover),
                                const SizedBox(height: 15),
                                const Text('Tap card to open fridge', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w600))
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                ]
            )
        )
    );

  }

}

