import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:netflixbro/constants.dart';
import 'package:netflixbro/models/content_model.dart';
import 'package:netflixbro/screens/anime_screen.dart';

class ContentList extends StatelessWidget {
  final String title;
  final List<Anime> contentList;
  final bool isOriginals;

  final BuildContext context;

  const ContentList(
      {Key? key,
      required this.title,
      required this.contentList,
      required this.context,
      this.isOriginals = false})
      : super(key: key);


  @override
  Widget build(BuildContext context) {
    return contentList.isEmpty ? SizedBox.shrink() : Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                title,
                style: TextStyle(
                    color: textColor, fontWeight: FontWeight.bold, fontSize: 20.0),
              ),
            ),
            Container(
              height: isOriginals ? 350 : 220,
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16.0,vertical: 8.0),
                itemCount: contentList.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (BuildContext context , int index){
                  final Anime content = contentList[index];
                  return GestureDetector(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => AnimeScreen(anime: content,context: this.context,))),
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 8.0),
                      height: isOriginals ? 350 : 200,
                      width: isOriginals ? 230 : 130,
                      child: Hero(
                        tag: content.imageUrl + content.myList + content.trending + content.main,
                        child: CachedNetworkImage(
                          imageUrl: content.imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => CircularProgressIndicator(color: Colors.red,),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
      ]),
    );
  }
}
