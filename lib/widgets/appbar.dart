import 'package:eeasy_rfid/pages/settings/settings_page.dart';
import 'package:eeasy_rfid/providers/app_state_provider.dart';
import 'package:eeasy_rfid/providers/checkout_provider.dart';
import 'package:eeasy_rfid/util/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
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
          hasSettingsButton ? const SizedBox(width: 20) : const SizedBox(),
          hasSettingsButton ? InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage()));
              },
              child: const Icon(Icons.settings)
          ) : const SizedBox(),
          const SizedBox(width: 30),
          hasInverseButton ? InkWell(
              onTap: () {
                Provider.of<AppStateProvider>(context, listen: false).setIsRecordingOn(!(Provider.of<AppStateProvider>(context, listen: false).isRecordingOn), context);
              },
              child: Icon(Icons.record_voice_over_rounded, color: Provider.of<AppStateProvider>(context).isRecordingOn ? AppTheme.baseColor : Colors.grey)
          ) : const SizedBox(),
          hasInverseButton ? InkWell(
              onTap: () {
                double amount = 0;
                for(Product product in Provider.of<CheckoutProvider>(context, listen: false).products) {
                  amount += (double.parse(product.discountedPrice) * 100).round();
                }
                Provider.of<AppStateProvider>(context, listen: false).paymentProcess1(context, false, amount.toInt(), 5);
              },
              child: Icon(Icons.exit_to_app)
          ) : const SizedBox(),
        ],
      ),
    );
  }
}
