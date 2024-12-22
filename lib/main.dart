import 'package:barber_appointment/firebase_options.dart';
import 'package:barber_appointment/views/barber_profile_setup.dart';
import 'package:barber_appointment/views/login_screen.dart';
import 'package:barber_appointment/views/user_profile_setup.dart';
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
        GetPage(name: '/barber_login', page: () => BarberProfileSetup()),
        GetPage(name: '/customer_login', page: () => UserProfileSetup()),
      ],
      home: LoginScreen(),
    ),
  );
}
