import 'package:eeasy_rfid/pages/home/widgets/empty_cart_widget.dart';
import 'package:eeasy_rfid/pages/home/widgets/final_amount_widget.dart';
import 'package:eeasy_rfid/pages/home/widgets/product_card.dart';
import 'package:eeasy_rfid/pages/home/widgets/products_selection_confirm.dart';
import 'package:eeasy_rfid/providers/rfid_read_provider.dart';
import 'package:eeasy_rfid/widgets/appbar.dart';
import 'package:eeasy_rfid/widgets/primary_button.dart';
import 'package:eeasy_rfid/widgets/secondary_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../widgets/bottombar.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    Provider.of<RfidReadProvider>(context, listen: false).init(context);

    return SafeArea(
      child: Material(
        child: Column(
          children: [
            const CAppbar(hasSettingsButton: true),
            Expanded(
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          Consumer<RfidReadProvider>(
                            builder: (_, provider, child) {
                              return provider.tags.isEmpty ? const EmptyCardWidget() : ListView(
                                  children: provider.tags.map((e) => ProductCard(epc: e, key: ValueKey(e)) as Widget).toList()..add(const SizedBox(height: 50) as Widget)
                              );
                            },
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            child: FinalAmountWidget(),
                          )
                        ],
                      ),
                    ),
                    /*Expanded(
                      flex: 3,
                      child: Consumer<RfidReadProvider>(
                        builder: (context, provider, child) {
                          return SingleChildScrollView(
                            child: Column(
                              children: [
                                Text('Live scan : ${provider.tagsScanned}'),
                                const SizedBox(height: 30),
                                provider.listOfList.isNotEmpty ? Column(
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
                                ) : const SizedBox(),
                              ],
                            )
                          );
                        }
                      ),
                    ) */
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
