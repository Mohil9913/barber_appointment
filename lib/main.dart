import 'package:barber_appointment/firebase_options.dart';
import 'package:barber_appointment/views/customer_home_screen.dart';
import 'package:barber_appointment/views/login_screen.dart';
import 'package:barber_appointment/views/manage_services.dart';
import 'package:barber_appointment/views/profile_setup.dart';
import 'package:barber_appointment/views/user_type_selection.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    GetMaterialApp(
      theme: ThemeData.dark(),
      getPages: [
        GetPage(name: '/user_selection', page: () => UserTypeSelection()),
        GetPage(name: '/profile_setup', page: () => ProfileSetup()),
        GetPage(name: '/manage_services', page: () => ManageServices()),
        GetPage(name: '/customer_home', page: () => CustomerHomeScreen()),
      ],
      //TODO: After OTP and user auth is Completed, make sure to send user to Home Screen directly
      home: LoginScreen(),
    ),
  );
}
