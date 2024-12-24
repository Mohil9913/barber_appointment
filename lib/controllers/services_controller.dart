import 'package:get/get.dart';

class ServicesController extends GetxController {
  var services = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    //TODO: Fetch Services from Database
    super.onInit();
    services.addAll([
      {"name": "Haircut", "selected": true, "price": 123, "minutes": 30},
      {"name": "Shaving", "selected": true, "price": 234, "minutes": 15},
      {"name": "Facial", "selected": true, "price": 345, "minutes": 60},
    ]);
  }

  void toggleService(int index) {
    services[index]['selected'] = !services[index]['selected'];
    services.refresh();
  }

  void addService(String name, int price, int minutes) {
    //TODO: Add Service to Database
    services.add({
      "name": name,
      "selected": true,
      "price": price,
      "minutes": minutes,
    });
    Get.snackbar('New Service Added', '$name is appended to services list');
  }

  void deleteService(int index) {
    //TODO: Delete Service from Database
    String name = services[index]['name'];
    services.removeAt(index);
    Get.snackbar('Delete Initiated', '$name is Deleted from the services list');
  }
}
