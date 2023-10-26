import 'package:eeasy_rfid/pages/start_shopping/start_shopping_page.dart';
import 'package:eeasy_rfid/providers/rfid_read_provider.dart';
import 'package:eeasy_rfid/util/theme.dart';
import 'package:eeasy_rfid/wrapper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../util/constants.dart';
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
            Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset('assets/success.png'),
                      const SizedBox(height: 20),
                      const Text('Payment Successful', style: TextStyle(fontSize: 18, color: AppTheme.baseColor))
                    ],
                  ),
                )
            ),
            CBottomBar(hasSecondary: true, secondaryText: 'Done', onSecondaryTap: () async {
                await Constants.methodChannel.invokeMethod('readTags');
                Provider.of<RfidReadProvider>(context, listen: false).tagsRemoved = [];
                Navigator.pushReplacement(context, CupertinoPageRoute(builder: (_) => const StartShoppingPage()));
            })
          ],
        ),
      ),
    );
  }
}
