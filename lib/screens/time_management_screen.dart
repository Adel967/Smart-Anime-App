import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:netflixbro/sqlite.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../constants.dart';


class TimeManagementScreen extends StatefulWidget {
  const TimeManagementScreen({Key? key}) : super(key: key);

  @override
  State<TimeManagementScreen> createState() => _TimeManagementScreenState();
}

class _TimeManagementScreenState extends State<TimeManagementScreen> {

  Map<String,dynamic> parentalControlData = {"password": "1"};
  List<String> blockedDays = [];
  List<String> allowedDays = [];
  TimeOfDay entryTime = TimeOfDay(hour: 0, minute: 0);
  TimeOfDay leavingTime = TimeOfDay(hour: 0, minute: 0);
  List<String> timeRangeList = ["AM","PM"];
  int min1 = 1;
  int hour1 = 1;
  String timeRange1 = "AM";
  int min2 = 1;
  int hour2 = 1;
  String timeRange2 = "AM";
  late FixedExtentScrollController h1;
  late FixedExtentScrollController m1;
  late FixedExtentScrollController tr1;
  late FixedExtentScrollController h2;
  late FixedExtentScrollController m2;
  late FixedExtentScrollController tr2;
  List<String> weekDays = ["Sa", "Su", "Mo", "Tu", "We","Th", "Fr"];
  List<bool> selectedDays = [false,false,false,false,false,false,false];
  final now = DateTime.now();
  List<DateTime> selectedDates = [];
  List<DateTime> allSelectedDates = [];
  List<DateTime> allowedDates = [];
  late DateRangePickerController dateRangePickerController;
  bool reload = false;
  bool display = false;


