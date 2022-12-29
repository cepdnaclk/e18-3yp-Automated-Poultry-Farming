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

class AutomatedData extends StatefulWidget {
  final String id_flock;
  final String startDateNavi;
  final String strainNavi;
  // const AddBodyWeight({Key? key}) : super(key: key);
  AutomatedData({
    Key? key,
    required this.id_flock,
    required this.startDateNavi,
    required this.strainNavi,
  }) : super(key: key);

  @override
  State<AutomatedData> createState() => _AutomatedDataState();
}

class _AutomatedDataState extends State<AutomatedData> {

  List<strainList.PoultryData> weightDataStrain = [];
  List<strainList.PoultryData> feedtDataStrain = [];

  //To get the device token
  String ? mtoken="";
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  int mortal = 0, startCount = 0;
  String totalChick = '', flockID = '', strain = '';

  String ? userToken="";
  String  titleForFeed ="Feed level Alert!!!";
  String  titleForwater ="Water level Alert!!!";
  String ? bodyForFeed ="";
  String ? bodyForwater ="";

  late DateTime startDate;
  int days = 0;
  int index = 0;

  DateTime date = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      DateTime.now().hour,
      DateTime.now().minute,
      DateTime.now().second);

  final TextEditingController _datecontroller = TextEditingController();
  final TextEditingController _numcontroller = TextEditingController();
  final TextEditingController _numcontrollerMorning = TextEditingController();
  final TextEditingController _numcontrollerEvening = TextEditingController();
  final TextEditingController _numcontrollerNight = TextEditingController();
  final TextEditingController timeinMor = TextEditingController();
  final TextEditingController timeinEve = TextEditingController();
  final TextEditingController timeinNit = TextEditingController();

  //List<strainList.PoultryData> _list = strainList.PoultryData.feedDataCobb500;
  @override
  void initState() {
    super.initState();
    startDate = DateTime.parse(widget.startDateNavi);
    timeinMor.text = ""; //set the initial value of text field
    timeinEve.text = ""; //set the initial value of text field
    timeinNit.text = ""; //set the initial value of text field


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


  initInfo(){
    var androidInitialize = AndroidInitializationSettings('@mipmap/ic_launcher');
    var iOSInitialize = IOSInitializationSettings();
    var initializationsSettings = InitializationSettings(android: androidInitialize, iOS: iOSInitialize);
    flutterLocalNotificationsPlugin.initialize(initializationsSettings, onSelectNotification: (String? payload) async{

      try{
        if(payload != null && payload.isNotEmpty){
          //once the notification is clicked the person will be redirected to this page
          Navigator.push(context,MaterialPageRoute(builder: (BuildContext context){
            //return DataDisplayPage(info: payload.toString());
            return DataDisplayPage(info: payload.toString(),flockid: flockID);
            //id_flock: args.flockID,
            //startDateNavi: startDate,
            //strainNavi: strainType,
          }

          ));

        }

      }catch(e){
        return;
      }


    }



    );


    FirebaseMessaging.onMessage.listen((RemoteMessage message) async{
      print(".................onMessage.................");
      print("onMessage: ${message.notification?.title}/${message.notification?.body}");

      BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
        message.notification!.body.toString(),htmlFormatBigText: true,
        contentTitle: message.notification!.title.toString(),
        htmlFormatContentTitle: true,
      );

      AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
        '3YP_Poultry','3YP_Poultry',importance: Importance.high,
        styleInformation: bigTextStyleInformation, priority: Priority.high, playSound: true,

      );

      NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics,
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
            (token){
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
    FirebaseMessaging messaging =FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,

    );

    if(settings.authorizationStatus == AuthorizationStatus.authorized){
      print('User granted permission');
    } else if(settings.authorizationStatus == AuthorizationStatus.provisional){
      print('User granted provisional permission');
    }else{
      print('User declined or has not accepted permission');
    }
  }

  void sendPushMessage(String token, String body, String title) async {
    try{
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
    catch(e){
      if(kDebugMode){
        print("error push notification");

      }

    }

  }





  @override
  Widget build(BuildContext context) {
    days = date.difference(startDate).inDays;
    print(date);
    //print(_list[13].valueOf(13));
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
    //print(_list[days].valueOf(days));

    // strainList.PoultryData chick = weightDataCobb500[20];

    //final args = ModalRoute.of(context)!.settings.arguments as ScreenArguments;


    // print(chick);
    //final args = ModalRoute.of(context)!.settings.arguments as ScreenArguments;
    return GestureDetector(

      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Automated Data",
            style: TextStyle(fontSize: 16),
          ),
          backgroundColor: mPrimaryColor,
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [


              StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("Farmers")
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .collection('flock')
                      .doc(widget.id_flock)
                      .collection('FeedIntake')
                      .where(FieldPath.documentId,
                          isEqualTo: date.toString().substring(0, 10))
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    num amount = -1;
                    try {
                     // amount = snapshot.data?.docs[0]['Number_of_bags'];
                    } catch (e) {
                      amount = -1;
                    }
                    if (amount == -1 || amount == 0) {
                      return SizedBox(
                        height: 5.0,

                      );
                    } else {
                      return SizedBox(
                        height: 5.0,

                      );
                    }
                  }),
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
                          if (ndate.difference(startDate).inDays < 0) return;
                          setState(() => date = ndate);
                        },
                        style: ElevatedButton.styleFrom(
                          fixedSize: const Size(180, 50), backgroundColor: mBackgroundColor,
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
                      (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      //return CircularProgressIndicator();
                    } else {
                      //print(snapshot.toString());
                      mortal = snapshot.data?.docs[0]['Mortal'];
                      totalChick = snapshot.data?.docs[0]['count'];
                      startCount = int.parse(totalChick);

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
                                  (startCount - mortal).toString(),
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

              //Morning Feed
              Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                child: Text(
                  "Morning Feed",
                  style: TextStyle(fontSize: 20, color: mPrimaryColor),
                ),
              ),


              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6.0, vertical: 10.0),
                //child: reuseTextField1("Number of chicks"),

                child: reusableTextField2("Morning Feed/chick", Icons.numbers,
                    false, _numcontrollerMorning, null, "g"),
              ),

              Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                child:TextFormField(
                  controller: timeinMor,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                          width: 10,
                          style: BorderStyle.none,
                          color: mPrimaryColor,
                        ),


                      ),
                      icon: Icon(Icons.timer,color: mPrimaryColor,), //icon of text field
                      labelText: "Enter Morning Feed Time",
                    labelStyle: TextStyle(
                        color: Colors.grey
                    ),//label text of field
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
                  readOnly: true,
                  onTap: () async{
                    TimeOfDay? pickedTime =  await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                      builder: (context,child){
                        return Theme(data: _buildShrineTheme(), child: child!);
                      },
                    );

                    if(pickedTime != null ){
                      print(pickedTime.format(context));   //output 10:51 PM
                      DateTime parsedTime = DateFormat.jm().parse(pickedTime.format(context).toString());
                      //converting to DateTime so that we can further format on different pattern.
                      print(parsedTime); //output 1970-01-01 22:53:00.000
                      String formattedTime = DateFormat('HH:mm:ss').format(parsedTime);
                      print(formattedTime); //output 14:59:00
                      //DateFormat() is from intl package, you can format the time on any pattern you need.

                      setState(() {
                        timeinMor.text = formattedTime; //set the value of text field.
                      });
                    }else{
                      print("Time is not selected");
                    }

                  },

                ),
              ),





              SizedBox(
                height: 20,
              ),

              Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                child: Text(
                  "Evening Feed",
                  style: TextStyle(fontSize: 20, color: mPrimaryColor),
                ),
              ),

              //Evening Feed
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 6.0, vertical: 10.0),
                //child: reuseTextField1("Number of chicks"),

                child: reusableTextField2("Evening Feed/chick", Icons.numbers,
                    false, _numcontrollerEvening, null, "g"),
              ),

              Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                child:TextFormField(
                  controller: timeinEve,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(
                        width: 10,
                        style: BorderStyle.none,
                        color: mPrimaryColor,
                      ),


                    ),
                    icon: Icon(Icons.timer,color: mPrimaryColor,), //icon of text field
                    labelText: "Enter Evening Feed Time",
                    labelStyle: TextStyle(
                        color: Colors.grey
                    ),//label text of field
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
                  readOnly: true,
                  onTap: () async{
                    TimeOfDay? pickedTime =  await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                      builder: (context,child){
                        return Theme(data: _buildShrineTheme(), child: child!);
                      },
                    );

                    if(pickedTime != null ){
                      print(pickedTime.format(context));   //output 10:51 PM
                      DateTime parsedTime = DateFormat.jm().parse(pickedTime.format(context).toString());
                      //converting to DateTime so that we can further format on different pattern.
                      print(parsedTime); //output 1970-01-01 22:53:00.000
                      String formattedTime = DateFormat('HH:mm:ss').format(parsedTime);
                      print(formattedTime); //output 14:59:00
                      //DateFormat() is from intl package, you can format the time on any pattern you need.

                      setState(() {
                        timeinEve.text = formattedTime; //set the value of text field.
                      });
                    }else{
                      print("Time is not selected");
                    }




                  },

                ),
              ),



              SizedBox(
                height: 20,
              ),

              Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                child: Text(
                  "Night Feed",
                  style: TextStyle(fontSize: 20, color: mPrimaryColor),
                ),
              ),

              //Night Feed
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 6.0, vertical: 10.0),
                //child: reuseTextField1("Number of chicks"),

                child: reusableTextField2("Night Feed/chick", Icons.numbers,
                    false, _numcontrollerNight, null, "g"),
              ),

              Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                child:TextFormField(
                  controller: timeinNit,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(
                        width: 10,
                        style: BorderStyle.none,
                        color: mPrimaryColor,
                      ),


                    ),
                    icon: Icon(Icons.timer,color: mPrimaryColor,), //icon of text field
                    labelText: "Enter Night Feed Time",
                    labelStyle: TextStyle(
                        color: Colors.grey
                    ),//label text of field
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
                  readOnly: true,
                  onTap: () async{
                    TimeOfDay? pickedTime =  await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                      builder: (context,child){
                        return Theme(data: _buildShrineTheme(), child: child!);
                      },
                    );

                    if(pickedTime != null ){
                      print(pickedTime.format(context));   //output 10:51 PM
                      DateTime parsedTime = DateFormat.jm().parse(pickedTime.format(context).toString());
                      //converting to DateTime so that we can further format on different pattern.
                      print(parsedTime); //output 1970-01-01 22:53:00.000
                      String formattedTime = DateFormat('HH:mm:ss').format(parsedTime);
                      print(formattedTime); //output 14:59:00
                      //DateFormat() is from intl package, you can format the time on any pattern you need.

                      setState(() {
                        timeinNit.text = formattedTime; //set the value of text field.
                      });
                    }else{
                      print("Time is not selected");
                    }

                  },

                ),
              ),



              SizedBox(
                height: 40,
              ),





              Center(
                child: Image.asset(
                  "assets/images/weight.png",
                  fit: BoxFit.fitWidth,
                  width: context.width * 0.4,
                  // height: 420,
                  //color: Colors.purple,
                ),
              ),
              SizedBox(
                height: 50,
              ),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    //print(date.toString().substring(12, 19));
                    // print(args.flockID);
                    // print(_numcontroller.text);
                    //print(time.toString());

                    sendPushMessage(mtoken!,"Morning Feed per Chick is  ${_numcontrollerMorning.text}g at ${timeinMor.text}\nEvening Feed per Chick is  ${_numcontrollerEvening.text}g at ${timeinEve.text}\nNight   Feed per Chick is  ${_numcontrollerNight.text}g   at ${timeinNit.text}\n" ,titleForFeed!);

                    addData(
                        widget.id_flock,date.toString().substring(0, 10),
                        timeinMor.text,
                        timeinEve.text,
                        timeinNit.text,
                        _numcontrollerMorning.text,
                        _numcontrollerEvening.text,
                        _numcontrollerNight.text);

                    timeinMor.clear();
                    timeinEve.clear();
                    timeinNit.clear();
                    _numcontrollerMorning.clear();
                    _numcontrollerEvening.clear();
                    _numcontrollerNight.clear();




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
                    fixedSize: const Size(200, 50), backgroundColor: mPrimaryColor,
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
            ],
          ),
        ),
      ),
    );
  }

  Future<void> addData(String id, String date ,String MorTime,String EveTime,String NitTime,String MorFeedAmnt,String EveFeedAmnt,String NitFeedAmnt ) async {
    //num current = 0;
    //num value = double.parse(amount);
    try {
      //print("try 1");
      DocumentReference<Map<String, dynamic>> documentReference =
          FirebaseFirestore.instance
              .collection('Farmers')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .collection('flock')
              .doc(id)
              .collection('Data')
              .doc(date);

      FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot<Map<String, dynamic>> snapshot =
            await transaction.get(documentReference);

        if (!snapshot.exists) {
          //print("done 1 befre");

          documentReference.set( {'Morning': "${MorTime}-${MorFeedAmnt}", 'Evening': "${EveTime}-${EveFeedAmnt}", 'Night': "${NitTime}-${NitFeedAmnt}"});
          //print("done 1");

          //return true;
        } else {
          try {
            //num newAmount = snapshot.data()!['Amount'] + value;
            //current = snapshot.data()!['Average_Weight'];
            transaction.update(
                documentReference, {'Morning': "${MorTime}-${MorFeedAmnt}", 'Evening': "${EveTime}-${EveFeedAmnt}", 'Night': "${NitTime}-${NitFeedAmnt}"});
            //print("done 1.2");
            //print(current);
            //return true;
          } catch (e) {
            //rethrow;
          }
        }
      });
      //return true;
    } catch (e) {
      // return false;
    }
    try {
      //print("try 2");
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
        /*
        if (!snapshot2.exists) {
          //print("snap 2 noy exist");
          documentReference2.update({'Avg_BodyWeight': value});
          print("done 2");
          print(value);
          //return true;
        } else {
          try {
            print("done 2.2 before");
            //num n = snapshot2.data()!['Avg_BodyWeight'];
            num newAmount = value;
            print("done 2.2 before 2");
            transaction2
                .update(documentReference2, {'Avg_BodyWeight': newAmount});
            print("done 2.2");
            //return true;
          } catch (e) {
            //rethrow;
          }
        }*/
      });
    } catch (e) {
      //
    }
  }
}



