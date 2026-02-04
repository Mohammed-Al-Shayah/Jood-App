import 'package:flutter_bloc/flutter_bloc.dart';

abstract class SafeCubit<S> extends Cubit<S> {
  SafeCubit(super.initialState);

  void emitSafe(S next) {
    if (isClosed) return;
    emit(next);
  }
}
