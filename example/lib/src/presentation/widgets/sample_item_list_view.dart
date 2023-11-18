import 'package:clean_cubit_reactor_example/src/domain/entities/sample_item.dart';
import 'package:clean_cubit_reactor_example/src/domain/reactors/items_repo_reactor.dart';
import 'package:clean_cubit_reactor_example/src/presentation/blocs/items_bloc.dart';
import 'package:clean_cubit_reactor_example/src/presentation/blocs/update_item_bloc.dart';
import 'package:clean_cubit_reactor_example/src/presentation/widgets/items_loader_wrapper.dart';
import 'package:clean_cubit_reactor_example/src/presentation/widgets/sample_item_add_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'sample_item_details_view.dart';

class SampleItemListView extends StatefulWidget {
  const SampleItemListView({super.key});

  static const routeName = '/';

  @override
  State<SampleItemListView> createState() => _SampleItemListViewState();
}

class _SampleItemListViewState extends State<SampleItemListView> {
  late ItemsCubit cubit;

  @override
  void initState() {
    super.initState();
    cubit = ItemsCubit(RepositoryProvider.of<ItemsRepoReactor>(context));
  }

  @override
  void dispose() {
    super.dispose();
    cubit.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sample Items'),
      ),
      body: ItemsLoadWrapper(
        dataBuilder: (context, data) {
          final items = data;

          //data view
          return ListView.builder(
            restorationId: 'sampleItemListView',
            itemCount: items.length,
            itemBuilder: (BuildContext context, int index) {
              final item = items[index];

              return ItemView(key: ValueKey(item.id), item: item);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.restorablePushNamed(
            context,
            SampleItemAddView.routeName,
          );
        },
      ),
    );
  }
}

class ItemView extends StatefulWidget {
  final SampleItem item;
  const ItemView({super.key, required this.item});

  @override
  State<ItemView> createState() => _ItemViewState();
}

class _ItemViewState extends State<ItemView> {
  late ItemUpdateCubit cubit;
  @override
  void initState() {
    super.initState();
    cubit = ItemUpdateCubit(RepositoryProvider.of<ItemsRepoReactor>(context));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ItemUpdateCubit, ItemUpdateCubitState>(
      bloc: cubit,
      builder: (context, state) {
        final isLoading = state is ItemUpdateCubitShimmerState && state.updateId == widget.item.id;
        return ListTile(
          title: Text(widget.item.name),
          leading: isLoading
              ? const CircularProgressIndicator()
              : const CircleAvatar(
                  foregroundImage: AssetImage('assets/images/flutter_logo.png'),
                ),
          onTap: isLoading
              ? null
              : () {
                  Navigator.restorablePushNamed(
                    context,
                    SampleItemDetailsView.routeName,
                    arguments: widget.item.id,
                  );
                },
          onLongPress: isLoading
              ? null
              : () {
                  cubit.deleteFlatItem(widget.item);
                },
        );
      },
    );
  }
}
