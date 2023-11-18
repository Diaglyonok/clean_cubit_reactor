const divider = ';';

class ItemModel {
  final String id;
  final String name;

  ItemModel(this.id, this.name);

  @override
  String toString() {
    return '$id$divider$name';
  }

  static ItemModel? fromString(String str) {
    final splitted = str.split(divider);

    if (splitted.length != 2) {
      return null;
    }
    return ItemModel(splitted.first, splitted.last);
  }
}
