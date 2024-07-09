import 'package:flutter/material.dart';
import 'package:netflixbro/constants.dart';
import 'package:netflixbro/services.dart';

class WatchedEpisodeScreen extends StatefulWidget {
  final String date;
  const WatchedEpisodeScreen({Key? key, required this.date}) : super(key: key);

  @override
  State<WatchedEpisodeScreen> createState() => _WatchedEpisodeScreenState();
}

class _WatchedEpisodeScreenState extends State<WatchedEpisodeScreen> {

  List<Map<String,dynamic>> l = [];
  bool isLoading = true;

  getWatchedAnime()async{
    final list = await Services.getWatchedAnime(widget.date);
    l = List.from(list);
    setState(() {
      isLoading = false;
    });
    print(list);
  }

  @override
  void initState() {
    // TODO: implement initState
    getWatchedAnime();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0A0D22),
      appBar: AppBar(
        title: Text(
          "Watched Episodes",
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Title",
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18
                    ),
                  ),
                  Text(
                    "EP.NO",
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Divider(
              height: 1,
              color: Colors.grey,
            ),
            SizedBox(height: 10,),
            isLoading ? Expanded(child: Center(child: CircularProgressIndicator(color: Colors.red,))) : l.isEmpty ? Expanded(child: Center(
              child: Text(
                "There is not any episode watched in this day!",
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
                    height: 40,
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 5,
                            child: Text(
                              l[index]["name"]!,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              l[index]["num"]!,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16
                              ),
                              textAlign: TextAlign.right,
                            ),
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
