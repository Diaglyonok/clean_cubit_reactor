import 'package:clean_cubit_reactor_example/src/data/models/item_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class ItemsService {
  Future<List<ItemModel>> loadItems();

  updateItem(String id, String name);
  deleteItem(String id);

  addItem(ItemModel itemModel);
}

class LocalItemsService extends ItemsService {
  static const storageKey = 'items_key';

  @override
  Future<List<ItemModel>> loadItems() async {
    final prefs = await SharedPreferences.getInstance();
    final itemsStr = prefs.getStringList(storageKey) ?? <String>[];

    return itemsStr
        .map((e) => ItemModel.fromString(e))
        .where((element) => element != null)
        .toList()
        .cast<ItemModel>();
  }

  @override
  addItem(ItemModel itemModel) async {
    final prefs = await SharedPreferences.getInstance();
    final itemsStr = prefs.getStringList(storageKey) ?? <String>[];

    itemsStr.add(itemModel.toString());
    await prefs.setStringList(storageKey, itemsStr);
  }

  @override
  deleteItem(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final itemsStr = (prefs.getStringList(storageKey) ?? <String>[])
        .where((element) => ItemModel.fromString(element)?.id != id)
        .toList();

    await prefs.setStringList(storageKey, itemsStr);
  }

  @override
  updateItem(String id, String name) async {
    final prefs = await SharedPreferences.getInstance();
    final items = (prefs.getStringList(storageKey) ?? <String>[])
        .map((element) => ItemModel.fromString(element))
        .toList();

    final index = items.indexWhere((element) => element?.id == id);
    if (index < 0 || items[index] == null) {
      throw Exception();
    }

    items[index] = ItemModel(items[index]!.id, name);

    await prefs.setStringList(
        storageKey, items.map((e) => e.toString()).toList());
  }
}
