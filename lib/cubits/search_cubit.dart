import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';


class SearchCubit extends Cubit<String> {
  SearchCubit() : super("");

  String get state => super.state;

  setSearch(String search){
    emit(search);
  }
}
