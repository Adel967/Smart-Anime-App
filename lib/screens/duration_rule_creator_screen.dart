import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:netflixbro/constants.dart';
import 'package:netflixbro/models/duration_rule.dart';
import 'package:netflixbro/sqlite.dart';

class DurationRuleCreatorScreen extends StatefulWidget {
  final DurationRule rule;
  const DurationRuleCreatorScreen({Key? key,required this.rule}) : super(key: key);

  @override
  State<DurationRuleCreatorScreen> createState() => _DurationRuleCreatorScreenState();
}

class _DurationRuleCreatorScreenState extends State<DurationRuleCreatorScreen> {

  late FixedExtentScrollController hourController;
  late FixedExtentScrollController minuteController;
  late FixedExtentScrollController episodeController;
  List<DurationRule> list = [];
  int hourValue = 0;
  int minuteValue = 0;
  int episodeValue = 3;
  List<String> weekDays = ["Sat", "Sun", "Mon", "Tue", "Wed","Thu", "Fri"];
  List<bool> selectedDays = [false,false,false,false,false,false,false];
  List<bool> disableDays = [false,false,false,false,false,false,false];
  bool loading  = true;

  buildToast(String msg){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,style: TextStyle(fontSize: 16),),
      backgroundColor: Color(0xFFB63159),
    ));
  }

  getList()async{
    loading = false;
    setState(() {});
    final res = await SQLiteHelper.instance.readRule();
    list = List.from(res);
    print(list);
    loading = false;
    weekDays.forEach((element) {
      list.forEach((element1) {
        if(element1.weekDay == element ){
          disableDays[weekDays.indexOf(element)] = true;
        }
      });
    });
    setState(() {});
  }

  @override
  void initState() {

    super.initState();

    if(widget.rule.durationUsage != "00:00"){
      hourValue = int.parse(widget.rule.durationUsage.split(":")[0]);
      minuteValue = int.parse(widget.rule.durationUsage.split(":")[1]);
      episodeValue = int.parse(widget.rule.epNum);
    }
    hourController = FixedExtentScrollController(initialItem: hourValue );
    minuteController = FixedExtentScrollController(initialItem: (minuteValue/10).round());
    episodeController = FixedExtentScrollController(initialItem: episodeValue - 1);
    getList();
    setState(() {

    });
  }

  @override
  void dispose() {
    hourController.dispose();
    minuteController.dispose();
    episodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0A0D22),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Time Duration",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  "${hourValue < 10 ? hourValue.toString().padLeft(2,"0") : hourValue}:${minuteValue < 10 ? minuteValue.toString().padLeft(2,"0") : minuteValue} ${hourValue > 1 ? "hours" : "hour"}",
                  style: const TextStyle(
                    color: Color(0xFFB63159),
                    fontSize: 30
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 70.0),
                  child: SizedBox(
                    height: 180,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: CupertinoPicker(
                            scrollController: hourController,
                            useMagnifier: false,
                            itemExtent: 64,
                            onSelectedItemChanged: (index){
                              hourValue = index;
                              setState(() {

                              });
                            },
                            looping: true,
                            children: List.generate(11, (index) => Center(
                              child: Text(
                                (index).toString(),
                                style: const TextStyle(
                                  fontSize: 25,
                                  color: Colors.white,
                                ),
                              ),
                            )),
                          ),
                        ),
                        const Text(
                          ":",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                        Expanded(
                          child: CupertinoPicker(
                            scrollController: minuteController,
                            useMagnifier: false,
                            itemExtent: 64,
                            onSelectedItemChanged: (index){
                              minuteValue = index * 10;
                              setState(() {

                              });
                            },
                            looping: true,
                            children: List.generate(6, (index) => Center(
                              child: Text(
                                (index * 10).toString(),
                                style: const TextStyle(
                                  fontSize: 25,
                                  color: Colors.white
                                ),
                              ),
                            )),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                const Divider(
                  thickness: 0.7,
                  indent: 80,
                  endIndent: 80,
                  color: Color(0xFFB63159),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  "Episodes Count",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold
                  ),
                ),
                const SizedBox(
                  height: 10
                ),
                Text(
                  "${episodeValue < 10 ? episodeValue.toString().padLeft(2,"0") : episodeValue} ${episodeValue > 1 ? "episodes" : "episode"}",
                  style: const TextStyle(
                      color: Color(0xFFB63159),
                      fontSize: 30
                  ),
                ),
                SizedBox(height: 20,),
                SizedBox(
                  width: 100,
                  height: 180,
                  child: CupertinoPicker(
                    scrollController: episodeController,
                    useMagnifier: false,
                    itemExtent: 64,
                    onSelectedItemChanged: (index){
                      episodeValue = index + 1;
                      setState(() {

                      });
                    },
                    looping: true,
                    children: List.generate(20, (index) => Center(
                      child: Text(
                        (index + 1).toString(),
                        style: const TextStyle(
                            fontSize: 25,
                            color: Colors.white
                        ),
                      ),
                    )),
                  ),
                ),
                const Divider(
                  thickness: 0.7,
                  indent: 60,
                  endIndent: 60,
                  color: Color(0xFFB63159),
                ),
                SizedBox(
                  height: 20,
                ),
                widget.rule.weekDay.isNotEmpty ? SizedBox.shrink() : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(7, (index) =>
                        Expanded(
                          child: Row(
                            children: [
                              SizedBox(width: 3,),
                              Expanded(
                                child: GestureDetector(
                                  onTap: (){
                                    if(disableDays[index]){
                                      buildToast("You already have created a rule for this day!");
                                    }else{
                                      selectedDays[index] = !selectedDays[index];
                                    }
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
                                          color: disableDays[index] ? Colors.grey : Colors.white,
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
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 5.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(
                              "Cancel",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextButton(
                            onPressed: () async{
                              print(hourValue);
                              print(minuteValue);
                              if((hourValue == 0 && minuteValue == 0) || (hourValue == 0 && minuteValue == 10)){
                              buildToast("Time Duration should be at least 20 minutes!");
                              }else if(widget.rule.weekDay.isEmpty){
                                int x = 0;
                                selectedDays.forEach((element) {
                                  if(element){
                                    x++;
                                  }
                                });
                                if(x != 0){
                                  List<DurationRule> rules = [];
                                  for(int i = 0;i<7;i++){
                                    if(selectedDays[i]){
                                      rules.add(DurationRule(weekDays[i],"$hourValue:$minuteValue ", "$episodeValue", true));
                                    }
                                  }
                                  rules.forEach((element) async{
                                    await SQLiteHelper.instance.insertRule(element);
                                  });
                                  saveParentalControlData();
                                  Navigator.of(context).pop();
                                }else{
                                  buildToast("You have to choose at least one day!");
                                }
                              }else if((hourValue == 0 && minuteValue == 0) || (hourValue == 0 && minuteValue == 10)){
                                buildToast("Time Duration should be at least 20 minutes!");
                              }else{
                                if(hourValue == int.parse(widget.rule.durationUsage.split(":")[0]) && minuteValue == int.parse(widget.rule.durationUsage.split(":")[1]) && episodeValue == int.parse(widget.rule.epNum)){
                                  buildToast("You did not change any rule!");
                                }else{
                                  final rule = DurationRule(widget.rule.weekDay,"$hourValue:$minuteValue", "$episodeValue", widget.rule.active);
                                  await SQLiteHelper.instance.updateRule(rule);
                                  saveParentalControlData();
                                  Navigator.of(context).pop();
                                }
                              }
                            },

                            child: Text(
                              "Save",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      ],
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
