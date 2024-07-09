import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:netflixbro/models/episode.dart';
import 'package:netflixbro/models/models.dart';
import 'package:netflixbro/models/watched_anime.dart';
import 'package:netflixbro/sqlite.dart';
import 'package:video_player/video_player.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../services.dart';

class VideoScreen extends StatefulWidget {

  final Episode episode;
  final Anime anime;
  final Function() notify;


  const VideoScreen({Key? key,required this.episode,required this.anime,required this.notify}) : super(key: key);



  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  late VideoPlayerController controller;
  bool isLoading = true;
  late Timer timer;

  getWatchedAnime()async{
    print(await SQLiteHelper.instance.readAllWatchedAnime());
  }

  @override
  void initState() {
    // TODO: implement initStat

    //setLandScape();
    getWatchedAnime();
    getTime();
    setDefault();
    super.initState();
    // controller = VideoPlayerController.network('https://www.4shared.com/web/embed/file/8vdQD6V4ea')
    //   ..addListener(() => (setState(() {})))
    //   ..setLooping(false)
    //   ..initialize();

  }

  getTime()async{
    print("i1");
    final res = await SQLiteHelper.instance.readWatchedEpisode(widget.anime.name, widget.episode.num);
    if(res.name == "" && res.time == 0 && res.num == 0){
      await SQLiteHelper.instance.insertWatchedEpisode(WatchedEpisode(name: widget.anime.name, num: int.parse(widget.episode.num), time: 0));
    }else {
      print("sq" + res.time.toString());
      if (res.time >= 5) {
        print("i4");
        return;
      }
    }
    timeCounter();
  }

  update()async{
    var res = await SQLiteHelper.instance.updateWatchedEpisode(widget.anime.name, widget.episode.num);
    if(res == 1){
      timer.cancel();
      final res = await Services.watchedEpisode(widget.anime.name, widget.episode.num);
      SQLiteHelper.instance.updateEpisodeNum();
      if(res){
        widget.notify();
      }
      final res1 = await Services.getInfo(widget.anime.name);
      print("res1......................///////");
      print(res1);
      if(res1["episodes"] != 0){
        bool b = false;
        if(res1["episodes"]! <= 25 && res1["watched_episodes"]! >=5){
          print(">5");
          b = true;
        }else if(res1["episodes"]! <= 120 && res1["watched_episodes"]! >= res1["episodes"]!*0.2){
          b = true;
        }else if(res1["episodes"]! <= 200 && res1["watched_episodes"]! >= res1["episodes"]!*0.18){
          b = true;
        } else if(res1["episodes"]! <= 2000 && res1["watched_episodes"]! >= 40){
          b = true;
        }
        print(b);
        if(b){
          final res = await SQLiteHelper.instance.readWatchedAnime(widget.anime.name);
          print(res);
          if(res.name.isEmpty){
            await SQLiteHelper.instance.insertWatchedAnime(WatchedAnime(name: widget.anime.name, kind: widget.anime.kind, sent: "0")) ;
            final res = await Services.followAnime(widget.anime.name);
            if(res){
              SQLiteHelper.instance.updateWatchedAnime(WatchedAnime(name: widget.anime.name, kind: widget.anime.kind, sent: "1"));
            }
          }
        }
      }
    }
  }

  timeCounter(){
    int seconds = 0;
    print("5");
    const oneSec = const Duration(seconds: 1);
    timer = new Timer.periodic(
      oneSec,
          (Timer timer) =>setState(
          () {
          if (seconds < 0) {
            timer.cancel();
          } else {
            seconds = seconds + 60;
            if (seconds == 60) {
              print("i");
              update();
              seconds = 0;

            }
          }
        } ),

    );

  }

  setDefault()async{
    WidgetsFlutterBinding.ensureInitialized();
    await SystemChrome.setPreferredOrientations(
        DeviceOrientation.values);
  }

  resetOrientations()async{
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  }

  setLandScape(){
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,overlays: []) ;
  }

  reset(){
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,overlays: [SystemUiOverlay.top,SystemUiOverlay.bottom]);
  }

  @override
  void dispose() {
    timer.cancel();
    reset();
    resetOrientations();
    super.dispose();

  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body:  Center(
        child: OrientationBuilder(
          builder: (context,orientation){
          final isPortrait = orientation == Orientation.portrait;
          isPortrait ? reset() : setLandScape();
          return Container(
            height: isPortrait ? size.height * 0.3 : double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black
            ),
            child: Stack(
              children: [
                WebView(
                  initialUrl: Uri.dataFromString('<html><body style="margin:0;padding:0;"><iframe src="${widget.episode.videoUrl}" style="background-color:black;" height="100%" width="100%" frameborder="0" allowfullscreen="true" ></iframe></body></html>', mimeType: 'text/html').toString(),
                  javascriptMode: JavascriptMode.unrestricted,
                  navigationDelegate: (NavigationRequest request) {
                    return NavigationDecision.prevent;
                  } ,
                  onPageFinished: (finish) {
                    setState(() {
                      isLoading = false;
                    });
                  },
                ),
                isLoading ? Center( child: CircularProgressIndicator(color: Colors.red,),)
                    : Stack(),
              ],
            ),
          );}
        ),
      ),
      //Center(child: VideoPlayerWidget(controller: controller)),
    );
  }
}


