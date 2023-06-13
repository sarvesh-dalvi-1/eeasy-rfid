import 'package:eeasy_rfid/pages/checkout/checkout_page.dart';
import 'package:eeasy_rfid/providers/checkout_provider.dart';
import 'package:eeasy_rfid/widgets/secondary_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/rfid_read_provider.dart';
import '../../widgets/appbar.dart';
import '../../widgets/bottombar.dart';

class PaperbagDecisionPage extends StatelessWidget {
  const PaperbagDecisionPage({Key? key}) : super(key: key);

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
                      const Text('Would you like a paper bag', style: TextStyle(color: Color(0xff000C38), fontSize: 24, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 5),
                      const Text.rich(TextSpan(
                        children: [
                          TextSpan(text: 'AED 0.25', style: TextStyle(fontWeight: FontWeight.w600)),
                          TextSpan(text: ' per bag', style: TextStyle(color: Colors.grey))
                        ]
                      )),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            onTap: () { },
                            child: Container(
                                width: 270, height: 170,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: const Color(0xff172F5D)
                              ),
                              child: const Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.shopping_bag_outlined, size: 24, color: Colors.white),
                                    SizedBox(height: 10),
                                    Text('Yes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white))
                                  ],
                                ),
                              )
                            ),
                          ),
                          const SizedBox(width: 15),
                          InkWell(
                            onTap: () async {
                              Provider.of<CheckoutProvider>(context, listen: false).populateCheckoutProductsFromTags(Provider.of<RfidReadProvider>(context, listen: false).tags);
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckoutPage()));
                            },
                            child: Container(
                              width: 270, height: 170,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white,
                                  border: Border.all(color: const Color(0xffD0D5DD), width: 1)
                              ),
                              child: const Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.arrow_forward, size: 24),
                                    SizedBox(height: 10),
                                    Text('No, I will use my own bag', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600))
                                  ],
                                ),
                              )
                            ),
                          )
                        ],
                      )

                    ],
                  ),
                )
            ),
            CBottomBar(hasPrimary: false, primaryText: 'Continue', onPrimaryTap: () => showDialog(context: context, builder: (_) => const SizedBox()))
          ],
        ),
      ),
    );
  }
}
