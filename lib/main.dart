import 'package:expence_tracker/AppScreens/change_password_screen.dart';
import 'package:expence_tracker/AppScreens/dashboard_screen.dart';
import 'package:expence_tracker/AppScreens/login_screen.dart';
import 'package:expence_tracker/AppScreens/signIn_screen.dart';
import 'package:expence_tracker/AppScreens/splash_screen.dart';
import 'package:expence_tracker/DashboardModuleScreens/expenserelatedscreens/add_expences_UI.dart';
import 'package:expence_tracker/DashboardModuleScreens/expenses_screen.dart';
import 'package:expence_tracker/DashboardModuleScreens/profile_screen.dart';
import 'package:expence_tracker/DashboardModuleScreens/reports_screen.dart';
import 'package:expence_tracker/DashboardModuleScreens/roommates_memeber_screen.dart';
import 'package:expence_tracker/DashboardModuleScreens/settings_screen.dart';
import 'package:expence_tracker/DashboardModuleScreens/settlement_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/get_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyD5_VjDfJ0vQiSXDBoEPlyA4VPekn0kS4E",
      appId: '1:76096219944:android:e127e0b4da04f9623efe1d',
      messagingSenderId: "76096219944",
      projectId: "expensetracker-9d82c",
    ),
  );
  // final fcmToken = await FirebaseMessaging.instance.getToken();
  // debugPrint("FCMToken $fcmToken");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,

      initialRoute: '/Splashscreen',

      getPages: [
        GetPage(name: '/Splashscreen', page: () => ExpenseSplash()),
        GetPage(name: '/LoginPage', page: () => LoginScreen()),
        GetPage(name: '/forgetPassword', page: () => ChangePasswordScreen()),
        GetPage(name: '/signIn', page: () => SignUpScreen()),
        GetPage(name: '/dashboard', page: () => DashboardScreen()),
        GetPage(name: '/profile', page: () => UserProfileScreen()),
        GetPage(name: '/showexpenses', page: () => ExpensesScreen()),
        GetPage(name: '/addexpenses', page: () => AddExpenseUI()),
        GetPage(name: '/roommates', page: () => RoomMembers()),
        GetPage(name: '/settlements', page: () => SettlementsScreen()),
        GetPage(name: '/reports', page: () => ReportScreen()),
        GetPage(name: '/settings', page: () => Settings()),
      ],

      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        fontFamily: 'Poppins',
      ),

      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        fontFamily: 'Poppins',
      ),

      themeMode: ThemeMode.system,//Auto theme as per system settings
      home: ExpenseSplash(),
    );
  }
}

