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
  RxList userAppointments = RxList([]);
  var isLoading = false.obs;

  RxList shopsInFirebase = RxList();
  RxList shopsIdInFirebase = RxList();
  RxList employeesInFirebase = RxList();
  RxList employeesIdInFirebase = RxList();
  RxList servicesInFirebase = RxList();
  RxList servicesIdInFirebase = RxList();
  RxList appointmentsInFirebase = RxList();
  RxList appointmentsIdInFirebase = RxList();

  RxInt selectedShopIndex = RxInt(0);
  RxInt selectedEmployeeIndex = RxInt(0);
  RxList<String> services = <String>[].obs;
  RxInt totalAmount = RxInt(0);
  RxInt totalTimeSlots = RxInt(0);

  // @override
  // void onInit() {
  //   fetchCustomerDetails();
  //   super.onInit();
  // }

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
      QuerySnapshot shopSnapshot = await FirebaseFirestore.instance
          .collection('shop')
          .where('status', isEqualTo: true)
          .get();
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
    final shop = shopsInFirebase[selectedShopIndex.value];
    servicesInFirebase.clear();
    servicesIdInFirebase.clear();

    try {
      for (String service in shop['services']) {
        DocumentSnapshot serviceDoc = await FirebaseFirestore.instance
            .collection('service')
            .doc(service)
            .get();

        if (serviceDoc.exists) {
          var serviceData = serviceDoc.data() as Map<String, dynamic>;
          if (serviceData != null && serviceData.isNotEmpty) {
            if (serviceData['serviceStatus'] == true) {
              servicesIdInFirebase.add(serviceDoc.id);
              servicesInFirebase.add(serviceData);
            }
          } else {
            log('Empty service data for service: $service');
          }
        } else {
          log('Service document not found for ID: $service');
        }
      }
    } catch (e) {
      log('Error fetching services: $e');
      Get.snackbar('Error Fetching Services', '$e');
    }
  }

  Future<void> fetchEmployee() async {
    final shop = shopsInFirebase[selectedShopIndex.value];
    employeesInFirebase.clear();
    employeesIdInFirebase.clear();

    try {
      QuerySnapshot employeeSnapshot = await FirebaseFirestore.instance
          .collection('employee')
          .where(FieldPath.documentId, whereIn: shop['employees'])
          .where('employeeStatus', isEqualTo: true)
          .get();

      for (var doc in employeeSnapshot.docs) {
        var employeeData = doc.data() as Map<String, dynamic>;

        employeesIdInFirebase.add(doc.id);

        // Convert entry and exit time strings to TimeOfDay
        if (employeeData['entryTime'] is String) {
          employeeData['entryTime'] =
              stringToTimeOfDay(employeeData['entryTime']);
        }

        if (employeeData['exitTime'] is String) {
          employeeData['exitTime'] =
              stringToTimeOfDay(employeeData['exitTime']);
        }

        employeesInFirebase.add(employeeData);
      }
    } catch (e) {
      log('Error fetching employees: $e');
      Get.snackbar('Error Fetching Employees', '$e');
    }
  }

  Future<String> fetchShopName(String shopId) async {
    try {
      DocumentSnapshot shopDoc =
          await FirebaseFirestore.instance.collection('shop').doc(shopId).get();

      if (shopDoc.exists) {
        return shopDoc['name'];
      } else {
        return 'SHOP DELETED';
      }
    } catch (e) {
      log('Error fetching shop name: $e');
      return 'Something went wrong';
    }
  }

  Future<String> fetchEmployeeName(String employeeId) async {
    try {
      DocumentSnapshot employeeDoc = await FirebaseFirestore.instance
          .collection('employee')
          .doc(employeeId)
          .get();

      if (employeeDoc.exists) {
        return employeeDoc['employeeName'];
      } else {
        return 'Employee DELETED';
      }
    } catch (e) {
      log('Error fetching employee name: $e');
      return 'Something went wrong';
    }
  }

  String formatFirebaseTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('d MMM yyyy').format(dateTime);
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
        imageUrl.value = customerDoc['imageUrl'] ?? '';
        gender.value = customerDoc['customerGender'] ?? 'Unknown';
        userAppointments.value = customerDoc['appointments'] ?? [];

        if (customerDoc['customerDOB'] != null) {
          DateTime birthDate = customerDoc['customerDOB'].toDate();
          dob.value = DateFormat('d MMM yyyy').format(birthDate);
          age.value = calculateAge(birthDate);
        }

        cacheProfileImage();
      } else {
        Get.offAllNamed('/login_screen');
      }
    } catch (e) {
      log('Error fetching customer details: $e');
      Get.snackbar(
          'Error', 'Failed to fetch customer details. Please try again.');
    }
  }

  Future<void> fetchAppointments() async {
    if (FirebaseAuth.instance.currentUser == null) {
      Get.offAllNamed('/login_screen');
      return;
    }

    try {
      await fetchCustomerDetails();

      if (userAppointments.isEmpty) {
        log('No appointments found.');
        return;
      }

      QuerySnapshot appointmentsSnapshot = await FirebaseFirestore.instance
          .collection('appointment')
          .where(FieldPath.documentId, whereIn: userAppointments)
          .get();

      appointmentsInFirebase.clear();
      appointmentsIdInFirebase.clear();

      for (var appointmentDoc in appointmentsSnapshot.docs) {
        appointmentsIdInFirebase.add(appointmentDoc.id);
        var appointmentData = appointmentDoc.data() as Map<String, dynamic>;
        appointmentsInFirebase.add(appointmentData);
      }

      log('Appointments fetched successfully.');
    } catch (e) {
      log('Error fetching appointments: $e');
      Get.snackbar('Error', 'Failed to fetch appointments. Please try again.');
    }
  }

  Future<void> createAppointment({
    required String shopId,
    required String employeeId,
    required String timeSlot,
  }) async {
    isLoading.value = true;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    WriteBatch batch = firestore.batch();

    String? appointmentId;
    bool customerUpdated = false;
    bool shopUpdated = false;
    bool employeeUpdated = false;
    DateTime? from;
    DateTime? to;

    try {
      customerId = FirebaseAuth.instance.currentUser!.phoneNumber;
      DateTime currentDate = DateTime.now();

      DocumentReference appointmentRef =
          firestore.collection('appointment').doc();
      appointmentId = appointmentRef.id;

      batch.set(appointmentRef, {
        'status': true,
        'shopId': shopId,
        'employeeId': employeeId,
        'customerId': customerId,
        'services': services,
        'date': Timestamp.fromDate(currentDate),
        'timeSlot': timeSlot,
        'amount': totalAmount.value,
      });

      DocumentReference customerRef =
          firestore.collection('customer').doc(customerId);
      batch.update(customerRef, {
        'appointments': FieldValue.arrayUnion([appointmentId]),
      });
      customerUpdated = true;

      DocumentReference shopRef = firestore.collection('shop').doc(shopId);
      batch.update(shopRef, {
        'appointments': FieldValue.arrayUnion([appointmentId]),
        'customer': FieldValue.arrayUnion([customerId]),
      });
      shopUpdated = true;

      List<String> timeRange = timeSlot.split(' - ');
      DateTime fromTime = DateFormat('hh:mm a').parse(timeRange[0]);
      DateTime toTime = DateFormat('hh:mm a').parse(timeRange[1]);
      from = DateTime(currentDate.year, currentDate.month, currentDate.day,
          fromTime.hour, fromTime.minute);
      to = DateTime(currentDate.year, currentDate.month, currentDate.day,
          toTime.hour, toTime.minute);

      DocumentReference employeeRef =
          firestore.collection('employee').doc(employeeId);
      batch.update(employeeRef, {
        'exceptions': FieldValue.arrayUnion([
          {
            'type': 'appointment',
            'date': Timestamp.fromDate(currentDate),
            'from': Timestamp.fromDate(from),
            'to': Timestamp.fromDate(to),
          }
        ]),
      });
      employeeUpdated = true;

      await batch.commit();

      Get.snackbar('Appointment Booked',
          'Your appointment has been successfully booked!');
      isLoading.value = false;
      services.clear();
      Get.offAllNamed('/customer_home');
    } catch (e) {
      try {
        if (appointmentId != null) {
          await firestore.collection('appointment').doc(appointmentId).delete();
        }
        if (customerUpdated) {
          await firestore.collection('customer').doc(customerId).update({
            'appointments': FieldValue.arrayRemove([appointmentId]),
          });
        }
        if (shopUpdated) {
          await firestore.collection('shop').doc(shopId).update({
            'appointments': FieldValue.arrayRemove([appointmentId]),
            'customers': FieldValue.arrayRemove([customerId]),
          });
        }
        if (employeeUpdated) {
          DocumentReference employeeRef =
              firestore.collection('employee').doc(employeeId);
          DocumentSnapshot employeeSnapshot = await employeeRef.get();
          if (employeeSnapshot.exists) {
            List<dynamic> exceptions = employeeSnapshot['exceptions'] ?? [];
            List<Map<String, dynamic>> updatedExceptions = exceptions
                .map((exception) => exception as Map<String, dynamic>)
                .where((exception) =>
                    exception['from'] != Timestamp.fromDate(from!))
                .toList();

            await employeeRef.update({'exceptions': updatedExceptions});
          }
        }
        isLoading.value = false;
      } catch (rollbackError) {
        log('Rollback Error: $rollbackError');
        isLoading.value = false;
      }
      log('Error creating appointment: $e');
      Get.snackbar('Error', 'Could not create the appointment: $e');
      isLoading.value = false;
    }
  }

  void appointmentSummaryDialog(BuildContext context, String shopName,
      String employeeName, String timeSlot) {
    Get.defaultDialog(
      title: 'Appointment Details',
      titlePadding: const EdgeInsets.only(
        top: 30,
      ),
      content: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 10.0,
          horizontal: 30.0,
        ),
        child: Column(
          children: [
            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  const TextSpan(text: 'Book you appointment at '),
                  TextSpan(
                    text: shopName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const TextSpan(text: ' with '),
                  TextSpan(
                    text: employeeName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const TextSpan(text: ' for '),
                  TextSpan(
                    text: services.join(', '),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const TextSpan(text: ' at '),
                  TextSpan(
                    text: '$timeSlot.',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const TextSpan(text: '\n\nTotal Amount: '),
                  TextSpan(
                    text: '$totalAmount',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Row(
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
                    'Cancel',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    if (Get.isDialogOpen ?? false) {
                      Get.back();
                    }
                    createAppointment(
                      shopId: shopsIdInFirebase[selectedShopIndex.value],
                      employeeId:
                          employeesIdInFirebase[selectedEmployeeIndex.value],
                      timeSlot: timeSlot,
                    );
                  },
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        12,
                      ),
                    ),
                  ),
                  child: const Text(
                    'Book Appointment',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void calculateTimeAndPrice(BuildContext context, int employeeIndex) {
    selectedEmployeeIndex.value = employeeIndex;
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
              future: calculateAvailableSlots(totalTimeSlots.value),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CupertinoActivityIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.data!.isEmpty) {
                  return const Center(child: Text('No available slots!'));
                } else {
                  return Column(
                    children: [
                      Text('Select Time Slot',
                          style: Theme.of(context).textTheme.headlineSmall),
                      Divider(),
                      SizedBox(
                        height: 350,
                        child: Scrollbar(
                          child: ListView.builder(
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(snapshot.data![index]),
                                onTap: () {
                                  Get.back();
                                  appointmentSummaryDialog(
                                    context,
                                    shopsInFirebase[selectedShopIndex.value]
                                        ['name'],
                                    employeesInFirebase[employeeIndex]
                                        ['employeeName'],
                                    snapshot.data![index],
                                  );
                                },
                              );
                            },
                          ),
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

  Future<List<String>> calculateAvailableSlots(int requiredBlocks) async {
    try {
      final employeeDoc = employeesInFirebase[selectedEmployeeIndex.value];

      TimeOfDay entryTime = employeeDoc['entryTime'];
      TimeOfDay exitTime = employeeDoc['exitTime'];
      List<dynamic>? exceptionList = employeeDoc['exceptions'];

      exceptionList ??= [];

      DateTime now = DateTime.now();

      DateTime timeOfDayToDateTime(TimeOfDay time) {
        return DateTime(now.year, now.month, now.day, time.hour, time.minute);
      }

      DateTime entryDateTime = timeOfDayToDateTime(entryTime);
      DateTime exitDateTime = timeOfDayToDateTime(exitTime);

      // Generate all possible time slots within entry and exit times
      List<DateTime> allSlots = [];
      DateTime currentSlot = entryDateTime;
      while (currentSlot.isBefore(exitDateTime)) {
        allSlots.add(currentSlot);
        currentSlot = currentSlot.add(Duration(minutes: 30));
      }

      // Filter for future slots only
      List<DateTime> futureSlots =
          allSlots.where((slot) => slot.isAfter(now)).toList();

      // Sort exception list by 'from' time
      exceptionList.sort((a, b) {
        DateTime fromA = a['from'].toDate();
        DateTime fromB = b['from'].toDate();
        return fromA.compareTo(fromB);
      });

      List<DateTime> unavailableSlots = [];

      // Process all exceptions and mark the unavailable slots
      for (var exception in exceptionList) {
        DateTime exceptionStart = exception['from'].toDate();
        DateTime exceptionEnd = exception['to'].toDate();

        if (exception['type'] == 'appointment') {
          // For 'appointment' type, block out the time range
          DateTime currentSlot = exceptionStart;
          while (currentSlot.isBefore(exceptionEnd)) {
            unavailableSlots.add(currentSlot);
            currentSlot = currentSlot.add(Duration(minutes: 30));
          }
        }
      }

      // Remove unavailable slots from the list of available slots
      List<DateTime> availableSlots = futureSlots.where((slot) {
        return !unavailableSlots.contains(slot);
      }).toList();

      List<String> groupedSlots = [];

      // Group available slots into the required blocks of time
      for (int i = 0; i <= availableSlots.length - requiredBlocks; i++) {
        DateTime start = availableSlots[i];
        DateTime end = availableSlots[i + requiredBlocks - 1];

        // Only add slots if the difference between start and end is equal to required blocks
        if (end.difference(start).inMinutes == (requiredBlocks - 1) * 30) {
          groupedSlots.add(
            '${DateFormat('hh:mm a').format(start)} - ${DateFormat('hh:mm a').format(end.add(Duration(minutes: 30)))}',
          );
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
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.purpleAccent.withValues(alpha: 0.3),
                      width: 4,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 80,
                    backgroundImage: imageUrl.value == ''
                        ? AssetImage(
                            'assets/images/login_screen/customer.jpeg',
                          )
                        : CachedNetworkImageProvider(
                            imageUrl.value,
                          ),
                  ),
                ),
                Divider(),
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
