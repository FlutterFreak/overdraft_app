import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:overdraft_app/slider/appearance.dart';
import 'package:overdraft_app/slider/circularSlider.dart';
import 'package:overdraft_app/slider/sizeConfig.dart';
import 'package:overdraft_app/utils/customSwitch.dart';
import 'package:overdraft_app/utils/local_notification.dart';
import 'package:overdraft_app/utils/local_notification_helper.dart';
import 'package:overdraft_app/utils/model.dart';
import 'package:scoped_model/scoped_model.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int btIndex = 4;
  bool showAlert = false;
  static double selectedValue = 1000;
  static double initialValue = 100;
  static double updatedValue = 0.0;
  static double min = 0;
  static double max = 2000;
  double annualInterestRate = 0.089;

  static double quarterlyInterestRate = 0.0;
  FlutterLocalNotificationsPlugin _localNotificationsPlugin;
  LocalNotifications _localNotification = LocalNotifications();

  @override
  void initState() {
    super.initState();
    updatedValue = initialValue;
    quarterlyInterestRate = annualInterestRate / 4;
    _localNotificationsPlugin = _localNotification.getNotificationPlugin();
    Timer.periodic(Duration(minutes: 6), (Timer t) {
      updateValues();
    });
    print('updatedvalue:$updatedValue');
    setState(() {});
  }

