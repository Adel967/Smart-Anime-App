import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:netflixbro/services.dart';

import '../constants.dart';

class SearchByImageScreen extends StatefulWidget {
  const SearchByImageScreen({Key? key}) : super(key: key);

  @override
  State<SearchByImageScreen> createState() => _SearchByImageScreenState();
}

class _SearchByImageScreenState extends State<SearchByImageScreen> {

  File? file;
  ImagePicker imagePicker= ImagePicker();
  bool isLoading = false;
  Map<String,String> searchedAnime = {"name":""};

  getImage()async{
    var image = await imagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      file = File(image!.path);
    });
  }

  searchAnime()async{
    setState(() {
      isLoading = true;
    });
    final res = await Services.getAnimeByImage(file!);
    isLoading = false;
    searchedAnime = res;
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      progressIndicator: CircularProgressIndicator(color: Colors.red,),
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: backgroundColor,
          title: Text(
            "Search Anime",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              Container(
                  height: 250,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Color(0xFF151E29),
                  ),
                  child: file == null ? Center(
                    child: GestureDetector(
                      onTap: getImage,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.cloud,
                            size: 35,
                            color: Colors.white,
                          ),
                          Text(
                            "Upload an Image",
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white
                            ),
                          )
                        ],
                      ),
                    ),
                  ) : Stack(
                    children: [
                      Image.file(
                        file!,
                        fit: BoxFit.cover,
                        height: 250,
                        width: double.infinity,
                      ),
                      Positioned(
                        top: 10,
                        left: 10,
                        child: GestureDetector(
                          onTap: getImage,
                          child: const Icon(
                            Icons.change_circle,
                            color: Color(0xFFE83D66),
                            size: 50,
                          ),
                        ),
                      )
                    ],
                  )
              ),
              SizedBox(height: 20,),
              GestureDetector(
                onTap: (){
                  if(file != null){
                    searchAnime();
                  }
                },
                child: Container(
                  height: 50,
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                          colors: file == null ? [Colors.grey,Colors.grey] : [Color(0xFF963B7B),Color(0xFF9D3873),Color(0xFFA5366B),Color(0xFFAA3465),Color(0xFFB63159),Color(0xFFBF2D4F),Color(0xFFA92A4B),Color(0xFFC22D4C)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight
                      )
                  ),
                  child: Text(
                    'Search',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600
                    ),
                  ),
                ),
              ),
              SizedBox(height: 15,),
              searchedAnime["name"]!.isNotEmpty ? Column(
                children: [
                  Text(
                    "Result",
                    style: TextStyle(
                      color: textColor,
                      fontSize: 25,
                      fontWeight: FontWeight.w600
                    ),
                  ),
                  SizedBox(height: 10,),
                  Container(
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
                            "Title: " + searchedAnime["name"]!,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16
                            ),
                            maxLines: 1,
                          ),
                          SizedBox(height: 10,),
                          Text(
                            "Episode: "+searchedAnime["episode"]!,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ):SizedBox.shrink()
            ],
          ),
        ),
      ),
    );
  }
}
