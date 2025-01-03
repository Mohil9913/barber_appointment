import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CustomerController extends GetxController {
  String? customerId;
  RxString customerName = RxString('');
  RxString imageUrl = ''.obs;
  RxString gender = RxString('');
  RxString dob = RxString('');
  RxInt age = RxInt(0);
  RxList? appointmentsInFirebase = RxList();
  RxList? appointmentsIdInFirebase = RxList();
  var isLoading = false.obs;

  RxList shopsInFirebase = RxList();
  RxList shopsIdInFirebase = RxList();
  RxList employeesInFirebase = RxList();
  RxList employeesIdInFirebase = RxList();
  RxList servicesInFirebase = RxList();
  RxList servicesIdInFirebase = RxList();

  RxInt selectedIndex = RxInt(0);
  RxList<String> services = <String>[].obs;
  RxInt totalAmount = RxInt(0);
  RxInt totalTimeSlots = RxInt(0);

  @override
  void onInit() {
    fetchCustomerDetails();
    super.onInit();
  }

  void cacheProfileImage() {
    if (imageUrl.value.isNotEmpty) {
      try {
        CachedNetworkImageProvider(imageUrl.value)
            .resolve(const ImageConfiguration());
      } catch (e) {
        log('Failed to cache profile image: $e');
      }
    } else {
      log('imageUrl is empty, skipping caching.');
    }
  }

  bool checkServices(String serviceName) {
    return services.contains(serviceName);
  }

  void toggleService(String serviceName) {
    if (checkServices(serviceName)) {
      services.remove(serviceName);
    } else {
      services.add(serviceName);
    }
  }

  int calculateAge(DateTime birthDate) {
    final currentDate = DateTime.now();

    int age = currentDate.year - birthDate.year;

    if (currentDate.month < birthDate.month ||
        (currentDate.month == birthDate.month &&
            currentDate.day < birthDate.day)) {
      age--;
    }

    return age;
  }

  Future<void> fetchCustomerDetails() async {
    if (FirebaseAuth.instance.currentUser == null) {
      Get.offAllNamed('/login_screen');
      return;
    }

    try {
      customerId = FirebaseAuth.instance.currentUser!.phoneNumber;

      DocumentSnapshot customerDoc = await FirebaseFirestore.instance
          .collection('customer')
          .doc(customerId)
          .get();

      if (customerDoc.exists) {
        customerName.value = customerDoc['customerName'] ?? 'Unknown';
        imageUrl.value = customerDoc['imageUrl'] ?? ''; // Ensure valid fallback
        gender.value = customerDoc['customerGender'] ?? 'Unknown';

        if (customerDoc['customerDOB'] != null) {
          DateTime birthDate = customerDoc['customerDOB'].toDate();
          dob.value = DateFormat('d MMM yyyy').format(birthDate);
          age.value = calculateAge(birthDate);
        }

        cacheProfileImage();

        appointmentsIdInFirebase!.value = customerDoc['appointments'] ?? [];
      } else {
        Get.offAllNamed('/login_screen');
      }
    } catch (e) {
      Get.snackbar('Error Fetching Customer', '$e');
      log('Error fetching customer details: $e');
    }
  }

  TimeOfDay stringToTimeOfDay(String timeString) {
    final parts = timeString.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    return TimeOfDay(hour: hour, minute: minute);
  }

  Future<void> fetchShops() async {
    shopsInFirebase.clear();
    shopsIdInFirebase.clear();

    try {
      QuerySnapshot shopSnapshot =
          await FirebaseFirestore.instance.collection('shop').get();
      if (shopSnapshot.docs.isNotEmpty) {
        shopsInFirebase.value = shopSnapshot.docs.map((doc) {
          shopsIdInFirebase.add(doc.id);
          return doc.data() as Map<String, dynamic>;
        }).toList();
      }
    } catch (e) {
      Get.snackbar('Error Fetching shops', '$e');
      log('Error fetching data: $e');
    }
  }

  Future<void> fetchServices() async {
    final shop = shopsInFirebase[selectedIndex.value];
    servicesInFirebase.clear();
    servicesIdInFirebase.clear();

    try {
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
      log('Error fetching services: $e');
      Get.snackbar('Error Fetching Services', '$e');
    }
  }

  Future<void> fetchEmployee() async {
    final shop = shopsInFirebase[selectedIndex.value];
    employeesInFirebase.clear();
    employeesIdInFirebase.clear();

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
    } catch (e) {
      log('Error fetching employees: $e');
      Get.snackbar('Error Fetching Employees', '$e');
    }
  }

  void calculateTimeAndPrice(BuildContext context, int index) {
    totalAmount.value = 0;
    totalTimeSlots.value = 0;

    for (String serviceName in services) {
      for (var service in servicesInFirebase) {
        if (service['serviceName'] == serviceName) {
          totalAmount += int.parse(service['servicePrice']);
          totalTimeSlots += service['serviceTime'];
        }
      }
    }

    Get.bottomSheet(
      isScrollControlled: true,
      Wrap(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
            ),
            child: FutureBuilder<List<String>>(
              future: calculateAvailableSlots(index, totalTimeSlots.value),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CupertinoActivityIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.data!.isEmpty) {
                  return const Center(child: Text('No available slots!'));
                } else {
                  return SizedBox(
                    height: 300, // Constrain the height or use Expanded.
                    child: ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(snapshot.data![index]),
                          onTap: () {
                            Get.snackbar(
                                'Selected Time Slot', snapshot.data![index]);
                          },
                        );
                      },
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<List<String>> calculateAvailableSlots(
      int index, int requiredBlocks) async {
    try {
      final employeeDoc = employeesInFirebase[index];

      TimeOfDay entryTime = employeeDoc['entryTime'];
      TimeOfDay exitTime = employeeDoc['exitTime'];
      List<dynamic>? exceptionList = employeeDoc['exceptionList'];

      exceptionList ??= [];

      DateTime now = DateTime.now();

      DateTime timeOfDayToDateTime(TimeOfDay time) {
        return DateTime(now.year, now.month, now.day, time.hour, time.minute);
      }

      DateTime entryDateTime = timeOfDayToDateTime(entryTime);
      DateTime exitDateTime = timeOfDayToDateTime(exitTime);

      List<DateTime> allSlots = [];
      DateTime currentSlot = entryDateTime;

      while (currentSlot.isBefore(exitDateTime)) {
        allSlots.add(currentSlot);
        currentSlot = currentSlot.add(Duration(minutes: 30));
      }

      List<DateTime> futureSlots =
          allSlots.where((slot) => slot.isAfter(now)).toList();

      List<DateTime> availableSlots = futureSlots.where((slot) {
        return !exceptionList!.any((exception) {
          DateTime exceptionStart = exception['start'].toDate();
          DateTime exceptionEnd = exception['end'].toDate();
          return slot.isAfter(exceptionStart.subtract(Duration(seconds: 1))) &&
              slot.isBefore(exceptionEnd.add(Duration(seconds: 1)));
        });
      }).toList();

      List<String> groupedSlots = [];
      for (int i = 0; i <= availableSlots.length - requiredBlocks; i++) {
        DateTime start = availableSlots[i];
        DateTime end = availableSlots[i + requiredBlocks - 1];

        if (end.difference(start).inMinutes == (requiredBlocks - 1) * 30) {
          groupedSlots.add(
              '${DateFormat('hh:mm a').format(start)} - ${DateFormat('hh:mm a').format(end.add(Duration(minutes: 30)))}');
        }
      }

      return groupedSlots;
    } catch (e) {
      log('Error calculating slots: $e');
      return [];
    }
  }

  void showCustomerData(BuildContext context) {
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
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      'Name:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Obx(
                      () => Text(customerName.value),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Text(
                      'Gender:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Obx(
                      () => Text(gender.value),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Text(
                      'Birth Date:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Obx(
                      () => Text(dob.value),
                    ),
                    Obx(
                      () => Text(' (~$age Years)'),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Text(
                      'Appointments till now:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Obx(
                      () => Text('${appointmentsIdInFirebase!.length}'),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                TextButton(
                  onPressed: () {
                    Get.defaultDialog(
                      title: 'Confirm Logout?',
                      titlePadding: const EdgeInsets.only(
                        top: 30,
                      ),
                      content: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10.0,
                          horizontal: 30.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                if (Get.isDialogOpen ?? false) {
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
                              child: const Text(
                                'No',
                                style: TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                await FirebaseAuth.instance.signOut();
                                Get.snackbar('Logged out',
                                    'You account is now logged out successfully!');
                                Get.offAllNamed('login_screen');
                              },
                              style: TextButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    12,
                                  ),
                                ),
                              ),
                              child: const Text(
                                'Logout',
                                style: TextStyle(
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout),
                      SizedBox(
                        width: 5,
                      ),
                      Text('Logout'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
