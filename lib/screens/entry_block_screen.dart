import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:netflixbro/screens/nav_screen.dart';
import 'package:netflixbro/screens/parentalControl_password.dart';

import '../cubits/is_loading_cubit.dart';
import '../models/user.dart';
import '../sqlite.dart';

class EntryBlockScreen extends StatefulWidget {
  int flag;
  String msg;

  EntryBlockScreen({Key? key, required this.flag, this.msg = ""}) : super(key: key);

  @override
  State<EntryBlockScreen> createState() => _EntryBlockScreenState();
}

class _EntryBlockScreenState extends State<EntryBlockScreen> {
  bool isLoading = false;
  late User user;

    void getRules()async{
    bool block = false;
    print("rrrrrrrrrrrrrrrrrrrrrriiiiiiiiiiiiiiiiiiiiiii");
    setState(() {
      isLoading = true;
    });
    final parentalControl = await SQLiteHelper.instance.readParentalControl();

    if(parentalControl["password"].toString().isNotEmpty){
      final now = DateTime.now();
      final date  = now.toString().replaceRange(10, null, "");
      print(date);
      if(await SQLiteHelper.instance.checkBlockDay(date)){
        setState(() {
          widget.flag = 1;
          isLoading = false;
        });
        return;
      }
      List<String> b = [];
      if(parentalControl["blockedDays"] != null){
        b = List.from((parentalControl["blockedDays"].split(',')));
      }
      String today  = DateFormat('EEEE').format(now).substring(0,3);
      if(b.contains(today)){
        if(!await SQLiteHelper.instance.checkAllowDay(date)){
          setState(() {
            widget.flag = 1;
            isLoading = false;
          });
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

      TimeOfDay entryTime = TimeOfDay(hour: h1 <= 12 ? h1 - 1 : h1 == 24 ? 12 : h1, minute: int.parse(ol[1]));
      TimeOfDay leavingTime = TimeOfDay(hour: h2 <= 12 ? h2 - 1 : h2 == 24 ? 12 : h2, minute: int.parse(cl[1]));

      print(entryTime);
      print(leavingTime);
      print(time.hour);
      if(h1 != -1 && h2 != -1){
        if(time.hour < entryTime.hour || (time.hour == entryTime.hour && time.minute < entryTime.minute)){
          setState(() {
            widget.flag = 2;
            widget.msg = "You can enter the app after ${entryTime.hour < 12 ? entryTime.hour + 1 : entryTime.hour > 12 ? entryTime.hour - 12 : 12}:${entryTime.minute} ${entryTime.hour < 12 ? "AM" : "PM"}";
            isLoading = false;
          });
          return;
        }else if(time.hour > leavingTime.hour || (time.hour == leavingTime.hour && time.minute > leavingTime.minute)){
          setState(() {
            widget.flag = 2;
            widget.msg = "You can\'t enter the app after ${leavingTime.hour < 12 ? leavingTime.hour + 1 : leavingTime.hour > 12 ? leavingTime.hour - 12 : 12}:${leavingTime.minute} ${leavingTime.hour < 12 ? "AM" : "PM"}";
            isLoading = false;
          });
          return;
        }
      }else if(h1 != -1){
        if(time.hour > leavingTime.hour || (time.hour == leavingTime.hour && time.minute > leavingTime.minute)){
          setState(() {
            widget.flag = 2;
            widget.msg = "You can\'t enter the app after ${leavingTime.hour < 12 ? leavingTime.hour + 1 : leavingTime.hour > 12 ? leavingTime.hour - 12 : 12}:${leavingTime.minute} ${leavingTime.hour < 12 ? "AM" : "PM"}";
            isLoading = false;
          });
          return;
        }
      }else if(h2 != -1){
        if(time.hour < entryTime.hour || (time.hour == entryTime.hour && time.minute < entryTime.minute)){
          setState(() {
            widget.flag = 2;
            widget.msg = "You can enter the app after ${entryTime.hour < 12 ? entryTime.hour + 1 : entryTime.hour > 12 ? entryTime.hour - 12 : 12}:${entryTime.minute} ${entryTime.hour < 12 ? "AM" : "PM"}";
            isLoading = false;
          });
          return;
        }
      }
      final trackingData = await SQLiteHelper.instance.readFromTrackingTable(date);
      final rule = await SQLiteHelper.instance.readRule();
      rule.forEach((element) {

        if(element.weekDay == today){
          if(element.active){
            List<String> l = (element.durationUsage.split(':'));
            int duration = int.parse(l[0]) *60 + int.parse(l[1]);
            if(trackingData["period"] != null){
              if(duration < trackingData["period"]){
                  setState(() {
                    isLoading = false;
                    widget.flag = 0;
                    block = true;
                  });
                return;
              }
            }
          }
        }
      });
      setState(() {
        isLoading = false;
      });
      if(!block){
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => BlocProvider(create: (_) => IsLoadingCubit(),child: NavScreen(user.email,),)));
      }
    }

  }

  getUser()async{
    final res = await SQLiteHelper.instance.readAllUsers();
    setState(() {
      if(res.isNotEmpty){
        user = res.first;
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    getUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      color: Colors.red,
      child: Scaffold(
        backgroundColor: Color(0xFF0A0D22),
        body: SafeArea(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: AutoSizeText(
                    widget.flag == 1 ? "The app is blocked toady!": widget.flag == 0 ? "You have used the application more than the allowed period!" : widget.msg,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                TextButton(
                  onPressed: () async{
                    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => SetParentalControlPassword(flag: 1,routeFlag: widget.flag == 0 ? 1 : 0,fun: () => getRules(),)));
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Color(0xFFEB1555),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        "Parental Control",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 17
                        ),
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
