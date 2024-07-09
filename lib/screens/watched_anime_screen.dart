import 'package:flutter/material.dart';
import 'package:netflixbro/services.dart';
import 'package:auto_size_text/auto_size_text.dart';

class WatchedAnimeScreen extends StatefulWidget {
  const WatchedAnimeScreen({Key? key}) : super(key: key);

  @override
  State<WatchedAnimeScreen> createState() => _WatchedAnimeScreenState();
}

class _WatchedAnimeScreenState extends State<WatchedAnimeScreen> {

  List<Map<String,dynamic>> l = [];
  bool isLoading = true;
  
  getWatchedAnime()async{
    final res = await Services.getFollowedAnime();
    print(res);
    print(res);

    l = List.from(res);
    print(l.length);
    l.sort((a, b) => b["date"].compareTo(a["date"]));
    isLoading = false;
    setState(() {
      
    });
  }
  
  @override
  void initState() {
    getWatchedAnime();
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0A0D22),
      appBar: AppBar(
        title: Text(
          "Watched Anime",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF0A0D22),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            isLoading ? const Expanded(child: Center(child: CircularProgressIndicator(color: Colors.red,))) : l.isEmpty ? const Expanded(child: Center(
              child: Text(
                "There is not any watched anime!",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18
                ),
              ),
            )): Expanded(
              child: ListView.builder(
                itemCount: l.length,
                itemBuilder: (context,index){
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 4),
                    width: double.infinity,

                    decoration: BoxDecoration(
                        color: Color(0xFF1C1F32),
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: [
                          BoxShadow(
                              color: Color(0xFFEB1555),
                              blurRadius: 3,
                              offset: Offset(0.0,0.0)
                          )
                        ]
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AutoSizeText(
                              l[index]["name"]!,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16
                              ),
                              maxLines: 1,
                          ),
                          SizedBox(height: 10,),
                          Text(
                            l[index]["date"]!,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
