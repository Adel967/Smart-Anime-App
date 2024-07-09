import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:netflixbro/constants.dart';
import 'package:netflixbro/cubits/cubits.dart';
import 'package:netflixbro/cubits/is_loading_cubit.dart';
import 'package:netflixbro/cubits/search_anime_cubit.dart';
import 'package:netflixbro/models/content_model.dart';
import 'package:netflixbro/models/episode.dart';
import 'package:netflixbro/screens/nav_screen.dart';
import 'package:netflixbro/screens/video_screen.dart';
import 'package:netflixbro/services.dart';
import 'package:netflixbro/sqlite.dart';
import 'package:netflixbro/widgets/circular_clipper.dart';
import 'package:provider/src/provider.dart';


class AnimeScreen extends StatefulWidget {
  final Anime anime;
  final BuildContext context;

  AnimeScreen({required this.anime,required this.context});

  @override
  _AnimeScreenState createState() => _AnimeScreenState();
}

class _AnimeScreenState extends State<AnimeScreen> {
  List<Episode> episodes = List.empty();
  bool isLoading = false;
  bool blocked = false;
  bool rated = false;

  animeRate(){
    double rate = double.parse(widget.anime.evaluation);
    rate /=2;
    String inString = rate.toStringAsFixed(1);
    double inDouble = double.parse(inString);
    return inDouble;
  }

  getEpisode() async{
    final response = await Services.getEpisodes("YOUKOSO JITSURYOKU SHIJOU SHUGI NO KYOUSHITSU E ");
    //final response = await Services.getEpisodes(widget.anime.name);
    setState(() {
      episodes = response;
      print(episodes.length);
    });

  }
 
