import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:home_login/screens/FeedAutomation/dataDisplay.dart';

import '../../constants.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

import 'dataDisplay.dart';
import 'alertDataDisplay.dart';

class TankAlertPage extends StatefulWidget {
  final String flockID;
  final int feed_capacity;
  final int feed_alert;
  final int water_capacity;
  final int water_alert;

  const TankAlertPage(
      {Key? key,
      required this.flockID,
      required this.feed_capacity,
      required this.feed_alert,
      required this.water_capacity,
      required this.water_alert})
      : super(key: key);

  @override
  State<TankAlertPage> createState() => _TankAlertPageState();
}

class _TankAlertPageState extends State<TankAlertPage> {
  // ignore: deprecated_member_use
  //DatabaseReference ref = FirebaseDatabase.instance.reference().child(FirebaseAuth.instance.currentUser!.uid);
  String CurrentWaterLevel = '0';
  String CurrentFeedLevel = '0';
  String mtoken = '';
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  double feed = 1585;
  int feedrate = 3000;
  int current_water = 120;

  @override
  void initState() {
    // TODO: implement initState
    //function which request permission from device
    requestPermission();

    //function retrieving device token
    getToken();

    //function initializing plugins
    initInfo();
    getsds();
  }

  Future onSelectNotification(String? payload) async {
    print(payload);
  }

  void getsds() async {
    final ref = FirebaseDatabase.instance
        // ignore: deprecated_member_use
        .reference()
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child(widget.flockID)
        .child('Current Water Level');

    final ref2 = FirebaseDatabase.instance
        // ignore: deprecated_member_use
        .reference()
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child(widget.flockID)
        .child('Current Feed Level');

// Get the Stream

    Stream<DatabaseEvent> stream1 = ref.onValue;
    Stream<DatabaseEvent> stream2 = ref2.onValue;
    print("Rishad");
    print(ref.onValue);
// Subscribe to the stream!

    stream1.listen((DatabaseEvent event) {
      print(event.snapshot.value);
      setState(() {
        print("Test Notification Before");
        CurrentWaterLevel = event.snapshot.value.toString();
        if (int.parse(CurrentWaterLevel) ==
            (widget.water_capacity - widget.water_alert)) {
          sendPushMessage(
              mtoken,
              "Water Level is low. Please fill the water tank",
              "```Water Tank Alert```");
          print("Test Notification After");
        }
      });
    });
    stream2.listen((DatabaseEvent event2) {
      print(event2.snapshot.value);
      setState(() {
        CurrentFeedLevel = event2.snapshot.value.toString();
        if (int.parse(CurrentFeedLevel) ==
            (widget.feed_capacity - widget.feed_alert)) {
          sendPushMessage(
              mtoken,
              "Feed Level is low. Please fill the feed tank",
              "```Feed Tank Alert```");
          print("Test Notification After");
        }
      });
    });
  }

  initInfo() {
    var androidInitialize =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    var iOSInitialize = IOSInitializationSettings();
    var initializationsSettings =
        InitializationSettings(android: androidInitialize, iOS: iOSInitialize);
    flutterLocalNotificationsPlugin.initialize(initializationsSettings,
        onSelectNotification: (String? payload) async {
      try {
        if (payload != null && payload.isNotEmpty) {
          //once the notification is clicked the person will be redirected to this page
          // Navigator.push(context,
          //     MaterialPageRoute(builder: (BuildContext context) {
          //   //return TankAlertPage();
          //   return DataDisplayPage(
          //       id_flock: widget.id_flock,
          //       startDateNavi: widget.startDateNavi,
          //       strainNavi: widget.strainNavi,
          //       info: payload.toString());
          //   //id_flock: args.flockID,
          //   //startDateNavi: startDate,
          //   //strainNavi: strainType,
          // }));
        }
      } catch (e) {
        return;
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print(".................onMessage.................");
      print(
          "onMessage: ${message.notification?.title}/${message.notification?.body}");

      BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
        message.notification!.body.toString(),
        htmlFormatBigText: true,
        contentTitle: message.notification!.title.toString(),
        htmlFormatContentTitle: true,
      );

      AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        '3YP_Poultry',
        '3YP_Poultry',
        importance: Importance.high,
        styleInformation: bigTextStyleInformation,
        priority: Priority.high,
        playSound: true,
      );

      NotificationDetails platformChannelSpecifics = NotificationDetails(
          android: androidPlatformChannelSpecifics,
          iOS: IOSNotificationDetails());
      await flutterLocalNotificationsPlugin.show(0, message.notification?.title,
          message.notification?.body, platformChannelSpecifics,
          payload: message.data['body']);
    });
  }

  //device tokewn
  void getToken() async {
    await FirebaseMessaging.instance.getToken().then((token) {
      setState(() {
        mtoken = token!;
        print("My token is $mtoken");
      });
      //saveToken(token!);
    });
  }

  //Save the token to identify the user
