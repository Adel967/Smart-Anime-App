import 'package:flutter/material.dart';
import 'package:netflixbro/constants.dart';
import 'package:netflixbro/screens/logIn_screen.dart';
import 'package:netflixbro/screens/reset_email_screen.dart';
import 'package:netflixbro/screens/screens.dart';
import 'package:netflixbro/widgets/settings_card.dart';

import '../sqlite.dart';

class AccountSettingsScreen extends StatefulWidget {
  final void Function(String) changeEmail;

  AccountSettingsScreen({required this.changeEmail});

  @override
  _AccountSettingsScreenState createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {

  String userEmail = NavScreen.email;

  
  @override
  void initState() {
    userEmail = NavScreen.email;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          'Account Settings',
          style: TextStyle(
            color: textColor
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(10),
          children: [
            SettingsCard(icon: Icons.email, title: 'Reset Email Address', fun: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ResetEmailScreen(changeEmail: widget.changeEmail,))), haveSwitch: false),
            SizedBox(height: 10,),
            SettingsCard(icon: Icons.lock, title: 'Reset Password', fun: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => VerifyEmailScreen(email: NavScreen.email, resetEmail: "2"))), haveSwitch: false),
          ],
        ),
      ),
    );
  }
}
