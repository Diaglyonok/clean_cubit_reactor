import 'package:clean_cubit_reactor/clean_cubit_reactor.dart';
import 'package:clean_cubit_reactor_example/src/domain/entities/error_model.dart';
import 'package:clean_cubit_reactor_example/src/domain/entities/items_response.dart';
import 'package:clean_cubit_reactor_example/src/domain/entities/listener_type.dart';
import 'package:clean_cubit_reactor_example/src/domain/entities/sample_item.dart';
import 'package:clean_cubit_reactor_example/src/data/repository/items_repo_reactor.dart';
import 'package:clean_cubit_reactor_example/src/domain/usecases/fetch_item_usecase.dart';
import 'package:flutter/material.dart';

@immutable
abstract class ItemsCubitState {
  final List<SampleItem>? items;
  const ItemsCubitState(this.items);
}

//STATES
class ItemsCubitShimmerState extends ItemsCubitState {
  const ItemsCubitShimmerState(List<SampleItem>? items) : super(items);
}

class ItemsCubitHasDataState extends ItemsCubitState {
  const ItemsCubitHasDataState(List<SampleItem> items) : super(items);
}

class ItemsCubitErrorState extends ItemsCubitState {
  final LoadError? error;
  const ItemsCubitErrorState(List<SampleItem>? items, {required this.error})
      : super(items);

  String getErrorString(BuildContext context) {
    //get localization from context here
    return 'Sorry, something went wrong, please, try again';
  }
}

//CUBIT
class ItemsCubit
    extends CubitListener<ListenersType, ItemsLoadResponse, ItemsCubitState> {
  ItemsCubit(ItemsBaseReactor reactor, FetchItemsUsecase fetchItemsUsecase)
      : super(
            ItemsCubitShimmerState(
                reactor.getLastData<ItemsLoadResponse>()?.data),
            reactor,
            ListenersType.loadListener) {
    fetchItemsUsecase();
  }

  @override
  void emitOnResponse(ItemsLoadResponse response) {
    final data = response.data;
    final error = response.error;

    if (error != null || data == null) {
      emit(ItemsCubitErrorState(null, error: error));
      return;
    }

    emit(ItemsCubitHasDataState(data));
  }

  @override
  void setLoading({required ItemsLoadResponse data}) {
    emit(ItemsCubitShimmerState(data.data));
  }
}