//  calculateInterest() {
//    quarterlyInterestRate = annualInterestRate / 4;
//
//    setState(() {});
//
//  }

  updateValues() {
    math.Random random = new math.Random();
    int overdraft = random.nextInt(200);
    print('overdraft to add:$overdraft');

    if (updatedValue < max) {
      setState(() {
        initialValue = updatedValue;
        updatedValue = initialValue + overdraft;
      });
      ScopedModel.of<OverdraftModel>(context, rebuildOnChange: true)
          .updateValue(updatedValue);
      if (updatedValue <= selectedValue && showAlert) {
        showOngoingNotification(_localNotificationsPlugin,
            title: 'Current Overdraft increased.',
            body:
                'Overdraft has increased from \$$initialValue to \$$updatedValue.');
      } else if (updatedValue >= selectedValue && showAlert) {
        showOngoingNotification(_localNotificationsPlugin,
            title: 'Current limit \$$selectedValue exceeded.',
            body:
                'Overdraft has increased from $initialValue to \$$updatedValue.');
      }

      if (updatedValue >= max) {
        showOngoingNotification(_localNotificationsPlugin,
            title: 'Maximum Overdraft limit \$$max exceeded.',
            body:
                'Overdraft has increased from \$$initialValue to \$$updatedValue.');
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          centerTitle: true,
          title: Text(widget.title),
        ),
        body: Padding(
          padding:
              EdgeInsets.symmetric(horizontal: 1 * SizeConfig.widthMultiplier),
          child: Column(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Center(
                  child: slider,
                ),
              ),
              SizedBox(
                height: 3 * SizeConfig.heightMultiplier,
              ),
              Expanded(
                  flex: 1,
                  child: ListView(
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border:
                                Border.all(width: 1, color: Colors.grey[300])),
                        child: ListTile(
                          title: new Text(
                            'Interest incurred this quater',
                            style: TextStyle(
                                fontSize: 2.2 * SizeConfig.textMultiplier,
                                color: Colors.black),
                          ),
                          subtitle: new Text(
                            'Effective annual interest rate 8.9% ',
                            style: TextStyle(
                                fontSize: 1.8 * SizeConfig.textMultiplier,
                                color: Colors.grey),
                          ),
                          trailing: new Text(
                            '- \$${double.parse((quarterlyInterestRate * updatedValue).toStringAsFixed(2))}  ',
                            style: TextStyle(
                                fontSize: 2.5 * SizeConfig.textMultiplier,
                                color: Colors.red),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 7 * SizeConfig.heightMultiplier,
                      ),
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border:
                                Border.all(width: 1, color: Colors.grey[300])),
                        child: ListTile(
                          title: new Text(
                            'Overdraft alert',
                            style: TextStyle(
                                fontSize: 2.2 * SizeConfig.textMultiplier,
                                color: Colors.black),
                          ),
                          trailing: CustomSwitch(
                            value: showAlert,
                            activeColor: Colors.teal[300],
                            inactiveColor: Colors.grey[300],
                            onChanged: (value) {
                              showAlert = !showAlert;
                              print('showalert:$showAlert');

                              setState(() {});
                            },
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border:
                                Border.all(width: 1, color: Colors.grey[300])),
                        child: ListTile(
                          title: new Text(
                            'Request Increase ',
                            style: TextStyle(
                                fontSize: 2.2 * SizeConfig.textMultiplier,
                                color: Colors.black),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.grey[400],
                            size: 3 * SizeConfig.heightMultiplier,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border:
                                Border.all(width: 1, color: Colors.grey[300])),
                        child: ListTile(
                          title: new Text(
                            '',
                            style: TextStyle(
                                fontSize: 2.2 * SizeConfig.textMultiplier,
                                color: Colors.black),
                          ),
                          subtitle: new Text(
                            ' ',
                            style: TextStyle(
                                fontSize: 1.8 * SizeConfig.textMultiplier,
                                color: Colors.grey),
                          ),
                          trailing: new Text(
                            ' ',
                            style: TextStyle(
                                fontSize: 2.5 * SizeConfig.textMultiplier,
                                color: Colors.red),
                          ),
                        ),
                      ),
                    ],
                  ))
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: btIndex,
          type: BottomNavigationBarType.fixed,
          elevation: 3,
          items: [
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.format_list_bulleted,
                  color: btIndex == 0 ? Colors.cyan[800] : Colors.black,
                ),
                title: new Text(
                  '',
                  style: TextStyle(fontSize: 1),
                )),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.donut_small,
                color: btIndex == 1 ? Colors.cyan[800] : Colors.black,
              ),
              title: new Text(
                '',
                style: TextStyle(fontSize: 1),
              ),
            ),
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.add,
                  color: btIndex == 2 ? Colors.cyan[800] : Colors.black,
                ),
                title: new Text(
                  '',
                  style: TextStyle(fontSize: 1),
                )),
            BottomNavigationBarItem(
                icon: Image.asset(
                  'assets/send.png',
                  color: btIndex == 3 ? Colors.cyan[800] : Colors.black,
                  height: 8 * SizeConfig.imageSizeMultiplier,
                  width: 8 * SizeConfig.imageSizeMultiplier,
                ),
                title: new Text('', style: TextStyle(fontSize: 1))),
            BottomNavigationBarItem(
                icon: Image.asset(
                  'assets/settings.png',
                  color: btIndex == 4 ? Colors.cyan[800] : Colors.black,
                  width: 6 * SizeConfig.imageSizeMultiplier,
                ),
                title: new Text(
                  '',
                  style: TextStyle(fontSize: 1),
                ))
          ],
          onTap: (index) {
            btIndex = index;
            setState(() {});
          },
        ));
  }

  final slider = SleekCircularSlider(
    initialValue: initialValue,
    min: min,
    max: max,
    selectedValue: selectedValue,
    appearance:
        CircularSliderAppearance(size: 70 * SizeConfig.imageSizeMultiplier),
    onChange: (double value) async {
      print('onchange:$value');

      selectedValue = value;
    },
    onChangeStart: (double startValue) {},
    onChangeEnd: (double endValue) {
      print('onchangeend:$endValue');
    },
    innerWidget: (double value) {
      return ScopedModelDescendant<OverdraftModel>(
        builder: (context, child, model) {
          return Container(
            padding: EdgeInsets.all(7 * SizeConfig.heightMultiplier),
            child: Column(
              children: <Widget>[
                Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Selected Limit',
                          style: TextStyle(
                              fontSize: 1.8 * SizeConfig.textMultiplier,
                              color: Colors.grey),
                        ),
                        new Text(
                          '\$${selectedValue.roundToDouble()}',
                          style: TextStyle(
                              fontSize: 2.2 * SizeConfig.textMultiplier,
                              color: Colors.black),
                        )
                      ],
                    )),
                Divider(
                  height: 3,
                  color: Colors.grey,
                  thickness: 1,
                ),
                Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Current Overdraft',
                          style: TextStyle(
                              fontSize: 1.8 * SizeConfig.textMultiplier,
                              color: Colors.grey),
                        ),
                        new Text(
                          '\$${model.updatedValue.roundToDouble()}',
                          style: TextStyle(
                              fontSize: 2.2 * SizeConfig.textMultiplier,
                              color: Colors.black),
                        )
                      ],
                    ))
              ],
            ),
          );
        },
      );
    },
  );
}
