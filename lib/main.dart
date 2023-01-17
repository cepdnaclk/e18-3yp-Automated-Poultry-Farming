import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_login/localeString.dart';
import 'package:flutter/services.dart';
import 'package:home_login/screens/QR.dart';
import 'package:home_login/screens/RegScreens/farmReg_screen.dart';
import 'package:home_login/screens/FeedAutomation/autoSelectionPage.dart';
import 'package:home_login/screens/egg_screen.dart';
import 'package:home_login/screens/farm_view.dart';
import 'package:home_login/screens/fcr_screen.dart';
import 'package:home_login/screens/feed_screen.dart';
import 'package:home_login/screens/griddashboard.dart';
import 'package:home_login/screens/mortality_screen.dart';
import 'package:home_login/screens/view_screen.dart';
import 'package:home_login/screens/signin_screen.dart';
import 'package:home_login/screens/selectBodyWeight.dart';
import 'package:home_login/screens/welcome_screen.dart';
import 'package:sizer/sizer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

//Handling background notifications
Future<void> _firebaseMessagingBackgroundhandler(RemoteMessage message) async {
  print('Handling a background message ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await FirebaseMessaging.instance.getInitialMessage();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundhandler);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return GetMaterialApp(
          translations: LocalString(),
          locale: Locale('en', 'US'),
          debugShowCheckedModeBanner: false,
          routes: {
            // When navigating to the "/" route, build the FirstScreen widget.

            GridDashboard.routeFCR: (context) => const FCRScreen(),
            GridDashboard.routeFeed: (context) => const FeedScreen(),
            '/farm': (context) => FarmView(),
            GridDashboard.routeMortal: (context) => const MortalityScreen(),
            GridDashboard.routeWeight: (context) => const BodyWeight(),
            GridDashboard.routeView: (context) => ViewScreen(),
            GridDashboard.routeAddData: (context) =>
                const AutomationSelection(),
            //'/view': (context) => const ViewScreen(),
            '/eggs': (context) => const EggScreen(),
          },
          // ignore: prefer_const_constructors
          home: SplashScreen(),
        );
      },
    );
  }
}
