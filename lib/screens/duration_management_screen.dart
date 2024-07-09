import 'package:flutter/material.dart';
import 'package:netflixbro/constants.dart';
import 'package:netflixbro/screens/duration_rule_creator_screen.dart';
import 'package:netflixbro/sqlite.dart';

import '../models/duration_rule.dart';

class DurationManagementScreen extends StatefulWidget {
  const DurationManagementScreen({Key? key}) : super(key: key);

  @override
  State<DurationManagementScreen> createState() => _DurationManagementScreenState();
}

class _DurationManagementScreenState extends State<DurationManagementScreen> {

  List<DurationRule> list  = [];
  List<int> selectedItem  = [];
  bool loading = true;
  bool delete = false;
  bool selectAll = false;



  getList()async{
    loading = false;
    setState(() {});
    final res = await SQLiteHelper.instance.readRule();
    list = List.from(res);
    print(list);
    loading = false;

    setState(() {});
  }

  buildToast(String msg){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,style: TextStyle(fontSize: 16),),
      backgroundColor: Color(0xFFB63159),
    ));
  }

  @override
  void initState() {
    getList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0A0D22),
      appBar: AppBar(
        title: Text(
          "Duration Management",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 8),
            child: IconButton(
              icon: Icon(Icons.add),
              color: list.length <7 && !delete ? Colors.white : Colors.grey,
              splashColor: Colors.transparent,
              focusColor: Colors.transparent,
              highlightColor: Colors.transparent,
              iconSize: 30,
              onPressed: () {
                if(!delete){
                  if(list.length < 7){
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => DurationRuleCreatorScreen(rule: DurationRule("", "00:00", "0", false),))).then((value) => getList());
                  }else{
                    buildToast("You can't have more than 7 usage rules!");
                  }
                }
              },
            ),
          )
        ],
        centerTitle: true,
        backgroundColor: Color(0xFF0A0D22),
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            AnimatedContainer(
              padding: EdgeInsets.symmetric(horizontal: 15),
              duration: Duration(milliseconds: 600 ),
              height: delete ? 150 : 0,
              child: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: Text(
                        "${selectedItem.length} selected",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: (){
                              selectAll = !selectAll;
                              if(selectAll){
                                selectedItem.clear();
                                for(int i = 0;i<list.length;i++){
                                  selectedItem.add(i);
                                }
                              }else{
                                selectedItem.clear();
                              }
                              setState(() {

                              });
                            },
                            child: delete ? Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Flexible(
                                  child: Container(
                                      alignment: Alignment.center,
                                      width: 22,
                                      height: 22,
                                      decoration: BoxDecoration(
                                          color: selectAll ? Colors.red : Colors.transparent,
                                          border: Border.all(color: Colors.red),
                                          shape: BoxShape.circle
                                      ),
                                      child: selectAll ? Icon(
                                        Icons.done,
                                        color: Colors.white,
                                        size: 18,
                                      ):SizedBox.shrink()
                                  ),
                                ),
                                Flexible(child: SizedBox(height: 5,)),
                                Flexible(child:
                                  Text(
                                    "All",
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  )
                                ),
                              ],
                            ):SizedBox.shrink()
                          ),
                          SizedBox(width: 10,),
                          GestureDetector(
                            onTap: (){
                              delete = false;
                              selectAll = false;
                              selectedItem.clear();
                              setState(() {

                              });
                            },
                            child: delete ? Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Flexible(child: Icon(Icons.close,color: Colors.white,size: 30,)),
                                Flexible(
                                  child: Text(
                                      "cancel",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                      )
                                  ),
                                )
                              ],
                            ):SizedBox.shrink()
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ) ,
            Expanded(
              child: ListView.builder(
                itemCount: list.length,
                itemBuilder: (context,index){
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: GestureDetector(
                      onTap: (){
                        if(delete){
                          if(selectedItem.contains(index)){
                            selectedItem.remove(index);
                          }else{
                            selectedItem.add(index);
                          }
                        }else{
                          Navigator.of(context).push(MaterialPageRoute(builder: (_) => DurationRuleCreatorScreen(rule: list[index],))).then((value) => getList());
                        }
                        setState(() {

                        });
                      },
                      onLongPress: (){
                        delete = true;
                        selectedItem.add(index);
                        setState(() {

                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(15),
                        margin: EdgeInsets.symmetric(vertical: 10),
                        height: 120,
                        decoration: BoxDecoration(
                          color: Color(0xFF1C1F32),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                                color: Color(0xFFEB1555),
                                blurRadius: 6,
                                offset: Offset(0.0,0.0)
                            )
                          ]
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            delete ? Row(
                              children: [
                                Container(
                                  alignment: Alignment.center,
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                      color: selectedItem.contains(index) ? Colors.red : Colors.transparent,
                                      border: Border.all(color: Colors.red),
                                      shape: BoxShape.circle
                                  ),
                                  child: selectedItem.contains(index) ? Icon(
                                    Icons.done,
                                    color: Colors.white,
                                    size: 18,
                                  ):SizedBox.shrink()
                                ),
                                SizedBox(width: 15,)
                              ],
                            ) : SizedBox.shrink(),
                            Text(
                              list[index].weekDay,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w600
                              ),
                            ),
                            SizedBox(
                              width: 30,
                            ),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${list[index].durationUsage} hrs",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600
                                    ),
                                  ),
                                  SizedBox(height: 10,),
                                  Text(
                                    "${list[index].epNum} ${int.parse(list[index].epNum) > 1 ? "episodes" : "episode"}",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            delete ? SizedBox.shrink() : Switch(
                              value: list[index].active,
                              onChanged: (value){
                                list[index].active = !list[index].active;
                                SQLiteHelper.instance.updateRule(list[index]);
                                saveParentalControlData();
                                setState(() {

                                });
                              },
                              inactiveTrackColor: Colors.red.shade300,
                              activeColor: Colors.white,
                              activeTrackColor: Colors.green.shade300,
                              focusColor: Colors.blue,
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            AnimatedContainer(
              padding: EdgeInsets.only(top: 5),
              duration: Duration(milliseconds: 600 ),
              height: selectedItem.length > 0 ? 80 : 0,
              child: GestureDetector(
                onTap: (){
                  selectedItem.forEach((element) async{
                    await SQLiteHelper.instance.removeRule(list[element].weekDay);
                  });
                  delete = false;
                  selectAll = false;
                  selectedItem.clear();
                  getList();
                  saveParentalControlData();
                  setState(() {

                  });
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(child: Icon(Icons.delete,color: Colors.white,size: selectedItem.length > 0 ? 30 : 0,)),
                    Expanded(
                      child: Text(
                        "Delete",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: selectedItem.length > 0 ? 18 : 0
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ) ,
          ],
        ),
      ),
    );
  }
}
