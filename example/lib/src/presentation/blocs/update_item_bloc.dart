import 'package:clean_cubit_reactor/clean_cubit_reactor.dart';
import 'package:clean_cubit_reactor_example/src/domain/entities/error_model.dart';
import 'package:clean_cubit_reactor_example/src/domain/entities/items_response.dart';
import 'package:clean_cubit_reactor_example/src/domain/entities/listener_type.dart';
import 'package:clean_cubit_reactor_example/src/domain/entities/sample_item.dart';
import 'package:clean_cubit_reactor_example/src/data/repository/items_repo_reactor.dart';
import 'package:clean_cubit_reactor_example/src/domain/usecases/add_item_usecase.dart';
import 'package:clean_cubit_reactor_example/src/domain/usecases/delete_item_usecase.dart';
import 'package:clean_cubit_reactor_example/src/domain/usecases/update_item_usecase.dart';
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

class ItemUpdateCubit extends CubitListener<ListenersType, ItemsUpdateResponse,
    ItemUpdateCubitState> {
  ItemUpdateCubit(ItemsBaseReactor reactor, this._addItemUsecase,
      this._deleteItemUsecase, this._updateItemUsecase)
      : super(
            ItemUpdateCubitInitState(), reactor, ListenersType.updateListener);

  final AddItemUsecase _addItemUsecase;
  final DeleteItemUsecase _deleteItemUsecase;
  final UpdateItemUsecase _updateItemUsecase;

  void addItem(String name) => _addItemUsecase(name);

  void deleteFlatItem(SampleItem item) => _deleteItemUsecase(item);

  void updateFlatItem(SampleItem item) => _updateItemUsecase(item);

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
