import 'package:clean_cubit_reactor_example/src/domain/entities/sample_item.dart';
import 'package:clean_cubit_reactor_example/src/presentation/blocs/items_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

class ItemsLoadWrapper extends StatelessWidget {
  final void Function(BuildContext, ItemsCubitState)? listener;
  final Widget Function(BuildContext, List<SampleItem>) dataBuilder;

  const ItemsLoadWrapper({
    super.key,
    required this.dataBuilder,
    this.listener,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ItemsCubit>(
      create: (context) => GetIt.I<ItemsCubit>(),
      child: BlocConsumer<ItemsCubit, ItemsCubitState>(
        listener: listener ?? (_, __) {},
        builder: (context, itemsState) {
          if (itemsState is ItemsCubitErrorState) {
            //error view
            return Center(
              child: Text(
                itemsState.getErrorString(context),
              ),
            );
          }

          if (itemsState is ItemsCubitShimmerState && (itemsState.items ?? []).isEmpty) {
            //loading view
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return dataBuilder(context, itemsState.items ?? []);
        },
      ),
    );
  }
}
