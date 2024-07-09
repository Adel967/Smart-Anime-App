import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';


class IsLoadingCubit extends Cubit<List<bool>> {
  IsLoadingCubit() : super([true,false]);

  List<bool> get state => super.state;

  changeFirstState(bool bo){
    List<bool> l = List.from(state);
    l[0] = bo;
    emit(l);
  }

  changeSecondState(bool bo){
    List<bool> l = List.from(state);
    l[1] = bo;
    emit(l);
  }


}
