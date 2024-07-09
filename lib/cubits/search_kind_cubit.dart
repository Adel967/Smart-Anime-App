import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';


class SearchKindCubit extends Cubit<List<String>> {
  SearchKindCubit() : super(List.empty());

  List<String> get state => super.state;

  changeSearch(int index,String search){
    List<String> l = [index.toString(),search];
    emit(l);
  }

}
