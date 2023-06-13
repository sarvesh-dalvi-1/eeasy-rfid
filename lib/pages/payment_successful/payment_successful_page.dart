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
            const Expanded(child: SizedBox()),
            CBottomBar(hasSecondary: true, secondaryText: 'Close Session', onPrimaryTap: () => showDialog(context: context, builder: (_) => const SizedBox()))
          ],
        ),
      ),
    );
  }
}
