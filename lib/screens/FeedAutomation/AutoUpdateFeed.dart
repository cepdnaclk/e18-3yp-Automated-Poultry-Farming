import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:home_login/constants.dart';
import 'package:home_login/screens/griddashboard.dart';
import 'package:home_login/screens/reusable.dart';
import 'package:get/get.dart';
import 'package:home_login/screens/view_screen.dart';
import 'package:home_login/screens/strain.dart' as strainList;
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

import 'dataDisplay.dart';
import 'alertDataDisplay.dart';

class AutoUpadateFeed extends StatefulWidget {
  final String id_flock;
  final String startDateNavi;
  final String strainNavi;
  // const AddBodyWeight({Key? key}) : super(key: key);
  AutoUpadateFeed({
    Key? key,
    required this.id_flock,
    required this.startDateNavi,
    required this.strainNavi,
  }) : super(key: key);

  @override
  State<AutoUpadateFeed> createState() => _AutoUpadateFeedState();
}

class _AutoUpadateFeedState extends State<AutoUpadateFeed> {

  List<strainList.PoultryData> weightDataStrain = [];
  List<strainList.PoultryData> feedtDataStrain = [];

  //To get the device token
  String ? mtoken = "";
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  int mortal = 0,
      startCount = 0;
  String totalChick = '',
      flockID = '',
      strain = '';
  double feedAmnt = 0;

  String ? userToken = "";
  String titleForFeed = "Feed level Alert!!!";
  String titleForwater = "Water level Alert!!!";
  String ? bodyForFeed = "";
  String ? bodyForwater = "";

  late DateTime startDate;
  int days = 0;
  int index = 0;

  DateTime date = DateTime(
      DateTime
          .now()
          .year,
      DateTime
          .now()
          .month,
      DateTime
          .now()
          .day,
      DateTime
          .now()
          .hour,
      DateTime
          .now()
          .minute,
      DateTime
          .now()
          .second);
  final TextEditingController _datecontroller = TextEditingController();
  late int morFeedAmnt = 0,
      eveFeedAmnt = 0,
      nitFeedAmnt = 0;
  String timeinMor = "06:30:00";
  String timeinEve = "12:30:00";
  String timeinNit = "19:30:00";
  int liveCount = 100;

  //List<strainList.PoultryData> _list = strainList.PoultryData.feedDataCobb500;
  @override
  void initState() {
    super.initState();
    startDate = DateTime.parse(widget.startDateNavi);

    //function which request permission from device
    requestPermission();

    //function retrieving device token
    getToken();

    //function initializing plugins
    initInfo();
  }

  Future onSelectNotification(String? payload) async {
    print(payload);
  }


  initInfo() {
    var androidInitialize = AndroidInitializationSettings(
        '@mipmap/ic_launcher');
    var iOSInitialize = IOSInitializationSettings();
    var initializationsSettings = InitializationSettings(
        android: androidInitialize, iOS: iOSInitialize);
    flutterLocalNotificationsPlugin.initialize(
        initializationsSettings, onSelectNotification: (String? payload) async {
      try {
        if (payload != null && payload.isNotEmpty) {
          //once the notification is clicked the person will be redirected to this page
          Navigator.push(
              context, MaterialPageRoute(builder: (BuildContext context) {
            //return TankAlertPage();
            return DataDisplayPage(id_flock: widget.id_flock,
                startDateNavi: widget.startDateNavi,
                strainNavi: widget.strainNavi,
                info: payload.toString());
            //id_flock: args.flockID,
            //startDateNavi: startDate,
            //strainNavi: strainType,
          }

          ));
        }
      } catch (e) {
        return;
      }
    }


    );


    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print(".................onMessage.................");
      print("onMessage: ${message.notification?.title}/${message.notification
          ?.body}");

      BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
        message.notification!.body.toString(), htmlFormatBigText: true,
        contentTitle: message.notification!.title.toString(),
        htmlFormatContentTitle: true,
      );

      AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
        '3YP_Poultry', '3YP_Poultry', importance: Importance.high,
        styleInformation: bigTextStyleInformation,
        priority: Priority.high,
        playSound: true,

      );

      NotificationDetails platformChannelSpecifics = NotificationDetails(
          android: androidPlatformChannelSpecifics,
          iOS: IOSNotificationDetails()

      );
      await flutterLocalNotificationsPlugin.show(0, message.notification?.title,
          message.notification?.body, platformChannelSpecifics,
          payload: message.data['body']
      );
    });
  }


  //device tokewn
  void getToken() async {
    await FirebaseMessaging.instance.getToken().then(
            (token) {
          setState(() {
            mtoken = token;
            print("My token is $mtoken");
          });
          //saveToken(token!);

        }
    );
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
    } else
    if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }

  void sendPushMessage(String token, String body, String title) async {
    try {
      await http.post(
          Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization': 'key=AAAA2NM6B2o:APA91bFQ-fVUfnC4xRx2pO7cANA7oNpchFgkOKrxX8Wy9kvukzF5StLE-fOU6wt6FofB62vEGvEoGLr9eCrYF9UDLIyH1IVEdka5qsu3qplBqM6cxh6DqgEMY97enHOleGV8gs561fWQ',
          },
          //This has two parts in json the FLUTTER NOTIFIcation CLICK part is to send
          //the user to a different page
          //second part "notification is to print the notification"
          body: jsonEncode(
              <String, dynamic>{

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
              }
          )

      );
    }
    catch (e) {
      if (kDebugMode) {
        print("error push notification");
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    days = date
        .difference(startDate)
        .inDays;
    //feedAmnt = feedtDataStrain[days].valueOf(days);



    if (widget.strainNavi == 'Cobb 500 - Broiler') {
      weightDataStrain = strainList.PoultryData.weightDataCobb500;
      feedtDataStrain = strainList.PoultryData.feedDataCobb500;
    } else if (widget.strainNavi == 'Ross 308 - Broiler') {
      weightDataStrain = strainList.PoultryData.weightDataRoss308;
      feedtDataStrain = strainList.PoultryData.feedDataRoss308;
    } else if (widget.strainNavi == 'Dekalb White - Layer') {
      weightDataStrain = strainList.PoultryData.weightDataDekalbWhite;
      feedtDataStrain = strainList.PoultryData.feedDataDekalbWhite;
    } else if (widget.strainNavi == 'Shaver Brown - Layer') {
      weightDataStrain = strainList.PoultryData.weightDataShaverBrown;
      feedtDataStrain = strainList.PoultryData.feedDataShavorBrown;
    }

    return GestureDetector(

      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Auto Update Feed data",
            style: TextStyle(fontSize: 16),
          ),
          backgroundColor: mPrimaryColor,
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Row(
                //mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6.0, vertical: 15.0),
                      child: reusableTextField3(
                          date.toString().substring(0, 10),
                          Icons.date_range,
                          false,
                          _datecontroller,
                          null,
                          false),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6.0, vertical: 15.0),
                      child: ElevatedButton(
                        onPressed: () async {
                          DateTime? ndate = await showDatePicker(
                            context: context,
                            initialDate: date,
                            firstDate: DateTime(2022),
                            lastDate: DateTime.now(),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: ColorScheme.light(
                                    primary: mNewColor,
                                    onPrimary: Colors.white,
                                    onSurface: mSecondColor,
                                  ),
                                  textButtonTheme: TextButtonThemeData(
                                    style: TextButton.styleFrom(
                                      foregroundColor: mPrimaryColor, // button text color
                                    ),
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (ndate == null) return;
                          if (ndate
                              .difference(startDate)
                              .inDays < 0) return;
                          setState(() => date = ndate);
                        },
                        style: ElevatedButton.styleFrom(
                          fixedSize: const Size(180, 50),
                          backgroundColor: mBackgroundColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              side: BorderSide(
                                width: 2.0,
                                color: mPrimaryColor,
                              )),
                          elevation: 20,
                          shadowColor: Colors.transparent,
                          textStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: Text(
                          "pickDate".tr,
                          style: TextStyle(color: Colors.black38),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              Center(
                child: Container(
                  alignment: Alignment.center,
                  height: 5.h,
                  width: 30.w,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: mPrimaryColor,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Text(
                    "Days: " + days.toString(),
                    style: TextStyle(fontSize: 18, color: mNewColor),
                  ),
                ),
              ),
              SizedBox(
                height: 2.h,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "ideal".tr + widget.strainNavi + "feed".tr,
                    style: TextStyle(fontSize: 15, color: mPrimaryColor),
                  ),
                  Container(
                    alignment: Alignment.center,
                    height: 25,
                    width: 30.w,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: mPrimaryColor,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Text(
                      feedtDataStrain[days].valueOf(days).toString() + " g",
                      style: TextStyle(
                          color: mNewColor,
                          fontSize: 17,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 1.h,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "   Start Date",
                    style: TextStyle(fontSize: 15, color: mPrimaryColor),
                  ),
                  Container(
                    alignment: Alignment.center,
                    height: 25,
                    width: 30.w,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: mPrimaryColor,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Text(
                      widget.startDateNavi,
                      style: TextStyle(
                          color: mNewColor,
                          fontSize: 17,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),

              StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('Farmers')
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .collection('flock')
                      .where(FieldPath.documentId, isEqualTo: widget.id_flock)
                      .snapshots(), // your stream url,
                  builder:
                      (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      //return CircularProgressIndicator();
                    } else {
                      //print(snapshot.toString());
                      mortal = snapshot.data?.docs[0]['Mortal'];
                      totalChick = snapshot.data?.docs[0]['count'];
                      startCount = int.parse(totalChick);
                      liveCount = startCount - mortal;
                      feedAmnt = feedtDataStrain[days].valueOf(days);
                    }

                    return Container(
                      child: Column(
                        children: [
                          SizedBox(
                            height: 1.h,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'totalMoartal'.tr,
                                style: TextStyle(
                                    fontSize: 15, color: mPrimaryColor),
                              ),
                              Container(
                                alignment: Alignment.center,
                                height: 25,
                                width: 30.w,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: mPrimaryColor,
                                  ),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Text(
                                  mortal.toString(),
                                  style: TextStyle(
                                      color: mNewColor,
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(
                            height: 1.h,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'totallive'.tr,
                                style: TextStyle(
                                    fontSize: 15, color: mPrimaryColor),
                              ),
                              Container(
                                alignment: Alignment.center,
                                height: 25,
                                width: 30.w,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: mPrimaryColor,
                                  ),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Text(
                                  (liveCount).toString(),
                                  style: TextStyle(
                                      color: mNewColor,
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),

                        ],
                      ),
                    ); // Your grid code.
                  }),


              // Text("Expected feed intake: " +
              //     weightDataStrain[index].valueOf(days).toString()),
              SizedBox(
                height: 20.0,
              ),
              //reuseTextField("Mortality"),

              Center(
                child: ElevatedButton(
                  onPressed: () async {
                   // sendPushMessage(mtoken!,
                       // "Morning Feed per Chick is  ${feedAmnt/3}g at ${timeinMor}\nEvening Feed per Chick is  ${feedAmnt/3}g at ${timeinEve}\nNight   Feed per Chick is  ${feedAmnt/3}g   at ${timeinNit}\n", titleForFeed!);


                    addAutomaticData(
                      widget.id_flock,
                      date.toString().substring(0, 10),
                      timeinMor,
                      timeinEve,
                      timeinNit,
                      (feedAmnt * liveCount) / 3,
                      (feedAmnt * liveCount) / 3,
                      (feedAmnt * liveCount) / 3,
                    );


                    setState(() {});
                    //Navigator.of(context).pop();

                    ///displayFCRdialog();
                    Fluttertoast.showToast(
                        msg: 'Successfully Added!',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: mNewColor3,
                        textColor: mPrimaryColor);
                  },
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size(200, 50),
                    backgroundColor: mPrimaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    elevation: 20,
                    shadowColor: mSecondColor,
                    textStyle: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: Text("add".tr),
                ),
              ),


              SizedBox(
                height: 20,
              )
            ],
          ),
        ),
      ),
    );
  }


  TextFormField reusableTextField3(String text,
      IconData icon,
      bool isPasswordType,
      TextEditingController controller,
      validator,
      bool val) {
    return TextFormField(
      onTap: () {

      },
      enabled: val,
      controller: controller,
      validator: validator,
      obscureText: isPasswordType,
      enableSuggestions: !isPasswordType,
      autocorrect: !isPasswordType,
      cursorColor: Colors.brown,
      style: TextStyle(color: Colors.black38),
      decoration: InputDecoration(
        prefixIcon: Icon(
          icon,
          color: mPrimaryColor,
        ),
        labelText: text,
        labelStyle: TextStyle(color: Colors.black38),
        filled: true,
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        fillColor: Colors.grey[50],
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide(
              width: 2,
              color: mPrimaryColor,
            )),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide(
            color: mPrimaryColor,
            width: 2.0,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide(
            color: mPrimaryColor,
            width: 2.0,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide(
            color: mPrimaryColor,
            width: 2.0,
          ),
        ),
      ),
      keyboardType: isPasswordType
          ? TextInputType.visiblePassword
          : TextInputType.emailAddress,
    );
  }


  Future<void> addAutomaticData(String id, String date, String MorTime,
      String EveTime, String NitTime, double MorFeedAmnt, double EveFeedAmnt,
      double NitFeedAmnt) async {
    try {
      DocumentReference<Map<String, dynamic>> documentReference2 =
      FirebaseFirestore.instance
          .collection('Farmers')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('flock')
          .doc(id);

      FirebaseFirestore.instance.runTransaction((transaction2) async {
        DocumentSnapshot<Map<String, dynamic>> snapshot2 =
        await transaction2.get(documentReference2);
        print(documentReference2);
        if (!snapshot2.exists) {
          documentReference2.update({'Morning Feed Amount': MorFeedAmnt});
          documentReference2.update({'Morning Feed Time': MorTime});
          documentReference2.update({'Evening Feed Amount': EveFeedAmnt});
          documentReference2.update({'Evening Feed Time': EveTime});
          documentReference2.update({'Night Feed Amount': NitFeedAmnt});
          documentReference2.update({'Night Feed Time': NitTime});
        } else {
          try {
            documentReference2.update({'Morning Feed Amount': MorFeedAmnt});
            documentReference2.update({'Morning Feed Time': MorTime});
            documentReference2.update({'Evening Feed Amount': EveFeedAmnt});
            documentReference2.update({'Evening Feed Time': EveTime});
            documentReference2.update({'Night Feed Amount': NitFeedAmnt});
            documentReference2.update({'Night Feed Time': NitTime});
          } catch (e) {

          }
        }
      });
    } catch (e) {
      //
    }
  }
}