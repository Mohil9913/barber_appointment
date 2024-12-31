import 'package:barber_appointment/controllers/login_controller.dart';
import 'package:barber_appointment/firebase_options.dart';
import 'package:barber_appointment/views/add_shop.dart';
import 'package:barber_appointment/views/barber_home.dart';
import 'package:barber_appointment/views/customer_home.dart';
import 'package:barber_appointment/views/login_screen.dart';
import 'package:barber_appointment/views/manage_services.dart';
import 'package:barber_appointment/views/manage_shops.dart';
import 'package:barber_appointment/views/profile_setup.dart';
import 'package:barber_appointment/views/user_type_selection.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(RunApp());
}

class RunApp extends StatelessWidget {
  const RunApp({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginController loginController = Get.put(LoginController());

    return GetMaterialApp(
      theme: ThemeData.dark(),
      getPages: [
        GetPage(name: '/login_screen', page: () => LoginScreen()),
        GetPage(name: '/user_selection', page: () => UserTypeSelection()),
        GetPage(name: '/profile_setup', page: () => ProfileSetup()),
        GetPage(name: '/manage_services', page: () => ManageServices()),
        GetPage(name: '/customer_home', page: () => CustomerHome()),
        GetPage(name: '/barber_home', page: () => BarberHome()),
        GetPage(name: '/manage_shops', page: () => ManageShops()),
        GetPage(name: '/add_shop', page: () => AddShop()),
      ],
      home: FutureBuilder<void>(
        future:
            Future.delayed(Duration.zero, () => loginController.checkIfExist()),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CupertinoActivityIndicator(),
                    SizedBox(width: 10),
                    Text('Connecting Server please wait...'),
                  ],
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Text('Error: ${snapshot.error}'),
              ),
            );
          } else {
            return SizedBox.shrink();
          }
        },
      ),
    );
  }
}
