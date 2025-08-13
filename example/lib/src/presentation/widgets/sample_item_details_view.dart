import 'package:clean_cubit_reactor_example/src/domain/entities/sample_item.dart';
import 'package:clean_cubit_reactor_example/src/presentation/blocs/items_bloc.dart';
import 'package:clean_cubit_reactor_example/src/presentation/blocs/update_item_bloc.dart';
import 'package:clean_cubit_reactor_example/src/presentation/widgets/items_loader_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

/// Displays detailed information about a SampleItem.
class SampleItemDetailsView extends StatefulWidget {
  final String itemId;
  const SampleItemDetailsView({super.key, required this.itemId});

  static const routeName = '/sample_item';

  @override
  State<SampleItemDetailsView> createState() => _SampleItemDetailsViewState();
}

class _SampleItemDetailsViewState extends State<SampleItemDetailsView> {
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
  }

  SampleItem? _getItem(List<SampleItem> list) {
    final index = list.indexWhere((element) => element.id == widget.itemId);
    if (index < 0) {
      return null;
    }

    return list[index];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Details'),
      ),
      body: ItemsLoadWrapper(
        listener: (context, itemsState) {
          if (itemsState is ItemsCubitHasDataState) {
            final name = _getItem(itemsState.items ?? [])?.name;
            if (name != null) {
              controller.text = name;
              setState(() {});
            }
          }
        },
        dataBuilder: (context, data) {
          final item = _getItem(data);

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              TextField(
                controller: controller,
              ),
              const SizedBox(height: 20),
              BlocProvider<ItemUpdateCubit>(
                create: (context) => GetIt.I<ItemUpdateCubit>(),
                child: BlocConsumer<ItemUpdateCubit, ItemUpdateCubitState>(
                  listener: (context, state) {
                    if (state is ItemUpdateCubitErrorState) {
                      showDialog(
                        context: context,
                        builder: (context) => SimpleDialog(
                          children: [
                            Text(state.getErrorString(context)),
                            MaterialButton(
                              child: const Text('OK'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            )
                          ],
                        ),
                      );
                    }

                    if (state is ItemUpdateCubitSuccessState) {
                      Navigator.of(context).pop();
                    }
                  },
                  builder: (context, state) {
                    final isLoading = state is ItemUpdateCubitShimmerState;

                    return FilledButton(
                      onPressed: () {
                        final text = controller.text;
                        if (text.isNotEmpty && item != null && item.name != text) {
                          BlocProvider.of<ItemUpdateCubit>(context)
                              .updateFlatItem(item.withName(text));
                        } else {
                          Navigator.of(context).pop();
                        }
                      },
                      child: isLoading ? const CircularProgressIndicator() : const Text('Save'),
                    );
                  },
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
