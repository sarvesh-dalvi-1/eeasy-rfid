import 'dart:convert';

import 'package:eeasy_rfid/Models/user_settings.dart';
import 'package:eeasy_rfid/pages/home/home.dart';
import 'package:eeasy_rfid/pages/settings/providers/settings_logs_provider.dart';
import 'package:eeasy_rfid/pages/settings/providers/settings_provider.dart';
import 'package:eeasy_rfid/providers/app_state_provider.dart';
import 'package:eeasy_rfid/providers/checkout_provider.dart';
import 'package:eeasy_rfid/providers/door_status_provider.dart';
import 'package:eeasy_rfid/providers/rfid_read_provider.dart';
import 'package:eeasy_rfid/providers/rfid_init_provider.dart';
import 'package:eeasy_rfid/wrapper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';

import 'Models/app_to_app_data.dart';
import 'api_collection/eeasy_rfid_api.dart';


void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  await Hive.initFlutter();
  await Hive.openBox('logs');

  runApp(
      MultiProvider(
          providers: [
            ChangeNotifierProvider<RfidInitProvider>(create: (_) => RfidInitProvider()),
            ChangeNotifierProvider<RfidReadProvider>(create: (_) => RfidReadProvider()),
            ChangeNotifierProvider<AppStateProvider>(create: (_) => AppStateProvider()),
            ChangeNotifierProvider<CheckoutProvider>(create: (_) => CheckoutProvider()),
            ChangeNotifierProvider<SettingsProvider>(create: (_) => SettingsProvider()),
            ChangeNotifierProvider<DoorStatusProvider>(create: (_) => DoorStatusProvider())
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
      home: const TempPage()///const HomePage()
    );
  }
}



class TempPage extends StatelessWidget {
  const TempPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    TextEditingController ipTextController = TextEditingController();



    return Material(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            children: [
              const Text('IP Address : '),
              Expanded(child: TextField(controller: ipTextController)),
              const SizedBox(width: 30),
              ElevatedButton(onPressed: () async {
                var box = await Hive.openBox('config');
                await box.put('ip', ipTextController.text);
                Navigator.push(context, CupertinoPageRoute(builder: (_) => Wrapper()));
              }, child: const Text('Save'))
            ],
          ),
        ),
      ),
    );
  }
}




