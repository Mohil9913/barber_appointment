import 'package:barber_appointment/views/barber_profile_setup.dart';
import 'package:barber_appointment/views/login_screen.dart';
import 'package:barber_appointment/views/user_type_selection.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  runApp(
    GetMaterialApp(
      theme: ThemeData.dark(),
      getPages: [
        GetPage(name: '/user_selection', page: () => UserTypeSelection()),
        GetPage(name: '/barber_login', page: () => BarberProfileSetup()),
      ],
      home: LoginScreen(),
    ),
  );
}
