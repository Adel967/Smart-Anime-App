import 'package:flutter/material.dart';
import 'package:netflixbro/screens/watched_episode_screen.dart';
import 'package:netflixbro/widgets/bar.dart';

class BarChart extends StatelessWidget {

  final int isFirst;
  final void Function(bool) callback;
  final List<dynamic> expense;
  final List<String> label;
  final String title;
  final String unit;
  final bool axis; //true vertical//false horiz
  final List<String>? date;




  const BarChart({Key? key, required this.expense,required this.title,required this.callback,required this.isFirst,required this.label, required this.unit, required this.axis, this.date }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    final height  = MediaQuery.of(context).size.height;
    print(label);
    dynamic mostExpensive = 0;
    expense.forEach((var period) {
      if(period > mostExpensive)
        mostExpensive = period;
    });
    return Column(
      children: [
        FittedBox(
          fit: BoxFit.fitWidth,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: isFirst != -1 && isFirst != 2? Colors.white : Colors.grey.shade500,
                ),
                iconSize: 30.0,
                onPressed: () {
                  if(isFirst != -1 && isFirst !=2)
                    callback(false);
                },
              ),
              Text(
                title,
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18.0,
                    letterSpacing: 1.2,
                  color: Colors.white,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.arrow_forward,
                ),
                iconSize: 30.0,
                color: isFirst != 1 && isFirst !=2 ? Colors.white : Colors.grey.shade500,
                onPressed: (){
                  if(isFirst != 1 && isFirst != 2)
                     callback(true);
                },
              ),
            ],
          ),
        ),
        SizedBox(
          height: height * 0.3,
          child:axis ? Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                label.length,
                    (index) => Expanded(
                      child: TextButton(
                          onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => WatchedEpisodeScreen(date: date![index]))),
                          child: Bar(label: label[index],amountSpending:expense[index],mostExpensive:mostExpensive,isFirst: isFirst,unit: unit,axis: axis,)),
                    ),
              )

          ):Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                label.length,
                    (index) => Bar(label: label[index],amountSpending:expense[index],mostExpensive:mostExpensive,isFirst: isFirst,unit: unit,axis: axis,),
              )),
        ),
      ],
    );
  }
}

