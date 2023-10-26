import 'dart:async';

class AppStreams {

  static StreamController<int> initAuthStatusStreamController = StreamController();   /// 0 -> SUCCESS     1 -> FAIL
  static Stream<int> initAuthStatusStream = initAuthStatusStreamController.stream.asBroadcastStream();

  static StreamController<int> doorCloseDetectedStreamController = StreamController();
  static Stream<int> doorCloseDetectedStream = doorCloseDetectedStreamController.stream.asBroadcastStream();


}