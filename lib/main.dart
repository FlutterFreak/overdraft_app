import 'package:flutter/material.dart';
import 'package:overdraft_app/screeens/home.dart';
import 'package:overdraft_app/slider/sizeConfig.dart';
import 'package:overdraft_app/utils/model.dart';
import 'package:scoped_model/scoped_model.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  OverdraftModel model = OverdraftModel();
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScopedModel<OverdraftModel>(
        model: model,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return OrientationBuilder(
              builder: (context, orientation) {
                SizeConfig().init(constraints, orientation);
                return MaterialApp(
                  debugShowCheckedModeBanner: false,
                  title: 'Movies',
                  theme: ThemeData(primaryColor: Colors.black),
                  home: MyHomePage(
                    title: 'OVERDRAFT',
                  ),
                );
              },
            );
          },
        ));
  }
}
