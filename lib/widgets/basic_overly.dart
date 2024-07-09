import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class BasicOverly extends StatefulWidget {

  final VideoPlayerController controller;

  const BasicOverly({Key? key,required this.controller}) : super(key: key);

  @override
  _BasicOverlyState createState() => _BasicOverlyState();
}

class _BasicOverlyState extends State<BasicOverly> {
  bool appear = false;

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => {
        setState(() => {
          appear = true
        }),
        Future.delayed(Duration(seconds: 3),() => {
          setState(() => appear = false)
        })
      },
      child: Stack(
        children: [
          appear || !widget.controller.value.isPlaying ? pauseAndStart() : SizedBox.shrink(),
          appear || !widget.controller.value.isPlaying ?
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: buildIndicator(),
          ) :
          SizedBox.shrink()
        ],
      ),
    );
  }

  Widget buildIndicator(){
    return VideoProgressIndicator(widget.controller, allowScrubbing: true);
  }

  Widget pauseAndStart(){
    return Container(
      color: Colors.black26,
      alignment: Alignment.center,
      child: widget.controller.value.isPlaying ?
          IconButton(
            icon: Icon(Icons.pause),
            color: Colors.white,
            onPressed: () => widget.controller.pause(),
            iconSize: 50.0,
          ) :
          IconButton(
            icon: Icon(Icons.play_arrow),
            color: Colors.white,
            onPressed: () => widget.controller.play(),
            iconSize: 50.0,
          ),
    );
  }
}
