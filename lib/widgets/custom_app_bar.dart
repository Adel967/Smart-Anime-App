import 'package:flutter/material.dart';
import 'package:netflixbro/assets.dart';

class CustomAppBar extends StatelessWidget {
  final scrollOffset;

  const CustomAppBar({Key? key, this.scrollOffset = 0.0}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity((scrollOffset / 350).clamp(0,1).toDouble()),
      padding: EdgeInsets.symmetric(
        vertical: 10.0,
        horizontal: 24.0
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SafeArea(
              child: Image.asset(Assets.netflixLogo0)
          ),
          SizedBox(width: 12.0,),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
              _AppBarButton("TV Shows", () => print("TV Shows")),
              _AppBarButton("Movies", () => print("Movies")),
              _AppBarButton("My List", () => print("My List"))
            ],),
          )
        ],
      ),
    );
  }
}

class _AppBarButton extends StatelessWidget {
  final String title;
  final Function onTap;


  _AppBarButton(this.title, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap,
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16.0,
          fontWeight: FontWeight.w600
        ),
      ),
    );
  }
}
