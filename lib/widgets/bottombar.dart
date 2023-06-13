import 'package:eeasy_rfid/widgets/primary_button.dart';
import 'package:eeasy_rfid/widgets/secondary_button.dart';
import 'package:flutter/material.dart';

class CBottomBar extends StatelessWidget {

  final bool hasPrimary, hasSecondary;
  final String primaryText, secondaryText;
  final VoidCallback? onPrimaryTap, onSecondaryTap;

  const CBottomBar({Key? key, this.hasPrimary = false, this.hasSecondary = false, this.primaryText = '', this.secondaryText = '', this.onPrimaryTap, this.onSecondaryTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xffD9D9D9), width: 1))),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        children: [
          hasSecondary ? SecondaryButton(text: secondaryText, onTap: onSecondaryTap) : const SizedBox(),
          const Expanded(child: SizedBox()),
          hasPrimary ? PrimaryButton(text: primaryText, onTap: onPrimaryTap) : const SizedBox()
        ],
      ),
    );
  }
}
