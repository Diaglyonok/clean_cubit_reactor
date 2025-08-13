import 'package:clean_cubit_reactor_example/src/data/data_sources/items_service.dart';
import 'package:clean_cubit_reactor_example/src/data/repository/items_repository.dart';
import 'package:clean_cubit_reactor_example/src/data/repository/items_repo_reactor.dart';
import 'package:clean_cubit_reactor_example/src/domain/usecases/add_item_usecase.dart';
import 'package:clean_cubit_reactor_example/src/domain/usecases/delete_item_usecase.dart';
import 'package:clean_cubit_reactor_example/src/domain/usecases/fetch_item_usecase.dart';
import 'package:clean_cubit_reactor_example/src/domain/usecases/update_item_usecase.dart';
import 'package:clean_cubit_reactor_example/src/presentation/blocs/items_bloc.dart';
import 'package:clean_cubit_reactor_example/src/presentation/blocs/update_item_bloc.dart';
import 'package:get_it/get_it.dart';

void registerDependencies() {
  GetIt.instance.registerFactory<ItemsService>(() => LocalItemsService());

  GetIt.instance.registerFactory<ItemsRepository>(
      () => ItemsRepositoryImpl(itemsService: GetIt.instance<ItemsService>()));
  GetIt.instance.registerLazySingleton<ItemsRepoReactor>(
      () => ItemsRepoReactorImpl(repository: GetIt.instance<ItemsRepository>()));

  GetIt.instance
      .registerFactory<AddItemUsecase>(() => AddItemUsecase(GetIt.instance<ItemsRepoReactor>()));
  GetIt.instance.registerFactory<DeleteItemUsecase>(
      () => DeleteItemUsecase(GetIt.instance<ItemsRepoReactor>()));
  GetIt.instance.registerFactory<UpdateItemUsecase>(
      () => UpdateItemUsecase(GetIt.instance<ItemsRepoReactor>()));
  GetIt.instance.registerFactory<FetchItemsUsecase>(
      () => FetchItemsUsecase(GetIt.instance<ItemsRepoReactor>()));

  GetIt.instance.registerFactory<ItemUpdateCubit>(() => ItemUpdateCubit(
      GetIt.instance<ItemsRepoReactor>(),
      GetIt.instance<AddItemUsecase>(),
      GetIt.instance<DeleteItemUsecase>(),
      GetIt.instance<UpdateItemUsecase>()));

  GetIt.instance.registerFactory<ItemsCubit>(
      () => ItemsCubit(GetIt.instance<ItemsRepoReactor>(), GetIt.instance<FetchItemsUsecase>()));
}
