import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../constants.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';

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

  double feed = 1585;
  int feedrate = 3000;
  int current_water = 120;

  @override
  void initState() {
    // TODO: implement initState
    getsds();
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
        CurrentWaterLevel = event.snapshot.value.toString();
      });
    });
    stream2.listen((DatabaseEvent event2) {
      print(event2.snapshot.value);
      setState(() {
        CurrentFeedLevel = event2.snapshot.value.toString();
      });
    });
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
                            value: int.parse(CurrentFeedLevel) /
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
                                value: int.parse(CurrentWaterLevel) /
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
