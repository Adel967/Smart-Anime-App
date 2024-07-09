import 'dart:developer';
import 'dart:io';
import 'package:encrypt/encrypt.dart' as encrypt;

import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:netflixbro/constants.dart';
import 'package:email_validator/email_validator.dart';
import 'package:netflixbro/screens/nav_screen.dart';
import 'package:netflixbro/screens/screens.dart';
import 'package:netflixbro/services.dart';

class ResetEmailScreen extends StatefulWidget {
  final void Function(String) changeEmail;

  ResetEmailScreen({required this.changeEmail});

  @override
  _ResetEmailScreenState createState() => _ResetEmailScreenState();
}

class _ResetEmailScreenState extends State<ResetEmailScreen> {
  bool isLoading = false;
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  String emailError = "";
  String passwordError = "";

  checkEmptyFields(){
    if(email.text.isEmpty){
      setState(() {
        emailError = "This Filed is required";
      });
    }
    if(password.text.isEmpty){
      setState(() {
        emailError = "This Filed is required";
      });
    }
    if(email.text.isNotEmpty && password.text.isNotEmpty  && emailError.isEmpty && passwordError.isEmpty )
      return true;
    else
      return false;
  }

  String encryption(String password){
    final plainText = password;
    final key = encrypt.Key.fromLength(32);
    final iv = encrypt.IV.fromLength(8);
    final encrypter = encrypt.Encrypter(encrypt.Salsa20(key));

    final encrypted = encrypter.encrypt(plainText, iv: iv);
    return encrypted.base64;

  }

  Future<bool> checkInternetConnection() async{
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

  buildToast(String msg){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,style: TextStyle(fontSize: 16),),
      backgroundColor: Color(0xFFB63159),
    ));
  }

  submit()async{
    final connection = await checkInternetConnection();
    if(connection){
      if(checkEmptyFields()){
        setState(() {
          FocusManager.instance.primaryFocus?.unfocus();
          isLoading = true;
        });
        final res = await Services.verifyInformation(email.text.trim(), NavScreen.email.trim(), encryption(password.text.trim()));
        if(res == "Done"){
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => VerifyEmailScreen(email: email.text,resetEmail: "1",changeEmail: widget.changeEmail,)));
        }else if(res == "This email is already used"){
          emailError = "This email is already used";
        }else if(res == "wrong password"){
          buildToast("The password is incorrect!");
        }else{
          buildToast(res);
        }
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      progressIndicator: CircularProgressIndicator(
        color: Colors.red,
      ),
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: backgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: textColor,
              size: 30,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          centerTitle: true,
          title: Text(
            'Reset Email',
            style: TextStyle(
                color: textColor
            ),
          ),
        ),
        body: Container(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextField(
                  controller: email,
                  style: TextStyle(
                      color: Colors.white
                  ),
                  onChanged: (email) => {

                    setState(() {
                      if(email.isNotEmpty){
                        if(EmailValidator.validate(email)){
                          emailError = "";
                        }else{
                          emailError = "Invalidity Email";
                        }
                      }else{
                        emailError = "";
                      }
                    })


                  },
                  autofillHints: [AutofillHints.email],
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.emailAddress,
                  cursorColor: Color(0xFFEF3340),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 20,vertical: 20),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFB63159)),
                        borderRadius: BorderRadius.circular(30)
                    ),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFB63159)),
                        borderRadius: BorderRadius.circular(30)
                    ),
                    labelText: "New Email",
                    labelStyle: TextStyle(
                        color: Color(0xFF963B7B),
                        fontSize: 20
                    ),
                    helperText: emailError.isNotEmpty ? emailError : null,
                    helperStyle: TextStyle(
                        color: Colors.red,
                        fontSize: 15
                    ),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(right: 20.0),
                      child: Icon(Icons.mail,color: Color(0xFFC22D4C),size: 30,),
                    ),
                  ),
                ),
                SizedBox(height: emailError.isEmpty ? 20 : 10,),
                TextField(

                  controller: password,
                  style: TextStyle(
                      color: Colors.white
                  ),
                  textInputAction: TextInputAction.go,
                  obscureText: true,
                  cursorColor: Color(0xFFEF3340),
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 20,vertical: 20),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFB63159)),
                          borderRadius: BorderRadius.circular(30)
                      ),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFB63159)),
                          borderRadius: BorderRadius.circular(30)
                      ),
                      labelText: "Password",
                      labelStyle: TextStyle(
                          color: Color(0xFF963B7B),
                          fontSize: 20
                      ),
                      helperText: passwordError.isNotEmpty ? passwordError : null,
                      helperStyle: TextStyle(
                          color: Colors.red,
                          fontSize: 15
                      ),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(right: 20.0),
                        child: Icon(Icons.lock,color: Color(0xFFC22D4C),size: 30,),
                      )
                  ),
                ),
                SizedBox(height: passwordError.isEmpty ? 30 : 20,),
                GestureDetector(
                  onTap: submit,
                  child: Container(
                    height: 50,
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: LinearGradient(
                            colors: [Color(0xFF963B7B),Color(0xFF9D3873),Color(0xFFA5366B),Color(0xFFAA3465),Color(0xFFB63159),Color(0xFFBF2D4F),Color(0xFFA92A4B),Color(0xFFC22D4C)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight
                        )
                    ),
                    child: Text(
                      'Reset Email',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600
                      ),
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
}
