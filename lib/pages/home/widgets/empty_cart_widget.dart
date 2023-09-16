import 'package:flutter/material.dart';

class EmptyCardWidget extends StatelessWidget {

  final bool isRecordingOn;

  const EmptyCardWidget({Key? key, this.isRecordingOn = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/cart.png', height: 70, width: 70),
          const SizedBox(height: 10),
          Text(isRecordingOn ? 'Place items in fridge to record tags' : 'Pick items from fridge', style: const TextStyle(color: Color(0xff000C38), fontWeight: FontWeight.w600, fontSize: 18))
        ],
      ),
    );
  }
}
