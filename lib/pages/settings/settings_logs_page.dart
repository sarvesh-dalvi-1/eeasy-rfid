import 'package:flutter/material.dart';
import 'package:hive/hive.dart';


class SettingsLogsPage extends StatelessWidget {
  const SettingsLogsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Material(
      child: SafeArea(
        child: SingleChildScrollView(
          child: FutureBuilder(
            future: future(),
            builder: (context, future) {
              if(future.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              else {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  child: Column(
                    children: future.data!.map((e) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5),
                      child: Text(e),
                    )).toList()
                  ),
                );
              }
            },
          )
        ),
      ),
    );
  }

  Future<List<String>> future() async {
    var box = await Hive.openBox('logs');
    List<String> logs = [];
    for (int i = box.length - 1; i >= 0; i--) {
      var _log = box.getAt(i);
      logs.add(_log);
    }
    return logs;
  }

}
