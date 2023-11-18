import 'package:clean_cubit_reactor_example/src/data/models/item_model.dart';
import 'package:clean_cubit_reactor_example/src/utils/string_randomizer.dart';

class SampleItem {
  const SampleItem({required this.id, required this.name});

  final String id;
  final String name;

  factory SampleItem.create({required String name}) {
    return SampleItem(
      id: generateRandomString(10),
      name: name,
    );
  }

  factory SampleItem.from({required ItemModel itemModel}) {
    return SampleItem(
      id: itemModel.id,
      name: itemModel.name,
    );
  }

  SampleItem withName(String name) {
    return SampleItem(id: id, name: name);
  }

  ItemModel toItemModel() {
    return ItemModel(id, name);
  }
}
