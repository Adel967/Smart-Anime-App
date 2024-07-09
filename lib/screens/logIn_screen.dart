import 'dart:convert';
import 'dart:io';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:netflixbro/constants.dart';
import 'package:netflixbro/cubits/is_loading_cubit.dart';
import 'package:netflixbro/models/models.dart';
import 'package:netflixbro/screens/screens.dart';
import 'package:netflixbro/services.dart';
import 'package:netflixbro/sqlite.dart';
import 'package:crypto/crypto.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  bool isLoading = false;
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  String emailError = "";
  String passwordError = "";


  String encryption(String password){

    var bytes = utf8.encode(password); // data being hashed

    var digest = md5.convert(bytes);


    print("Digest as hex string: $digest");
    return digest.toString();
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

  submit() async{
    final connection = await checkInternetConnection();
    if(connection){
      if(checkEmptyFields()){
        setState(() {
          isLoading = true;
        });
        if(await Services.login(email.text, encryption(password.text))){
          DateTime date = DateTime.now();
          final  result = await SQLiteHelper.instance.insertUser(User(email: email.text, createdTime: date));
          setState(() {
            isLoading = false;
          });
          result ? Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => BlocProvider(create: (_) => IsLoadingCubit(),child: NavScreen(email.text,),))) : buildToast("There is something incorrect,try again");
        }else{
          setState(() {
            isLoading = false;
            buildToast("The email or password is incorrect!");
          });
        }
      }
    }
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
                SizedBox(height: 50,),
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
                    labelText: "Email",
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
                  onTap: () => submit(),
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
                      'Login',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 13,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      Text(
                        'Don\'t have an account?',
                        style: TextStyle(
                          color: Color(0xFF963B7B),
                          fontSize: 17
                        ),
                      ),
                      SizedBox(width: 9,),
                      GestureDetector(
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => SignUpScreen())),
                        child: Text(
                          'Sign up',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 17,
                            fontWeight: FontWeight.w600
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
