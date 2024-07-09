import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:netflixbro/models/duration_rule.dart';
import 'package:netflixbro/screens/parentalControl_password.dart';
import 'package:netflixbro/screens/setup_parental_control.dart';
import 'package:netflixbro/screens/watched_anime_screen.dart';
import 'package:netflixbro/services.dart';
import 'package:netflixbro/sqlite.dart';
import 'package:intl/intl.dart';
import 'package:netflixbro/widgets/bar_chart.dart';
import 'package:netflixbro/widgets/settings_card.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../widgets/customdropdownbutton.dart';



class ParentalControl extends StatefulWidget {
  const ParentalControl({super.key});

  @override
  _ParentalControlState createState() => _ParentalControlState();
}

class _ParentalControlState extends State<ParentalControl> {
  List<Map<String,dynamic>> data = [];
  List<Map<String,dynamic>> weekData = [];
  List<Map<String,dynamic>> allData = [];
  int index = 0;
  List<String> weekDays = ["Sa", "Su", "Mo", "Tu", "We","Th", "Fr"];
  List<String> months = ["Jan", "Feb", "Mar", "Apr", "May","Jun", "Jul","Aug","Sept","Oct","Nov","Dec"];
  int isFirstWeek = 1; //1:first ....-1:last.....0:middle.....2:first-last
  int isFirstYear = 1; //1:first ....-1:last.....0:middle.....2:first-last
  String dropDown1Value = "weekly";
  String dropDown2Value = "hours";
  final List<String> dropDown1Items = ["weekly","monthly","yearly"];
  final List<String> dropDown2Items = ["hours","episodes"];
  final List<String> unClickableKey1 = [];
  final List<String> unClickableKey2 = [];
  bool isLoading = false;
  List<Map<String,int>> monthsData = [];
  late int currentYear;
  List<String> availableYears = [];
  List<Map<String,int>> yearsInfo = [];
  List<Map<String,String>> category = [];
  late bool parentalControlIsLoaded;



