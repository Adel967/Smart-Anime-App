import 'package:flutter/material.dart';

import '../constants.dart';

class SettingsCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool? isSwitch;
  final bool haveSwitch;
  final Function fun;

  const SettingsCard({Key? key,required this.icon,required this.title,this.isSwitch,required this.fun,required this.haveSwitch}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        if(!haveSwitch){
          fun();
        }
      },
      child: Row(
        children: [
          Icon(
            icon,
            color: textColor,
            size: 30,
          ),
          SizedBox(width: 10,),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                  color: textColor,
                  fontSize: 18
              ),
            ),
          ),
          haveSwitch ? Switch(
            value: isSwitch!,
            onChanged: (value){
              fun(value);
            },
            inactiveTrackColor: Colors.red.shade300,
            activeColor: Colors.white,
            activeTrackColor: Colors.green.shade300,
            focusColor: Colors.blue,
          ): Padding(
            padding: EdgeInsets.only(right: 10),
            child: Icon(Icons.arrow_forward_ios,size: 25,color: textColor,),
          )
        ],
      ),
    );
  }
}
