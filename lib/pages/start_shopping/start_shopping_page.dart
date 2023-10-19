import 'package:eeasy_rfid/providers/app_state_provider.dart';
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

  @override
  void initState() {
    /*AppStreams.initAuthStatusStreamController.stream.asBroadcastStream().listen((event) {
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
    }); */
    super.initState();
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
                        child: state != 2 ? ElevatedButton(
                            onPressed: state == 0 ? () {
                              setState(() { state = 1; });
                             Provider.of<AppStateProvider>(context, listen: false).paymentProcess(context, false, 10000, 3, notifyInitAuthSuccess: true).then((value) {
                                if(value['error'] == true) {
                                  Fluttertoast.showToast(msg: value['message']);
                                }
                                else {
                                  Fluttertoast.showToast(msg: 'Pre Auth Resp : ${value['error']} : ${value['code']}');
                                  Constants.methodChannel.invokeMethod('openDoor', {}).then((value) {
                                    Fluttertoast.showToast(msg: 'Open Door resp : $value');
                                    Navigator.pop(context);
                                    Future.delayed(const Duration(seconds: 4), () {
                                      Provider.of<DoorStatusProvider>(context, listen: false).safeToCallDoorStatusCheck = true;
                                    });
                                  });
                                }
                              });
                            } : () { },
                            style: ElevatedButton.styleFrom(fixedSize: Size(MediaQuery.of(context).size.width * 0.3, MediaQuery.of(context).size.height * 0.35), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), backgroundColor: const Color(0xff172F5D)),
                            child: state == 0 ? const Text('START SHOPPING', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white)) : const CircularProgressIndicator(color: Colors.white)
                        ) : Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Lottie.asset('assets/start_shopping.json', height: MediaQuery.of(context).size.height * 0.65, fit: BoxFit.fitHeight),
                              const SizedBox(height: 15),
                              const Text('Tap card to open fridge', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500))
                            ],
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

