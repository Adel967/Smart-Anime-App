import 'package:bloc/bloc.dart';
import 'package:netflixbro/models/content_model.dart';


class SearchAnimeCubit extends Cubit<List<Anime>> {
  SearchAnimeCubit() : super(List.empty());

  List<Anime> get state => super.state;

  setSearchAnimes(List<Anime> animes) => emit(animes);

  clearSearchAnime() => emit([]);

  addToList(String name){
    List<Anime> animes = List.from(state);
    if(animes.isNotEmpty){
      animes.forEach((element) {
        if(element.name == name){
          element.myList = '1';
        }
      });
    }
  }
}
