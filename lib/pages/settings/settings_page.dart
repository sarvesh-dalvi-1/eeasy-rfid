import 'dart:convert';

import 'package:eeasy_rfid/pages/settings/settings_logs_page.dart';
import 'package:eeasy_rfid/pages/settings/providers/settings_logs_provider.dart';
import 'package:eeasy_rfid/pages/settings/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

import '../../widgets/appbar.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    TextEditingController ipTextController = TextEditingController();

    return Scaffold(
      body: FutureBuilder<String>(
        future: getIPFromLocalDB(),
        builder: (context, future) {
          if(future.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          else {

            ipTextController.text = future.data ?? '';

            return Column(
              children: [
                const CAppbar(),
                Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                          children: List.generate(4, (index) => AntennaSwitch(antennaNo: index + 1))
                      ),
                    )
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Row(
                    children: [
                      const Text('IP Address : '),
                      Expanded(child: TextField(controller: ipTextController)),
                      const SizedBox(width: 30),
                      ElevatedButton(onPressed: () async {
                        var box = await Hive.openBox('config');
                        await box.put('ip', ipTextController.text);
                        Fluttertoast.showToast(msg: 'Saved');
                      }, child: const Text('Save'))
                    ],
                  ),
                )
              ],
            );
          }
        }
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsLogsPage()));
        },
        child: const Icon(Icons.settings),
      ),
    );
  }

  Future<String> getIPFromLocalDB() async {
    var box = await Hive.openBox('config');
    if(box.values.isNotEmpty) {
      return box.get('ip');
    }
    else {
      return '';
    }
  }

}


class AntennaSwitch extends StatelessWidget {

  final int antennaNo;

  const AntennaSwitch({Key? key, required this.antennaNo}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    var settingsProvider = Provider.of<SettingsProvider>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Switch(value: Provider.of<SettingsProvider>(context).selectedAntennas.contains(antennaNo), onChanged: (_) {
            if(settingsProvider.selectedAntennas.contains(antennaNo)) {
              settingsProvider.removeAntenna(antennaNo, context);
            }
            else {
              settingsProvider.addAntenna(antennaNo, context);
            }
          }),
          const SizedBox(width: 20),
          Text('Antenna $antennaNo'),
          const Expanded(child: SizedBox()),
          SizedBox(
              width: 50,
              child: DropdownButton(
                value: Provider.of<SettingsProvider>(context).powerMap[antennaNo],
                onChanged: (val) {
                  Provider.of<SettingsProvider>(context, listen: false).setPowerMap(antennaNo, val ?? 0, context);
                },
                items: List.generate(6, (index) => DropdownMenuItem(value: (index + 1) * 5, child: Text(((index + 1) * 5).toString())),
              )
          ))
        ],
      ),
    );
  }
}

