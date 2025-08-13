import 'package:clean_cubit_reactor_example/src/presentation/widgets/sample_item_add_view.dart';
import 'package:clean_cubit_reactor_example/src/presentation/widgets/sample_item_details_view.dart';
import 'package:clean_cubit_reactor_example/src/presentation/widgets/sample_item_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// The Widget that configures your application.
class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      restorationScopeId: 'app',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English, no country code
      ],
      onGenerateTitle: (BuildContext context) => 'Reactor Example',
      theme: ThemeData(),
      darkTheme: ThemeData.dark(),
      onGenerateRoute: (RouteSettings routeSettings) {
        return MaterialPageRoute<void>(
          settings: routeSettings,
          builder: (BuildContext context) {
            switch (routeSettings.name) {
              case SampleItemDetailsView.routeName:
                return SampleItemDetailsView(
                    itemId: routeSettings.arguments as String);
              case SampleItemAddView.routeName:
                return const SampleItemAddView();
              case SampleItemListView.routeName:
              default:
                return const SampleItemListView();
            }
          },
        );
      },
    );
  }
}
