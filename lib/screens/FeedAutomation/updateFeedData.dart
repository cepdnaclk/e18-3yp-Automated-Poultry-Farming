import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:home_login/constants.dart';
import 'package:home_login/screens/griddashboard.dart';
import 'package:home_login/screens/reusable.dart';
import 'package:get/get.dart';
import 'package:home_login/screens/view_screen.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

class UpdateAutomatedFeed extends StatefulWidget {
  final String id_flock;
  final String startDateNavi;
  final String strainNavi;
  // const AddBodyWeight({Key? key}) : super(key: key);
  UpdateAutomatedFeed({
    Key? key,
    required this.id_flock,
    required this.startDateNavi,
    required this.strainNavi,
  }) : super(key: key);

  @override
  State<UpdateAutomatedFeed> createState() => _UpdateAutomatedFeedState();
}

class _UpdateAutomatedFeedState extends State<UpdateAutomatedFeed> {
  // ignore: deprecated_member_use
  final databaseRef = FirebaseDatabase.instance.reference();
  List<DropdownMenuItem<String>> dateItems = [];
  String selectedDate = "";
  num recordedWeight = 0;
  num recMfeed = 0, recEfeed = 0, recNfeed = 0;
  int mortal = 0, startCount = 0;
  String totalChick = '';

  //DateTime date =
  //DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  final TextEditingController _datecontroller = TextEditingController();
  final TextEditingController _numcontroller = TextEditingController();
  final TextEditingController _numcontrollerMorning = TextEditingController();
  final TextEditingController _numcontrollerEvening = TextEditingController();
  final TextEditingController _numcontrollerNight = TextEditingController();
  final TextEditingController timeinMor = TextEditingController();
  final TextEditingController timeinEve = TextEditingController();
  final TextEditingController timeinNit = TextEditingController();

  late StreamBuilder _widget;

