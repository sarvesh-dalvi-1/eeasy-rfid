import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/rfid_read_provider.dart';
import '../../../widgets/primary_button.dart';
import '../../../widgets/secondary_button.dart';
import '../../paperbag_decision/paperbag_decision_page.dart';

class ProductsSelectionConfirmWidget extends StatelessWidget {
  const ProductsSelectionConfirmWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Material(
          child: Container(
            width: 350,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('You have scanned', style: TextStyle(color: Color(0xff101828), fontSize: 16)),
                const SizedBox(height: 15),
                Text.rich(
                    TextSpan(
                        children: [
                          TextSpan(text: Provider.of<RfidReadProvider>(context).tagsRemoved.length.toString(), style: const TextStyle(color: Color(0xff30313D), fontSize: 22)),
                          const TextSpan(text: ' Items', style: TextStyle(color: Color(0xff30313D), fontSize: 22)),
                        ]
                    )
                ),
                const SizedBox(height: 15),
                const Text('if this is incorrect, please try again or seek assistance.', style: TextStyle(color: Color(0xff344054)), textAlign: TextAlign.center),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(flex: 1, child: SecondaryButton(text: 'Try Again', onTap: () => Navigator.pop(context))),
                    const SizedBox(width: 15),
                    Expanded(
                      flex: 1,
                      child: PrimaryButton(text: 'Confirm', onTap: () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const PaperbagDecisionPage()));
                      }),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
