import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {

  final String text;
  final VoidCallback? onTap;

  const PrimaryButton({Key? key, required this.text, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: const Color(0xff172F5D)
        ),
        child: Center(child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white))),
      ),
    );
  }
}
