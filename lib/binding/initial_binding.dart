import 'package:barber_appointment/controllers/customer_controller.dart';
import 'package:barber_appointment/controllers/login_controller.dart';
import 'package:barber_appointment/controllers/manage_shop_controller.dart';
import 'package:barber_appointment/controllers/profile_setup_controller.dart';
import 'package:barber_appointment/controllers/shops_controller.dart';
import 'package:get/get.dart';

class InitialBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ManageShopController());
    Get.lazyPut(() => ProfileSetupController());
    Get.lazyPut(() => ShopsController());
    Get.lazyPut(() => CustomerController());
    Get.lazyPut(() => LoginController());
  }
}
