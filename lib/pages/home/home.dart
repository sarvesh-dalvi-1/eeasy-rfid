import 'package:eeasy_rfid/pages/home/widgets/empty_cart_widget.dart';
import 'package:eeasy_rfid/pages/home/widgets/final_amount_widget.dart';
import 'package:eeasy_rfid/pages/home/widgets/product_card.dart';
import 'package:eeasy_rfid/pages/home/widgets/products_selection_confirm.dart';
import 'package:eeasy_rfid/providers/app_state_provider.dart';
import 'package:eeasy_rfid/providers/door_status_provider.dart';
import 'package:eeasy_rfid/providers/rfid_read_provider.dart';
import 'package:eeasy_rfid/widgets/appbar.dart';
import 'package:eeasy_rfid/widgets/primary_button.dart';
import 'package:eeasy_rfid/widgets/secondary_button.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../../models/product.dart';
import '../../providers/checkout_provider.dart';
import '../../widgets/bottombar.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    Provider.of<DoorStatusProvider>(context, listen: false).init();
    Provider.of<RfidReadProvider>(context, listen: false).init(context);

    DoorStatusProvider prov = DoorStatusProvider();

    prov.addListener(() {
      if(Provider.of<DoorStatusProvider>(context, listen: false).isDoorOpenOld != Provider.of<DoorStatusProvider>(context, listen: false).isDoorOpen && (Provider.of<DoorStatusProvider>(context, listen: false).isDoorOpen == false)) {
        Fluttertoast.showToast(msg: 'Door close detected');
        double amount = 0;
        for(Product product in Provider.of<CheckoutProvider>(context, listen: false).products) {
          amount += (double.parse(product.discountedPrice) * 100).round();
        }
        Provider.of<AppStateProvider>(context, listen: false).paymentProcess1(context, false, amount.toInt(), 5);
      }
    });

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
                      child: Consumer<RfidReadProvider>(
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
                                /*provider.listOfList.isNotEmpty ? Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text('List 1 : '), ...provider.listOfList[0].map((e) => Text(e)).toList(),
                                  ],
                                ) : const SizedBox(),
                                const SizedBox(height: 30),
                                provider.listOfList.length >= 2 ? Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text('List 2 : '), ...provider.listOfList[1].map((e) => Text(e)).toList(),
                                  ],
                                ) : const SizedBox(),
                                const SizedBox(height: 30),
                                provider.listOfList.length == 3 ? Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text('List 3 : '), ...provider.listOfList[2].map((e) => Text(e)).toList(),
                                  ],
                                ) : const SizedBox(), */
                              ],
                            )
                          );
                        }
                      ),
                    )
                  ],
                )
            ),
            CBottomBar(hasPrimary: true, primaryText: 'Continue', onPrimaryTap: () => showDialog(context: context, builder: (_) => const ProductsSelectionConfirmWidget()))
          ],
        ),
      ),
    );
  }
}
