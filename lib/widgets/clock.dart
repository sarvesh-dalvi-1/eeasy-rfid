import 'dart:async';

import 'package:flutter/material.dart';

class ClockWidget extends StatefulWidget {
  const ClockWidget({Key? key}) : super(key: key);

  @override
  State<ClockWidget> createState() => _ClockWidgetState();
}

class _ClockWidgetState extends State<ClockWidget> {

  @override
  void initState() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if(mounted) {
        setState(() { });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DateTime dateTime = DateTime.now();
    return Text('${dateTime.hour} : ${dateTime.minute}', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20));
  }
}
