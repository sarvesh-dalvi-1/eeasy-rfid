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

    Provider.of<RfidReadProvider>(context, listen: false).init();

    return SafeArea(
      child: Material(
        child: Column(
          children: [
            const CAppbar(),
            Expanded(
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
                )
            ),
            CBottomBar(hasPrimary: true, primaryText: 'Continue', onPrimaryTap: () => showDialog(context: context, builder: (_) => const ProductsSelectionConfirmWidget()))
          ],
        ),
      ),
    );
  }
}