/*
  void saveToken(String token) async {
    await FirebaseFirestore.instance.collection("UserTokens").doc("User2").set({
      'token': token,
    });
  }

 */

  void requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }

  void sendPushMessage(String token, String body, String title) async {
    try {
      await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization':
                'key=AAAA2NM6B2o:APA91bFQ-fVUfnC4xRx2pO7cANA7oNpchFgkOKrxX8Wy9kvukzF5StLE-fOU6wt6FofB62vEGvEoGLr9eCrYF9UDLIyH1IVEdka5qsu3qplBqM6cxh6DqgEMY97enHOleGV8gs561fWQ',
          },
          //This has two parts in json the FLUTTER NOTIFIcation CLICK part is to send
          //the user to a different page
          //second part "notification is to print the notification"
          body: jsonEncode(<String, dynamic>{
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'status': 'done',
              'body': body,
              'title': title,
            },
            "notification": <String, dynamic>{
              "title": title,
              "body": body,
              "android_channel_id": "3YP_Poultry",
              "priority": "10",
            },
            "to": token,
          }));
    } catch (e) {
      if (kDebugMode) {
        print("error push notification");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[90],
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          "Overhead Tank Monitor",
          style: TextStyle(fontSize: 17),
        ),
        backgroundColor: mPrimaryColor,
      ),
      body: SingleChildScrollView(
        child: Container(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Column(
                  children: <Widget>[
                    Text(
                      "Current Feed level in the flock",
                      style: TextStyle(
                          fontSize: 20,
                          color: mPrimaryColor,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        Container(
                          child: LiquidCustomProgressIndicator(
                            value: (widget.feed_capacity -
                                    int.parse(CurrentFeedLevel)) /
                                widget.feed_capacity,
                            valueColor:
                                AlwaysStoppedAnimation(mPrimaryTextColor),
                            backgroundColor: Colors.grey,
                            direction: Axis.vertical,
                            shapePath: _buildBoatPath(45, 10, 1),
                            //center: Text("50%"),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Alert level',
                              style: TextStyle(
                                color: mPrimaryColor,
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              'Feed Tank Level',
                              style: TextStyle(
                                color: mPrimaryColor,
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              'Current Level',
                              style: TextStyle(
                                color: mPrimaryColor,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              alignment: Alignment.center,
                              height: 25,
                              width: 80,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: mPrimaryColor,
                                ),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Text(
                                widget.feed_alert.toString() + " cm",
                                style: TextStyle(
                                    color: mNewColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Container(
                              alignment: Alignment.center,
                              height: 25,
                              width: 80,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: mPrimaryColor,
                                ),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Text(
                                widget.feed_capacity.toString() + " cm",
                                style: TextStyle(
                                    color: mNewColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Container(
                              alignment: Alignment.center,
                              height: 25,
                              width: 80,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: mPrimaryColor,
                                ),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Text(
                                CurrentFeedLevel + " cm",
                                style: TextStyle(
                                    color: mNewColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Column(
                      children: [
                        Text(
                          "Current Water level in the flock",
                          style: TextStyle(
                              fontSize: 20,
                              color: mPrimaryColor,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            Container(
                              child: LiquidCustomProgressIndicator(
                                value: (widget.water_capacity -
                                        int.parse(CurrentWaterLevel)) /
                                    widget.water_capacity,
                                valueColor:
                                    AlwaysStoppedAnimation(Colors.cyan[100]!),
                                backgroundColor: Colors.grey,
                                direction: Axis.vertical,
                                shapePath: _buildBoatPath(45, 0, 1),
                                //center: Text("50%"),
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Alert level',
                                  style: TextStyle(
                                    color: mPrimaryColor,
                                    fontSize: 18,
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  'Water Tank Level',
                                  style: TextStyle(
                                    color: mPrimaryColor,
                                    fontSize: 18,
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  'Current Level',
                                  style: TextStyle(
                                    color: mPrimaryColor,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  alignment: Alignment.center,
                                  height: 25,
                                  width: 80,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: mPrimaryColor,
                                    ),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: Text(
                                    widget.water_alert.toString() + " cm",
                                    style: TextStyle(
                                        color: mNewColor,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Container(
                                  alignment: Alignment.center,
                                  height: 25,
                                  width: 80,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: mPrimaryColor,
                                    ),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: Text(
                                    widget.water_capacity.toString() + " cm",
                                    style: TextStyle(
                                        color: mNewColor,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Container(
                                  alignment: Alignment.center,
                                  height: 25,
                                  width: 80,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: mPrimaryColor,
                                    ),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: Text(
                                    CurrentWaterLevel + " cm",
                                    style: TextStyle(
                                        color: mNewColor,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            )),
      ),
    );
  }
}

//give the size as 1,2,3,4 etc
Path _buildBoatPath(double x, double y, double size) {
  double z = size * 10;
  return Path()
    ..moveTo(x, y)
    ..lineTo(x + 2 * z, y)
    ..lineTo(x + 2 * z, y + 2 * z)
    ..lineTo(x + 4 * z, y + 4 * z)
    ..lineTo(x + 4 * z, y + 9 * z)
    ..lineTo(x + 2 * z, y + 9 * z)
    ..lineTo(x + 2 * z, y + 11 * z)
    ..quadraticBezierTo(x + 4 * z, y + 11 * z, x + 4 * z, y + 13 * z)
    ..lineTo(x + 4 * z, y + 15 * z)
    ..quadraticBezierTo(x + 5 * z, y + 16 * z, x + 5 * z, y + 19 * z)
    ..lineTo(x + 2 * z, y + 19 * z)
    ..quadraticBezierTo(x + 2 * z, y + 16 * z, x + 3 * z, y + 15 * z)
    ..lineTo(x + 3 * z, y + 13 * z)
    ..quadraticBezierTo(x + 3 * z, y + 12 * z, x + 2 * z, y + 12 * z)
    ..lineTo(x + 0 * z, y + 12 * z)
    ..quadraticBezierTo(x + (-1) * z, y + 12 * z, x + (-1) * z, y + 13 * z)
    ..lineTo(x + (-1) * z, y + 15 * z)
    ..quadraticBezierTo(x + 0 * z, y + 16 * z, x + 0 * z, y + 19 * z)
    ..lineTo(x + (-3) * z, y + 19 * z)
    ..quadraticBezierTo(x + (-3) * z, y + 16 * z, x + (-2) * z, y + 15 * z)
    ..lineTo(x + (-2) * z, y + 14 * z)
    ..quadraticBezierTo(x + (-2) * z, y + 11 * z, x + 0 * z, y + 11 * z)
    ..lineTo(x + 0 * z, y + 9 * z)
    ..lineTo(x + (-2) * z, y + 9 * z)
    ..lineTo(x + (-2) * z, y + 4 * z)
    ..lineTo(x + 0 * z, y + 2 * z)
    ..lineTo(x + 0 * z, y + 0 * z)
    ..close();
}
