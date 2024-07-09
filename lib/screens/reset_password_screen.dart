import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:netflixbro/screens/screens.dart';
import 'package:netflixbro/screens/verify_email_screen.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import '../constants.dart';
import '../services.dart';
import 'nav_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  TextEditingController password = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();

  String passwordError = '';
  String confirmError = '';
  bool isLoading = false;

  checkEmptyFields(){
    if(confirmPassword.text.isEmpty){
      setState(() {
        confirmError = "This Filed is required";
      });
    }
    if(password.text.isEmpty){
      setState(() {
        confirmError = "This Filed is required";
      });
    }
    if(confirmPassword.text.isNotEmpty && password.text.isNotEmpty  && confirmError.isEmpty && passwordError.isEmpty )
      return true;
    else
      return false;
  }

  String encryption(String password){
    var bytes = utf8.encode(password); // data being hashed

    var digest = md5.convert(bytes);


    print("Digest as hex string: $digest");
    return digest.toString();

  }

  resetPasswordError(){
    setState(() {
      if(passwordError == "Excellent"){
        setState(() {
          passwordError = "";
        });
      }
    });
  }

  confirmPasswordFun(){
    if(password.text != confirmPassword.text && confirmPassword.text.isNotEmpty){
      setState(() {
        confirmError = 'Password Mismatch';
      });
    }else{
      confirmError = '';
    }
  }

  setPasswordError(String password){
    setState(() {
      if(password.length < 10){
        if(password.length == 0)
          passwordError = "";
        else if(password.length < 5 && password.length > 0){
          passwordError = 'Weak';
        }else{
          passwordError = "Good";
        }
      }else{
        passwordError = "Excellent";
      }
    });
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
    resetPasswordError();
    confirmPasswordFun();
    final connection = await checkInternetConnection();
    if(connection){
      if(checkEmptyFields()){
        setState(() {
          FocusManager.instance.primaryFocus?.unfocus();
          isLoading = true;
        });
        final res = await Services.resetPassword(encryption(password.text.trim()),NavScreen.email );
        if(res == "Done"){
          setState(() {
            isLoading = false;
            buildToast("Password changed successfully");
          });
          Navigator.of(context).pop();
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
            'Reset Password',
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
                  onTap: () => {
                    confirmPasswordFun(),
                    if(password.text.length >= 10){
                      setState(() {
                        passwordError = "Excellent";
                      }),
                    }
                  },
                  onChanged: (password) => {
                    setPasswordError(password),
                    confirmPasswordFun()
                  },
                  controller: password,
                  style: TextStyle(
                      color: Colors.white
                  ),
                  textInputAction: TextInputAction.next,
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
                      labelText: "New Password",
                      labelStyle: TextStyle(
                          color: Color(0xFF963B7B),
                          fontSize: 20
                      ),
                      helperText: passwordError.isNotEmpty ? passwordError : null,
                      helperStyle: TextStyle(
                          color: passwordError == "Weak" || passwordError == "This Filed is required"? Colors.red : passwordError == "Good" ? Colors.yellow : Colors.green,
                          fontSize: 16
                      ),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(right: 20.0),
                        child: Icon(Icons.lock,color: Color(0xFFC22D4C),size: 30,),
                      )
                  ),
                ),
                SizedBox(height: passwordError.isEmpty ? 20 : 10,),
                TextField(
                  onTap: () => resetPasswordError(),
                  controller: confirmPassword,
                  style: TextStyle(
                      color: Colors.white
                  ),
                  onChanged: (confirmPassword) {
                    if(confirmError.isNotEmpty){
                      setState(() {
                        if(confirmPassword == password.text){
                          confirmError = '';
                        }
                      });
                    }
                  },
                  textInputAction: TextInputAction.done,
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
                      labelText: "Confirm Password",
                      labelStyle: TextStyle(
                          color: Color(0xFF963B7B),
                          fontSize: 20
                      ),
                      helperText: confirmError.isNotEmpty ? confirmError : null,
                      helperStyle: TextStyle(
                          color: Colors.red,
                          fontSize: 16
                      ),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(right: 20.0),
                        child: Icon(Icons.security,color: Color(0xFFC22D4C),size: 30,),
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
                        gradient: const LinearGradient(
                            colors: [Color(0xFF963B7B),Color(0xFF9D3873),Color(0xFFA5366B),Color(0xFFAA3465),Color(0xFFB63159),Color(0xFFBF2D4F),Color(0xFFA92A4B),Color(0xFFC22D4C)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight
                        )
                    ),
                    child: const Text(
                      'Reset Password',
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
