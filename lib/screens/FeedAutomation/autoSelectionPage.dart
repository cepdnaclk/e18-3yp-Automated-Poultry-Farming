import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:home_login/constants.dart';
import 'package:home_login/screens/griddashboard.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'AutoUpdateFeed.dart';
import 'addAlertData.dart';
import 'addFeedData.dart';
import '../drawerMenu.dart';
import 'dataDisplay.dart';
import 'alertDataDisplay.dart';

class AutomationSelection extends StatefulWidget {
  const AutomationSelection({Key? key}) : super(key: key);

  @override
  State<AutomationSelection> createState() => _AutomationSelectionState();
}

class _AutomationSelectionState extends State<AutomationSelection>
    with TickerProviderStateMixin {
  List weightDataCobb500 = [];
  String startDate = '';
  String strainType = '';
  int waterCap = 0;
  int waterAlert = 0;
  int feedCap = 0;
  int feedAlert = 0;

  DateTime date =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  double translateX = 0.0;
  double translateY = 0.0;
  double scale = 1;
  bool toggle = false;
  late AnimationController _animationController;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as ScreenArguments;
    return Stack(
      children: [
        DrawerMenu(args.flockID),
        AnimatedContainer(
          duration: Duration(milliseconds: 500),
          transform: Matrix4.translationValues(translateX, translateY, 0)
            ..scale(scale),
          child: GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: ClipRRect(
              borderRadius: (toggle)
                  ? BorderRadius.circular(20)
                  : BorderRadius.circular(0),
              child: Scaffold(
                appBar: AppBar(
                  leading: IconButton(
                    icon: AnimatedIcon(
                      icon: AnimatedIcons.menu_arrow,
                      progress: _animationController,
                    ),
                    onPressed: () {
                      toggle = !toggle;
                      if (toggle) {
                        translateX = 200.0;
                        translateY = 80.0;
                        scale = 0.8;
                        _animationController.forward();
                      } else {
                        translateX = 0.0;
                        translateY = 0.0;
                        scale = 1;
                        _animationController.reverse();
                      }
                      setState(() {});
                    },
                    //icon: Icon(Icons.menu),
                  ),
                  title: Text("Automation Selection"),
                  backgroundColor: mPrimaryColor,
                ),
                body: SingleChildScrollView(
                  child: Center(
                    child: Column(
                      children: [
                        StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection('Farmers')
                                .doc(FirebaseAuth.instance.currentUser!.uid)
                                .collection('flock')
                                .where(FieldPath.documentId,
                                    isEqualTo: args.flockID)
                                .snapshots(), // your stream url,
                            builder: (BuildContext context,
                                AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (!snapshot.hasData) {
                                return CircularProgressIndicator();
                              } else {
                                //print(snapshot.toString());
                                startDate = snapshot.data?.docs[0]['startdays'];
                                strainType = snapshot.data?.docs[0]['strain'];
                                waterCap = snapshot.data?.docs[0]
                                    ['Water Tank Capacity'];
                                waterAlert =
                                    snapshot.data?.docs[0]['Water Tank Alert'];
                                feedAlert =
                                    snapshot.data?.docs[0]['Feed Tank Alert'];
                                feedCap = snapshot.data?.docs[0]
                                    ['Feed Tank Capacity'];
                              }

                              return Container(); // Your grid code.
                            }),
                        SizedBox(
                          height: 4.h,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(20, 10, 10, 10),
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DataDisplayPage(
                                          info: "No data",
                                          id_flock: args.flockID,
                                          startDateNavi: startDate,
                                          strainNavi: strainType),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  fixedSize: const Size(150, 150),
                                  backgroundColor: mPrimaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                  elevation: 15,
                                  shadowColor: mSecondColor,
                                  textStyle: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                child: Text(
                                  "AUTOMATION DATA",
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(10, 10, 20, 10),
                              child: ElevatedButton(
                                onPressed: () {
                                  print(args.flockID);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddAutomatedFeed(
                                        id_flock: args.flockID,
                                        startDateNavi: startDate,
                                        strainNavi: strainType,
                                      ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  fixedSize: const Size(150, 150),
                                  backgroundColor: mBackgroundColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                  side: BorderSide(color: mPrimaryColor),
                                  elevation: 20,
                                  shadowColor: mSecondColor,
                                  textStyle: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                child: Text(
                                  "ADD FEED DATA",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: mPrimaryColor,
                                    fontSize: 17,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 2.h,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(20, 10, 10, 10),
                              child: ElevatedButton(
                                onPressed: () {
                                  print(args.flockID);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddAlertData(
                                        id_flock: args.flockID,
                                        startDateNavi: startDate,
                                        strainNavi: strainType,
                                      ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  fixedSize: const Size(150, 150),
                                  backgroundColor: mBackgroundColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                  side: BorderSide(color: mPrimaryColor),
                                  elevation: 20,
                                  shadowColor: mSecondColor,
                                  textStyle: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                child: Text(
                                  "ADD ALERT DATA".tr,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: mPrimaryColor,
                                    fontSize: 17,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(10, 10, 20, 10),
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TankAlertPage(
                                          feed_capacity: feedCap,
                                          feed_alert: feedAlert,
                                          water_capacity: waterCap,
                                          water_alert: waterAlert),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  fixedSize: const Size(150, 150),
                                  backgroundColor: mPrimaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                  elevation: 20,
                                  shadowColor: mSecondColor,
                                  textStyle: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                child: Text(
                                  "ALERT DATA",
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 2.h,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(20, 10, 10, 10),
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AutoUpadateFeed(
                                        id_flock: args.flockID,
                                        startDateNavi: startDate,
                                        strainNavi: strainType,
                                      ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  fixedSize: const Size(150, 150),
                                  backgroundColor: mPrimaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                  elevation: 20,
                                  shadowColor: mSecondColor,
                                  textStyle: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                child: Text(
                                  "AUTO FEED ADD".tr,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(20, 10, 10, 10),
                              child: ElevatedButton(
                                onPressed: () {
                                  // print(args.flockID);
                                  // Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //     builder: (context) => AddAlertData(
                                  //       id_flock: args.flockID,
                                  //       startDateNavi: startDate,
                                  //       strainNavi: strainType,
                                  //     ),
                                  //   ),
                                  // );
                                },
                                style: ElevatedButton.styleFrom(
                                  fixedSize: const Size(150, 150),
                                  backgroundColor: mBackgroundColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                  side: BorderSide(color: mPrimaryColor),
                                  elevation: 20,
                                  shadowColor: mSecondColor,
                                  textStyle: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                child: Text(
                                  "UPDATE ALERT DATA",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: mPrimaryColor,
                                    fontSize: 17,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 2.h,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(20, 10, 10, 10),
                              child: ElevatedButton(
                                onPressed: () {
                                  // print(args.flockID);
                                  // Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //     builder: (context) => AddAlertData(
                                  //       id_flock: args.flockID,
                                  //       startDateNavi: startDate,
                                  //       strainNavi: strainType,
                                  //     ),
                                  //   ),
                                  // );
                                },
                                style: ElevatedButton.styleFrom(
                                  fixedSize: const Size(150, 150),
                                  backgroundColor: mBackgroundColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                  side: BorderSide(color: mPrimaryColor),
                                  elevation: 20,
                                  shadowColor: mSecondColor,
                                  textStyle: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                child: Text(
                                  "DELETE ALERT DATA",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: mPrimaryColor,
                                    fontSize: 17,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 4.h,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  TextFormField reusableTextField3(
      String text,
      IconData icon,
      bool isPasswordType,
      TextEditingController controller,
      validator,
      bool val) {
    return TextFormField(
      onTap: () {},
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
}
