import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:netflixbro/constants.dart';
import 'package:netflixbro/models/content_model.dart';
import 'package:netflixbro/screens/anime_screen.dart';

class Previews extends StatelessWidget {

  final String title;
  final List<Anime> contentList;
  final BuildContext context;

  const Previews({Key? key,required this.title,required this.contentList,required this.context}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            title,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 20.0
            ),
          ),
        ),
        Container(
          height: 175,
          padding: EdgeInsets.symmetric(horizontal: 8,vertical: 12),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: contentList.length,
            itemBuilder: (BuildContext context,int index){
              final Anime content = contentList[index];
              return GestureDetector(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => AnimeScreen(anime: content,context: this.context,))),
                child: Stack(
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 16),
                      height: 140,
                      width: 140,
                      child: ClipOval(
                        child: Hero(
                          tag: content.imageUrl + content.myList + content.trending + content.main,
                          child: CachedNetworkImage(
                            imageUrl: content.imageUrl,
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                            placeholder: (context, url) => CircularProgressIndicator(color: Colors.red,),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 16),
                      height: 140,
                      width: 140,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: backgroundColor == Colors.black ? [Colors.black87,Colors.black45,Colors.transparent] : [Colors.white54,Colors.white24,Colors.transparent],
                          stops: [0,0.25,1],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter
                        ),
                        shape: BoxShape.circle
                      ),
                    ),
                    // content.titleUrl.isEmpty ? SizedBox.shrink():
                    // Positioned(
                    //   bottom: 0,
                    //   right: 0,
                    //   left: 0,
                    //   child: Hero(
                    //     tag: content.imageUrl,
                    //     child: Image(
                    //       height: 60,
                    //       image: AssetImage(content.titleUrl),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
