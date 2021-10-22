import 'package:era15dias/src/pages/run/run_page.dart';
import 'package:era15dias/src/pages/tictactoe/tictactoe_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'pages/home/home_page.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hackathona Matata',
      debugShowCheckedModeBanner: false,
      //TODO ARRUMAR
      initialRoute: "/jogoDaVelha",
      routes: {
        "/": (_) => const HomePage(),
        "/era15dias": (_) => const RunPage(),
        "/jogoDaVelha": (_) => const TicTacToePage(),
      },
      localizationsDelegates: const [
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
      ],
      supportedLocales: const [Locale('pt', 'BR')],
      locale: const Locale('pt', 'BR'),
    );
  }
}
