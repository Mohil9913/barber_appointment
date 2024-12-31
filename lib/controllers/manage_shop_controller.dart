import 'dart:developer';

import 'package:barber_appointment/controllers/shops_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

final ShopsController shopsController = Get.find();

class ManageShopController extends GetxController {
  final barberId = FirebaseAuth.instance.currentUser!.phoneNumber;
  var isLoading = false.obs;

  //stores backup of data before updating shop, to rollback in case of partial update
  String? currentId;
  String? currentName;
  List? currentEmployees;
  List? currentServices;
  String? currentLat;
  String? currentLong;

  //stores data received from firebase
  RxList shopsInFirebase = RxList();
  RxList shopsIdInFirebase = RxList();
  RxList employeesInFirebase = RxList();
  RxList employeesIdInFirebase = RxList();
  RxList servicesInFirebase = RxList();
  RxList servicesIdInFirebase = RxList();

  TimeOfDay stringToTimeOfDay(String timeString) {
    final parts = timeString.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    return TimeOfDay(hour: hour, minute: minute);
  }

  Future<void> fetchShops() async {
    shopsIdInFirebase.clear();
    shopsInFirebase.clear();

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
            shopsIdInFirebase.add(shopDoc.id);
            shopsInFirebase.add(shopDoc.data() as Map<String, dynamic>);
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

  Future<void> fetchEmployeesAndServices(int index) async {
    final shop = shopsInFirebase[index];
    employeesInFirebase.clear();
    employeesIdInFirebase.clear();
    servicesInFirebase.clear();
    servicesIdInFirebase.clear();

    try {
      for (String employee in shop['employees']) {
        DocumentSnapshot employeeDoc = await FirebaseFirestore.instance
            .collection('employee')
            .doc(employee)
            .get();

        if (employeeDoc.exists) {
          employeesIdInFirebase.add(employeeDoc.id);
          employeesInFirebase.add(employeeDoc.data() as Map<String, dynamic>);
        }
      }

      for (var employee in employeesInFirebase) {
        employee['entryTime'] = stringToTimeOfDay(employee['entryTime']);
        employee['exitTime'] = stringToTimeOfDay(employee['exitTime']);
      }

      for (String service in shop['services']) {
        DocumentSnapshot serviceDoc = await FirebaseFirestore.instance
            .collection('service')
            .doc(service)
            .get();

        if (serviceDoc.exists) {
          servicesIdInFirebase.add(serviceDoc.id);
          servicesInFirebase.add(serviceDoc.data() as Map<String, dynamic>);
        }
      }
    } catch (e) {
      log('Error fetching data: $e');
    }
  }

  Future<void> toggleShopStatus(int index, bool value) async {
    final shop = shopsInFirebase[index];
    final shopId = shopsIdInFirebase[index];

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
                    shopsInFirebase[index] = {...shop, "status": value};
                    shopsIdInFirebase.refresh();
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

  Future<void> showShopDetails(BuildContext context, int index) async {
    final shop = shopsInFirebase[index];
    final shopId = shopsIdInFirebase[index];

    Get.bottomSheet(
      isScrollControlled: true,
      Wrap(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
            ),
            child: isLoading.value
                ? Center(child: CupertinoActivityIndicator())
                : FutureBuilder(
                    future: fetchEmployeesAndServices(index),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CupertinoActivityIndicator(),
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text('Error: ${snapshot.error}'),
                        );
                      } else {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              shop['name'],
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Divider(),
                            Container(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Services',
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                  SizedBox(height: 10),
                                  if (servicesInFirebase.isEmpty)
                                    Text(
                                      'No services available.',
                                      style: TextStyle(color: Colors.grey),
                                    )
                                  else
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: servicesInFirebase.length,
                                      itemBuilder: (context, index) {
                                        final service =
                                            servicesInFirebase[index];
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 4.0),
                                          child: Text(
                                            '${service['serviceName']} | ₹${service['servicePrice']} | Time Slots - ${service['serviceTime']}',
                                            style: service['serviceStatus']
                                                ? TextStyle()
                                                : TextStyle(
                                                    decoration: TextDecoration
                                                        .lineThrough),
                                          ),
                                        );
                                      },
                                    ),
                                ],
                              ),
                            ),
                            Divider(),
                            Container(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Employees',
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                  SizedBox(height: 10),
                                  if (servicesInFirebase.isEmpty)
                                    Text(
                                      'No employees available.',
                                      style: TextStyle(color: Colors.grey),
                                    )
                                  else
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: employeesInFirebase.length,
                                      itemBuilder: (context, index) {
                                        final employee =
                                            employeesInFirebase[index];
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 4.0),
                                          child: Text(
                                            '${employee['employeeName']} | ${MaterialLocalizations.of(context).formatTimeOfDay(employee['entryTime'])} - ${MaterialLocalizations.of(context).formatTimeOfDay(employee['exitTime'])}',
                                            style: employee['employeeStatus']
                                                ? TextStyle()
                                                : TextStyle(
                                                    decoration: TextDecoration
                                                        .lineThrough),
                                          ),
                                        );
                                      },
                                    ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                currentId = shopId;
                                currentName = shop['name'];
                                currentEmployees = employeesInFirebase;
                                currentServices = servicesInFirebase;
                                currentLat = shop['location']['lat'];
                                currentLong = shop['location']['long'];

                                shopsController.shopNameController.text =
                                    shop['name'];
                                shopsController.services = servicesInFirebase;
                                shopsController.employees = employeesInFirebase;
                                shopsController.latitude.value =
                                    shop['location']['lat'];
                                shopsController.longitude.value =
                                    shop['location']['long'];
                                Get.toNamed('/add_shop',
                                    arguments: {'isEdit': true});
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    'Edit Shop Details',
                                    style: TextStyle(color: Colors.blue),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
