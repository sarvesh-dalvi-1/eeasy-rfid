import 'dart:convert';
import 'dart:ui';

import 'package:eeasy_rfid/Models/user_settings.dart';
import 'package:eeasy_rfid/models/session.dart';
import 'package:eeasy_rfid/pages/checkout/checkout_page.dart';
import 'package:eeasy_rfid/pages/home/home.dart';
import 'package:eeasy_rfid/pages/settings/providers/settings_logs_provider.dart';
import 'package:eeasy_rfid/pages/settings/providers/settings_provider.dart';
import 'package:eeasy_rfid/pages/start_shopping/start_shopping_page.dart';
import 'package:eeasy_rfid/providers/app_state_provider.dart';
import 'package:eeasy_rfid/providers/checkout_provider.dart';
import 'package:eeasy_rfid/providers/door_status_provider.dart';
import 'package:eeasy_rfid/providers/rfid_read_provider.dart';
import 'package:eeasy_rfid/providers/rfid_init_provider.dart';
import 'package:eeasy_rfid/util/constants.dart';
import 'package:eeasy_rfid/util/data.dart';
import 'package:eeasy_rfid/wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';

import 'Models/app_to_app_data.dart';
import 'api_collection/eeasy_rfid_api.dart';

import 'firebase_options.dart';


void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

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
      key: Constants.navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const TempPage()
    );
  }
}



class TempPage extends StatefulWidget {
  const TempPage({Key? key}) : super(key: key);

  @override
  State<TempPage> createState() => _TempPageState();
}

class _TempPageState extends State<TempPage> {

  TextEditingController ipTextController = TextEditingController();
  TextEditingController delayController = TextEditingController(text: '1500');

  @override
  void initState() {
    _fun();
    super.initState();
  }


  _fun() async {
    var box = await Hive.openBox('config');
    setState(() async {
      ipTextController.text = await box.get('ip');
    });
  }

  @override
  Widget build(BuildContext context) {


    return Material(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Text('IP Address : '),
                  Expanded(child: TextField(controller: ipTextController)),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  const Text('Door Status check delay (in milliseconds) : '),
                  Expanded(child: TextField(controller: delayController)),
                ],
              ),
              const SizedBox(height: 30),
              ElevatedButton(onPressed: () async {
                var box = await Hive.openBox('config');
                await box.put('ip', ipTextController.text);
                AppData.doorStatusCallMillis = int.parse(delayController.text);
                Navigator.pushReplacement(context, CupertinoPageRoute(builder: (_) => Wrapper()));
              }, child: const Text('Save'))
            ],
          )
        ),
      ),
    );
  }
}




