import 'package:flutter/material.dart';

import 'clock.dart';

class CAppbar extends StatelessWidget {
  const CAppbar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xffD9D9D9), width: 1))),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        children: [
          Image.asset('assets/eeasy_logo.png', height: 40),
          const Expanded(child: SizedBox()),
          const ClockWidget()
        ],
      ),
    );
  }
}
