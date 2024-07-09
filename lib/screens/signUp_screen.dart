import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:netflixbro/services.dart';

import 'screens.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {

  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();
  DateTime now = new DateTime.now();
  String emailError = '';
  String passwordError = '';
  String confirmError = '';
  bool isLoading = false;

  List<String> generateYears (){
    List<String> years = [];

    for(int i =  now.year;i >= 1950;i--){
      years.add(i.toString());
    }
    return years;
  }

  String dropdownValue = '';
  int _group = 1;

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

  checkEmptyField(){
    setState(() {
      if(email.text.isEmpty)
        emailError = "This Filed is required";
      if(password.text.isEmpty)
        passwordError = "This Filed is required";
      if(confirmPassword.text.isEmpty)
        confirmError = "This Filed is required";
    });
    if(email.text.isNotEmpty && password.text.isNotEmpty && confirmPassword.text.isNotEmpty && emailError.isEmpty && passwordError.isEmpty  && confirmError.isEmpty)
      return true;
    else
      return false;
  }

  getGender(){
    return _group == 1 ? "Male" : _group == 2 ? "Female" : "Others";
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

  submit() async{
    resetPasswordError();
    confirmPasswordFun();
    final internetAccess = await checkInternetConnection();
    if(checkEmptyField() && internetAccess)
      setState(() {
        isLoading = true;
      });
    else return;
    final res = await Services.checkEmail(email.text);
    if(res){
      print("Done");
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => VerifyEmailScreen(email: email.text,password: password.text,birthyear: dropdownValue,gender: getGender(),resetEmail: "0",)));
    }else{
      print("This Email is already used");
      setState(() {
        emailError = "This email is already used";
      });
    }
    setState(() {
      isLoading = false;
    });

  }

  @override
  void initState() {
    dropdownValue = now.year.toString();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {



    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ModalProgressHUD(
        inAsyncCall: isLoading,
        progressIndicator: CircularProgressIndicator(
          color: Colors.red,
        ),
        child: GestureDetector(
          onTap: () => {
            FocusScope.of(context).unfocus(),
            resetPasswordError(),
            confirmPasswordFun()
          },
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.fromLTRB( 10, 70, 10,10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image(
                    image: AssetImage('assets/images/logo1.png'),
                    height: 200,
                    width: 200,
                  ),
                  //SizedBox(height: 20,),
                  TextField(
                    controller: email,
                    style: TextStyle(
                      color: Colors.white
                    ),
                    onTap: () => {
                      resetPasswordError(),
                      confirmPasswordFun()
                    },
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
                        labelText: "Password",
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
                  SizedBox(height: confirmError.isEmpty ? 20 : 10,),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        AutoSizeText(
                          'Male',
                          style: TextStyle(color: Color(0xFF963B7B) ),
                          maxFontSize: 20,
                          maxLines: 1,
                        ),
                        Radio(
                          activeColor: Color(0xFFC22D4C),
                          value: 1,
                          groupValue: _group,
                          onChanged: (i)  {
                            resetPasswordError();
                            confirmPasswordFun();
                            setState(() {
                              print(i);
                              _group = int.parse(i.toString());
                            });
                          },
                        ),
                        AutoSizeText(
                          'Female',
                          style: TextStyle(color: Color(0xFF963B7B) ),
                          maxFontSize: 20,
                          maxLines: 1,
                        ),
                        Radio(
                          activeColor: Color(0xFFC22D4C),
                          value: 2,
                          groupValue: _group,
                          onChanged: (i)  {
                            resetPasswordError();
                            confirmPasswordFun();
                            setState(() {
                              print(i);
                              _group = int.parse(i.toString());
                            });
                          },
                        ),
                        AutoSizeText(
                          'Others',
                          style: TextStyle(color: Color(0xFF963B7B) ),
                          maxFontSize: 20,
                          maxLines: 1,
                        ),
                        Radio(
                          activeColor: Color(0xFFC22D4C),
                          value: 3,
                          groupValue: _group,
                          onChanged: (i)  {
                            resetPasswordError();
                            confirmPasswordFun();
                            setState(() {
                              _group = int.parse(i.toString());
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        Text('BirthYear',style: TextStyle(color: Color(0xFF963B7B),fontSize: 19),),
                        SizedBox(width: 10,),
                        DropdownButton<String>(
                          value: dropdownValue,
                          icon: const Icon(Icons.arrow_drop_down_outlined,color: Color(0xFFC22D4C),),
                          iconSize: 30,
                          dropdownColor: Colors.black,
                          style: const TextStyle(color: Color(0xFFB63159),fontSize: 18),
                          underline: SizedBox.shrink(),
                          onTap: () => {
                            resetPasswordError(),
                            confirmPasswordFun()
                          },
                          onChanged: (String? newValue) {
                            setState(() {
                              dropdownValue = newValue!;
                            });
                          },
                          items: generateYears()
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 20,),
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
                        'Sign up',
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
      ),
    );
  }
}
