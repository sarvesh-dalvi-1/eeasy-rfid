import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ClockWidget extends StatefulWidget {
  const ClockWidget({Key? key}) : super(key: key);

  @override
  State<ClockWidget> createState() => _ClockWidgetState();
}

class _ClockWidgetState extends State<ClockWidget> {

  NumberFormat formatter = NumberFormat("00");

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
    return Text('${formatter.format(dateTime.hour)} : ${formatter.format(dateTime.minute)}', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20));
  }
}
