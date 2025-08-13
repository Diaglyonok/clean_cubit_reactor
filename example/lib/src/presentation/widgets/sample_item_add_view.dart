import 'package:clean_cubit_reactor_example/src/presentation/blocs/update_item_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

class SampleItemAddView extends StatefulWidget {
  static const routeName = '/sample_item_add';

  const SampleItemAddView({super.key});

  @override
  State<SampleItemAddView> createState() => _SampleItemAddViewState();
}

class _SampleItemAddViewState extends State<SampleItemAddView> {
  late TextEditingController controller = TextEditingController();
  late ItemUpdateCubit cubit;

  @override
  void initState() {
    super.initState();
    cubit = GetIt.I<ItemUpdateCubit>();
  }

  @override
  void dispose() {
    cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Item"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: controller,
          ),
          const SizedBox(height: 20),
          BlocConsumer<ItemUpdateCubit, ItemUpdateCubitState>(
            bloc: cubit,
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
                  if (text.isEmpty) {
                    return;
                  }

                  cubit.addItem(text);
                },
                child: isLoading ? const CircularProgressIndicator() : const Text('Add'),
              );
            },
          ),
        ],
      ),
    );
  }
}
