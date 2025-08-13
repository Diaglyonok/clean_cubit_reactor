import 'package:clean_cubit_reactor_example/src/data/repository/items_repo_reactor.dart';
import 'package:clean_cubit_reactor_example/src/domain/entities/sample_item.dart';

class UpdateItemUsecase {
  final ItemsRepoReactor _reactor;

  UpdateItemUsecase(this._reactor);

  void call(SampleItem item) async {
    _reactor.update(item);
  }
}
