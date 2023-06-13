import 'package:eeasy_rfid/pages/home/home.dart';
import 'package:eeasy_rfid/util/theme.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionConfirmScreen extends StatelessWidget {

  SessionConfirmScreen({
    this.deviceId,
    this.name,
  });

  final String? deviceId;
  final String? name;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 110.0,
        actions: [
          Padding(
            padding:
            const EdgeInsets.only(right: 18.0, top: 28.0, bottom: 26.0),
            child: Container(
              width: 218.0,
              height: 66,
              child: OutlinedButton(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                ),
                child: const Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                    fontSize: 24.0,
                  ),
                ),
                onPressed: () async {
                  (await SharedPreferences.getInstance()).remove("token");
                  Navigator.pop(context);
                },
              ),
            ),
          )
        ],
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "Confirm Session",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 32.0,
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 18.0),
          child: Image.asset("assets/image5.png"),
        ),
        leadingWidth: 150.0,
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(
              height: 100,
            ),
            const Text(
              'Do you want to continue the previous Session?',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w500,
                color: AppTheme.baseColor,
              ),
            ),
            SizedBox(
              height: 120,
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.30,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () async {
                      ///await DatabaseHelper.instance.deleteAll();
                      /**Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ),
                      );*/
                    },
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.30,
                      width: MediaQuery.of(context).size.width * 0.25,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppTheme.baseColor2,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        'NO',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.colorWhite,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 60),
                  InkWell(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const HomePage()));
                    },
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.30,
                      width: MediaQuery.of(context).size.width * 0.25,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppTheme.baseColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        'YES',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.colorWhite,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}