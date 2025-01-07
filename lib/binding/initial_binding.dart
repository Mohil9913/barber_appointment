import 'dart:developer';

import 'package:barber_appointment/controllers/barber_appointment_controller.dart';
import 'package:barber_appointment/controllers/customer_controller.dart';
import 'package:barber_appointment/controllers/login_controller.dart';
import 'package:barber_appointment/controllers/manage_shop_controller.dart';
import 'package:barber_appointment/controllers/profile_setup_controller.dart';
import 'package:barber_appointment/controllers/shops_controller.dart';
import 'package:get/get.dart';

class InitialBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(LoginController(), permanent: true);
    log("LoginController Created!");
    Get.put(ManageShopController(), permanent: true);
    log("ManageShop Created!");
    Get.put(CustomerController(), permanent: true);
    log("Customer Created!");
    Get.put(ProfileSetupController(), permanent: true);
    log("ProfileSetup Created!");
    Get.put(ShopsController(), permanent: true);
    log("Shop Created!");
    Get.put(BarberAppointmentController(), permanent: true);
    log("Barber Created!");
  }
}
