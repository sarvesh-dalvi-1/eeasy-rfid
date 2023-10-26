import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class Constants {

  static const methodChannel = MethodChannel('com.example.eeasy_rfid/method');

  static const rfidLogsEventChannel = EventChannel('com.example.eeasy_rfid/event');
  static const rfidReaderEventChannel = EventChannel('com.example.eeasy_rfid/event/tags');

  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

}