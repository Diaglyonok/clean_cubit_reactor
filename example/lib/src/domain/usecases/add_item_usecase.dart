import 'package:clean_cubit_reactor_example/src/data/repository/items_repo_reactor.dart';
import 'package:clean_cubit_reactor_example/src/domain/entities/sample_item.dart';

class AddItemUsecase {
  final ItemsRepoReactor _reactor;

  AddItemUsecase(this._reactor);

  void call(String name) async {
    _reactor.addItem(SampleItem.create(name: name));
  }
}
