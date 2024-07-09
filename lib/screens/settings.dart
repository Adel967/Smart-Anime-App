import 'package:flutter/material.dart';
import 'package:netflixbro/constants.dart';
import 'package:netflixbro/screens/nav_screen.dart';
import 'package:netflixbro/screens/parental_control.dart';
import 'package:netflixbro/services.dart';
import 'package:netflixbro/sqlite.dart';
import 'package:netflixbro/widgets/settings_card.dart';

import 'account_settings_screen.dart';
import 'logIn_screen.dart';

class SettingsScreen extends StatefulWidget {
  final void Function(bool) changeTheme;
  final void Function(bool) changeBackgroundDownload;
  final void Function(String) changeEmail;

  SettingsScreen({required this.changeTheme,required this.changeBackgroundDownload,required this.changeEmail});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  late bool isSwitchedTheme ;
  late bool isSwitchedStorage = false ;
  late bool parentalControlIsLoaded;


  showAlertDialog(bool value,String content,Function sqliteFun) {
    // set up the button
    Widget okButton = TextButton(
      child: Text(value ? "OK" : "YES",style: TextStyle(color: Colors.green),),
      onPressed: () {
        sqliteFun();
        SQLiteHelper.instance.updateStorage(value);
        setState(() {
          isSwitchedStorage = value;
          widget.changeBackgroundDownload(value);
        });

        Navigator.of(context).pop();
      },
    );

    Widget cancelButton = TextButton(
      child: Text( "Cancel" ,style: TextStyle(color: Colors.red),),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget noButton = TextButton(
      child: Text( "NO" ,style: TextStyle(color: Colors.red),),
      onPressed: () {
        SQLiteHelper.instance.updateStorage(value);
        setState(() {
          widget.changeBackgroundDownload(value);
          isSwitchedStorage = value;
        });
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: Colors.white,
      content: Text(
          content
      ),
      actions: [
        cancelButton,
        !value ? noButton : SizedBox.shrink(),
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  call()async{
    final res  = await Services.getWatchedAnime("2022-11-08");
    print(res);
  }

  @override
  void initState() {
    call();
    if(backgroundColor == Colors.black){
      isSwitchedTheme = true;
    }else{
      isSwitchedTheme = false;
    }
    isSwitchedStorage = backgroundDownload;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(10),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: backgroundColor == Colors.black ? Color(0xFF151E29) : Colors.grey.shade200
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        NavScreen.email,
                        style: TextStyle(
                            color: textColor,
                            fontSize: 18
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(onPressed: ()async{
                  await SQLiteHelper.instance.clearTableUser();
                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => LoginScreen()));
                }, child: Row(
                  children: [
                    Text(
                      'Logout',
                      style: TextStyle(
                          color: Colors.red,
                          fontSize: 18
                      ),
                    ),
                    SizedBox(width: 5,),
                    Icon(
                      Icons.logout,
                      color: Colors.red,
                      size: 25,
                    )
                  ],
                ),)
              ],
            ),
            SettingsCard(icon: Icons.nightlight_round, title: 'Dark Mode', isSwitch: isSwitchedTheme, fun: (value) => setState(() {
              isSwitchedTheme = value;
              SQLiteHelper.instance.updateTheme(value);
              widget.changeTheme(value);
            }), haveSwitch: true),
            SettingsCard(icon: Icons.sd_storage, title: 'Background Download', isSwitch: isSwitchedStorage, fun: (value) => setState(() {
              if(value){
                showAlertDialog(value,'By this option you can search for anime offline but by the time it could harm your storage',() => SQLiteHelper.instance.updateStorage(value));
              }else{
                showAlertDialog(value,'Do want to clear your background downloaded anime?\nIf you choose YES you won\'t be able to search for anime offline',() => SQLiteHelper.instance.clearAnimeTable());
              }
            }), haveSwitch: true),
            SizedBox(height: 10,),
            SettingsCard(icon: Icons.person, title: 'Account Settings', fun: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => AccountSettingsScreen(changeEmail: widget.changeEmail))), haveSwitch: false),
            SizedBox(height: 15,),
            SettingsCard(icon: Icons.family_restroom, title: 'Parental Controls', fun: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ParentalControl())), haveSwitch: false),
          ],
        ),
      ),
    );
  }
}




