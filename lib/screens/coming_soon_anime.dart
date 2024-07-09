import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:netflixbro/constants.dart';
import 'package:netflixbro/cubits/coming_soon_anime_cubit.dart';
import 'package:netflixbro/cubits/search_cubit.dart';
import 'package:netflixbro/models/content_model.dart';
import 'package:netflixbro/services.dart';

class ComingSoonScreen extends StatefulWidget {
  @override
  _ComingSoonScreenState createState() => _ComingSoonScreenState();
}

class _ComingSoonScreenState extends State<ComingSoonScreen> {


  PageStorageKey searchKey = PageStorageKey("search");
  bool isLoading = true;
  String search = "";
  ScrollController _scrollController = ScrollController();
  TextEditingController searchController = TextEditingController();
  List<Anime> animes = [];
  String error = "";

  changeSearch(){
    context.read<SearchCubit>().setSearch(search);
  }

  changeAnime(){
    changeSearch();
    context.read<ComingSoonAnimeCubit>().changeAmime(animes);
    setState(() {

    });
  }

  clearAnime(){
    changeSearch();
    context.read<ComingSoonAnimeCubit>().clearAnime();
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

  getAnimes(String s)async{
    if(await checkInternetConnection()){

      setState(() {
        error = "";
      });
      final response = await Services.getComingSoonAnime( animes.length ,s.trim());
      print(response);
      setState(() {
        if( s == search) {
          for (int i = 0; i < response.length; i++) {
            animes.add(response[i]);
          }
          changeAnime();
        }
        if(animes.length % 10 != 0 || response.isEmpty){
          isLoading = false;
          if(response.isEmpty)
            error = "There isn't any anime like this! ";
        }

      });
    }else{
      setState(() {
        error = "Check your internet connection!";
      });

    }
  }

  @override
  void initState() {
    _scrollController.addListener(() {
      if(_scrollController.position.pixels == _scrollController.position.maxScrollExtent){
        if(isLoading){
          getAnimes("");
        }
      }

    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    final List<Anime> counterBloc = BlocProvider.of<ComingSoonAnimeCubit>(context).state;
    final String  searchBloc = BlocProvider.of<SearchCubit>(context).state;

    if(counterBloc.isNotEmpty){
      setState(() {
        animes = List.from(counterBloc);
        searchController.text = searchBloc;
        if(animes.length < 10){
          isLoading = false;
        }
      });
    }else{
      getAnimes("");
    }


    //do whatever you want with the bloc here.
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: PreferredSize(
        preferredSize: Size(screenSize.width,50.0),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                color: backgroundColor,
                child: TextField(
                  controller: searchController,
                  cursorColor: Colors.red,
                  onChanged: (input) => setState(() {
                    isLoading = true;
                    animes = [];
                    clearAnime();
                    search = input;
                    getAnimes(input);

                  }),
                  style: TextStyle(
                      color: Colors.white
                  ),

                  decoration: InputDecoration(
                      hintStyle: TextStyle(
                          color: textColor
                      ),
                      hintText: 'Search for anime....',
                      fillColor: backgroundColor,
                      border: InputBorder.none,
                      suffixIcon: Icon(
                        Icons.search,
                        color: textColor,
                        size: 25.0,
                      )
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: GestureDetector(
          onTap: () => {
            FocusScope.of(context).unfocus(),

          },

          child: BlocBuilder<ComingSoonAnimeCubit,List<Anime>>(
              builder: (context,animes){
                return  animes.isEmpty ? error.isEmpty ? Center(child: CircularProgressIndicator(color: Colors.red,)) : Center(child: Text(error,style: TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.w600),),) :
                Container(
                  width: double.infinity,
                  child: ListView.builder(
                    key: PageStorageKey("Coming"),
                    padding: EdgeInsets.symmetric(vertical: 15,horizontal: 10),
                    controller: _scrollController,
                    shrinkWrap: true,
                    itemCount: isLoading ? animes.length + 1  : animes.length ,
                    itemBuilder: (context,index){

                      print("index " + index.toString() + animes.length.toString());
                      print(searchKey.value);

                      if(index == animes.length     && isLoading)
                        return Center(child: CircularProgressIndicator(color: Colors.red,));

                      Anime anime = animes[index];
                      return Container(
                        margin: EdgeInsets.only(top: 20,bottom: 20),
                        width: double.infinity,
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20.0),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black45,
                                        offset: Offset(0.0, 2.0),
                                        blurRadius: 6)
                                  ]),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.only(topRight: Radius.circular(20.0),topLeft: Radius.circular(20)),
                                    child: SizedBox(
                                      height: 180,
                                      width: 270,
                                      child: Image.asset(
                                        "assets/images/naruto.jpg",
                                        height: 180,
                                        width: 270,
                                        fit: BoxFit.cover,
                                        alignment: Alignment.center,
                                      ),
                                    ),
                                  ),
                                  ClipRRect(
                                    borderRadius: BorderRadius.only(topRight: Radius.circular(20.0),topLeft: Radius.circular(20)),
                                    child: SizedBox(
                                      height: 180,
                                      width: 270,
                                      child: Image.network(
                                        anime.imageUrl,
                                        height: 180,
                                        width: 270,
                                        fit: BoxFit.cover,
                                        alignment: Alignment.center,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                               Container(
                                width: 360,
                                padding: EdgeInsets.fromLTRB(10,10,10,10),
                                decoration: BoxDecoration(
                                    color: textColor,
                                    borderRadius: BorderRadius.circular(10)),
                                child: Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        anime.name.toUpperCase(),
                                        style: TextStyle(
                                          color: backgroundColor,
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: 10,),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: <Widget>[
                                          Column(
                                            children: <Widget>[
                                              Text(
                                                 'release' ,
                                                style: TextStyle(
                                                  color: backgroundColor == Colors.black ? Colors.black54 : Colors.white70,
                                                  fontSize: 16.0,
                                                ),
                                              ),
                                              SizedBox(height: 2.0),
                                              Text(
                                                anime.released.toString(),
                                                style: TextStyle(
                                                  color: backgroundColor,
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
                                                  color: backgroundColor == Colors.black ? Colors.black54 : Colors.white70,
                                                  fontSize: 16.0,
                                                ),
                                              ),
                                              SizedBox(height: 2.0),
                                              Text(
                                                anime.country.toUpperCase(),
                                                style: TextStyle(
                                                  color: backgroundColor,
                                                  fontSize: 20.0,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),


                                        ],
                                      ),
                                      SizedBox(height: 10,),
                                      Container(
                                        height: 50,
                                        child: SingleChildScrollView(
                                          child: Text(
                                            anime.description,
                                            style: TextStyle(
                                              color: backgroundColor == Colors.black ? Colors.black54 : Colors.white70,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),


                          ],
                        ),
                        // child: Row(
                        //
                        //   children: [
                        //     ClipRRect(
                        //         borderRadius: BorderRadius.circular(15),
                        //         child: Hero(
                        //           tag: anime.imageUrl + anime.myList + anime.trending + anime.main,
                        //           child: CachedNetworkImage(
                        //             height: 210,
                        //             width: screenSize.width * 0.35,
                        //             imageUrl: anime.imageUrl,
                        //             fit: BoxFit.cover,
                        //             placeholder: (context, url) => Center(child: CircularProgressIndicator(color: Colors.red)),
                        //           ),
                        //         )
                        //     ),
                        //     Expanded(
                        //       child: Container(
                        //         padding: EdgeInsets.only(left: 10),
                        //         height: 180,
                        //         alignment: Alignment.center,
                        //         decoration: BoxDecoration(
                        //             color: Colors.white,
                        //             borderRadius: BorderRadius.only(topRight: Radius.circular(15),bottomRight: Radius.circular(15))
                        //         ),
                        //         child: Column(
                        //           crossAxisAlignment: CrossAxisAlignment.start,
                        //           mainAxisAlignment: MainAxisAlignment.center,
                        //           children: [
                        //             Container(
                        //               width: 230,
                        //               child: Text(anime.name,
                        //                 style: TextStyle(
                        //                     color: Colors.black,
                        //                     fontSize: 19,
                        //                     fontWeight: FontWeight.w600
                        //                 ),
                        //                 maxLines: 2,
                        //                 overflow: TextOverflow.ellipsis,
                        //               ),
                        //             ),
                        //             SizedBox(height: 8),
                        //             Text('Episodes ${anime.episodesNum}',
                        //               style: TextStyle(
                        //                   color: Colors.black,
                        //                   fontSize: 18,
                        //                   fontWeight: FontWeight.w600
                        //               ),
                        //             ),
                        //             SizedBox(height:8),
                        //             // Text(animeRate(int.parse(anime.evaluation)),style: TextStyle(fontSize: 18),),
                        //             SizedBox(height: 8),
                        //             Text('Year ${anime.released}',
                        //               style: TextStyle(
                        //                   color: Colors.black,
                        //                   fontSize: 18,
                        //                   fontWeight: FontWeight.w600
                        //               ),
                        //             ),
                        //           ],
                        //         ),
                        //       ),
                        //     ),
                        //   ],
                        // ),
                      );
                    },
                  ),
                );})
      ),
    );
  }
}
