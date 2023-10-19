import 'dart:convert';

import 'package:eeasy_rfid/pages/home/widgets/empty_cart_widget.dart';
import 'package:eeasy_rfid/pages/home/widgets/final_amount_widget.dart';
import 'package:eeasy_rfid/pages/home/widgets/product_card.dart';
import 'package:eeasy_rfid/pages/home/widgets/products_selection_confirm.dart';
import 'package:eeasy_rfid/providers/app_state_provider.dart';
import 'package:eeasy_rfid/providers/door_status_provider.dart';
import 'package:eeasy_rfid/providers/rfid_read_provider.dart';
import 'package:eeasy_rfid/util/constants.dart';
import 'package:eeasy_rfid/widgets/appbar.dart';
import 'package:eeasy_rfid/widgets/primary_button.dart';
import 'package:eeasy_rfid/widgets/secondary_button.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

import '../../Models/user_settings.dart';
import '../../api_collection/eeasy_rfid_api.dart';
import '../../models/product.dart';
import '../../providers/checkout_provider.dart';
import '../../widgets/bottombar.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  bool liveDoorStatus = false;
  bool liveDoorStatusOld = false;

  bool pseudoInit = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    if(pseudoInit == true) {
      Provider.of<RfidReadProvider>(context, listen: false).init(context);
      initDoorCall(context);
      Provider.of<DoorStatusProvider>(context, listen: false).doorCloseDetectedStream.stream.asBroadcastStream().listen((event) async {
        if(event == 1) {
          Fluttertoast.showToast(msg: 'Door close detected');
          await Constants.methodChannel.invokeMethod('closeDoor', {});
          Provider.of<DoorStatusProvider>(context, listen: false).safeToCallDoorStatusCheck = false;
          await Provider.of<CheckoutProvider>(context, listen: false).populateCheckoutProductsFromTags(Provider.of<RfidReadProvider>(context, listen: false).tagsRemoved);
          showDialog(context: context, builder: (_) => const ProductsSelectionConfirmWidget());
        }
      });
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
                                child: ElevatedButton(
                                  onPressed: () {
                                    Provider.of<AppStateProvider>(context, listen: false).setIsRecordingOn(!(Provider.of<AppStateProvider>(context, listen: false).isRecordingOn), context);
                                  },
                                  style: ElevatedButton.styleFrom(fixedSize: Size(constraints.constrainWidth() * 0.75, constraints.constrainHeight() * 0.4), foregroundColor: Colors.black.withOpacity(0.5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), backgroundColor: const Color(0xff172F5D)),
                                  child: const Text('SETUP', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600, color: Colors.white))
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
