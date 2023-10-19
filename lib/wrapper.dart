import 'package:eeasy_rfid/pages/error.dart';
import 'package:eeasy_rfid/pages/home/home.dart';
import 'package:eeasy_rfid/pages/settings/providers/settings_provider.dart';
import 'package:eeasy_rfid/pages/splash.dart';
import 'package:eeasy_rfid/providers/rfid_init_provider.dart';
import 'package:eeasy_rfid/util/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({Key? key}) : super(key: key);

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {

  bool pseudoInit = true;

  @override
  Widget build(BuildContext context) {

    if(pseudoInit == true) {
      Constants.rfidLogsEventChannel.receiveBroadcastStream().listen((event) {
        print('Logs : $event');
      });
      Constants.rfidReaderEventChannel.receiveBroadcastStream().listen((event) {
        print('Tags : $event');
      });

      Provider.of<RfidInitProvider>(context, listen: false).connectTcp().then((val) {
        Provider.of<SettingsProvider>(context, listen: false).setInitValues(context);
      });
      pseudoInit = false;
    }

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Stack(
        children: [
          Consumer<RfidInitProvider>(
            builder: (context, provider, child) {
              return provider.isTcpConnected == null ? const SplashPage() : (provider.isTcpConnected == true ? Provider.of<SettingsProvider>(context).initValuesSet ? const HomePage() : const Material(color: Colors.white, child: Center(child: SizedBox(width: 30, child: CircularProgressIndicator()))) : const ErrorPage());
            }
          ),
          /*Align(
            alignment: Alignment.topRight,
            child: Container(
              padding: const EdgeInsets.only(top: 55, right: 50),
              child: const Banner(
                message: "DEMO",
                location: BannerLocation.bottomStart,
              ),
            ),
          ), */
        ],
      ),
    );
  }
}
