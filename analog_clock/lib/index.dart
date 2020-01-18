import 'package:flutter/material.dart';
import 'package:analog_clock/clock/clock_page.dart';
import 'package:analog_clock/model/ClockModel.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class MyApp extends StatelessWidget {
  final _model = ClockModel();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Clock',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Scaffold(
            body: Stack(
          children: <Widget>[
            Center(
              child: ClockPage(),
            ),
            Positioned(
              left: 10,
              bottom: 5,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("(${_model.low} - ${_model.highString})"),
                  Text("${_model.temperatureString}"),
                  Text("${_model.weatherString}"),
                  Text("${_model.location}")
                ],
              ),
            )
          ],
        )),
        localizationsDelegates: [
          // ... app-specific localization delegate[s] here
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: [
          Locale('zh', 'CH'),
          Locale('en', 'US'),
          // ... other locales the app supports
        ]);
  }
}
