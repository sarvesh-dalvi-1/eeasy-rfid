import 'package:eeasy_rfid/pages/settings/settings_page.dart';
import 'package:eeasy_rfid/providers/app_state_provider.dart';
import 'package:eeasy_rfid/providers/checkout_provider.dart';
import 'package:eeasy_rfid/util/constants.dart';
import 'package:eeasy_rfid/util/theme.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/door_status_provider.dart';
import 'clock.dart';

class CAppbar extends StatelessWidget {

  final bool hasSettingsButton;
  final bool hasInverseButton;
  final bool hasExitButton;

  const CAppbar({Key? key, this.hasSettingsButton = false, this.hasInverseButton = false, this.hasExitButton = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xffD9D9D9), width: 1))),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        children: [
          Image.asset('assets/eeasy_logo.png', height: 40),
          const Expanded(child: SizedBox()),
          const ClockWidget(),
          hasSettingsButton ? const SizedBox(width: 30) : const SizedBox(),
          hasSettingsButton ? InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage()));
              },
              child: const Icon(Icons.settings)
          ) : const SizedBox(),
          const SizedBox(width: 30),
          /*hasInverseButton ? InkWell(
              onTap: () {
                Provider.of<AppStateProvider>(context, listen: false).setIsRecordingOn(!(Provider.of<AppStateProvider>(context, listen: false).isRecordingOn), context);
              },
              child: Icon(Icons.record_voice_over_rounded, color: Provider.of<AppStateProvider>(context).isRecordingOn ? AppTheme.baseColor : Colors.grey)
          ) : const SizedBox(),
          const SizedBox(width: 30), */
          /*hasInverseButton ? InkWell(
              onTap: () async {
                var resp = await Constants.methodChannel.invokeMethod('openDoor', {});
                Fluttertoast.showToast(msg: 'Open Door resp : $resp');
                Future.delayed(const Duration(seconds: 2), () {
                  Provider.of<DoorStatusProvider>(context, listen: false).safeToCallDoorStatusCheck = true;
                });
              },
              child: const Icon(Icons.open_in_new)
          ) : const SizedBox(),
          const SizedBox(width: 30),
          hasInverseButton ? InkWell(
              onTap: () async {
                var resp = await Constants.methodChannel.invokeMethod('closeDoor', {});
                Fluttertoast.showToast(msg: 'Close Door resp : $resp');
              },
              child: const Icon(Icons.open_in_new_off)
          ) : const SizedBox(),
          const SizedBox(width: 30), */
        ],
      ),
    );
  }
}
