import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

class ShopsController extends GetxController {
  final barberId = FirebaseAuth.instance.currentUser!.phoneNumber;
  RxList shops = RxList();
  var services = [].obs;
  var skills = [].obs;
  RxList employees = RxList();
  RxString latitude = ''.obs;
  RxString longitude = ''.obs;

  Rx<TimeOfDay?> employeeEntryTime = Rx<TimeOfDay?>(null);
  Rx<TimeOfDay?> employeeExitTime = Rx<TimeOfDay?>(null);
  var isLoading = false.obs;

  String timeOfDayToString(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void toggleService(int index) {
    services[index]['serviceStatus'] = !services[index]['serviceStatus'];
    services.refresh();
  }

  void toggleEmployee(int index) {
    employees[index]['employeeStatus'] = !employees[index]['employeeStatus'];
    employees.refresh();
  }

  bool checkSkills(String serviceName) {
    return skills.contains(serviceName);
  }

  void toggleSkills(String serviceName) {
    if (checkSkills(serviceName)) {
      skills.remove(serviceName);
    } else {
      skills.add(serviceName);
    }
    skills.refresh();
  }

  int calculateTimeSlots(int minutes) {
    return (minutes / 30).ceil();
  }

  Future<void> fetchShops() async {
    try {
      DocumentSnapshot barberDoc = await FirebaseFirestore.instance
          .collection('barber')
          .doc(barberId)
          .get();

      if (barberDoc.exists) {
        final List<dynamic> fetchedShops = barberDoc['shops'] ?? [];
        shops.value = fetchedShops;
      } else {
        Get.offAllNamed('/login_screen');
      }
    } catch (e) {
      Get.snackbar('Error Fetching shops', '$e');
    }
  }

  Future<void> pickEntryTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: employeeEntryTime.value ?? TimeOfDay.now(),
    );

    if (pickedTime != null) {
      employeeEntryTime.value = pickedTime;
    }
  }

  Future<void> pickExitTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: employeeExitTime.value ?? TimeOfDay.now(),
    );

    if (pickedTime != null) {
      employeeExitTime.value = pickedTime;
    }
  }

  Future<void> fetchLocation() async {
    isLoading.value = true;
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.snackbar('Permission Denied',
              'Please allow to fetch location to add shop!');
          isLoading.value = false;
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Get.snackbar(
            'Permission Denied', 'Please allow to fetch location to add shop!');
        isLoading.value = false;
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(accuracy: LocationAccuracy.high),
      );

      latitude.value = (position.latitude).toString();
      longitude.value = (position.longitude).toString();
      isLoading.value = false;
    } catch (e) {
      Get.snackbar('Error fetching location', '$e');
      isLoading.value = false;
    }
  }

  Future<void> createShopAndAddData(
    String shopName,
  ) async {
    isLoading.value = true;
    List<String> serviceIds = [];
    List<String> employeeIds = [];

    try {
      final shopData = {
        "status": true,
        "name": shopName,
        "location": {"lat": latitude.value, "long": longitude.value},
        "customer": [],
        "appointments": [],
        "employees": [],
        "services": [],
        "exceptions": []
      };

      final shopRef =
          await FirebaseFirestore.instance.collection('shop').add(shopData);

      await FirebaseFirestore.instance
          .collection('barber')
          .doc(barberId)
          .update({
        "shops": FieldValue.arrayUnion([shopRef.id])
      });

      for (var service in services) {
        final serviceData = {
          "serviceStatus": service['serviceStatus'] ?? true,
          "shopId": shopRef.id,
          "serviceName": service['serviceName'],
          "servicePrice": service['servicePrice'],
          "serviceTime": service['serviceTime'],
          "exceptions": []
        };

        final serviceRef = await FirebaseFirestore.instance
            .collection('service')
            .add(serviceData);
        serviceIds.add(serviceRef.id);
      }

      for (var employee in employees) {
        final employeeData = {
          "employeeStatus": employee['employeeStatus'] ?? true,
          "shopId": shopRef.id,
          "skills": employee['skills'],
          "entryTime": timeOfDayToString(employee['entryTime']),
          "exitTime": timeOfDayToString(employee['exitTime']),
          "exceptions": []
        };

        final employeeRef = await FirebaseFirestore.instance
            .collection('employee')
            .add(employeeData);
        employeeIds.add(employeeRef.id);
      }

      await FirebaseFirestore.instance
          .collection('shop')
          .doc(shopRef.id)
          .update({
        "services": FieldValue.arrayUnion(serviceIds),
        "employees": FieldValue.arrayUnion(employeeIds)
      });

      Get.snackbar('$shopName created successfully',
          'Your shop with all services and employees is now listed!');
      isLoading.value = false;
      Get.off('/manage_shops');
    } catch (e) {
      Get.snackbar('Error Fetching shops', '$e');
      isLoading.value = false;
    }
  }
}
