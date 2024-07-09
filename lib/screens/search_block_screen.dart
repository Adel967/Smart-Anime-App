import 'dart:io';
import 'package:flutter/material.dart';
import '../constants.dart';
import '../models/content_model.dart';
import '../services.dart';
import '../sqlite.dart';

class SearchBlockScreen extends StatefulWidget {
  final List<String> blockedAnime ;
  const SearchBlockScreen({Key? key, required this.blockedAnime}) : super(key: key);

  @override
  State<SearchBlockScreen> createState() => _SearchBlockScreenState();
}

class _SearchBlockScreenState extends State<SearchBlockScreen> {

  List<Anime> animes = [];
  List<Anime> myList = [];
  bool isLoading = true;
  String error = "";
  String search = "";
  ScrollController _scrollController  = ScrollController();

  getListAnime()async{
    final res = await SQLiteHelper.instance.readListAnime();
    setState(() {
      myList = List.from(res);
    });
  }

  showAlertDialog(String title) {
    // set up the button
    Widget okButton = TextButton(
      child: Text("YES",style: TextStyle(color: Colors.green),),
      onPressed: () async{
        if(widget.blockedAnime.contains(title)){
          widget.blockedAnime.remove(title);
          await SQLiteHelper.instance.unBlockAnime(title);
          saveParentalControlData();
        }else{
          widget.blockedAnime.add(title);
          await SQLiteHelper.instance.insertBlockedAnime(title);
          saveParentalControlData();
        }
        setState(() {

        });

        Navigator.of(context).pop();
      },
    );

    Widget cancelButton = TextButton(
      child: Text( "Cancel" ,style: TextStyle(color: Colors.red),),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: Colors.white,
      content: Text(
          widget.blockedAnime.contains(title) ? "Are you sure you want to unblock this anime ? " : "Are you sure you want to block this anime ?",
      ),
      actions: [
        cancelButton,
        okButton,
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

  getAnimes(String s)async{
    print("search.....");
    isLoading = true;
    getListAnime();
    if(await checkInternetConnection()){
      setState(() {
        error = "";
      });
      final response = await Services.getAnimesByKind("All", animes.length ,s.trim(),50);
      setState(() {
        if(s == search) {
          response.forEach((element) {
            if(myList.where((element1) => element1.name == element.name).toList().isNotEmpty){
              element.myList = '1';
            }
          });
          animes.addAll(response);
        }
        if(animes.length % 10 != 0 || response.isEmpty){
          isLoading = false;
          if(response.isEmpty)
            error = "There isn't any anime like this! ";
        }

      });
    }
    isLoading = false;
    print(animes);
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

  @override
  void initState() {
    _scrollController.addListener(() {
      if(_scrollController.position.pixels == _scrollController.position.maxScrollExtent){
        if(isLoading){
          getAnimes(search);
        }
      }

    });
    getAnimes("");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0A0D22),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Color(0xFF1C1F32),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: TextField(
                        cursorColor: Colors.red,
                        onChanged: (input) => setState(() {
                          isLoading = true;
                          animes = [];
                          search = input;
                          getAnimes(input);

                        }),
                        style: TextStyle(
                            color: Colors.white
                        ),

                        decoration: InputDecoration(
                            hintStyle: TextStyle(
                                color: Colors.white
                            ),
                            hintText: 'Search...',
                            fillColor: Colors.white,
                            border: InputBorder.none,

                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            animes.isEmpty ? error.isNotEmpty ? Center(child: Text(error,style: TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.w600),),) :
            Expanded(child: Center(child: CircularProgressIndicator(color: Colors.red,)))
                :
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(10),
                itemCount: isLoading ? animes.length + 1  : animes.length,
                itemBuilder: (context,index){

                  if(index == animes.length && isLoading)
                    return Center(child: CircularProgressIndicator(color: Colors.red,));

                  return Container(
                    width: double.infinity,
                    height: 40,
                    margin: EdgeInsets.symmetric(vertical: 5),
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
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 8,
                            child: Text(
                              animes[index].name,
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
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                onPressed: () {
                                  showAlertDialog(animes[index].name);
                                },
                                icon: Icon(
                                  widget.blockedAnime.contains(animes[index].name) ? Icons.lock_open : Icons.block,
                                  color: Colors.white,
                                  size: 25,
                                ),
                              ),
                            )
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
      ),
    );
  }
}
