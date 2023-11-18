import 'package:clean_cubit_reactor_example/src/data/data_sources/items_service.dart';
import 'package:clean_cubit_reactor_example/src/data/models/item_model.dart';
import 'package:clean_cubit_reactor_example/src/domain/entities/sample_item.dart';

abstract class ItemsRepository {
  Future<(List<SampleItem>?, String?)> loadData();
  Future<(bool, String?)> updateItem(String id, String name);
  Future<(bool, String?)> deleteItem(String id);
  Future<(bool, String?)> addNewItem(SampleItem item);
}

class ItemsRepositoryImpl extends ItemsRepository {
  final ItemsService _itemsService;

  ItemsRepositoryImpl({required ItemsService itemsService}) : _itemsService = itemsService;

  List<SampleItem>? _converter(List<ItemModel>? data) {
    return data?.map((e) => SampleItem.from(itemModel: e)).toList();
  }

  @override
  Future<(List<SampleItem>?, String?)> loadData() async {
    List<ItemModel>? resultList;
    String? err;

    try {
      resultList = await _itemsService.loadItems();
    } catch (e) {
      err = e.toString();
    }

    return (_converter(resultList), err);
  }

  @override
  Future<(bool, String?)> addNewItem(SampleItem item) async {
    try {
      await _itemsService.addItem(item.toItemModel());
      return (true, null);
    } catch (e) {
      return (false, e.toString());
    }
  }

  @override
  Future<(bool, String?)> deleteItem(String id) async {
    try {
      await _itemsService.deleteItem(id);
      return (true, null);
    } catch (e) {
      return (false, e.toString());
    }
  }

  @override
  Future<(bool, String?)> updateItem(String id, String name) async {
    try {
      await _itemsService.updateItem(id, name);
      return (true, null);
    } catch (e) {
      return (false, e.toString());
    }
  }
}
