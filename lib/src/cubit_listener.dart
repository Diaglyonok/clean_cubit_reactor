import 'dart:developer';

import 'package:clean_cubit_reactor/src/reactor_base_response.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import './reactor.dart';

abstract class CubitListener<T, D extends ReactorResponse<T>, S>
    extends Cubit<S> {
  final Reactor _reactor;
  final T type;

  CubitListener(S state, this._reactor, this.type) : super(state) {
    _reactor.addListener(this);
  }

  @override
  Future<void> close() {
    _reactor.removeListener(this);
    return super.close();
  }

  void typedEmit(ReactorResponse<T> data, {bool isLoading = false}) {
    if (data is D) {
      if (isLoading) {
        setLoading(data: data);
      } else {
        emitOnResponse(data);
      }
    } else {
      log(data.runtimeType.toString());
    }
  }

  void emitOnResponse(D response);

  void setLoading({required D data});
}
