import 'package:bloc/bloc.dart';
import 'package:netflixbro/models/content_model.dart';


class ComingSoonAnimeCubit extends Cubit<List<Anime>> {
  ComingSoonAnimeCubit() : super(List.empty());

  List<Anime> get state => super.state;

  changeAmime(List<Anime> animes){
    emit(animes);
  }

  clearAnime(){
    emit([]);
  }
}
