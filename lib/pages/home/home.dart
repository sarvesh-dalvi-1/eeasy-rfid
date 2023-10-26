import 'dart:async';
import 'dart:convert';

import 'package:eeasy_rfid/pages/checkout/checkout_page.dart';
import 'package:eeasy_rfid/pages/home/widgets/empty_cart_widget.dart';
import 'package:eeasy_rfid/pages/home/widgets/final_amount_widget.dart';
import 'package:eeasy_rfid/pages/home/widgets/product_card.dart';
import 'package:eeasy_rfid/providers/app_state_provider.dart';
import 'package:eeasy_rfid/providers/door_status_provider.dart';
import 'package:eeasy_rfid/providers/rfid_read_provider.dart';
import 'package:eeasy_rfid/util/constants.dart';
import 'package:eeasy_rfid/util/streams.dart';
import 'package:eeasy_rfid/widgets/appbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

import '../../Models/user_settings.dart';
import '../../api_collection/eeasy_rfid_api.dart';
import '../../providers/checkout_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  bool liveDoorStatus = false;
  bool liveDoorStatusOld = false;

  bool pseudoInit = true;

  late StreamSubscription<int> doorCloseDetectStreamSubscription;


  @override
  void dispose() {
    _cancelSubscription();
    super.dispose();
  }

  _cancelSubscription() async {
    await doorCloseDetectStreamSubscription.cancel();
  }

  _fun(event) async {
    if(event == 1) {
      Fluttertoast.showToast(msg: 'Door close detected');
      await Constants.methodChannel.invokeMethod('closeDoor', {});
      Provider.of<DoorStatusProvider>(context, listen: false).safeToCallDoorStatusCheck = false;
      await Provider.of<CheckoutProvider>(context, listen: false).populateCheckoutProductsFromTags(Provider.of<RfidReadProvider>(context, listen: false).tagsRemoved);
      /**Provider.of<RfidReadProvider>(context, listen: false).finalRecordedTags = Provider.of<RfidReadProvider>(context, listen: false).tagsRemoved.toList();
      Provider.of<RfidReadProvider>(context, listen: false).tagsRemoved = [];
      Provider.of<RfidReadProvider>(context, listen: false).recordedTags = []; */
      //showDialog(context: context, builder: (_) => const ProductsSelectionConfirmWidget());
      await Constants.methodChannel.invokeMethod('stopTagsRead', {});
      Navigator.pushReplacement(context, CupertinoPageRoute(builder: (_) => const CheckoutPage()));
    }
  }

  @override
  Widget build(BuildContext context) {

    if(pseudoInit == true) {
      if(Provider.of<AppStateProvider>(context, listen: false).isRecordingOn == true) {
        Provider.of<RfidReadProvider>(context, listen: false).init();
        initDoorCall(context);
      }
      else {
        Provider.of<RfidReadProvider>(context, listen: false).tagsRemoved = [];
      }
      doorCloseDetectStreamSubscription = AppStreams.doorCloseDetectedStream.listen(_fun);

      pseudoInit = false;
    }


    return SafeArea(
      child: Material(
        child: Column(
          children: [
            const CAppbar(hasSettingsButton: true, hasInverseButton: true),
            Expanded(
                child: Row(
                  children: [
                    Expanded(
                      flex: 7,
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          Consumer<RfidReadProvider>(
                            builder: (context, provider, child) {
                              return Provider.of<AppStateProvider>(context).isRecordingOn ? (provider.recordedTags.isEmpty ? const EmptyCardWidget(isRecordingOn: true) : ListView(
                                  children: provider.recordedTags.map((e) => ProductCard(epc: e, key: ValueKey(e)) as Widget).toList()..add(const SizedBox(height: 50) as Widget)
                              )) : (provider.tagsRemoved.isEmpty ? const EmptyCardWidget(isRecordingOn: false) : ListView(
                              children: provider.tagsRemoved.map((e) => ProductCard(epc: e, key: ValueKey(e)) as Widget).toList()..add(const SizedBox(height: 50) as Widget)
                              ));
                            },
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            child: FinalAmountWidget(),
                          )
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              Center(
                                child: Consumer<AppStateProvider>(
                                  builder: (context, prov, child) {
                                    return prov.isRecordingOn ? ElevatedButton(
                                      onPressed: () {
                                        Provider.of<AppStateProvider>(context, listen: false).setIsRecordingOn(false, context);
                                      },
                                      style: ElevatedButton.styleFrom(fixedSize: Size(constraints.constrainWidth() * 0.75, constraints.constrainHeight() * 0.4), foregroundColor: Colors.black.withOpacity(0.5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), backgroundColor: const Color(0xff172F5D)),
                                      child: const Text('SETUP', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600, color: Colors.white))
                                    ) : const Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text('Fridge Door is Open', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                                        Text('Remove products and close door to proceed', style: TextStyle(fontSize: 14))
                                      ],
                                    );
                                  }
                                ),
                              ),
                              Positioned(
                                bottom: 20,
                                child: SizedBox(
                                  width: constraints.constrainWidth() - 40,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: ElevatedButton(
                                          onPressed: () async {
                                              var resp = await Constants.methodChannel.invokeMethod('openDoor', {});
                                              Fluttertoast.showToast(msg: 'Open Door resp : $resp');
                                              Future.delayed(const Duration(seconds: 2), () {
                                                Provider.of<DoorStatusProvider>(context, listen: false).safeToCallDoorStatusCheck = true;
                                              });
                                          },
                                          style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade300, foregroundColor: Colors.black.withOpacity(0.5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))),
                                          child: const Text('Open Door', style: TextStyle(color: Color(0xff172F5D), fontWeight: FontWeight.w500)),
                                        ),
                                      ),
                                      const SizedBox(width: 20),
                                      Expanded(
                                        flex: 1,
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            var resp = await Constants.methodChannel.invokeMethod('closeDoor', {});
                                            Fluttertoast.showToast(msg: 'Close Door resp : $resp');
                                          },
                                          style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade300, foregroundColor: Colors.black.withOpacity(0.5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))),
                                          child: const Text('Close Door', style: TextStyle(color: Color(0xff172F5D), fontWeight: FontWeight.w500)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          );
                        }
                      )/*Consumer<RfidReadProvider>(
                        builder: (context, provider, child) {
                          return SingleChildScrollView(
                            child: Column(
                              children: [
                                Text('Live scan : ${provider.tagsScanned}'),
                                const SizedBox(height: 30),
                                Text('Recorded Tags'),
                                Column(
                                  children: Provider.of<RfidReadProvider>(context).recordedTags.map((e) => Text(e)).toList(),
                                ),
                                const SizedBox(height: 30),
                                Text('Final recorded tags'),
                                Column(
                                  children: Provider.of<RfidReadProvider>(context).finalRecordedTags.map((e) => Text(e)).toList(),
                                ),
                                const SizedBox(height: 30),
                                Text('Tags removed'),
                                Column(
                                  children: Provider.of<RfidReadProvider>(context).tagsRemoved.map((e) => Text(e)).toList(),
                                ),
                              ],
                            )
                          );
                        }
                      ), */
                    )
                  ],
                )
            ),
            //CBottomBar()
          ],
        ),
      ),
    );
  }

  initDoorCall(BuildContext context) async {

    var resp = await RfidAPICollection.getUserSettingsRFID();

    if(resp.statusCode != 200) {
      return {
        'error' : true,
        'code' : 0,
        'message' : 'Unable to fetch user settings'
      };
    }

    Provider.of<AppStateProvider>(context, listen: false).userSettings = UserSettingsModel.fromMap(jsonDecode(resp.body)['data']);

    Fluttertoast.showToast(msg: jsonEncode(Provider.of<AppStateProvider>(context, listen: false).userSettings!.rfidData!.toMap() as Map<String, String>));

    var box = await Hive.openBox('logs');
    box.add('${DateTime.now()} : ${jsonEncode(Provider.of<AppStateProvider>(context, listen: false).userSettings!.rfidData!.toMap() as Map<String, String>)}');

    //Provider.of<AppStateProvider>(context, listen: false).userSettings!.rfidData?.toMap() as Map<String, String>

    var initResp = await Constants.methodChannel.invokeMethod('vfiDoorInit', Provider.of<AppStateProvider>(context, listen: false).userSettings!.rfidData?.toMap() as Map<String, String>);

    Fluttertoast.showToast(msg: 'Init door done');

  }
}
