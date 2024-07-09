import 'package:flutter/material.dart';
import 'package:netflixbro/widgets/widgets.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/widgets.dart';

class VideoPlayerWidget extends StatelessWidget {
  final VideoPlayerController controller;

  const VideoPlayerWidget({Key? key, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return controller.value.isInitialized
        ? Container(
            alignment: Alignment.center,
            child: buildVideo(),
          )
        : Container(
            height: 60,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
  }

  Widget buildVideo() {
    return Stack(
        children: [
          buildVideoPlayer(),
          Positioned.fill(child: BasicOverly(controller: controller,))
        ]);
  }

  Widget buildVideoPlayer() {
    return AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: VideoPlayer(controller));
  }
}
