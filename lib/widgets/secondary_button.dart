import 'package:flutter/material.dart';

class SecondaryButton extends StatelessWidget {

  final String text;
  final VoidCallback? onTap;

  const SecondaryButton({Key? key, this.text = '', this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: Colors.white,
            border: Border.all(color: const Color(0xffD0D5DD), width: 1)
        ),
        child: Center(child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xff344054)))),
      ),
    );
  }
}
