import 'package:flutter/material.dart';
import 'package:netflixbro/constants.dart';

class VerticalIconButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final Function onTap;

  const VerticalIconButton({Key? key,required this.icon,required this.title,required this.onTap}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {onTap();},
      child: Column(
        children: [
          Icon(icon,color: textColor,size: 30,),
          SizedBox(height: 2.0,),
          Text(
            title,
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w600
            ),
          )
        ],
      ),
    );
  }
}
