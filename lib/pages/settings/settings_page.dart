import 'package:eeasy_rfid/pages/settings/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../widgets/appbar.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return SafeArea(
      child: Material(
        child: Column(
          children: [
            const CAppbar(),
            Expanded(
                child: SingleChildScrollView(
                  child: Column(
                      children: List.generate(4, (index) => AntennaSwitch(antennaNo: index + 1))
                  ),
                )
            ),
          ],
        )
      ),
    );
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
              settingsProvider.removeAntenna(antennaNo);
            }
            else {
              settingsProvider.addAntenna(antennaNo);
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
                  Provider.of<SettingsProvider>(context, listen: false).setPowerMap(antennaNo, val ?? 0);
                },
                items: List.generate(6, (index) => DropdownMenuItem(value: (index + 1) * 5, child: Text(((index + 1) * 5).toString())),
              )
          ))
        ],
      ),
    );
  }
}

