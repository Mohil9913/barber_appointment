import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

class ShopsController extends GetxController {
  final barberId = FirebaseAuth.instance.currentUser!.phoneNumber;

  var skills = [].obs;
  RxString latitude = ''.obs;
  RxString longitude = ''.obs;
  RxInt serviceTime = 0.obs;

  RxList shops = RxList();
  RxList shopsId = RxList();
  RxList services = RxList();
  RxList employees = RxList();

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

  Future<void> toggleShopStatus(int index, bool value) async {
    final shop = shops[index];
    final shopId = shopsId[index];

    Get.defaultDialog(
      barrierDismissible: false,
      title: value
          ? 'Mark ${shop['name']} OPEN for customers?'
          : 'Mark ${shop['name']} CLOSED for customers?',
      titlePadding: EdgeInsets.only(
        top: 30,
        left: 20,
        right: 20,
      ),
      content: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20.0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () {
                if (Get.isDialogOpen == true) {
                  Get.back();
                }
              },
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    12,
                  ),
                ),
              ),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                isLoading.value = true;
                if (Get.isDialogOpen == true) {
                  Get.back();
                }
                try {
                  await FirebaseFirestore.instance
                      .collection('shop')
                      .doc(shopId)
                      .update({"status": value}).then((_) {
                    shops[index] = {...shop, "status": value};
                    shops.refresh();
                    isLoading.value = false;
                  });
                } catch (e) {
                  Get.snackbar(
                      'Something went wrong', 'Please try again later');
                  log('$e');
                  isLoading.value = false;
                }
              },
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    12,
                  ),
                ),
              ),
              child: Text(
                value ? 'Mark Open' : 'Mark Close',
                style: TextStyle(color: value ? Colors.green : Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> fetchShops() async {
    try {
      DocumentSnapshot barberDoc = await FirebaseFirestore.instance
          .collection('barber')
          .doc(barberId)
          .get();

      if (barberDoc.exists) {
        final List<dynamic> fetchedShops = barberDoc['shops'] ?? [];
        for (String shopId in fetchedShops) {
          DocumentSnapshot shopDoc = await FirebaseFirestore.instance
              .collection('shop')
              .doc(shopId)
              .get();

          if (shopDoc.exists) {
            shopsId.add(shopDoc.id);
            shops.add(shopDoc.data() as Map<String, dynamic>);
          }
        }
      } else {
        Get.offAllNamed('/login_screen');
      }
    } catch (e) {
      Get.snackbar('Error Fetching shops', '$e');
      log('$e');
    }
  }

  Future<void> createShopAndAddData(String shopName) async {
    isLoading.value = true;

    List<String> serviceIds = [];
    List<String> employeeIds = [];
    DocumentReference? shopRef;

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

      shopRef =
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

      Get.offAllNamed('/barber_home');
      Get.snackbar('$shopName created successfully',
          'Your shop with all services and employees is now listed!');
    } catch (e, stackTrace) {
      if (shopRef != null) {
        await FirebaseFirestore.instance
            .collection('shop')
            .doc(shopRef.id)
            .delete();

        await FirebaseFirestore.instance
            .collection('barber')
            .doc(barberId)
            .update({
          "shops": FieldValue.arrayRemove([shopRef.id])
        });
      }

      for (var serviceId in serviceIds) {
        await FirebaseFirestore.instance
            .collection('service')
            .doc(serviceId)
            .delete();
      }

      for (var employeeId in employeeIds) {
        await FirebaseFirestore.instance
            .collection('employee')
            .doc(employeeId)
            .delete();
      }

      log('Error: $e\n\nStacktrace: $stackTrace');
      Get.snackbar('Error Creating Shop', '$e');
    } finally {
      isLoading.value = false;
    }
  }
}
