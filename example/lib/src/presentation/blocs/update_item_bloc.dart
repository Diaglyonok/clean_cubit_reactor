import 'package:clean_cubit_reactor/clean_cubit_reactor.dart';
import 'package:clean_cubit_reactor_example/src/domain/entities/error_model.dart';
import 'package:clean_cubit_reactor_example/src/domain/entities/items_response.dart';
import 'package:clean_cubit_reactor_example/src/domain/entities/listener_type.dart';
import 'package:clean_cubit_reactor_example/src/domain/entities/sample_item.dart';
import 'package:clean_cubit_reactor_example/src/domain/reactors/items_repo_reactor.dart';
import 'package:flutter/material.dart';

@immutable
abstract class ItemUpdateCubitState {}

class ItemUpdateCubitInitState extends ItemUpdateCubitState {}

class ItemUpdateCubitShimmerState extends ItemUpdateCubitState {
  final String? updateId;

  ItemUpdateCubitShimmerState({this.updateId});
}

class ItemUpdateCubitSuccessState extends ItemUpdateCubitState {
  final SampleItem? item;

  ItemUpdateCubitSuccessState(this.item);
}

class ItemUpdateCubitErrorState extends ItemUpdateCubitState {
  final UpdateError? error;

  ItemUpdateCubitErrorState({
    this.error,
  });

  String getErrorString(BuildContext context) {
    //get localization from context here
    return 'Sorry, something went wrong, please, try again';
  }
}

class ItemUpdateCubit extends CubitListener<ListenersType, ItemsUpdateResponse, ItemUpdateCubitState> {
  ItemUpdateCubit(this._reactor) : super(ItemUpdateCubitInitState(), _reactor, ListenersType.updateListener);

  final ItemsRepoReactor _reactor;

  void addItem(String name) async {
    _reactor.addItem(SampleItem.create(name: name));
  }

  void deleteFlatItem(SampleItem item) async {
    _reactor.delete(item);
  }

  void updateFlatItem(SampleItem item) async {
    _reactor.update(item);
  }

  @override
  void emitOnResponse(ItemsUpdateResponse response) {
    final data = response.updateItem;
    final error = response.error;

    if (error != null) {
      emit(ItemUpdateCubitErrorState(error: error));
      return;
    }

    emit(ItemUpdateCubitSuccessState(data));
  }

  @override
  void setLoading({required ItemsUpdateResponse data}) {
    emit(ItemUpdateCubitShimmerState(
      updateId: data.updateItem?.id,
    ));
  }
}
