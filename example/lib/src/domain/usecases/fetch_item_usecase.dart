import 'package:clean_cubit_reactor_example/src/data/repository/items_repo_reactor.dart';

class FetchItemsUsecase {
  final ItemsRepoReactor _reactor;

  FetchItemsUsecase(this._reactor);

  void call() => _reactor.loadItems();
}
