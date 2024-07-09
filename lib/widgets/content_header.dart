import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:netflixbro/constants.dart';
import 'package:netflixbro/models/models.dart';
import 'package:netflixbro/screens/anime_screen.dart';
import 'package:netflixbro/services.dart';
import 'package:netflixbro/widgets/widgets.dart';

class ContentHeader extends StatefulWidget {
  final Anime anime;
  final BuildContext context;

  const ContentHeader({Key? key,required this.anime,required this.context}) : super(key: key);

  @override
  State<ContentHeader> createState() => _ContentHeaderState();
}

class _ContentHeaderState extends State<ContentHeader> {


  @override
  void initState() {

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return  Stack(
      alignment: Alignment.center,
      children: [
        Container(
          height: 570,
          width: double.infinity,
          child: CachedNetworkImage(
            imageUrl: widget.anime.imageUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => Center(child: CircularProgressIndicator(color: Colors.red)),
          ),
        ),
        Container(
          height: 571,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [backgroundColor,Colors.transparent],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter
            )
          ),
        ),
        widget.anime.titleUrl.isEmpty ? SizedBox.shrink():
        Positioned(
          bottom: 140,
          child: SizedBox(
              width: 180,
              child: CachedNetworkImage(
                imageUrl: widget.anime.titleUrl,
              )
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              VerticalIconButton(
                icon:Icons.add,
                title:'List',
                onTap:()async{
                  print("loading");
                  final res = await Services.getAnimes1();
                  print(res[1].length);
                }
              ),
              _PlayButton(anime:  widget.anime,context: widget.context,),
              VerticalIconButton(
                  icon:Icons.info_outline,
                  title:'Info',
                  onTap:()=>{
                    print("info"),
                  }
              ),
            ],
          ),
        )
      ],
    );
  }
}

class _PlayButton extends StatelessWidget {

  final Anime anime;
  final BuildContext context;
  _PlayButton({required this.anime,required this.context});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      
      icon: Icon(Icons.play_arrow,color: backgroundColor,size: 30,),
      label: Text('Play',style: TextStyle(color:backgroundColor,fontSize: 16.0,fontWeight: FontWeight.w600)),
      onPressed: () =>  Navigator.of(context).push(MaterialPageRoute(builder: (_) => AnimeScreen(anime: anime,context: this.context,))),
      style: TextButton.styleFrom(
        backgroundColor: textColor,
        padding: EdgeInsets.fromLTRB(15.0,10.0, 20.0, 10.0)
      ),
    );
  }
}
