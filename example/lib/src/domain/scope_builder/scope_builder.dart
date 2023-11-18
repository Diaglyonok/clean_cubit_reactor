import 'package:clean_cubit_reactor_example/src/data/data_sources/items_service.dart';
import 'package:clean_cubit_reactor_example/src/data/repository/items_repository.dart';
import 'package:clean_cubit_reactor_example/src/domain/reactors/items_repo_reactor.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ScopeBuilder extends StatelessWidget {
  final Widget child;
  const ScopeBuilder({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        //all repositories here
        RepositoryProvider<ItemsRepository>(
          create: (context) => ItemsRepositoryImpl(
            itemsService: LocalItemsService(),
          ),
        ),
      ],
      child: MultiRepositoryProvider(
        providers: [
          //all reactors here
          RepositoryProvider<ItemsRepoReactor>(
            create: (context) => ItemsRepoReactorImpl(
              repository: RepositoryProvider.of<ItemsRepository>(context),
            ),
          ),
        ],
        child: child,
      ),
    );
  }
}
