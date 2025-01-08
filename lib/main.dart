import 'package:barber_appointment/binding/initial_binding.dart';
import 'package:barber_appointment/firebase_options.dart';
import 'package:barber_appointment/views/barber/add_shop.dart';
import 'package:barber_appointment/views/barber/barber_home.dart';
import 'package:barber_appointment/views/barber/manage_shops.dart';
import 'package:barber_appointment/views/common/login_screen.dart';
import 'package:barber_appointment/views/common/profile_setup.dart';
import 'package:barber_appointment/views/common/user_type_selection.dart';
import 'package:barber_appointment/views/customer/customer_home.dart';
import 'package:barber_appointment/views/customer/new_appointment.dart';
import 'package:barber_appointment/views/customer/select_employee.dart';
import 'package:barber_appointment/views/customer/select_service.dart';
import 'package:barber_appointment/widgets/launcher_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseAuth.instance.setSettings(appVerificationDisabledForTesting: true);
  runApp(RunApp());
}

class RunApp extends StatelessWidget {
  const RunApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData.dark(),
      initialBinding: InitialBinding(),
      initialRoute: '/launch',
      getPages: [
        GetPage(name: '/launch', page: () => LauncherScreen()),
        GetPage(name: '/login_screen', page: () => LoginScreen()),
        GetPage(name: '/user_selection', page: () => UserTypeSelection()),
        GetPage(name: '/profile_setup', page: () => ProfileSetup()),
        GetPage(name: '/customer_home', page: () => CustomerHome()),
        GetPage(name: '/barber_home', page: () => BarberHome()),
        GetPage(name: '/manage_shops', page: () => ManageShops()),
        GetPage(name: '/add_shop', page: () => AddShop()),
        GetPage(name: '/new_appointment', page: () => NewAppointment()),
        GetPage(name: '/select_service', page: () => SelectService()),
        GetPage(name: '/select_employee', page: () => SelectEmployee()),
      ],
    );
  }
}
