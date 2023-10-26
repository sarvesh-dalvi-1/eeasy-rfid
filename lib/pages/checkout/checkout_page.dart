import 'dart:convert';

import 'package:eeasy_rfid/Models/user_settings.dart';
import 'package:eeasy_rfid/api_collection/eeasy_rfid_api.dart';
import 'package:eeasy_rfid/models/product.dart';
import 'package:eeasy_rfid/pages/home/widgets/product_card.dart';
import 'package:eeasy_rfid/pages/payment_successful/payment_successful_page.dart';
import 'package:eeasy_rfid/providers/checkout_provider.dart';
import 'package:eeasy_rfid/util/constants.dart';
import 'package:eeasy_rfid/util/data.dart';
import 'package:eeasy_rfid/widgets/appbar.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../../providers/app_state_provider.dart';
import '../../providers/rfid_read_provider.dart';
import '../../widgets/bottombar.dart';

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    var checkoutProvider = Provider.of<CheckoutProvider>(context, listen: false);

    int totalAmount = 0;
    double totalAmountDisplay = 0;

    for(Product product in Provider.of<CheckoutProvider>(context, listen: false).products) {
      totalAmount += (double.parse(product.discountedPrice) * 100).round();
      totalAmountDisplay += double.parse(product.discountedPrice);
    }

    Future.delayed(const Duration(seconds: 1)).then((value) async {
      var resp = await Provider.of<AppStateProvider>(context, listen: false).paymentProcess1(context, false, totalAmount.toInt(), 4);
      if(resp['error'] == true) {
        Fluttertoast.showToast(msg: 'Error : ${resp['code']} : ${resp['message']}');
      }
      else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const PaymentSuccessfulPage()));
      }
    });





    return SafeArea(
      child: Material(
        child: Column(
          children: [
            const CAppbar(),
            Expanded(
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Text('Pay with Card/Contactless', style: TextStyle(color: Color(0xff000C38), fontSize: 20, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 30),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 15.0),
                              child: Row(
                                children: [
                                  Text('Subtotal (${checkoutProvider.products.length} Items)', style: const TextStyle(fontSize: 18, color: Color(0xff6A7383), fontWeight: FontWeight.w500)),
                                  const Expanded(child: SizedBox()),
                                  Text('AED ${totalAmountDisplay.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, color: Color(0xff30313D), fontWeight: FontWeight.w600))
                                ],
                              ),
                            ),
                            Container(width: double.infinity, height: 1, color: const Color(0xffD9D9D9)),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(Provider.of<CheckoutProvider>(context).products.length, (index) => LoadedProductCard(product: Provider.of<CheckoutProvider>(context).products[index]))
                            ),
                            Container(width: double.infinity, height: 1, color: const Color(0xffD9D9D9)),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 15.0),
                              child: Row(
                                children: [
                                  const Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('Total', style: TextStyle(fontSize: 18, color: Color(0xff6A7383), fontWeight: FontWeight.w500)),
                                      SizedBox(height: 5),
                                      Text('including 5% VAT')
                                    ],
                                  ),
                                  const Expanded(child: SizedBox()),
                                  Text('AED ${(totalAmountDisplay + (totalAmountDisplay * (5/100))).toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, color: Color(0xff30313D), fontWeight: FontWeight.w600))
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: 1, height: double.infinity,
                      color: const Color(0xffD9D9D9),
                    ),
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Image.asset('assets/processing.png'),
                            const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Please follow directions on card reader', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20)),
                                SizedBox(height: 5),
                                Text('waiting for terminal')
                              ],
                            )
                          ],
                        ),
                      )
                    ),
                  ],
                )
            ),
            CBottomBar(hasSecondary: true, secondaryText: 'Back', onPrimaryTap: () => Navigator.pop(context))
          ],
        ),
      ),
    );
  }

}
