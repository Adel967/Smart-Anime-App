import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:netflixbro/screens/account_settings_screen.dart';
import 'package:netflixbro/screens/logIn_screen.dart';
import 'package:netflixbro/screens/nav_screen.dart';
import 'package:netflixbro/screens/reset_password_screen.dart';
import 'package:netflixbro/services.dart';
import 'package:netflixbro/sqlite.dart';

class VerifyEmailScreen extends StatefulWidget {
  final String email;
  final String? password;
  final String? birthyear;
  final String? gender;
  final String resetEmail;
  final void Function(String)? changeEmail;

  const VerifyEmailScreen(
      {Key? key,
      required this.email,
      this.password,
      this.birthyear,
      this.gender,
      required this.resetEmail,
      this.changeEmail})
      : super(key: key);

  @override
  _VerifyEmailScreenState createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool isLoading = false;

  TextEditingController _controller1 = TextEditingController();
  TextEditingController _controller2 = TextEditingController();
  TextEditingController _controller3 = TextEditingController();
  TextEditingController _controller4 = TextEditingController();

  sendOTP(bool first) async {
    Services.sendotp(widget.email);
    setState(() {
      _controller1.text = "";
      _controller2.text = "";
      _controller3.text = "";
      _controller4.text = "";
    });
    if (!first) {
      buildToast("The code has sent successfully!");
    }
  }

  String encryption(String password) {
    var bytes = utf8.encode(password); // data being hashed

    var digest = md5.convert(bytes);

    print("Digest as hex string: $digest");
    return digest.toString();
  }

  verifyOTP() async {
    final conn = await checkInternetConnection();
    if (conn) {
      String code = _controller1.text +
          _controller2.text +
          _controller3.text +
          _controller4.text;
      setState(() {
        FocusManager.instance.primaryFocus?.unfocus();
        isLoading = true;
      });
      final res = await Services.checkOTP(widget.email, code);
      if (res == "Success" && widget.resetEmail == "2") {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => ResetPasswordScreen()));
      } else if (res == "Success" && widget.resetEmail == "1") {
        final res =
            await Services.saveInformation(widget.email, NavScreen.email);
        if (res == "Done") {
          setState(() {
            SQLiteHelper.instance.update(widget.email, NavScreen.email);
            isLoading = false;
            widget.changeEmail!(widget.email);
          });
          buildToast("Email changed successfully");
          final nav = Navigator.of(context);
          nav.pop();
          nav.pop();
        } else {
          buildToast(res);
        }
      } else if (res == "Success") {
        final res = await Services.signUp(widget.email,
            encryption(widget.password!), widget.birthyear, widget.gender);
        if (res) {
          setState(() {
            isLoading = false;
          });
          buildToast("Account created successfully");
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => LoginScreen()),
              (route) => false);
        } else
          buildToast("try again later");
      } else {
        buildToast(res);
        setState(() {
          _controller1.text = "";
          _controller2.text = "";
          _controller3.text = "";
          _controller4.text = "";
        });
      }
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<bool> checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      buildToast("Check your internet connection!");
      return false;
    }
    return false;
  }

  buildToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        msg,
        style: TextStyle(fontSize: 16),
      ),
      backgroundColor: Color(0xFFB63159),
    ));
  }

  @override
  void initState() {
    print(widget.email);
    sendOTP(true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ModalProgressHUD(
        inAsyncCall: isLoading,
        progressIndicator: CircularProgressIndicator(
          color: Colors.red,
        ),
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.fromLTRB(10, 90, 10, 10),
            alignment: Alignment.center,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image(
                  image: AssetImage('assets/images/logo1.png'),
                  height: 200,
                  width: 200,
                ),
                Text(
                  'Email Verification',
                  style: TextStyle(
                      color: Color(0xFF963B7B),
                      fontSize: 25,
                      fontWeight: FontWeight.w600),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  'We sent a code to ${widget.email}',
                  style: TextStyle(
                      color: Color(0xFFB63159),
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                  maxLines: 2,
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'The code will expire after 15 minutes',
                  style: TextStyle(
                      color: Color(0xFFB63159),
                      fontSize: 14,
                      fontWeight: FontWeight.w600),
                  maxLines: 2,
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _textFieldOTP(
                        first: true, last: false, controller: _controller1),
                    SizedBox(
                      width: 10,
                    ),
                    _textFieldOTP(
                        first: false, last: false, controller: _controller2),
                    SizedBox(
                      width: 10,
                    ),
                    _textFieldOTP(
                        first: false, last: false, controller: _controller3),
                    SizedBox(
                      width: 10,
                    ),
                    _textFieldOTP(
                        first: false, last: true, controller: _controller4),
                  ],
                ),
                SizedBox(
                  height: 30,
                ),
                GestureDetector(
                  onTap: () => sendOTP(false),
                  child: Container(
                    height: 50,
                    margin: EdgeInsets.symmetric(horizontal: 50),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: LinearGradient(
                            colors: [
                              Color(0xFF963B7B),
                              Color(0xFF9D3873),
                              Color(0xFFA5366B),
                              Color(0xFFAA3465),
                              Color(0xFFB63159),
                              Color(0xFFBF2D4F),
                              Color(0xFFA92A4B),
                              Color(0xFFC22D4C)
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight)),
                    child: Text(
                      'Resend Code',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _textFieldOTP(
      {bool first = false, last, required TextEditingController controller}) {
    return Container(
      height: 85,
      child: AspectRatio(
        aspectRatio: 0.8,
        child: TextField(
          controller: controller,
          autofocus: true,
          onChanged: (value) {
            if (_controller1.text.isNotEmpty &&
                _controller2.text.isNotEmpty &&
                _controller3.text.isNotEmpty &&
                _controller4.text.isNotEmpty) {
              //FocusScope.of(context).requestFocus(FocusNode());
              verifyOTP();
            }

            if (value.length == 1 && last == false) {
              FocusScope.of(context).nextFocus();
            }
            if (value.length == 0 && first == false) {
              FocusScope.of(context).previousFocus();
            }
          },
          showCursor: false,
          readOnly: false,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          keyboardType: TextInputType.number,
          maxLength: 1,
          decoration: InputDecoration(
            counter: Offstage(),
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(width: 2, color: Color(0xFF963B7B)),
                borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(width: 2, color: Colors.red),
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }
}
