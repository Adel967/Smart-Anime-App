import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:netflixbro/constants.dart';
import 'package:netflixbro/cubits/cubits.dart';
import 'package:netflixbro/cubits/search_anime_cubit.dart';
import 'package:netflixbro/cubits/search_kind_cubit.dart';
import 'package:netflixbro/models/content_model.dart';
import 'package:netflixbro/screens/anime_screen.dart';
import 'package:netflixbro/screens/nav_screen.dart';
import 'package:netflixbro/screens/search_by_image_screen.dart';
import 'package:netflixbro/services.dart';
import 'package:netflixbro/sqlite.dart';
import 'package:provider/src/provider.dart';


class SearchScreen extends StatefulWidget {

  static late  final BuildContext context;

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with AutomaticKeepAliveClientMixin<SearchScreen>{
  PageStorageKey searchKey = PageStorageKey("search");
  bool isLoading = true;
  bool isLoading1 = false;
  String search = "";
  ScrollController _scrollController = ScrollController();
  TextEditingController searchController = TextEditingController();
  late int _currentTap ;
  List<Anime> animes = [];
  String kind = "All";
  String error = "";
  List<Anime> myList = [];
  List<String> kinds = [
    "All",
    "Action",
    "Adventure",
    "Comedy",
    "Shounen",
    "Romance",
    "Horror",
    "Mystery",
    "Psychological"
  ];

  @override
  void initState() {
    print(NavScreen.context.toString());
    _scrollController.addListener(() {
      if(_scrollController.position.pixels == _scrollController.position.maxScrollExtent){
        if(isLoading && !isLoading1){
          getAnimes(kind,searchController.text);
        }
      }

    });
    super.initState();
  }

  getListAnime()async{
    final res = await SQLiteHelper.instance.readListAnime();
    setState(() {
      myList = List.from(res);
    });
  }

  @override
  void didChangeDependencies() {
    final List<Anime> counterBloc = BlocProvider.of<SearchAnimeCubit>(context).state;
    final List<String>  searchBloc = BlocProvider.of<SearchKindCubit>(context).state;
    if(counterBloc.isNotEmpty){
      setState(() {
        _currentTap = int.parse(searchBloc.first);
        animes = List.from(counterBloc);
        searchController.text = searchBloc.last;
        if(animes.length < 10){
          isLoading = false;
        }
      });
    }else{
      _currentTap = 0;
      getAnimes("All","");
    }


    //do whatever you want with the bloc here.
    super.didChangeDependencies();
  }

  changeSearchKind(){
    context.read<SearchKindCubit>().changeSearch(_currentTap,search);
  }

  changeAnime(){
    context.read<SearchAnimeCubit>().setSearchAnimes(animes);
    changeSearchKind();
    setState(() {

    });
  }

  clearAnime(){
    changeSearchKind();
    context.read<SearchAnimeCubit>().clearSearchAnime();
  }

  getAnimes(String k,String s)async{
    isLoading1 = true;
    final List<List<Anime>>  animeBloc = BlocProvider.of<AnimesLoadCubit>(context).state;
    if(animeBloc[1].isEmpty){
      await getListAnime();
    }else{
      myList = List.from(animeBloc[1]);
    }
    if(await checkInternetConnection()){
      setState(() {
        error = "";
      });
      final response = await Services.getAnimesByKind(kind, animes.length ,s.trim(),10);
      setState(() {
        if(kinds[_currentTap] == k && s == search) {
          response.forEach((element) {
            if(myList.where((element1) => element1.name == element.name).toList().isNotEmpty){
              element.myList = '1';
            }
          });
          animes.addAll(response);
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
        error = "";
      });
      final response = await SQLiteHelper.instance.readAllAnimesForSearch(kind, animes.length ,s);

      setState(() {
        if(response.isEmpty && !backgroundDownload){
          error = "Check your Internet connection!";
          return;
        }
        if(kinds[_currentTap] == k && s == search) {
          response.forEach((element) {
            if(myList.where((element1) => element1.name == element.name).toList().isNotEmpty){
              element.myList = '1';
            }
          });
          animes.addAll(response);
          changeAnime();
        }
        if(animes.length % 10 != 0 || response.isEmpty){
          isLoading = false;
          if(response.isEmpty)
            error = "There isn't any anime like this! ";
        }

      });
    }
    isLoading1 = false;
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

  animeRate(String evaluation){
    double rate = double.parse(evaluation);
    rate /=2;
    String inString = rate.toStringAsFixed(1);
    double inDouble = double.parse(inString);
    return inDouble;
  }

  @override
  // ignore: must_call_super
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: backgroundColor,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFFE83D66),
        child: Icon(Icons.image,color: Colors.white,),
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => SearchByImageScreen())),
      ),
      appBar: PreferredSize(
        preferredSize: Size(screenSize.width,95.0),
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
                    getAnimes(kind,input);

                  }),
                  style: TextStyle(
                      color: textColor
                  ),

                  decoration: InputDecoration(
                      hintStyle: TextStyle(
                          color: textColor
                      ),
                      hintText: 'Search for anime....',
                      fillColor: Colors.white,
                      border: InputBorder.none,
                      suffixIcon: Icon(
                        Icons.search,
                        color: textColor,
                        size: 25.0,
                      )
                  ),
                ),
              ),
              Container(
                height: 40,
                child: ListView.builder(
                  key: PageStorageKey('kinds'),
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  itemCount: kinds.length,
                  itemBuilder: (context,index){
                    String kind = kinds[index];
                    return GestureDetector(
                      onTap: () => setState(() {
                        _currentTap = index;
                        this.kind = kind;
                        animes = [];
                        clearAnime();
                        isLoading = true;
                        getAnimes(kind,search);
                      }),
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 5,vertical: 5),
                        padding: EdgeInsets.symmetric(horizontal: 14),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: _currentTap == index ? Color(0xFFE83D66) : Color(0xFF151E29),
                            borderRadius: BorderRadius.circular(15)
                        ),
                        child: Text(
                          kind,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16
                          ),
                        ),
                      ),
                    );
                  },
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
          child: BlocBuilder<SearchAnimeCubit,List<Anime>>(
              builder: (context,animes){
                return  animes.isEmpty ? error.isEmpty ? Center(child: CircularProgressIndicator(color: Colors.red,)) : Center(child: Text(error,style: TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.w600),),) :
                Container(
                  width: double.infinity,
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(vertical: 15,horizontal: 12),
                    controller: _scrollController,
                    shrinkWrap: true,
                    itemCount: isLoading ? animes.length + 1  : animes.length ,
                    itemBuilder: (context,index){

                      print("index " + index.toString() + animes.length.toString());
                      print(searchKey.value);

                      if(index == animes.length && isLoading)
                        return Center(child: CircularProgressIndicator(color: Colors.red,));

                      Anime anime = animes[index];
                      return GestureDetector(
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => AnimeScreen(anime: anime,context: context,))),
                        child: Container(
                          margin: EdgeInsets.only(top: 20,bottom: 20),
                          child: Row(
                            children: [
                              Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Image(image: AssetImage("assets/images/naruto.jpg"),
                                      height: 210,
                                      width: screenSize.width * 0.35,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Hero(
                                        tag: anime.imageUrl + anime.myList + anime.trending + anime.main,
                                        child: backgroundDownload ? CachedNetworkImage(
                                          height: 210,
                                          width: screenSize.width * 0.35,
                                          imageUrl: anime.imageUrl,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) => Center(child: CircularProgressIndicator(color: Colors.red)),
                                        ) :
                                        SizedBox(
                                          height: 210,
                                          width: screenSize.width * 0.35,
                                          child: Image.network(
                                              anime.imageUrl,
                                              height: 210,
                                              width: screenSize.width * 0.35,
                                              fit: BoxFit.cover
                                          ),
                                        )
                                    ),
                                  ),
                                ],
                              ),
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.only(left: 10),
                                  height: 180,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      color: textColor,
                                      borderRadius: BorderRadius.only(topRight: Radius.circular(15),bottomRight: Radius.circular(15))
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 230,
                                        child: Text(anime.name,
                                          style: TextStyle(
                                              color: backgroundColor,
                                              fontSize: 19,
                                              fontWeight: FontWeight.w600
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text('Episodes ${anime.episodesNum}',
                                        style: TextStyle(
                                            color: backgroundColor,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600
                                        ),
                                      ),
                                      SizedBox(height:8),
                                      RatingBar.builder(
                                        initialRating: animeRate(anime.evaluation),
                                        minRating: 1,
                                        direction: Axis.horizontal,
                                        allowHalfRating: true,
                                        ignoreGestures: true,
                                        itemCount: 5,
                                        itemPadding: EdgeInsets.symmetric(horizontal: 0.0),
                                        itemBuilder: (context, _) => Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                        ),
                                        onRatingUpdate: (rating) {
                                          print(rating);
                                        },
                                      ),
                                      SizedBox(height: 8),
                                      Text('Released in ${anime.released}',
                                        style: TextStyle(
                                            color: backgroundColor,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600
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
                );})
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
