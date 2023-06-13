import 'package:eeasy_rfid/providers/rfid_read_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FinalAmountWidget extends StatelessWidget {
  const FinalAmountWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: const Color(0xffF2F2F7)
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Consumer<RfidReadProvider>(
        builder: (context, provider, child) {
          return Row(
            children: [
              Text.rich(TextSpan(
                children: [
                  TextSpan(text: provider.tags.length.toString(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const TextSpan(text: ' Items', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xff6A7383))),
                ]
              )),
              const Expanded(child: SizedBox()),
              const Text.rich(TextSpan(
                  children: [
                    TextSpan(text: 'Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xff6A7383))),
                    TextSpan(text: ' AED 111.11', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  ]
              ))
            ],
          );
        }
      )
    );
  }
}