  styledContainer({required Widget child,required double padding}){
    return Container(
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
            color: Color(0xFF1C1F32),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                  color: Color(0xFFEB1555),
                  blurRadius: 6,
                  offset: Offset(0.0,0.0)
              )
            ]
        ),
        child: child
    );
  }
  getInfo()async{

    parentalControlData = await SQLiteHelper.instance.readParentalControl();
    blockedDays = List.from(await SQLiteHelper.instance.readBlockedDays());
    allowedDays = List.from(await SQLiteHelper.instance.readAllowedDays());
    String blockedWeekDays = parentalControlData["blockedDays"] == null ? "" : parentalControlData["blockedDays"];
    print("Allowed");
    print(allowedDays);
    if(blockedWeekDays.isNotEmpty){
      List<String> b = (blockedWeekDays.split(','));
      b.forEach((element) {
        if(weekDays.contains(element)){
          selectedDays[weekDays.indexOf(element)] = true;
        }
      });
    }
    print(blockedDays);

    for(int i = 0;i<7;i++){
      if(selectedDays[i] == true){
        selectedDates.addAll(getAllDaysBetweenTwoDates(i));
      }
    }
    print(selectedDates.length);
    selectedDates.removeWhere((element) => allowedDays.contains(element.toString().replaceRange(10, null, "")));
    print(selectedDates.length);
    List<DateTime> ld = List.from(blockedDays.map((e) => DateTime.tryParse(e)).toList());
    print(ld);
    allSelectedDates.addAll(ld);
    allSelectedDates.addAll(selectedDates);
    print(selectedDates);
    print(allSelectedDates);
    final s = parentalControlData["openTime"].toString();
    if(s != "null"){
      entryTime = TimeOfDay(hour:int.parse(s.split(":")[0]),minute: int.parse(s.split(":")[1]));

    }
    final s1 = parentalControlData["closeTime"].toString();
    if(s1 != "null"){
      leavingTime = TimeOfDay(hour:int.parse(s1.split(":")[0]),minute: int.parse(s1.split(":")[1]));
    }
    if(entryTime.hour != 0){
      hour1 = entryTime.hour > 12 ? entryTime.hour - 12: entryTime.hour;
      min1 = entryTime.minute;
      timeRange1 = entryTime.hour > 12 ? "PM" : "AM";
      h1 = FixedExtentScrollController(initialItem: entryTime.hour > 12 ? entryTime.hour - 12 - 1 : entryTime.hour - 1);
      m1 = FixedExtentScrollController(initialItem: entryTime.minute);
      tr1 = FixedExtentScrollController(initialItem: entryTime.hour > 12 ? 1 : 0);
      print("........");
      print(hour1);
      print(min1);
      print(timeRange1);
      print("........");
    }else{
      hour1 = 1;
      min1 = 0;
      timeRange1 = entryTime.hour > 12 ? "PM" : "AM";
      h1 = FixedExtentScrollController(initialItem: 0);
      m1 = FixedExtentScrollController(initialItem: 0);
      tr1 = FixedExtentScrollController(initialItem: 0);
    }
    if(leavingTime.hour != 0){
      hour2 = leavingTime.hour > 12 ? leavingTime.hour - 12 : leavingTime.hour;
      min2 = leavingTime.minute;
      timeRange2 = leavingTime.hour > 12 ? "PM" : "AM";
      h2 = FixedExtentScrollController(initialItem: leavingTime.hour > 12 ? leavingTime.hour - 12 - 1 : leavingTime.hour - 1);
      m2 = FixedExtentScrollController(initialItem: leavingTime.minute);
      tr2 = FixedExtentScrollController(initialItem: leavingTime.hour > 12 ? 1 : 0);
    }else{
      h2 = FixedExtentScrollController(initialItem: 0);
      m2 = FixedExtentScrollController(initialItem: 0);
      tr2 = FixedExtentScrollController(initialItem: 0);
    }

    display = true;
    setState(() {

    });

  }



  buildToast(String msg){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,style: TextStyle(fontSize: 16),),
      backgroundColor: Color(0xFFB63159),
    ));
  }

  reSetValuesControllers(){

    final h11 = h1.initialItem;
    final m11 = m1.initialItem;
    final tr11 = tr1.initialItem;
    h1.dispose();
    m1.dispose();
    tr1.dispose();
    h1 = FixedExtentScrollController(initialItem: h11);
    m1 = FixedExtentScrollController(initialItem: m11);
    tr1 = FixedExtentScrollController(initialItem: tr11);

    final h22 = h2.initialItem;
    final m22 = m2.initialItem;
    final tr22 = tr2.initialItem;
    h2.dispose();
    m2.dispose();
    tr2.dispose();
    h2 = FixedExtentScrollController(initialItem: h22);
    m2 = FixedExtentScrollController(initialItem: m22);
    tr2 = FixedExtentScrollController(initialItem: tr22);

  }

  resetValues(bool b){
    if(b){
      hour1 = h1.initialItem + 1;
      min1 = m1.initialItem;
      timeRange1 = tr1.initialItem == 1 ? "PM" : "AM";
      h1.dispose();
      m1.dispose();
      tr1.dispose();
      h1 = FixedExtentScrollController(initialItem: hour1 > 12 ? hour1 - 12 -1 : hour1 - 1);
      m1 = FixedExtentScrollController(initialItem: min1);
      tr1 = FixedExtentScrollController(initialItem: timeRange1 == "PM" ? 1 : 0);
    }else{
      hour2 = h2.initialItem + 1;
      min2 = m2.initialItem;
      timeRange2 = tr2.initialItem == 1 ? "PM" : "AM";
      h2.dispose();
      m2.dispose();
      tr2.dispose();
      h2 = FixedExtentScrollController(initialItem: hour2 > 12 ? hour2 - 12 -1 : hour2 - 1);
      m2 = FixedExtentScrollController(initialItem: min2);
      tr2 = FixedExtentScrollController(initialItem: timeRange2 == "PM" ? 1 : 0);
    }
  }

  reInitialValuesControllers(bool b){
    if(b){
      h1.dispose();
      m1.dispose();
      tr1.dispose();
      h1 = FixedExtentScrollController(initialItem: hour1 > 12 ? hour1 - 12 -1 : hour1 - 1);
      m1 = FixedExtentScrollController(initialItem: min1);
      tr1 = FixedExtentScrollController(initialItem: hour1 > 12 ? 1 : 0);
    }else{
      h2.dispose();
      m2.dispose();
      tr2.dispose();
      print("hours");
      print(hour2);
      h2 = FixedExtentScrollController(initialItem: hour2 > 12 ? hour2 - 12 -1 : hour2 - 1);
      m2 = FixedExtentScrollController(initialItem: min2);
      tr2 = FixedExtentScrollController(initialItem: hour2 > 12 ? 1 : 0);
    }
  }

  datePicker(){
    return SfDateRangePicker(
      minDate: now,
      maxDate: DateTime(now.year,now.month + 1,DateTime(now.year,now.month + 2,0).day),
      selectionColor: Color(0xFFB63159),
      selectionTextStyle: TextStyle(color: Colors.white,fontSize: 18),
      todayHighlightColor: Color(0xFFB63159),
      headerHeight: 50,
      monthViewSettings: DateRangePickerMonthViewSettings(
          firstDayOfWeek: 6,
          viewHeaderStyle: DateRangePickerViewHeaderStyle(textStyle: TextStyle(color: Colors.white,fontSize: 16))
      ),
      initialSelectedDates: allSelectedDates,
      allowViewNavigation: false,
      navigationMode: DateRangePickerNavigationMode.snap,
      showNavigationArrow: true,
      selectionMode: DateRangePickerSelectionMode.multiple,
      headerStyle: DateRangePickerHeaderStyle(textStyle: TextStyle(color: Colors.white,fontSize: 18),textAlign: TextAlign.center),
      monthCellStyle: DateRangePickerMonthCellStyle(
          textStyle: TextStyle(color: Colors.white,fontSize: 18),
          todayTextStyle: TextStyle(color: Colors.greenAccent),
          disabledDatesTextStyle: TextStyle(color: Colors.grey)
      ),
      yearCellStyle: DateRangePickerYearCellStyle(
          textStyle: TextStyle(color: Colors.red)
      ),
      view: DateRangePickerView.month,
      onSelectionChanged: (selected)async{
        if(selected.value.length > allSelectedDates.length){
          final date = selected.value.last.toString().replaceRange(10, null, "");
          print(date);
          await SQLiteHelper.instance.insertBlockedDays(date);
        }else{
          print(allSelectedDates);
          print(selected.value);
          List<DateTime> output = [];

          allSelectedDates.forEach((element) {
            if(!selected.value.contains(element)){
              output.add(element);
            }
          });
          String date = output.first.toString().replaceRange(10, null, "");
          if(selectedDates.contains(output.first)){
            print("allow");
            selectedDates.remove(output.first);
            allSelectedDates.remove(output.first);
            await SQLiteHelper.instance.insertAllowedDays(date);
          }else{
            print("unblock");
            allSelectedDates.remove(output.first);
            await SQLiteHelper.instance.unBlockDate(date);
          }
        }
      },
    );
  }

  List<DateTime> getAllDaysBetweenTwoDates(int index){
    DateTime firstDate = now;
    DateTime lastDate = DateTime(now.year,now.month + 1,DateTime(now.year,now.month + 2,0).day);
    List<DateTime> list = [];
    while(firstDate.compareTo(lastDate) < 0) {
      String today = DateFormat('EEEE').format(firstDate).substring(0, 2);

      if (today == weekDays[index]) {
        list.add(firstDate);
      }
      firstDate = firstDate.add(Duration(days: 1));
    }
    return list;
  }

  setBlockDay(int index)async{
    if(selectedDays[index]){
      final res = await SQLiteHelper.instance.readParentalControl();
      String blockedDays = res["blockedDays"] == null ? "" : res["blockedDays"];
      print(blockedDays);
      List<String> b  = [];
      if(blockedDays.isNotEmpty){
        b = List.from(blockedDays.split(','));
      }
      b.add(weekDays[index]);


      await SQLiteHelper.instance.setBlockedDays(b.join(","));
      setState(() {
        reload = true;
      });

      Future.delayed(Duration(seconds: 1),()async{
        final list = getAllDaysBetweenTwoDates(index);
        selectedDates.addAll(list);
        allSelectedDates.addAll(list);
        print(selectedDates);
        setState(() {
          reload = false;
        });
        List<String> l = list.map((e) => e.toString().replaceRange(10, null, "")).toList();
        await SQLiteHelper.instance.deleteBlockedDays(l);
      });
    }else{
      final res = await SQLiteHelper.instance.readParentalControl();
      String blockedDays = res["blockedDays"];
      List<String> b = (blockedDays.split(','));
      b.remove(weekDays[index]);
      await SQLiteHelper.instance.setBlockedDays(b.join(","));
      setState(() {
        reload = true;
      });
      Future.delayed(Duration(seconds: 1),()async{
        final list = getAllDaysBetweenTwoDates(index);
        selectedDates.removeWhere((element) => list.contains(element));
        allSelectedDates.removeWhere((element) => list.contains(element));

        setState(() {
          reload = false;
        });
        List<String> l = list.map((e) => e.toString().replaceRange(10, null, "")).toList();
        await SQLiteHelper.instance.deleteAllowedDay(l);
      });
    }
    setState(() {

    });

  }

  showTimeSelector(bool b){ //true:entryTime false:leavingTime
    resetValues(true);
    resetValues(false);
    return showCupertinoModalPopup(
      context: context,
      builder: (_) => CupertinoActionSheet(
        actions: [selectTime(b),],
        cancelButton: CupertinoActionSheetAction(
          child: Text(
            "Save",
            style: TextStyle(
                color: Colors.black
            ),
          ),
          onPressed: () async{
            final t ;
            int h ;
            int m ;

            if(b){
              t = timeRange1;
              h = hour1;
              m = min1;
            }else{
              t = timeRange2;
              h = hour2;
              m = min2;
            }
            if(t == "PM" && (h < 13)){
              h += 12;
              b ? hour1 += 12 : hour2 += 12;
            }
            if(b){
              print("object");
              if(leavingTime.hour != 0){
                print("object");
                print(m - leavingTime.minute);
                if(h > leavingTime.hour || (h == leavingTime.hour && m > leavingTime.minute)){
                  if(timeRange1 == timeRange2 && ((h == 12 && hour2 != 12) || (h == 24 && hour2 != 24))){
                    print("object");
                    entryTime = TimeOfDay(hour: h, minute: m);
                    await SQLiteHelper.instance.setOpeningTime("${entryTime.hour}:$m");
                    saveParentalControlData();
                    reInitialValuesControllers(true);
                  }else{
                    print("object");
                    Navigator.of(context).pop();
                    buildToast("Entry time can't be after closing time!");
                    resetValues(true);
                    return;
                  }


                }else if(h == leavingTime.hour && (m - leavingTime.minute).abs() < 30){
                  Navigator.of(context).pop();
                  buildToast("It should be at least 30 min between entry and leaving time!");
                  resetValues(true);
                  return;
                }else{
                  print("object");
                  entryTime = TimeOfDay(hour: h, minute: m);
                  await SQLiteHelper.instance.setOpeningTime("${entryTime.hour}:$m");
                  saveParentalControlData();
                  reInitialValuesControllers(true);
                }
              }else{
                print("object");
                entryTime = TimeOfDay(hour: h, minute: m);
                await SQLiteHelper.instance.setOpeningTime("${entryTime.hour}:$m");
                saveParentalControlData();
                reInitialValuesControllers(true);
              }
            }else{
              if(entryTime.hour != 0){
                print("object");
                print(entryTime.hour);
                if(h == entryTime.hour && (m - entryTime.minute).abs() < 30){
                  Navigator.of(context).pop();
                  buildToast("It should be at least 30 min between entry and leaving time!");
                  resetValues(true);
                  return;
                }else if(h < entryTime.hour || (h == entryTime.hour && m < entryTime.minute)){
                  if(timeRange1 == timeRange2 && ((h == 12 && hour1 != 12) || (h == 24 && hour1 != 24))){
                    print("object");
                    leavingTime = TimeOfDay(hour: h, minute: m);
                    await SQLiteHelper.instance.setClosingTime("$h:$m");
                    saveParentalControlData();
                    reInitialValuesControllers(false);
                  }
                  print("object");
                  print("Entry time can't be after closing time!");
                  resetValues(false);
                  Navigator.of(context).pop();
                  buildToast("Entry time can't be after closing time!");
                  return;
                }else{
                  print("object2");
                  leavingTime = TimeOfDay(hour: h, minute: m);
                  await SQLiteHelper.instance.setClosingTime("$h:$m");
                  saveParentalControlData();
                  reInitialValuesControllers(false);
                }
              }else{
                print("object1");
                leavingTime = TimeOfDay(hour: h, minute: m);
                await SQLiteHelper.instance.setClosingTime("$h:$m");
                saveParentalControlData();
                reInitialValuesControllers(false);
              }
            }
            setState(() {

            });
            Navigator.of(context).pop();

          },
        ),
      ),
    );
  }

  getTime(TimeOfDay t){
    print(t.hour);
    print(t.minute);
    if(t.hour !=0){
      if(t.hour > 12){
        return "${(t.hour-12) < 10 ? (t.hour-12).toString().padLeft(2,"0") : (t.hour-12)}:${t.minute < 10 ? t.minute.toString().padLeft(2,"0") : t.minute} PM";
      }else{
        return "${(t.hour) < 10 ? (t.hour).toString().padLeft(2,"0") : (t.hour)}:${t.minute < 10 ? t.minute.toString().padLeft(2,"0") : t.minute} AM";
      }
    }else{
      return "anytime";
    }
  }

  selectTime(bool b){
    return Container(
        height: 350,
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: CupertinoPicker(
                scrollController: b ? h1 : h2,
                useMagnifier: false,
                itemExtent: 64,
                children:  List.generate(12, (index) => Center(
                  child: Text(
                    (index + 1).toString(),
                    style: TextStyle(
                      fontSize: 25,
                    ),
                  ),
                )),
                onSelectedItemChanged: (index){
                  b ? hour1 = index + 1 :hour2 = index + 1;
                  reSetValuesControllers();
                },
                looping: true,
              ),
            ),
            Text(
              ":",
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                  decoration: TextDecoration.none,
                  fontSize: 40
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                scrollController: b ? m1 : m2,
                itemExtent: 64,
                children: List.generate(60, (index) => Center(
                  child: Text(
                    (index).toString(),
                    style: TextStyle(
                        fontSize: 25
                    ),
                  ),
                )),
                onSelectedItemChanged: (index){
                  b ?  min1= index : min2 = index;
                  reSetValuesControllers();
                },
                looping: true,
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                scrollController: b ? tr1 : tr2,
                itemExtent: 64,
                children: timeRangeList.map((e) => Center(child: Text(e,style: TextStyle(fontSize: 25),),),).toList(),
                onSelectedItemChanged: (index){
                  b ? timeRange1 = timeRangeList[index] : timeRange2 = timeRangeList[index];
                  reSetValuesControllers();
                },
              ),
            ),
          ],
        )
    );
  }

  @override
  void initState() {
    // DateTime now = DateTime.now();
    // String formattedDate = DateFormat('kk:mm').format(now);
    final s = "7:30";
    TimeOfDay t = TimeOfDay(hour:int.parse(s.split(":")[0]),minute: int.parse(s.split(":")[1]));
    print(t.hour);
    //print(formattedDate);
    getInfo();

    super.initState();
  }

  @override
  void dispose() {
    h1.dispose();
    h2.dispose();
    m1.dispose();
    m2.dispose();
    tr1.dispose();
    tr2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
        backgroundColor: Color(0xFF0A0D22),
        appBar: AppBar(
          title: Text(
            "Time Management",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          backgroundColor: Color(0xFF0A0D22),
          elevation: 0,
        ),
        body: !display ? Center(child: CircularProgressIndicator(color: Colors.red,)) : Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                      child: GestureDetector(
                        onTap: () => showTimeSelector(true),
                        child: styledContainer(
                          padding: 5,
                          child: SizedBox(
                            height: 130,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Opening Time",
                                    style: TextStyle(
                                        color: Colors.grey.shade500,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600
                                    ),
                                  ),
                                  SizedBox(height: 10,),
                                  Text(
                                    getTime(entryTime),
                                    style: TextStyle(
                                        color: parentalControlData["openTime"].toString().isNotEmpty ? Colors.white : Colors.red,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                  ),

                  SizedBox(width: 20,),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => showTimeSelector(false),
                      child: styledContainer(
                        padding: 5,
                        child: SizedBox(
                          height: 130,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Closing Time",
                                  style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600
                                  ),
                                ),
                                SizedBox(height: 10,),
                                Text(
                                  getTime(leavingTime),
                                  style: TextStyle(
                                      color: parentalControlData["closeTime"].toString().isNotEmpty ? Colors.white : Colors.red,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20,),
              Expanded(
                child: styledContainer(
                  padding: 10,
                  child: SizedBox(
                      width: double.infinity,
                      child: Column(
                        children: [
                          Text(
                            "Blocked Days",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 15,),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: List.generate(7, (index) =>
                                  Expanded(
                                    child: Row(
                                      children: [
                                        SizedBox(width: 3,),
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: (){
                                              selectedDays[index] = !selectedDays[index];
                                              setBlockDay(index);
                                              setState(() {
                                              });
                                            },
                                            child: Container(
                                                padding: EdgeInsets.all(15),
                                                decoration: BoxDecoration(
                                                    color: selectedDays[index] ? Color(0xFFB63159) : Color(0xFF1C1F32),
                                                    shape: BoxShape.circle,
                                                    border: Border.all(color: Color(0xFFB63159),width: 1)
                                                ),
                                                child: Text(
                                                  weekDays[index][0],
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 15,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                )
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 3,),
                                      ],
                                    ),
                                  ),
                              ).toList()
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Divider(
                            thickness: 0.7,
                            indent: 60,
                            endIndent: 60,
                            color: Color(0xFFB63159),
                          ),
                          Expanded(
                              child: reload ? Center(child: CircularProgressIndicator(color: Colors.red,)) : datePicker()
                          ),
                        ],
                      )
                  ),
                ),
              ),
            ],
          ),
        )
    );
  }
}
