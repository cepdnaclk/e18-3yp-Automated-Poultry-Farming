import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:home_login/constants.dart';
import 'package:home_login/screens/griddashboard.dart';
import 'package:home_login/screens/reusable.dart';
import 'package:get/get.dart';
import 'package:home_login/screens/view_screen.dart';
import 'package:sizer/sizer.dart';

class DataDisplayPage extends StatefulWidget {
  final String info;
  final String id_flock;
  final String startDateNavi;
  final String strainNavi;
  // const AddBodyWeight({Key? key}) : super(key: key);
  DataDisplayPage({
    Key? key,
    required this.id_flock,
    required this.startDateNavi,
    required this.strainNavi,
    required this.info,
  }) : super(key: key);

  @override
  State<DataDisplayPage> createState() => _DataDisplayPageState();
}

class _DataDisplayPageState extends State<DataDisplayPage> {
  List<DropdownMenuItem<String>> dateItems = [];
  String selectedDate = "";
  //num recordedWeight = 0;
  String rcdFeedMor ="";
  String rcdFeedEve ="";
  String rcdFeedNit ="";
  String rcdTimeMor ="";
  String rcdTimeEve ="";
  String rcdTimeNit ="";
  String rcdMor="";
  String rcdEve="";
  String rcdNit="";


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

            return SizedBox(
              height: 0,
              width: 0,
            );

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
          title: Text("Automation Details",

              style: TextStyle(fontSize: 16)),
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
                      return Padding(
                        padding:  EdgeInsets.fromLTRB(0, 0, 20, 0),
                        child: Container(
                          child: Column(
                            children: [
                              SizedBox(
                                height: 20,
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

                                    try {
                                      rcdMor=snapshot.data?.docs[0]['Morning'];
                                      rcdEve=snapshot.data?.docs[0]['Evening'];
                                      rcdNit=snapshot.data?.docs[0]['Night'];
                                      rcdFeedMor =rcdMor.substring(rcdMor.indexOf('-')+1, );
                                      rcdFeedEve =rcdEve.substring(rcdEve.indexOf('-')+1, );
                                      rcdFeedNit =rcdNit.substring(rcdNit.indexOf('-')+1, );
                                      rcdTimeMor =rcdMor.substring(0, rcdMor.indexOf('-'));
                                      rcdTimeEve =rcdEve.substring(0, rcdMor.indexOf('-'));
                                      rcdTimeNit =rcdNit.substring(0, rcdMor.indexOf('-'));




                                    } catch (e) {
                                      amount = -1;
                                    }
                                    if (amount == -1 || amount == 0) {
                                      return Center();
                                    } else {
                                      return Container();
                                    }
                                  }),


                            ],
                          ),
                        ),
                      );
                      print(dateItems);
                    }
                  }),

            Padding(
              padding:  EdgeInsets.fromLTRB(0, 0, 20, 0),
              child: Container(
                child: Column(
                  children: [
                    SizedBox(height: 5),
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "     " + "Morning Feed/chick",
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
                            rcdFeedMor + " g",
                            style: TextStyle(
                                fontSize: 16,
                                color: mPrimaryColor),
                          ),
                        ),

                      ],
                    ),
                    SizedBox(height: 5),

                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "     " + "Morning Feeding Time",
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
                            rcdTimeMor,
                            style: TextStyle(
                                fontSize: 16,
                                color: mPrimaryColor),
                          ),
                        ),

                      ],
                    ),
                    SizedBox(height: 5),

                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "     " + "Evening Feed/chick",
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
                            rcdFeedEve + " g",
                            style: TextStyle(
                                fontSize: 16,
                                color: mPrimaryColor),
                          ),
                        ),

                      ],
                    ),
                    SizedBox(height: 5),

                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "     " + "Evening Feeding Time",
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
                            rcdTimeEve,
                            style: TextStyle(
                                fontSize: 16,
                                color: mPrimaryColor),
                          ),
                        ),

                      ],
                    ),
                    SizedBox(height: 5),

                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "     " + "Night Feed/chick",
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
                            rcdFeedNit + " g",
                            style: TextStyle(
                                fontSize: 16,
                                color: mPrimaryColor),
                          ),
                        ),

                      ],
                    ),
                    SizedBox(height: 5),

                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "     " + "Night Feeding Time",
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
                            rcdTimeNit,
                            style: TextStyle(
                                fontSize: 16,
                                color: mPrimaryColor),
                          ),
                        ),

                      ],
                    ),

                    SizedBox(height: 5),

                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "     " + "Feed Tank Capacity",
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
                            "1000 kg",
                            style: TextStyle(
                                fontSize: 16,
                                color: mPrimaryColor),
                          ),
                        ),

                      ],
                    ),

                    SizedBox(height: 5),

                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "     " + "Water Tank Capacity",
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
                            "300 l",
                            style: TextStyle(
                                fontSize: 16,
                                color: mPrimaryColor),
                          ),
                        ),

                      ],
                    ),



                  ],
                ),


              ),
            ),



             SizedBox(
               height: 20,
             ),


              /*
              Center(
                child: ElevatedButton(
                  onPressed: () async {

                    /*
                    await updateBodyWeight(widget.id_flock, _numcontroller.text,
                        selectedDate.toString().substring(0, 10));
                    _numcontroller.clear();
                    setState(() {});
                    //Navigator.of(context).pop();

                     */

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
                  child: Text("update".tr),
                ),
              ),
              */
            ],
          ),
        ),
      ),
    );
  }

  Future<void> updateBodyWeight(String id, String amount, String date) async {
    //num current = 0;
    num value = double.parse(amount);
    try {
      //print("try 1");
      DocumentReference<Map<String, dynamic>> documentReference =
      FirebaseFirestore.instance
          .collection('Farmers')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('flock')
          .doc(id)
          .collection('BodyWeight')
          .doc(date);

      FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot<Map<String, dynamic>> snapshot =
        await transaction.get(documentReference);

        if (!snapshot.exists) {
          //print("done 1 befre");
          documentReference.set({'Average_Weight': value});
          //print("done 1");

          //return true;
        } else {
          try {
            //num newAmount = snapshot.data()!['Amount'] + value;
            //current = snapshot.data()!['Average_Weight'];
            transaction.update(documentReference, {'Average_Weight': value});
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
        }
      });
    } catch (e) {
      //
    }
  }
}

// TextField reuseTextField1(String text) {
//   return TextField(
//     decoration: InputDecoration(
//       labelText: text,
//       labelStyle: TextStyle(color: Colors.black38),
//       filled: true,
//       floatingLabelBehavior: FloatingLabelBehavior.auto,
//       fillColor: Colors.white,
//       focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(30.0),
//           borderSide: BorderSide(
//             width: 2.0,
//             color: mPrimaryColor,
//           )),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(30.0),
//         borderSide: BorderSide(
//           color: mPrimaryColor,
//           width: 2.0,
//         ),
//       ),
//       errorBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(30.0),
//         borderSide: BorderSide(
//           color: mPrimaryColor,
//           width: 2.0,
//         ),
//       ),
//       focusedErrorBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(30.0),
//         borderSide: BorderSide(
//           color: mPrimaryColor,
//           width: 2.0,
//         ),
//       ),
//     ),
//   );
// }

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