  styledContainer({required Widget child,required double padding}){
    return Container(
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
            color: const Color(0xFF1C1F32),
            borderRadius: BorderRadius.circular(15),
            boxShadow: const [
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

  double countWeeklyHours(){
    double num = 0;
    for (var element in weekData) {
      num += element["period"]/60;
    }

    return num;
  }

  countWeeklyEpisodes(){
    int num = 0;
    for (var element in weekData) {
      num += element["episodeNum"] as int;
    }

    return num;
  }

  double countYearHours(List<dynamic> list){
    double num = 0;
    for (var element in list) {
      num += element["period"] as int;
    }

    return num;
  }

  countYearEpisodes(List<dynamic> list){
    int num = 0;
    for (var element in list) {
      num += element["episodeNum"] as int;
    }

    return num;
  }

  getLastWeekData()async{
    allData.addAll(weekData);
    weekData = [];
    data = List.from(await SQLiteHelper.instance.readLast7RowsFromTrackingTable(index));
    if(allData.isNotEmpty){
      if(data.length < 7){
        isFirstWeek = -1;
      }else{
        isFirstWeek = 0;
      }
    }
    DateTime date  = DateTime.tryParse(data.first["date"]) as DateTime;
    String weekDay  = DateFormat('EEEE').format(date).substring(0,2);

    weekDays.forEach((element) {
      if(weekDay == element){
        int x = 7 - (weekDays.indexOf(element) + 1);
        while(x > 0){
          DateTime date1 = DateTime(date.year,date.month,date.day + x);
          final d  = date1.toString().replaceRange(10, null, "");
          weekData.add({
            "date": d,
            "firstOpen":"",
            "lastOpen":"",
            "period": 0,
            "episodeNum": 0
          });
          x--;
        }
      }
    });

    for(int i = 0; i < 7; i++){
      if(data.isNotEmpty && daysBetween(DateTime.tryParse(data[i]["date"]) as DateTime, DateTime.tryParse(weekData.isNotEmpty ? weekData.last["date"] : data[0]["date"]) as DateTime) <= 1){
        weekData.add(data[i]);
        data.removeAt(i);
        index++;
        i--;
      }else{
        DateTime date  = DateTime.tryParse(weekData.last["date"]) as DateTime;
        DateTime date1 = DateTime(date.year,date.month,date.day - 1);
        final d  = date1.toString().replaceRange(10, null, "");
        weekData.add({
          "date": d,
          "firstOpen":"",
          "lastOpen":"",
          "period": 0,
          "episodeNum": 0
        });
        i--;
      }
      if(weekData.length == 7){
        break;
      }
    }

    setState(() {

    });
  }

  getWeekData(bool b){ //true next week......false last week
    if(b){
      weekData.forEach((element) {
        if(element["firstOpen"].toString().isNotEmpty){
          index--;
        }
      });

      weekData = List.from(allData.sublist(allData.length - 7,allData.length));
      allData.removeRange(allData.length - 7,allData.length);
      if(allData.isNotEmpty){
        isFirstWeek = 0;
      }else{
        isFirstWeek = 1;
      }
      setState(() {});
    }else{
      getLastWeekData();
    }
    checkDataAvailability();
  }

  getTitle(){
    if(dropDown1Value == "weekly"){
      return getDate();
    }else{
      return currentYear.toString();
    }
  }

  getAvailableYears()async{
    availableYears =  List.from(await SQLiteHelper.instance.checkYearsInfoAvailability(currentYear));
    if(availableYears.isNotEmpty){
      isFirstYear = 1;
    }else{
      isFirstYear = 2;
    }
    getYearsData();
  }

  getYearData(bool b){ //true next year......false last year
    if(b){
      getMonthsData(currentYear + 1);
      if(availableYears.first == (currentYear + 1).toString()){
        isFirstYear = 1;
      }else{
        isFirstYear = 0;
      }
      currentYear += 1;
    }else{
      getMonthsData(currentYear - 1);
      if(availableYears.last == (currentYear - 1).toString()){
        isFirstYear = -1;
      }else{
        isFirstYear = 0;
      }
      currentYear -= 1;
    }
    setState(() {

    });
  }


  getDate(){
    DateTime date1 = DateTime.tryParse(weekData.reversed.first["date"]) as DateTime;
    DateTime date2 = DateTime.tryParse(weekData.reversed.last["date"]) as DateTime;
    String month1  = DateFormat('MMMM').format(date1).substring(0,3);
    String month2  = DateFormat('MMMM').format(date2).substring(0,3);
    setState(() {

    });
    return '$month1 ${date1.day}, ${date1.year}-$month2 ${date2.day}, ${date2.year}';
  }

  int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }

  generateExpense(){
    if(dropDown1Value == "weekly"){
      if(dropDown2Value == "hours") {
        return List.of(weekData.map((e) => e["period"]/60).toList().reversed).cast<double>();
      } else {
        return List.of(weekData.map((e) => e["episodeNum"]).toList().reversed).cast<int>();
      }
    }else if(dropDown1Value == "monthly"){
      if(dropDown2Value == "hours") {
        return List.of(monthsData.map((e) => e["period"]).toList()).cast<int>();
      } else {
        return List.of(monthsData.map((e) => e["episodeNum"]).toList()).cast<int>();
      }
    }
  }

  getHoursAndEpisodes(){
    Map<String,String> map;
    dynamic hours = 0;
    dynamic episodes = 0;
    if(dropDown1Value == "yearly"){
      yearsInfo.forEach((element) {
        hours += element["hours"]!.round();
        episodes += element["episodes"]!.round();
      });
    }else if(dropDown1Value == "weekly"){
      hours = countWeeklyHours();
      episodes = countWeeklyEpisodes();
    }else{
      hours = countYearHours(monthsData).round();
      episodes = countYearEpisodes(monthsData);
    }
    map = {
      "hours" : hours is int ? hours.toString() : hours.toStringAsFixed(1),
      "episodes" : episodes.toString(),
    };

    return map;
  }

  checkDataAvailability() async{
    unClickableKey1.clear();
    unClickableKey2.clear();
    if(!await SQLiteHelper.instance.checkMonthlyInfo()) {
      unClickableKey1.add("monthly");
    }

    if(!await SQLiteHelper.instance.checkYearlyInfo()) {
      unClickableKey1.add("yearly");
    }

    if(dropDown1Value == "yearly"){
       return;
    }
    int episodes = 0;
    if(dropDown1Value == "weekly"){
      for (var element in weekData) {
        episodes += element["episodeNum"] as int;
      }
    }else if(dropDown1Value == "monthly"){
      for (var element in monthsData) {
        episodes += element["episodeNum"] as int;
      }
    }
    if(episodes == 0){
      unClickableKey2.add("episodes");
    }

    setState(() {

    });
  }

  stringToList(String text){
    List<String> result = text.split(', ');
    return result;
  }

  getParentalControlData() async{
    final res = await SQLiteHelper.instance.readParentalControl();
    parentalControlIsLoaded = res["password"].toString().isNotEmpty;
  }

  getWatchedAnimeKinds()async{
    final res  = await SQLiteHelper.instance.readAllWatchedAnime();
    List<List<String>> l = [];

    // for(int i=0;i<res.length;i++){
    //   l.add(stringToList(res[i].kind));
    // }

    Map<String,int> m = {
      "Action":5,
      "Adventure":15,
      "Comedy":3,
      "Shounen":2,
      "Romance":3,
      "Horror":0,
      "Mystery":3,
      "Psychological":0,
      "Martial-Arts":0,
      "Drama":0,
    };
    for(int i=0;i<l.length;i++) {
      for(int j=0;j<l[i].length;j++) {
        m[l[i][j]] = m[l[i][j]]! + 1;
      }
    }
    List<Map<String,String>> list = [];
    m.forEach((key, value) { 
      if(value != 0){
        list.add({
          "category":key,
          "value":value.toString()
        });
      }
    });
    category = List.from(list);
    setState(() {

    });

  }

  getYearsData() async{
    for(int i=0;i<availableYears.length;i++)  {
      List<dynamic> l = await loadMonthsData(int.parse(availableYears[i]));
      int x = countYearHours(l).round();
      int y = countYearEpisodes(l);
      yearsInfo.add({
        "year" : int.parse(availableYears[i]),
        "hours" : x,
        "episodes" : y
      });

      setState(() {

      });
    }


  }

  Future<List<dynamic>> loadMonthsData(int year) async{
    List<dynamic> list = [];
    for(int i=1;i<13;i++){
      list.add(await SQLiteHelper.instance.getMonthData(year, i));
    }
    return list;
  }

  getMonthsData(int year) async{

    monthsData = List.from(await loadMonthsData(year));
    setState(() {

    });
  }

  buildToast(String msg){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,style: const TextStyle(fontSize: 16),),
      backgroundColor: const Color(0xFFB63159),
    ));
  }

  moveToManageUsage()async{
    if(parentalControlIsLoaded){
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SetParentalControlPassword(flag: 1)));
    }else{
      setState(() {
        isLoading = true;
      });
      final res = await Services.readParentalControl();
      if(res["password"].toString().isEmpty){
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SetUpParentalControl()));
      }else if(res["password"].toString() == "There is a problem! try again later"){
        buildToast("There is a problem! try again later");
      }else{
        //parental control exist
        await SQLiteHelper.instance.insertParentalControl(res["password"]);
        await SQLiteHelper.instance.setOpeningTime(res["openTime"]);
        await SQLiteHelper.instance.setClosingTime(res["closeTime"]);
        await SQLiteHelper.instance.setBlockedCategories(res["blockedCategories"]);
        String blockedAnimes = res["blockedAnime"];
        List<String> b = List.from(blockedAnimes.split(","));
        b.forEach((element) {
          SQLiteHelper.instance.insertBlockedAnime(element);
        });
        String rules = res["rules"];
        List<String> r = List.from(rules.split(","));
        r.forEach((element) {
          List<String> s = List.from(element.split("."));
          DurationRule dr = DurationRule(s[0], s[1], s[2], s[3] == "true" ? true : false);
          SQLiteHelper.instance.insertRule(dr);
        });
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SetParentalControlPassword(flag: 1)));
      }
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    currentYear = DateTime.now().year;
    getAvailableYears();
    getLastWeekData();
    getWatchedAnimeKinds();
    checkDataAvailability();
    getMonthsData(currentYear);
    getParentalControlData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      progressIndicator: const CircularProgressIndicator(
        color: Colors.red,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0D22),
        appBar: AppBar(
          title: const Text(
            'Digital Wellbeing',
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFF0A0D22),
          elevation: 0,
        ),
        body: weekData.isEmpty ? const Center(child: CircularProgressIndicator(color: Colors.red,)) : ListView(
          padding: const EdgeInsets.all(15.0),
            children: [
              styledContainer(
                padding: 10,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomDropDownButton(
                          textList: dropDown1Items,
                          function: (String v) => setState(() {
                            if(v != dropDown1Value){
                              dropDown2Value = "hours";
                            }
                            dropDown1Value = v;
                            checkDataAvailability();
                          }),
                          dropDownValue: dropDown1Value,
                          unClickableItems: unClickableKey1,
                        ),
                        const Text(
                          "spending",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.white
                          ),
                        ),
                        const SizedBox(width: 8,),
                        CustomDropDownButton(
                          textList: dropDown2Items,
                          function: (String v) => setState(() {
                            dropDown2Value = v;

                          }),
                          dropDownValue: dropDown2Value,
                          unClickableItems: unClickableKey2,
                        ),
                      ],
                    ),
                    dropDown1Value == "yearly" ?
                        SizedBox(
                          height: size.height * 0.35,
                          child: SfCircularChart(
                            legend: Legend(isVisible: true,overflowMode: LegendItemOverflowMode.wrap,textStyle: TextStyle(color: Colors.white),iconHeight: 20,iconWidth: 20),
                            series: <CircularSeries>[
                              DoughnutSeries<Map<String,int>,String>(
                                explode: false,
                                dataSource: yearsInfo,
                                xValueMapper: (Map<String,int> data,_) => data["year"].toString(),
                                yValueMapper: (Map<String,int> data,_) => dropDown2Value == "hours" ? data["hours"] : data["episodes"],
                                dataLabelSettings: const DataLabelSettings(isVisible: true,textStyle: TextStyle(color: Colors.white,fontWeight: FontWeight.w600)),
                                radius: '100%',
                              )
                            ],
                          ),
                        )
                        : BarChart(date: dropDown1Value == "weekly" ? List.from(weekData.reversed.map((e) => e["date"]).toList()) : [] ,expense: generateExpense() ,title: getTitle(),callback: dropDown1Value == "weekly" ?  getWeekData : getYearData,isFirst: dropDown1Value == "weekly" ? isFirstWeek : isFirstYear,unit: dropDown2Value == "hours" ? "h" : "ep",label: dropDown1Value == "weekly" ? weekDays : months,axis: dropDown1Value == "weekly" ? true : false ,),
                  ],
                ),
              ),
              const SizedBox(height: 20,),
              Row(
                children: [
                  Expanded(
                    child: styledContainer(
                      padding: 5,
                      child: SizedBox(
                        height: size.width/2 -110,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                getHoursAndEpisodes()["hours"],
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 35,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                              const SizedBox(height: 5,),
                              Text(
                                "Hours",
                                style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600
                                ),
                              ),
                            ],
                          )
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 20,),
                  Expanded(
                    child: styledContainer(
                      padding: 5,
                      child: SizedBox(
                        height: size.width/2 -110,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                getHoursAndEpisodes()["episodes"],
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 35,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                              SizedBox(height: 5,),
                              Text(
                                "Episodes",
                                style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20,),
              styledContainer(
                padding: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Watched Categories",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w600
                      ),
                    ),
                    SfCircularChart(
                      legend: Legend(isVisible: true,overflowMode: LegendItemOverflowMode.wrap,textStyle: TextStyle(color: Colors.white),iconHeight: 20,iconWidth: 20),
                      series: <CircularSeries>[
                        PieSeries<Map<String,String>,String>(
                          explode: false,
                          dataSource: category,
                          xValueMapper: (Map<String,String> data,_) => data["category"],
                          yValueMapper: (Map<String,String> data,_) => int.parse(data["value"]!),
                          dataLabelSettings: DataLabelSettings(isVisible: false,textStyle: TextStyle(color: Colors.white,fontWeight: FontWeight.w600)),
                          radius: '110%',
                        )
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 15,),
              SettingsCard(icon: Icons.screenshot_monitor, title: "Watched Anime", fun: () =>Navigator.of(context).push(MaterialPageRoute(builder: (_) => WatchedAnimeScreen())),haveSwitch: false,),
              SizedBox(height: 10,),
              SettingsCard(icon: Icons.family_restroom, title: "Parental Control", fun: () => moveToManageUsage(),haveSwitch: false,),

            ],
          ),
        ),
    );
  }
}

