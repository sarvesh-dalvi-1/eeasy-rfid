import 'dart:typed_data';

import 'package:eeasy_rfid/pages/error.dart';
import 'package:eeasy_rfid/pages/home/home.dart';
import 'package:eeasy_rfid/pages/login/login.dart';
import 'package:eeasy_rfid/pages/splash.dart';
import 'package:eeasy_rfid/providers/rfid_init_provider.dart';
import 'package:eeasy_rfid/util/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    Constants.rfidLogsEventChannel.receiveBroadcastStream().listen((event) {
      print('Logs : $event');
    });
    Constants.rfidReaderEventChannel.receiveBroadcastStream().listen((event) {
      print('Tags : $event');
    });

    Provider.of<RfidInitProvider>(context, listen: false).connectTcp();

    return Consumer<RfidInitProvider>(
      builder: (context, provider, child) {
        return provider.isTcpConnected == null ? const SplashPage() : (provider.isTcpConnected == true ? const HomePage() : const ErrorPage());
      }
    );
  }
}