  @override
  void initState() {
    selectedDate = widget.startDateNavi;

    _widget = StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("Farmers")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('flock')
            .doc(widget.id_flock)
            .collection('Data')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            for (int i = 0; i < snapshot.data!.docs.length; i++) {
              DocumentSnapshot snap = snapshot.data!.docs[i];

              double amount = -1;
              String date;
              try {
                date = snapshot.data!.docs[i].id;

                dateItems.add(
                  DropdownMenuItem(
                    child: Text(
                      date,
                      style: TextStyle(color: mPrimaryColor),
                    ),
                    value: "$date",
                  ),
                );
              } catch (e) {
                //amount = -1;
              }
            }
            //print(dateItems);
            return Container();
            print(dateItems);
          }
        });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //final args = ModalRoute.of(context)!.settings.arguments as ScreenArguments;
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text("Update Feed Data", style: TextStyle(fontSize: 17)),
          backgroundColor: mPrimaryColor,
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _widget,
              StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('Farmers')
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .collection('flock')
                      .where(FieldPath.documentId, isEqualTo: widget.id_flock)
                      .snapshots(), // your stream url,
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      //return CircularProgressIndicator();
                    } else {
                      //print(snapshot.toString());
                      mortal = snapshot.data?.docs[0]['Mortal'];
                      totalChick = snapshot.data?.docs[0]['count'];
                      startCount = int.parse(totalChick);
                    }
                    return Container();
                  }),
              StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("Farmers")
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .collection('flock')
                      .doc(widget.id_flock)
                      .collection('Data')
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else {
                      return Container(
                        child: Column(
                          children: [
                            SizedBox(
                              height: 50,
                            ),
                            Center(
                              child: Container(
                                alignment: Alignment.center,
                                height: 25,
                                width: 40.w,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: mPrimaryColor,
                                  ),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: DropdownButton(
                                    alignment: Alignment.center,
                                    hint: new Text(
                                      'selectDate'.tr,
                                      style: TextStyle(
                                        color: mPrimaryColor,
                                        fontSize: 18,
                                      ),
                                    ),
                                    items: dateItems.toSet().toList(),
                                    onChanged: (newValue) {
                                      setState(() {
                                        selectedDate = newValue
                                            .toString()
                                            .substring(0, 10);
                                        //Text(selectedDate);
                                        print(selectedDate);
                                      });
                                    }),
                              ),
                            ),
                            SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "     " + "selectedDate".tr,
                                  style: TextStyle(
                                      fontSize: 16, color: mPrimaryColor),
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
                                    "${selectedDate}",
                                    style: TextStyle(
                                        fontSize: 16, color: mPrimaryColor),
                                  ),
                                ),
                              ],
                            ),
                            StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection("Farmers")
                                    .doc(FirebaseAuth.instance.currentUser!.uid)
                                    .collection('flock')
                                    .doc(widget.id_flock)
                                    .collection('Data')
                                    .where(FieldPath.documentId,
                                        isEqualTo: selectedDate
                                            .toString()
                                            .substring(0, 10))
                                    .snapshots(),
                                builder: (BuildContext context,
                                    AsyncSnapshot<QuerySnapshot> snapshot) {
                                  num amount = -1;
                                  String recmorning = "";
                                  String recevening = "";
                                  String recnight = "";
                                  try {
                                    recmorning =
                                        snapshot.data?.docs[0]['Morning'];
                                    recevening =
                                        snapshot.data?.docs[0]['Evening'];
                                    recnight = snapshot.data?.docs[0]['Night'];

                                    //print(amount);
                                  } catch (e) {
                                    amount = -1;
                                  }
                                  if (recmorning == "" ||
                                      recevening == "" ||
                                      recnight == "") {
                                    return Center();
                                  } else {
                                    return Container(
                                      child: Column(
                                        children: [
                                          SizedBox(height: 2.h),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "     " +
                                                    "Recorded Morning Feed Time",
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: mPrimaryColor),
                                              ),
                                              Container(
                                                alignment: Alignment.center,
                                                height: 25,
                                                width: 30.w,
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: mPrimaryColor,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                ),
                                                child: Text(
                                                  recmorning
                                                      .toString()
                                                      .substring(0, 8),
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: mPrimaryColor),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 1.h),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "     " + "Morning Feed Amount",
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: mPrimaryColor),
                                              ),
                                              Container(
                                                alignment: Alignment.center,
                                                height: 25,
                                                width: 30.w,
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: mPrimaryColor,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                ),
                                                child: Text(
                                                  recmorning
                                                      .toString()
                                                      .substring(9),
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: mPrimaryColor),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 1.h),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "     " +
                                                    "Recorded Evening Feed Time",
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: mPrimaryColor),
                                              ),
                                              Container(
                                                alignment: Alignment.center,
                                                height: 25,
                                                width: 30.w,
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: mPrimaryColor,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                ),
                                                child: Text(
                                                  recevening
                                                      .toString()
                                                      .substring(0, 8),
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: mPrimaryColor),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 1.h),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "     " + "Evening Feed Amount",
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: mPrimaryColor),
                                              ),
                                              Container(
                                                alignment: Alignment.center,
                                                height: 25,
                                                width: 30.w,
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: mPrimaryColor,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                ),
                                                child: Text(
                                                  recevening
                                                      .toString()
                                                      .substring(9),
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: mPrimaryColor),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 1.h),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "     " +
                                                    "Recorded Night Feed Time",
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: mPrimaryColor),
                                              ),
                                              Container(
                                                alignment: Alignment.center,
                                                height: 25,
                                                width: 30.w,
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: mPrimaryColor,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                ),
                                                child: Text(
                                                  recnight
                                                      .toString()
                                                      .substring(0, 8),
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: mPrimaryColor),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 1.h),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "     " + "Night Feed Amount",
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: mPrimaryColor),
                                              ),
                                              Container(
                                                alignment: Alignment.center,
                                                height: 25,
                                                width: 30.w,
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: mPrimaryColor,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                ),
                                                child: Text(
                                                  recnight
                                                      .toString()
                                                      .substring(9),
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: mPrimaryColor),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 1.h),
                                        ],
                                      ),

                                      // child: Text(
                                      //   "You have already recorded ${snapshot.data?.docs[0]['Average_Weight']} average weight for ${date.toString().substring(0, 10)}",
                                      //   textAlign: TextAlign.center,
                                      //   style: TextStyle(
                                      //       fontSize: 20,
                                      //       color: mPrimaryTextColor),
                                      // ),
                                    );
                                  }
                                }),

                            /*
                           Row(
                             children: [
                               Text("Selected Date"),
                               TextField(
                                 decoration: InputDecoration(
                                   border: OutlineInputBorder(),
                                   hintText: "$selectedDate" ,
                                 ),
                               ),
                             ],
                           )
                           */
                          ],
                        ),
                      );
                      print(dateItems);
                    }
                  }),

              SizedBox(
                height: 4.h,
              ),

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
                child: TextFormField(
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
                    icon: Icon(
                      Icons.timer,
                      color: mPrimaryColor,
                    ), //icon of text field
                    labelText: "Enter Morning Feed Time",
                    labelStyle:
                        TextStyle(color: Colors.grey), //label text of field
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
                  onTap: () async {
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                      builder: (context, child) {
                        return Theme(data: _buildShrineTheme(), child: child!);
                      },
                    );

                    if (pickedTime != null) {
                      print(pickedTime.format(context)); //output 10:51 PM
                      DateTime parsedTime = DateFormat.jm()
                          .parse(pickedTime.format(context).toString());
                      //converting to DateTime so that we can further format on different pattern.
                      print(parsedTime); //output 1970-01-01 22:53:00.000
                      String formattedTime =
                          DateFormat('HH:mm:ss').format(parsedTime);
                      print(formattedTime); //output 14:59:00
                      //DateFormat() is from intl package, you can format the time on any pattern you need.

                      setState(() {
                        timeinMor.text =
                            formattedTime; //set the value of text field.
                      });
                    } else {
                      print("Time is not selected");
                    }
                  },
                ),
              ),

              SizedBox(
                height: 3.h,
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
                child: TextFormField(
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
                    icon: Icon(
                      Icons.timer,
                      color: mPrimaryColor,
                    ), //icon of text field
                    labelText: "Enter Evening Feed Time",
                    labelStyle:
                        TextStyle(color: Colors.grey), //label text of field
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
                  onTap: () async {
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                      builder: (context, child) {
                        return Theme(data: _buildShrineTheme(), child: child!);
                      },
                    );

                    if (pickedTime != null) {
                      print(pickedTime.format(context)); //output 10:51 PM
                      DateTime parsedTime = DateFormat.jm()
                          .parse(pickedTime.format(context).toString());
                      //converting to DateTime so that we can further format on different pattern.
                      print(parsedTime); //output 1970-01-01 22:53:00.000
                      String formattedTime =
                          DateFormat('HH:mm:ss').format(parsedTime);
                      print(formattedTime); //output 14:59:00
                      //DateFormat() is from intl package, you can format the time on any pattern you need.

                      setState(() {
                        timeinEve.text =
                            formattedTime; //set the value of text field.
                      });
                    } else {
                      print("Time is not selected");
                    }
                  },
                ),
              ),

              SizedBox(
                height: 3.h,
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
                child: TextFormField(
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
                    icon: Icon(
                      Icons.timer,
                      color: mPrimaryColor,
                    ), //icon of text field
                    labelText: "Enter Night Feed Time",
                    labelStyle:
                        TextStyle(color: Colors.grey), //label text of field
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
                  onTap: () async {
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                      builder: (context, child) {
                        return Theme(data: _buildShrineTheme(), child: child!);
                      },
                    );

                    if (pickedTime != null) {
                      print(pickedTime.format(context)); //output 10:51 PM
                      DateTime parsedTime = DateFormat.jm()
                          .parse(pickedTime.format(context).toString());
                      //converting to DateTime so that we can further format on different pattern.
                      print(parsedTime); //output 1970-01-01 22:53:00.000
                      String formattedTime =
                          DateFormat('HH:mm:ss').format(parsedTime);
                      print(formattedTime); //output 14:59:00
                      //DateFormat() is from intl package, you can format the time on any pattern you need.

                      setState(() {
                        timeinNit.text =
                            formattedTime; //set the value of text field.
                      });
                    } else {
                      print("Time is not selected");
                    }
                  },
                ),
              ),

              SizedBox(
                height: 4.h,
              ),

              // Center(
              //   child: Image.asset(
              //     "assets/images/weight-new.png",
              //     fit: BoxFit.fitWidth,
              //     width: context.width * 0.7,
              //     // height: 420,
              //     //color: Colors.purple,
              //   ),
              // ),

              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    // print(args.flockID);
                    // print(_numcontroller.text);
                    // print(date);
                    await updateData(
                        mortal,
                        startCount,
                        widget.id_flock,
                        selectedDate.toString().substring(0, 10),
                        timeinMor.text,
                        timeinEve.text,
                        timeinNit.text,
                        _numcontrollerMorning.text,
                        _numcontrollerEvening.text,
                        _numcontrollerNight.text);
                    _numcontroller.clear();
                    setState(() {});
                    //Navigator.of(context).pop();

                    ///displayFCRdialog();
                    Fluttertoast.showToast(
                        msg: 'Successfully Updated!',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: mNewColor3,
                        textColor: mPrimaryColor);
                  },
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size(200, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    primary: mPrimaryColor,
                    elevation: 20,
                    shadowColor: mSecondColor,
                    textStyle: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: Text("update".tr),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> updateData(
      int mortal,
      int startcount,
      String id,
      String date,
      String MorTime,
      String EveTime,
      String NitTime,
      String MorFeedAmnt,
      String EveFeedAmnt,
      String NitFeedAmnt) async {
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
          updatefeeddataRealtimeData(
              mortal,
              startcount,
              FirebaseAuth.instance.currentUser!.uid,
              id,
              date,
              MorTime,
              EveTime,
              NitTime,
              int.parse(MorFeedAmnt),
              int.parse(EveFeedAmnt),
              int.parse(NitFeedAmnt));

          documentReference.set({
            'Morning': "${MorTime}-${MorFeedAmnt}",
            'Evening': "${EveTime}-${EveFeedAmnt}",
            'Night': "${NitTime}-${NitFeedAmnt}"
          });
          //print("done 1");

          //return true;
        } else {
          try {
            updatefeeddataRealtimeData(
                mortal,
                startcount,
                FirebaseAuth.instance.currentUser!.uid,
                id,
                date,
                MorTime,
                EveTime,
                NitTime,
                int.parse(MorFeedAmnt),
                int.parse(EveFeedAmnt),
                int.parse(NitFeedAmnt));
            //num newAmount = snapshot.data()!['Amount'] + value;
            //current = snapshot.data()!['Average_Weight'];
            transaction.update(documentReference, {
              'Morning': "${MorTime}-${MorFeedAmnt}",
              'Evening': "${EveTime}-${EveFeedAmnt}",
              'Night': "${NitTime}-${NitFeedAmnt}"
            });
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
      });
    } catch (e) {
      //
    }
  }

  void updatefeeddataRealtimeData(
    int mortal,
    int startcount,
    String uid,
    String id,
    String date,
    String mTime,
    String eTime,
    String nTime,
    int mAmt,
    int eAmt,
    int nAmt,
  ) {
    databaseRef.child(uid).child(id).update({
      // 'Morning Feed Time': mTime,
      // 'Evening Feed Time': eTime,
      // 'Night Feed Time': nTime,
      'Morning Time': int.parse(mTime.toString().substring(0, 2)),
      'Morning Feed Time MM': int.parse(mTime.toString().substring(3, 5)),
      'Evening Time': int.parse(eTime.toString().substring(0, 2)),
      'Evening Feed Time MM': int.parse(eTime.toString().substring(3, 5)),
      'Night Time': int.parse(nTime.toString().substring(0, 2)),
      'Night Feed Time MM': int.parse(nTime.toString().substring(3, 5)),
      'Morning Feed Amount': (mAmt * (startcount - mortal) / 2),
      'Evening Feed Amount': (eAmt * (startcount - mortal) / 2),
      'Night Feed Amount': (nAmt * (startcount - mortal) / 2),
      'Last Modified Date': date,
    });
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

class PoultryData {
  final double amount;
  final int day;

  PoultryData(this.day, this.amount);
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
    iconTheme: _customIconTheme(base.iconTheme),
    colorScheme: _shrineColorScheme.copyWith(secondary: shrineBrown900),
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
