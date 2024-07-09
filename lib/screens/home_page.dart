import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:netflixbro/constants.dart';
import 'package:netflixbro/cubits/is_loading_cubit.dart';
import 'package:netflixbro/models/models.dart';
import 'package:netflixbro/screens/nav_screen.dart';
import 'package:netflixbro/services.dart';
import 'package:netflixbro/sqlite.dart';
import 'package:netflixbro/widgets/widgets.dart';
import 'package:netflixbro/cubits/cubits.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {

  const HomePage({required Key key}) : super(key:key);



  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double scrollOffset = 0.0;
  ScrollController _scrollController = ScrollController();

  List<Anime> main_anime = [];
  List<Anime> previews = [];
  List<Anime> myList = [];
  List<Anime> popularity = [];
  List<Anime> similar_anime = [];
  List<Anime> for_you = [];


  getAnime() async {

    if(await checkInternetConnection()){
      NavScreen.context.read<IsLoadingCubit>().changeFirstState(true);
      final response = await Future.wait<List<Anime>>(
          [ Services.getAnimes(),
            Services.getList()]
      );
      if(response[0].isEmpty){
        final res = await SQLiteHelper.instance.readAllHomeAnimes();
        final res1 = await SQLiteHelper.instance.readListAnime();
        res.forEach((element) {
          if(res1.where((element1) => element1.name == element.name).toList().isNotEmpty){
            element.myList = '1';
          }
        });
        this.context.read<AnimesLoadCubit>().setAnimes([res,res1]);

        return;
      }
      if(response[1].isEmpty)
        response[1] = [];
      response[0].forEach((element) {
        if(response[1].where((element1) => element1.name == element.name).toList().isNotEmpty){
          element.myList = '1';
        }
      });
      SQLiteHelper.instance.insertHomeAnime(response[0]);
      SQLiteHelper.instance.insertListAnime(response[1]);

      this.context.read<AnimesLoadCubit>().setAnimes([response[0],response[1]]);

      Future.delayed(Duration(seconds: 5),(){
        NavScreen.context.read<IsLoadingCubit>().changeFirstState(false);
      });

    }else{
      final res = await SQLiteHelper.instance.readAllHomeAnimes();
      final res1 = await SQLiteHelper.instance.readListAnime();
      res.forEach((element) {
        if(res1.where((element1) => element1.name == element.name).toList().isNotEmpty){
          element.myList = '1';
        }
      });
      this.context.read<AnimesLoadCubit>().setAnimes([res,res1]);

    }

  }

  getAnimeList(List<List<Anime>> animes){
    List<Anime> animeList = [];
    animes[0][0].main = '1';
    animes[0][0].trending = '0';
    animes[1].forEach((element) {
      element.trending = '0';
      element.main = '0';
    });
    animes[2].forEach((element) {
      element.trending = '1';
      element.main = '0';
    });
    animeList.add(animes[0][0]);
    animeList.addAll(animes[1]);
    animeList.addAll(animes[2]);
    return animeList;
  }

  getAnimeLists(List<Anime> animes){
    List<List<Anime>> animeList = [[],[],[]];
    for(int i=0;i<animes.length;i++) {
      Anime element = animes[i];
      if(element.main == '1' && element.trending == '0'){
        animeList[0].add(element);
      }else if(element.main == '0' && element.trending == '0'){
        if(animeList[1].length >=18)
          continue;
        animeList[1].add(element);
      }else{
        animeList[2].add(element);
      }
    };
    return animeList;
  }

  getAnime1() async {

    if(await checkInternetConnection()){
      NavScreen.context.read<IsLoadingCubit>().changeFirstState(true);
      final response = await Future.wait<dynamic>(
          [ Services.getAnimes1(),
            Services.getList()]
      );
      if(response[0].isEmpty){
        final res = await SQLiteHelper.instance.readAllHomeAnimes();
        final res1 = await SQLiteHelper.instance.readListAnime();
        res.forEach((element) {
          if(res1.where((element1) => element1.name == element.name).toList().isNotEmpty){
            element.myList = '1';
          }
        });
        this.context.read<AnimesLoadCubit>().setAnimes([res,res1]);

        return;
      }
      if(response[1].isEmpty)
        response[1] = [];

      List<List<Anime>> lists = [];
      lists.add(response[1]);
      lists.addAll(response[0]);
      lists.sublist(1).forEach((element) {
        element.forEach((element) {
          if(response[1].where((element1) => element1.name == element.name).toList().isNotEmpty){
            element.myList = '1';
          }
        });
      });
      print(lists);
      SQLiteHelper.instance.insertHomeAnime(getAnimeList(response[0]));
      SQLiteHelper.instance.insertListAnime(response[1]);
      this.context.read<AnimesLoadCubit>().setAnimes(lists);
      Future.delayed(Duration(seconds: 5),(){
        NavScreen.context.read<IsLoadingCubit>().changeFirstState(false);
      });
      setState(() {

      });
    }else{
      final res = await SQLiteHelper.instance.readAllHomeAnimes();
      final myList = await SQLiteHelper.instance.readListAnime();
      res.forEach((element) {
        if(myList.where((element1) => element1.name == element.name).toList().isNotEmpty){
          element.myList = '1';
        }
      });
      List<List<Anime>> animeLists = getAnimeLists(res);
      this.context.read<AnimesLoadCubit>().setAnimes([myList,animeLists[0],animeLists[1],animeLists[2]]);
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

  @override
  void initState() {
    final List<List<Anime>>  animes = BlocProvider.of<AnimesLoadCubit>(context).state;
    print(animes);
    if(animes[2].length < 20){
      getAnime1();
    }
    _scrollController = ScrollController()..addListener(() {
      setState(() {
        scrollOffset = _scrollController.offset;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AnimesLoadCubit,List<List<Anime>>>(
      builder: (context,animes){
        return animes[1].isEmpty ?
        Center(child: CircularProgressIndicator(color: Colors.red,),):
        Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: backgroundColor,
          // floatingActionButton: FloatingActionButton(
          //   backgroundColor: Colors.grey[850],
          //   child: Icon(Icons.cast),
          //   onPressed: () => print("Cast"),
          // ),
          // appBar: PreferredSize(
          //   preferredSize: Size(screenSize.width,50.0),
          //   child: CustomAppBar(scrollOffset: scrollOffset),
          // ),
          body: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(
                  child: ContentHeader(anime: animes[1][0],context: context,)
              ),
              SliverPadding(
                key: PageStorageKey('previews'),
                padding: EdgeInsets.only(top: 16),
                sliver: SliverToBoxAdapter(
                  child: Previews(
                    context: context,
                    title:'previews',
                    contentList: animes[2],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                key: PageStorageKey('myList'),
                child: ContentList(
                    title: 'My List',
                    contentList: animes[0].reversed.toList(),
                    context: context,
                    isOriginals: true,
                ),
              ),
              SliverPadding(
                key: PageStorageKey('trending'),
                padding: EdgeInsets.only(bottom: 20),
                sliver: SliverToBoxAdapter(
                  child: ContentList(
                    title: 'Popularity',
                    contentList: animes[3],
                    context: context

                  ),
                ),
              ),
              animes.length > 4 && animes[4].isNotEmpty ? SliverPadding(
                key: PageStorageKey('you may like'),
                padding: EdgeInsets.only(bottom: 20),
                sliver: SliverToBoxAdapter(
                  child: ContentList(
                      title: 'You may like',
                      contentList: animes[4],
                      context: context
                  ),
                ),
              ):SliverToBoxAdapter(),
              animes.length > 4 && animes[5].isNotEmpty ? SliverPadding(
                key: PageStorageKey('for you'),
                padding: EdgeInsets.only(bottom: 20),
                sliver: SliverToBoxAdapter(
                  child: ContentList(
                      title: 'For you',
                      contentList: animes[5],
                      context: context

                  ),
                ),
              ):SliverToBoxAdapter()
            ],
          ),
        ) ;
      },
    );
  }
}