TextFormField reusableTextField3(
    String text,
    IconData icon,
    bool isPasswordType,
    TextEditingController controller,
    validator,
    bool val) {
  return TextFormField(
    onTap: () {
      print("shamod");
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


ThemeData _buildShrineTheme() {
  final ThemeData base = ThemeData.light();
  return base.copyWith(
    toggleableActiveColor: shrinePink400,
    primaryColor: shrinePink100,
    scaffoldBackgroundColor: shrineBackgroundWhite,
    cardColor: shrineBackgroundWhite,
    textSelectionTheme: TextSelectionThemeData(selectionColor: shrinePink100),
    errorColor: shrineErrorRed,
    buttonTheme: const ButtonThemeData(
      colorScheme: _shrineColorScheme,
      textTheme: ButtonTextTheme.normal,
    ),
    primaryIconTheme: _customIconTheme(base.iconTheme),
    textTheme: _buildShrineTextTheme(base.textTheme),
    primaryTextTheme: _buildShrineTextTheme(base.primaryTextTheme),
    iconTheme: _customIconTheme(base.iconTheme), colorScheme: _shrineColorScheme.copyWith(secondary: shrineBrown900),
  );
}

IconThemeData _customIconTheme(IconThemeData original) {
  return original.copyWith(color: shrineBrown900);
}

TextTheme _buildShrineTextTheme(TextTheme base) {
  return base
      .copyWith(
    caption: base.caption?.copyWith(
      fontWeight: FontWeight.w400,
      fontSize: 14,
      letterSpacing: defaultLetterSpacing,
    ),
    button: base.button?.copyWith(
      fontWeight: FontWeight.w500,
      fontSize: 14,
      letterSpacing: defaultLetterSpacing,
    ),
  )
      .apply(
    fontFamily: 'Rubik',
    displayColor: shrineBrown900,
    bodyColor: shrineBrown900,
  );
}

const ColorScheme _shrineColorScheme = ColorScheme(
  primary: shrinePink400,
  secondary: shrinePink50,
  surface: shrineSurfaceWhite,
  background: shrineBackgroundWhite,
  error: shrineErrorRed,
  onPrimary: shrineBrown900,
  onSecondary: shrineBrown900,
  onSurface: shrineBrown900,
  onBackground: shrineBrown900,
  onError: shrineSurfaceWhite,
  brightness: Brightness.light,
);

const Color shrinePink50 = Color(0xFFC28E79);
const Color shrinePink100 = Color(0xFFC28E79);
const Color shrinePink300 = Color(0xFFB98068);
const Color shrinePink400 = Color(0xFFB98068);

const Color shrineBrown900 = Color(0xFF442B2D);
const Color shrineBrown600 = Color(0xFF7D4F52);

const Color shrineErrorRed = Color(0xFFC5032B);

const Color shrineSurfaceWhite = Color(0xFFFFFBFA);
const Color shrineBackgroundWhite = Colors.white;

const defaultLetterSpacing = 0.03;
