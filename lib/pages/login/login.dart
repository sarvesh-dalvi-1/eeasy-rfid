import 'dart:async';

import 'package:barcode_widget/barcode_widget.dart';
import 'package:eeasy_rfid/util/theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unique_identifier/unique_identifier.dart';

import '../../providers/login_provider.dart';
import '../session/confirm_session_page.dart';
import '../session/start_session_terminal.dart';



class LoginPage extends StatefulWidget {
  final String? date;
  final String? deviceId;

  LoginPage({this.date, this.deviceId});
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  String? email, password, deviceMacid;
  var now = DateTime.now();
  late LoginProvider loginProvider;

  login() async {
    if (_formkey.currentState!.validate()) {
      _formkey.currentState!.save();

      print('ABCD : ${await UniqueIdentifier.serial}');

      Map loginData = {"email": email, "password": password, "serial_number": await UniqueIdentifier.serial};

      bool isLogin = await loginProvider.logIn(loginData, context);
      if (isLogin) {
        var name = (await SharedPreferences.getInstance()).getString('userInfo/name');
        var sessionId = (await SharedPreferences.getInstance()).getString('sessionId');
        if (sessionId != null && sessionId.isNotEmpty) {
          deviceMacid = await UniqueIdentifier.serial;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SessionConfirmScreen(deviceId: deviceMacid, name: name),
            ),
          );
        } else {
          var name = (await SharedPreferences.getInstance()).getString('userInfo/name');
          var deviceId = await UniqueIdentifier.serial;
          Navigator.push(context, MaterialPageRoute(builder: (_) => StartSessionTerminal(deviceId: deviceId, name: name)));
        }
      }
    }
  }


  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    loginProvider = Provider.of<LoginProvider>(context);
    // ignore: unused_local_variable
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xffE5E5E5),
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        toolbarHeight: 96.0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text('Login', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 32.0)),
        leadingWidth: 150.0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 18.0),
          child: Image.asset("assets/image5.png"),
        ),
      ),
      body: Row(
        children: [
          Form(
            key: _formkey,
            child: Container(
              width: MediaQuery.of(context).size.width / 2,
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        primary: true,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FutureBuilder<String?>(
                              future: UniqueIdentifier.serial,
                              builder: ((context, snapshot) {
                                print(snapshot.data);
                                if (snapshot.connectionState == ConnectionState.done) {
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      RichText(
                                        textAlign: TextAlign.start,
                                        text: TextSpan(
                                          text: 'Device ID: ',
                                          style: const TextStyle(color: Colors.black, fontSize: 36, fontWeight: FontWeight.w500, fontFamily: "poppins"),
                                          children: <TextSpan>[
                                            TextSpan(
                                              text: snapshot.data,
                                              style: const TextStyle(color: AppTheme.baseColor, fontSize: 36, fontWeight: FontWeight.w700),
                                            )
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      SizedBox(
                                        width: 200,
                                        height: 80,
                                        child: BarcodeWidget(
                                          data: snapshot.data as String,
                                          barcode: Barcode.code128(),
                                        ),
                                      )
                                    ],
                                  );
                                } else {
                                  return RichText(
                                    textAlign: TextAlign.start,
                                    text: const TextSpan(
                                      text: 'Device ID: ',
                                      style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.w500, fontFamily: "poppins"),
                                      children: <TextSpan>[
                                        TextSpan(text: '', style: TextStyle(color: AppTheme.baseColor, fontSize: 24, fontWeight: FontWeight.w600),
                                        )
                                      ],
                                    ),
                                  );
                                }
                              }),
                            ),
                            const SizedBox(height: 40),
                            SizedBox(
                              width: 532.0,
                              child: TextFormField(
                                initialValue: "mike@carrefour.com",
                                decoration: InputDecoration(labelText: 'Username', labelStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0), borderSide: const BorderSide()),
                                  //fillColor: Colors.green
                                ),
                                onSaved: (val) => email = val,
                                keyboardType: TextInputType.emailAddress,
                                style: const TextStyle(fontSize: 16.0),
                              ),
                            ),
                            const SizedBox(height: 36.0),
                            SizedBox(
                              width: 532.0,
                              child: TextFormField(
                                obscureText: true,
                                initialValue: "test12345!",
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  labelStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0), borderSide: const BorderSide()),
                                ),
                                validator: (val) => val!.length < 4 ? 'Password too Short..' : null,
                                onSaved: (val) => password = val,
                                keyboardType: TextInputType.emailAddress,
                                style: const TextStyle(fontSize: 16.0),
                              ),
                            ),
                            const SizedBox(height: 36.0),
                            SizedBox(
                              height: 66, width: 199,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 10.0),
                                child: ElevatedButton(
                                  style: ButtonStyle(
                                    foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                                    backgroundColor: MaterialStateProperty.all<Color>(AppTheme.baseColor),
                                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30.0),
                                        side: const BorderSide(color: Colors.black),
                                      ),
                                    ),
                                  ),
                                  onPressed: login,
                                  child: loginProvider.loading == false
                                      ? const Text('Login', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, fontFamily: "poppins"))
                                      : const Center(child: CircularProgressIndicator(color: Colors.white)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).viewInsets.bottom)
                ],
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width / 2,
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(image: DecorationImage(image: AssetImage("assets/Rectangle26.png"), fit: BoxFit.cover)),
            child: Padding(
              padding: const EdgeInsets.only(top: 28.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 18.0),
                        child: Text(
                          widget.date != null ? widget.date as String : ' ',
                          style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 36.0),
                        ),
                      ),
                      const TimeWidget(),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height / 2),
                  const Text('RFID Application', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 64.0)),
                  const SizedBox(height: 5),
                  FutureBuilder(
                    future: PackageInfo.fromPlatform().then((value) {
                      return value.version;
                    }),
                    builder: (context, future) {
                      if(future.hasData) {
                        return Text('v ${future.data!}', style: const TextStyle(color: Colors.white, fontSize: 18));
                      }
                      else {
                        return const SizedBox();
                      }
                    },
                  ),
                  const Expanded(child: SizedBox()),
                  /**Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: FutureBuilder<String?>(
                      future: UniqueIdentifier.serial,
                      builder: (context, future) {
                        if(future.hasData) {
                          print('Device ID : ${future.data!}');
                          return Text(future.data!, style: TextStyle(color: Colors.white, fontSize: 20));
                        }
                        else {
                          return const SizedBox();
                        }
                      },
                    ),
                  ) */
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class TimeWidget extends StatefulWidget {
  const TimeWidget({Key? key}) : super(key: key);

  @override
  State<TimeWidget> createState() => _TimeWidgetState();
}

class _TimeWidgetState extends State<TimeWidget> {
  String _timeString = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Timer.periodic(const Duration(seconds: 1), (timer) {
        var now = DateTime.now();
        setState(() {
          _timeString = DateFormat.jm().format(now).toString();
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 18.0),
      child: Text(_timeString ?? ' ', style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 36.0),
      ),
    );
  }
}
