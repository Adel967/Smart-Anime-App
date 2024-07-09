import 'package:flutter/material.dart';
import 'package:netflixbro/screens/block_screen.dart';
import 'package:netflixbro/screens/duration_management_screen.dart';
import 'package:netflixbro/screens/parentalControl_password.dart';
import 'package:netflixbro/screens/time_management_screen.dart';
import 'package:netflixbro/widgets/settings_card.dart';

class ManagementScreen extends StatelessWidget {
  const ManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0A0D22),
      appBar: AppBar(
        title: Text(
          "Usage Management",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF0A0D22),
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.all(8),
        children: [
          SettingsCard(icon: Icons.access_time_filled, title: "Time Usage Management", fun: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => TimeManagementScreen())), haveSwitch: false),
          SizedBox(height: 10,),
          SettingsCard(icon: Icons.timer, title: "Duration Usage Management", fun: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => DurationManagementScreen())), haveSwitch: false),
          SizedBox(height: 10,),
          SettingsCard(icon: Icons.block, title: "Block specific Anime and Category", fun: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => BlockScreen())), haveSwitch: false),
          SizedBox(height: 10,),
          SettingsCard(icon: Icons.lock_reset_outlined, title: "Reset Password", fun: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => SetParentalControlPassword(flag: 2))), haveSwitch: false),
        ],
      ),
    );
  }
}
