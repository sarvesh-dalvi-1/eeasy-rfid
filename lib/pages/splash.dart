import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/rfid_init_provider.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(
        child: Image.asset('assets/eeasy_logo.png'),
      ),
    );
  }
}
