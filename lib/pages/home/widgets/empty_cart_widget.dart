import 'package:flutter/material.dart';

class EmptyCardWidget extends StatelessWidget {
  const EmptyCardWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/cart.png', height: 70, width: 70),
          const SizedBox(height: 10),
          const Text('Add Items to basket', style: TextStyle(color: Color(0xff000C38), fontWeight: FontWeight.w600, fontSize: 18))
        ],
      ),
    );
  }
}
