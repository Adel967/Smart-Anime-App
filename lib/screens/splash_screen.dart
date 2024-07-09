import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:netflixbro/constants.dart';
import 'package:netflixbro/cubits/is_loading_cubit.dart';
import 'package:netflixbro/models/models.dart';
import 'package:netflixbro/models/watched_anime.dart';
import 'package:netflixbro/screens/entry_block_screen.dart';
import 'package:netflixbro/screens/logIn_screen.dart';
import 'package:netflixbro/screens/nav_screen.dart';
import 'package:netflixbro/screens/onboarding_screen.dart';
import 'package:netflixbro/services.dart';
import 'package:netflixbro/sqlite.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Splashscreen extends StatefulWidget {
  static String id='SplashScreen';

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<Splashscreen> with SingleTickerProviderStateMixin{
  late AnimationController _controller ;
  late Animation animation ;
  late User user;
  bool block = false;
  bool finish = false;

  bool findUser = false;
  int? isViewed;

  sendUnsentWatchedAnime()async{
    List<WatchedAnime> l = [];
    l = List.from(await SQLiteHelper.instance.readUnSentWatchedAnime());
    l.forEach((element) async{
      final res  =  await Services.followAnime(element.name);
      if(res){
        element.sent = "1";
        SQLiteHelper.instance.updateWatchedAnime(element);
      }
    });
  }

   getUser()async{
    final res = await SQLiteHelper.instance.readAllUsers();
    setState(() {
      if(res.isNotEmpty){
        user = res.first;
        print(user.email + user.createdTime.toString());
        findUser = true;
      }
    });

    print("response length = " + res.length.toString());
  }

  getTheme()async{
    final res = await SQLiteHelper.instance.readSwitch();
    setState(() {
      if(res.isNotEmpty){
        if(res[0]){
          textColor = Colors.white;
          backgroundColor = Colors.black;
        }else{
          textColor = Colors.black;
          backgroundColor = Colors.white;
        }
        if(res[1]){
          backgroundDownload = true;
        }else{
          backgroundDownload = false;
        }
      }else{
        textColor = Colors.white;
        backgroundColor = Colors.black;
        backgroundDownload = false;
        SQLiteHelper.instance.insertSwitch(true, false);
      }
    });

  }

  getRules()async{
    final parentalControl = await SQLiteHelper.instance.readParentalControl();
    if(parentalControl["password"].toString().isNotEmpty){
      final now = DateTime.now();
      final date  = now.toString().replaceRange(10, null, "");
      if(await SQLiteHelper.instance.checkBlockDay(date)){
        await Future.delayed(
          const Duration(seconds: 2),
            (){
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => EntryBlockScreen(flag: 1)));
              finish = true;
              block = true;
            }
        );
        return;
      }
      List<String> b = [];
      if(parentalControl["blockedDays"] != null){
        b = List.from((parentalControl["blockedDays"].split(',')));
      }
      String today  = DateFormat('EEEE').format(now).substring(0,3);
      if(b.contains(today)){
        if(!await SQLiteHelper.instance.checkAllowDay(date)){
          await Future.delayed(
              const Duration(seconds: 2),
                  (){
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => EntryBlockScreen(flag: 1)));
                finish = true;
                block = true;
              }
          );
          return;
        }
      }
      DateTime time = DateTime.now();
      print("Hours::::");
      List<String> ol = [];
      List<String> cl = [];
      int h1 = -1;
      int h2 = -1;
      if(parentalControl["openTime"] != null){
        ol = List.from(parentalControl["openTime"].toString().split(":"));
        h1 = int.parse(ol[0]);
      }
      if(parentalControl["closeTime"] != null){
        cl = List.of(parentalControl["closeTime"].toString().split(":"));
        h2 = int.parse(cl[0]);
      }
      TimeOfDay entryTime = TimeOfDay(hour: h1 < 12 ? h1 - 1 : h1 == 12 ? 0: h1 == 24 ? 12 : h1, minute: int.parse(ol[1]));
      TimeOfDay leavingTime = TimeOfDay(hour: h2 < 12 ? h2 - 1 : h2 == 12 ? 0: h2 == 24 ? 12 : h2, minute: int.parse(cl[1]));
      print(h1);
      print(time.hour);
      if(h1 != -1 && h2 != -1){
        if(time.hour < entryTime.hour || (time.hour == entryTime.hour && time.minute < entryTime.minute)){
          await Future.delayed(
              const Duration(seconds: 2),
                  (){
                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => EntryBlockScreen(flag: 2, msg: "You can enter the app after ${entryTime.hour < 12 ? entryTime.hour + 1 : entryTime.hour > 12 ? entryTime.hour - 12 : 12}:${entryTime.minute} ${entryTime.hour < 12 ? "AM" : "PM"}",)));
                finish = true;
                block = true;
              }
          );

          return;
        }else if(time.hour > leavingTime.hour || (time.hour == leavingTime.hour && time.minute > leavingTime.minute)){
          await Future.delayed(
              const Duration(seconds: 2),
                  (){
                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => EntryBlockScreen(flag: 2, msg: "You can\'t enter the app after ${leavingTime.hour < 12 ? leavingTime.hour + 1 : leavingTime.hour > 12 ? leavingTime.hour - 12 : 12}:${leavingTime.minute} ${leavingTime.hour < 12 ? "AM" : "PM"}",)));
                finish = true;
                block = true;
              }
          );
          return;
        }
      }else if(h1 != -1){
        if(time.hour > leavingTime.hour || (time.hour == leavingTime.hour && time.minute > leavingTime.minute)){
          await Future.delayed(
              const Duration(seconds: 2),
                  (){
                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => EntryBlockScreen(flag: 2, msg: "You can\'t enter the app after ${leavingTime.hour < 12 ? leavingTime.hour + 1 : leavingTime.hour > 12 ? leavingTime.hour - 12 : 12}:${leavingTime.minute} ${leavingTime.hour < 12 ? "AM" : "PM"}",)));
                finish = true;
                block = true;
              }
          );
          return;
        }
      }else if(h2 != -1){
        if(time.hour < entryTime.hour || (time.hour == entryTime.hour && time.minute < entryTime.minute)){
          await Future.delayed(
              const Duration(seconds: 2),
                  (){
                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => EntryBlockScreen(flag: 2, msg: "You can enter the app after ${entryTime.hour < 12 ? entryTime.hour + 1 : entryTime.hour > 12 ? entryTime.hour - 12 : 12}:${entryTime.minute} ${entryTime.hour < 12 ? "AM" : "PM"}",)));
                finish = true;
                block = true;
              }
          );
          return;
        }
      }
      final trackingData = await SQLiteHelper.instance.readFromTrackingTable(date);
      final rule = await SQLiteHelper.instance.readRule();
      rule.forEach((element) async{

        if(element.weekDay == today){
          if(element.active){
            List<String> l = (element.durationUsage.split(':'));
            int duration = int.parse(l[0]) *60 + int.parse(l[1]);

            if(trackingData["period"] != null){
              if(duration < trackingData["period"]){
                await Future.delayed(
                    const Duration(seconds: 2),
                        (){
                          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => EntryBlockScreen(flag: 0)));
                      finish = true;
                      block = true;
                    }
                );
                return;
              }
            }
          }
        }
      });

    }
    finish = true;
    setState(() {

    });
  }

  checkOnBoarding()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isViewed = prefs.getInt('onBoard');
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getRules();
    getTheme();
    getUser();
    checkOnBoarding();

    _controller=AnimationController(
        duration: Duration(seconds: 1),
        vsync: this
    );
    animation=ColorTween(begin: Color(0xFFB63159),end: Colors.black).animate(_controller);
    _controller.forward();
    _controller.addListener(() {
      setState(() {});

    });

    sendUnsentWatchedAnime();
      Future.delayed(
            const Duration(seconds: 4), ()async{
            while(!finish){
             await Future.delayed(Duration(seconds: 1));
             print("x");
            }
            if(!block){
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => isViewed != 1 ? OnBoardingScreen() : findUser ? BlocProvider(create: (_) => IsLoadingCubit(),child: NavScreen(user.email,),) : LoginScreen()));
            }
      }
      );

  }
  @override
  void dispose() {
    // TODO: implement dispose
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: animation.value,
      body: Center(
        child:  Container(
            height: 250.0,
            child: Image.asset('assets/images/logo1.png')//animation.value *100 ,
        ),
      ),
    );
  }
}