  addToList()async{
    if(await checkInternetConnection()){

      setState(() {
        isLoading = true;
      });
      final res = await Services.addToList(NavScreen.email, widget.anime.name,true);

      if(res){
        Anime anime =  Anime.clone(widget.anime);
        anime.myList = '1';
        anime.trending = '';
        anime.main = '';
        setState(() {
          widget.anime.myList = '1';
        });
        await SQLiteHelper.instance.insertAnimeToList(widget.anime);
        //widget.animes.add(widget.anime);

        setState(() {
          isLoading = false;
        });
        try{
          widget.context.read<AnimesLoadCubit>().addListAnime(anime);
          widget.context.read<SearchAnimeCubit>().addToList(anime.name);
        }catch(e){

        }
        buildToast("This anime has been added to your list");
      }
      else{
        setState(() {
          isLoading = false;
        });
        buildToast("Something went wrong,try again later");
      }
    }else {
      buildToast("Check your internet connection!");
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  removeFromList()async{
    if(await checkInternetConnection()){
      setState(() {
        isLoading = true;
      });
      final res = await Services.addToList(NavScreen.email, widget.anime.name,false);
      if(res){
        await SQLiteHelper.instance.deleteListAnime(widget.anime.name);
        setState(() {
          widget.anime.myList = '0';
        });
        setState(() {
          isLoading = false;
        });
        try{
          widget.context.read<AnimesLoadCubit>().deleteListAnime(widget.anime.name);
        }catch(e){

        }
        buildToast("This anime has been removed from your list");
      }
      else{
        setState(() {
          isLoading = false;
        });
        buildToast("Something went wrong,try again later");
      }
    } else {
      buildToast("Check your internet connection!");
    }
  }

  Future<bool> checkInternetConnection() async{
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      //buildToast("Check your internet connection!");
      return false;
    }
    return false;
  }

  buildToast(String msg){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,style: TextStyle(fontSize: 16),),
      backgroundColor: Color(0xFFB63159),
    ));
  }

  checkBlockAnimes()async{
    final pc = await SQLiteHelper.instance.readParentalControl();
    final ba = await SQLiteHelper.instance.readBlockedAnime();
    List<String> blockedCategories = [];
    if(pc["blockedCategories"] != null){
      blockedCategories = List.from(pc["blockedCategories"].toString().split(","));
    }
    blockedCategories.forEach((element) {
      List<String> animeCategories = List.from(widget.anime.kind.split(","));
      if(animeCategories.contains(element)){
        setState(() {
          blocked = true;
        });
      }
    });
    if(ba.contains(widget.anime.name)){
      setState(() {
        blocked = true;
      });
    }

  }

  showAlertDialog() {
    Widget submitButton = TextButton(
      child: Text( "Submit" ,style: TextStyle(color: Colors.green),),
      onPressed: () {
        rated = true;
        setState(() {

        });
        Navigator.of(context).pop();
      },
    );


    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: Colors.white,
      content: SizedBox(
        height: 80,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Rate this anime",
              style: TextStyle(
                color: Colors.black
              ),
            ),
            SizedBox(height: 5,),
            RatingBar.builder(
              initialRating: 1,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              ignoreGestures: false,
              itemCount: 5,
              itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
              glow: false,
              itemBuilder: (context, _) => Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                print(rating);
              },
            )
          ],
        ),
      ),
      actions: [
        submitButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  void initState() {
    checkBlockAnimes();
    getEpisode();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: isLoading,
        progressIndicator: CircularProgressIndicator(
          color: Colors.red,
        ),
        child: ListView(
          children: <Widget>[
            Stack(
              children: <Widget>[
                Container(
                  transform: Matrix4.translationValues(0.0, -50.0, 0.0),
                  child: ClipShadowPath(
                    clipper: CircularClipper(),
                    shadow: Shadow(blurRadius: 20.0),
                    child: Hero(
                      tag: widget.anime.imageUrl + widget.anime.myList + widget.anime.trending + widget.anime.main,
                      child: CachedNetworkImage(
                        imageUrl: widget.anime.imageUrl,
                        alignment: Alignment.topCenter,
                        height: 400.0,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Center(child: CircularProgressIndicator(color: Colors.red)),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.arrow_back),
                        iconSize: 30.0,
                        color: Colors.black,
                      ),
                      IconButton(
                        padding: EdgeInsets.only(left: 30.0),
                        onPressed: () => showAlertDialog(),
                        icon: Icon(rated ? Icons.favorite : Icons.favorite_border),
                        iconSize: 30.0,
                        color: rated ? Colors.red : Colors.black,
                      ),
                    ],
                  ),
                ),
                // Positioned.fill(
                //   bottom: 10.0,
                //   child: Align(
                //     alignment: Alignment.bottomCenter,
                //     child: RawMaterialButton(
                //       padding: EdgeInsets.all(10.0),
                //       elevation: 12.0,
                //       onPressed: () => print('Play Video'),
                //       shape: CircleBorder(),
                //       fillColor: Colors.white,
                //       child: Icon(
                //         Icons.play_arrow,
                //         size: 60.0,
                //         color: Colors.red,
                //       ),
                //     ),
                //   ),
                // ),
                Positioned(
                  bottom: 0.0,
                  left: 20.0,
                  child: IconButton(
                    onPressed: () => widget.anime.myList == '1' ? removeFromList() : addToList(),
                    icon: widget.anime.myList == '1' ? Icon(Icons.highlight_remove_sharp) : Icon(Icons.add),
                    iconSize: 40.0,
                    color: Colors.black,
                  ),
                ),
                Positioned(
                  bottom: 0.0,
                  right: 25.0,
                  child: IconButton(
                    onPressed: () => print('Share'),
                    icon: Icon(Icons.share),
                    iconSize: 35.0,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    widget.anime.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10.0),
                  widget.anime.kind.isEmpty ? SizedBox.shrink() : Column(
                    children: [
                      Text(
                        widget.anime.kind,
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 16.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 12.0),
                    ],
                  ),
                  widget.anime.evaluation.isEmpty ? SizedBox.shrink() : RatingBar.builder(
                    initialRating: animeRate(),
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    ignoreGestures: true,
                    itemCount: 5,
                    itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                    itemBuilder: (context, _) => Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (rating) {
                      print(rating);
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Text(
                            widget.anime.released.length > 4 ? 'release' : 'Year',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 16.0,
                            ),
                          ),
                          SizedBox(height: 2.0),
                          Text(
                            widget.anime.released.toString(),
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: <Widget>[
                          Text(
                            'Country',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 16.0,
                            ),
                          ),
                          SizedBox(height: 2.0),
                          Text(
                            widget.anime.country.toUpperCase(),
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      widget.anime.episodesNum.isEmpty ? SizedBox.shrink() : Column(
                        children: <Widget>[
                          Text(
                            'Episodes',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 16.0,
                            ),
                          ),
                          SizedBox(height: 2.0),
                          Text(
                            widget.anime.episodesNum.toUpperCase(),
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),

                    ],
                  ),
                  SizedBox(height: 25.0),
                  Container(
                    height: widget.anime.episodesNum.isEmpty ?  170.0 : 100.0,
                    child: SingleChildScrollView(
                      child: Text(
                        widget.anime.description,
                        style: TextStyle(
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            widget.anime.episodesNum.isEmpty ? SizedBox.shrink() : ContentScroll(
              anime: widget.anime,
              episodes: episodes,
              blocked: blocked,
              title: 'Episodes',
            ),
          ],
        ),
      ),
    );
  }

}

class ContentScroll extends StatefulWidget {

  final Anime anime;
  final List<Episode> episodes;
  final String title;
  final bool blocked;
  const ContentScroll({Key? key,required this.anime,required this.episodes,required this.title, this.blocked = false}) : super(key: key);

  @override
  State<ContentScroll> createState() => _ContentScrollState();
}

class _ContentScrollState extends State<ContentScroll> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 35),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  widget.title,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20.0,
                      fontWeight: FontWeight.w600
                  ),
                ),
                GestureDetector(
                  onTap: (){},
                  child: Icon(
                    Icons.arrow_forward,
                    color: Colors.black,
                    size: 30,
                  ),
                ),
              ],
            ),
          ),
          widget.blocked ?
          SizedBox(
            height: 70,
            child: Center(
              child: Text(
                "This anime is blocked!",
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 20,
                  fontWeight: FontWeight.w500
                ),
              ),
            ),
          )
              : widget.episodes.isEmpty ?
              CircularProgressIndicator(color: Colors.red,):
              Container(
                height: 180,

                child: ListView.builder(
                  padding: EdgeInsets.only(left: 15,right: 15),
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.episodes.length,
                  itemBuilder: (BuildContext context,int index){
                    Episode episode = widget.episodes[index];
                    return GestureDetector(
                      onTap: () {
                        NavScreen.context.read<IsLoadingCubit>().changeFirstState(true);
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => VideoScreen(episode: episode,anime: widget.anime,notify: () => setState(() => {episode.views = (int.parse(episode.views) + 1).toString(),episode.date = "1"}),))).then((value) => NavScreen.context.read<IsLoadingCubit>().changeFirstState(false));
                      },
                      child: Container(
                        width: 260,
                        margin: EdgeInsets.only(left: 20 ,top: 20,bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [BoxShadow(color: Colors.black26,blurRadius: 6.0,offset: Offset(0.0,2.0))],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image(
                                width: 110,
                                height: 160,
                                image: CachedNetworkImageProvider(widget.anime.imageUrl),
                                fit: BoxFit.cover
                              ),
                            ),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 240,
                                      child: Text('Episode ${episode.num}',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Text('Views ${episode.views}',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600
                                      ),
                                    ),
                                    SizedBox(height:10),
                                    FittedBox(
                                      fit: BoxFit.fitWidth,
                                      child: Row(
                                        children: [
                                          Text(episode.date != "" ? "Watched" : "Not watched",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600
                                            ),
                                          ),
                                          SizedBox(width: 4,),
                                          Icon(episode.date != "" ?  Icons.remove_red_eye: FontAwesomeIcons.eyeSlash,size: 19,color: Colors.black,)
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              )
        ],
      ),
    );
  }
}



