import 'package:bloc/bloc.dart';
import 'package:netflixbro/models/content_model.dart';


class AnimesLoadCubit extends Cubit<List<List<Anime>>> {
  AnimesLoadCubit() : super([List.empty(),List.empty(),List.empty(),List.empty()]);
  @override
  // TODO: implement state
  List<List<Anime>> get state => super.state;
  
  void setAnimes(List<List<Anime>> animes) {
    emit( animes );
  }

  void addListAnime(Anime anime) {
    List<List<Anime>> l = List.from(state);
    l[1].add(anime);
    emit(l);
  }

  void deleteListAnime(String name) {
    List<List<Anime>> l = List.from(state);
    l[1].removeWhere((element) => element.name == name);
    l[0].forEach((element) {
      if(element.name == name)
        element.myList = '';
    });
    emit(l);
  }

}
