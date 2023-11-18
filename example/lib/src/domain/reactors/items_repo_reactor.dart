import 'package:clean_cubit_reactor/clean_cubit_reactor.dart';
import 'package:clean_cubit_reactor_example/src/data/repository/items_repository.dart';
import 'package:clean_cubit_reactor_example/src/domain/entities/error_model.dart';
import 'package:clean_cubit_reactor_example/src/domain/entities/items_response.dart';
import 'package:clean_cubit_reactor_example/src/domain/entities/listener_type.dart';
import 'package:clean_cubit_reactor_example/src/domain/entities/sample_item.dart';

abstract class ItemsRepoReactor with Reactor<ListenersType, ItemsBaseResponse> {
  bool isReady();
  List<SampleItem>? get data;

  void loadItems();
  void addItem(SampleItem item);
  void delete(SampleItem item);
  void update(SampleItem item);
}

class ItemsRepoReactorImpl extends ItemsRepoReactor {
  final ItemsRepository _repository;

  List<SampleItem>? _data;

  ItemsRepoReactorImpl({required ItemsRepository repository}) : _repository = repository;

  @override
  bool isReady() => _data != null && _data!.isNotEmpty;

  @override
  List<SampleItem>? get data => _data;

  @override
  void loadItems() async {
    setLoading(
      currentData: ItemsLoadResponse(_data, error: null),
    );

    //here may be local caching

    List<SampleItem>? resultList;
    String? err;

    (resultList, err) = await _repository.loadData();

    _data = resultList;
    provideUpdatedLoadData(err);
  }

  provideUpdatedLoadData(String? err) {
    provideDataToListeners(
      ItemsLoadResponse(
        data,
        error: LoadError.getError(err),
      ),
    );
  }

  @override
  void addItem(SampleItem item) async {
    const type = RequestUpdateType.add;
    setLoading(
      currentData: ItemsUpdateResponse(updateItem: item, updateType: type),
    );

    bool isAdded;
    String? err;

    (isAdded, err) = await _repository.addNewItem(item);

    provideDataToListeners(
      ItemsUpdateResponse(
        updateItem: isAdded ? item : null,
        updateType: type,
        error: UpdateError.getError(err, type),
      ),
    );

    if (isAdded) {
      _data?.add(item);
      provideUpdatedLoadData(err);
    }
  }

  @override
  void delete(SampleItem item) async {
    const type = RequestUpdateType.delete;
    setLoading(
      currentData: ItemsUpdateResponse(updateItem: item, updateType: type),
    );

    bool isDeleted;
    String? err;

    (isDeleted, err) = await _repository.deleteItem(item.id);

    provideDataToListeners(
      ItemsUpdateResponse(
        updateItem: isDeleted ? item : null,
        updateType: type,
        error: UpdateError.getError(err, type),
      ),
    );

    if (isDeleted) {
      _data?.removeWhere((element) => element.id == item.id);
      provideUpdatedLoadData(err);
    }
  }

  @override
  void update(SampleItem item) async {
    const type = RequestUpdateType.update;

    setLoading(
      currentData: ItemsUpdateResponse(updateItem: item, updateType: type),
    );

    bool isUpdated;
    String? err;

    (isUpdated, err) = await _repository.updateItem(item.id, item.name);

    provideDataToListeners(
      ItemsUpdateResponse(
        updateItem: isUpdated ? item : null,
        updateType: type,
        error: UpdateError.getError(err, type),
      ),
    );

    if (isUpdated) {
      final index = _data?.indexWhere((element) => element.id == item.id) ?? -1;
      if (index < 0) {
        return;
      }

      _data?[index] = item;
      provideUpdatedLoadData(err);
    }
  }
}
