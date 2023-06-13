import 'package:eeasy_rfid/util/theme.dart';
import 'package:eeasy_rfid/wrapper.dart';
import 'package:flutter/material.dart';

import '../../widgets/appbar.dart';
import '../../widgets/bottombar.dart';

class PaymentSuccessfulPage extends StatelessWidget {
  const PaymentSuccessfulPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Material(
        child: Column(
          children: [
            const CAppbar(),
            const Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Payment Successful', style: TextStyle(fontSize: 18, color: AppTheme.baseColor))
                    ],
                  ),
                )
            ),
            CBottomBar(hasSecondary: true, secondaryText: 'Done', onSecondaryTap: () {
              for(int i=0; i<3; i++) {
                Navigator.pop(context);
              }
            })
          ],
        ),
      ),
    );
  }
}
