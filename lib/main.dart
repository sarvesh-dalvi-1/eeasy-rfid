import 'package:eeasy_rfid/pages/settings/providers/settings_provider.dart';
import 'package:eeasy_rfid/providers/app_state_provider.dart';
import 'package:eeasy_rfid/providers/checkout_provider.dart';
import 'package:eeasy_rfid/providers/rfid_read_provider.dart';
import 'package:eeasy_rfid/providers/rfid_init_provider.dart';
import 'package:eeasy_rfid/wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(
      MultiProvider(
          providers: [
            ChangeNotifierProvider<RfidInitProvider>(create: (_) => RfidInitProvider()),
            ChangeNotifierProvider<RfidReadProvider>(create: (_) => RfidReadProvider()),
            ChangeNotifierProvider<AppStateProvider>(create: (_) => AppStateProvider()),
            ChangeNotifierProvider<CheckoutProvider>(create: (_) => CheckoutProvider()),
            ChangeNotifierProvider<SettingsProvider>(create: (_) => SettingsProvider()),
          ],
          child: const MyApp()
      )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'eeasy rfid',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Wrapper()
    );
  }
}



