import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:netflixbro/screens/logIn_screen.dart';
import 'screens/screens.dart';



void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NetflixPro',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: Colors.black, unselectedWidgetColor: Color(0xFFB63159),

      ),
      home: Splashscreen(),
    );
  }
}
