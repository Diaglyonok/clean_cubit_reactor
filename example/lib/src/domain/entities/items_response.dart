import 'package:clean_cubit_reactor/clean_cubit_reactor.dart';
import 'package:clean_cubit_reactor_example/src/domain/entities/error_model.dart';
import 'package:clean_cubit_reactor_example/src/domain/entities/sample_item.dart';

import 'listener_type.dart';

enum RequestUpdateType {
  delete,
  add,
  update,
}

abstract class ItemsBaseResponse extends ReactorResponse<ListenersType> {}

class ItemsLoadResponse extends ItemsBaseResponse {
  final List<SampleItem>? data;
  final LoadError? error;

  ItemsLoadResponse(
    this.data, {
    this.error,
  });

  @override
  ListenersType get type => ListenersType.loadListener;
}

class ItemsUpdateResponse extends ItemsBaseResponse {
  final SampleItem? updateItem;
  final UpdateError? error;
  final RequestUpdateType updateType;

  ItemsUpdateResponse({
    required this.updateType,
    this.updateItem,
    this.error,
  });

  @override
  ListenersType get type => ListenersType.updateListener;
}
