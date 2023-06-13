import 'package:eeasy_rfid/pages/home/home.dart';
import 'package:eeasy_rfid/util/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/formatters/pos_input_formatter.dart';
import 'package:provider/provider.dart';

import '../../providers/login_provider.dart';
import '../../providers/session_provider.dart';

class StartSessionTerminal extends StatefulWidget {
  final String? name;
  final String? deviceId;

  const StartSessionTerminal({super.key, this.deviceId, this.name});

  @override
  _StartSessionTerminalState createState() => _StartSessionTerminalState();
}

class _StartSessionTerminalState extends State<StartSessionTerminal> {

  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  String? startAmount, endAmount;
  LoginProvider? loginProvider;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    loginProvider = Provider.of<LoginProvider>(context);
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          elevation: 2,
          automaticallyImplyLeading: false,
          toolbarHeight: 110.0,
          centerTitle: true,
          leadingWidth: 150,
          leading: Container(
            width: 96,
            margin: const EdgeInsets.only(
              left: 30.0,
            ),
            child: Image.asset(
              "assets/image5.png",
            ),
          ),
          title: const Text('Start Session', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: AppTheme.colorBlack)),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 55, top: 25, bottom: 25),
              width: 220.0,
              height: 66,
              child: OutlinedButton(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      side: const BorderSide(color: AppTheme.baseColor),
                    ),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Back', style: TextStyle(color: AppTheme.baseColor, fontWeight: FontWeight.w700, fontSize: 24)),
              ),
            ),
          ],
          backgroundColor: Colors.white,
        ),
        body: Form(
          key: _formkey,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      alignment: Alignment.center,
                      child: const Text('Enter opening amount', style: TextStyle(fontSize: 30)),
                    ),
                    const Padding(padding: EdgeInsets.only(top: 10)),
                    RichText(
                      textAlign: TextAlign.start,
                      text: TextSpan(
                        text: 'Hi ',
                        style: const TextStyle(color: Colors.black, fontSize: 30, fontWeight: FontWeight.w500, fontFamily: "poppins"),
                        children: <TextSpan>[
                          TextSpan(
                            text: widget.name,
                            style: const TextStyle(color: AppTheme.baseColor, fontSize: 30, fontWeight: FontWeight.w700),
                          )
                        ],
                      ),
                    ),
                    const Padding(padding: EdgeInsets.only(top: 30)),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.3,
                          height: 120.0,
                          child: Center(
                            child: TextFormField(
                              inputFormatters: [
                                PosInputFormatter(
                                  mantissaLength: LoginProvider.decimalPlace,
                                  thousandsSeparator: ThousandsPosSeparator.comma,
                                ),
                              ],
                              autofocus: true,
                              style: const TextStyle(
                                fontSize: 40.0,
                                fontWeight: FontWeight.w400,
                              ),
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                prefix: Text(LoginProvider.currencyCode, style: TextStyle(fontWeight: FontWeight.w400, fontSize: 40)),
                                hintStyle: TextStyle(fontWeight: FontWeight.w400, fontSize: 20),
                              ),
                              validator: (val) {
                                if (val!.isEmpty) {
                                  return "This Field is Required";
                                }
                                return null;
                              },
                              onSaved: (val) => startAmount = val,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 64,
                        ),
                        Consumer<SessionProvider>(
                          builder: (context, sessions, child) {
                            return SizedBox(
                              height: 80,
                              width: MediaQuery.of(context).size.width * 0.18,
                              child: ElevatedButton(
                                style: ButtonStyle(
                                  foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                                  backgroundColor: MaterialStateProperty.all<Color>(AppTheme.baseColor),
                                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      side: const BorderSide(color: Colors.black),
                                    ),
                                  ),
                                ),
                                onPressed: () async {
                                  if (_formkey.currentState!.validate()) {
                                    _formkey.currentState!.save();
                                    bool sessionCreate = await sessions.getSessionDetails({"device_id": widget.deviceId, "start_money": startAmount!.replaceAll(',', '')});
                                    if (sessionCreate == true) {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
                                    }
                                  }
                                },
                                child: SessionProvider.loading == false ? const Text("Start Session", style: TextStyle(fontSize: 26)) : const Center(child: CircularProgressIndicator(color: AppTheme.colorWhite)),
                              ),
                            );
                          },
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
