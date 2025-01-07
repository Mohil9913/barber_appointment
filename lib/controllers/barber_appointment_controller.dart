import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class BarberAppointmentController extends GetxController {
  String? barberId;

  RxString barberName = RxString('');
  RxString imageUrl = ''.obs;
  RxList barberShops = RxList([]);

  RxList shopsInFirebase = RxList();
  RxList shopsIdInFirebase = RxList();
  RxList appointmentsInFirebase = RxList();
  RxList appointmentsIdInFirebase = RxList();

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

  String formatFirebaseTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('d MMM yyyy').format(dateTime);
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

  Future<String> fetchCustomerName(String customerId) async {
    try {
      DocumentSnapshot customerDoc = await FirebaseFirestore.instance
          .collection('customer')
          .doc(customerId)
          .get();

      if (customerDoc.exists) {
        return customerDoc['customerName'];
      } else {
        return 'Customer DELETED';
      }
    } catch (e) {
      log('Error fetching customer name: $e');
      return 'Something went wrong';
    }
  }

  Future<void> fetchBarberDetails() async {
    if (FirebaseAuth.instance.currentUser == null) {
      Get.offAllNamed('/login_screen');
      return;
    }

    try {
      barberId = FirebaseAuth.instance.currentUser!.phoneNumber;

      DocumentSnapshot barberDoc = await FirebaseFirestore.instance
          .collection('barber')
          .doc(barberId)
          .get();

      if (barberDoc.exists) {
        barberName.value = barberDoc['barberName'] ?? 'Unknown';
        imageUrl.value = barberDoc['imageUrl'] ?? '';
        barberShops.value = barberDoc['shops'] ?? [];

        cacheProfileImage();
      } else {
        Get.offAllNamed('/login_screen');
      }
    } catch (e) {
      log('Error fetching barber details: $e');
      Get.snackbar(
          'Error', 'Failed to fetch barber details. Please try again.');
    }
  }

  Future<void> fetchAppointments() async {
    log('\n\n\nfetching appointments...');
    appointmentsInFirebase.value = [];
    appointmentsIdInFirebase.value = [];

    if (FirebaseAuth.instance.currentUser == null) {
      Get.offAllNamed('/login_screen');
      return;
    }

    try {
      await fetchBarberDetails();
      final firestore = FirebaseFirestore.instance;

      final futures = barberShops.map((shopId) {
        return firestore
            .collection('appointment')
            .where('shopId', isEqualTo: shopId)
            .get();
      }).toList();

      final results = await Future.wait(futures);

      for (var querySnapshot in results) {
        for (var doc in querySnapshot.docs) {
          appointmentsIdInFirebase.add(doc.id);
          appointmentsInFirebase.add(doc.data());
        }
      }
      appointmentsInFirebase.refresh();
      log('\n\nAppointments: $appointmentsInFirebase');
    } catch (e) {
      log('Error fetching appointments: $e');
      Get.snackbar('Error fetching appointments', '$e');
    }
  }

  Future<void> markCompleted(int index) async {
    final appointmentId = appointmentsIdInFirebase[index];

    Get.defaultDialog(
      barrierDismissible: false,
      title: 'Mark appointment as completed?',
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
                if (Get.isDialogOpen == true) {
                  Get.back();
                }
                try {
                  await FirebaseFirestore.instance
                      .collection('appointment')
                      .doc(appointmentId)
                      .update({"status": false}).then((_) {
                    fetchAppointments();
                  });
                } catch (e) {
                  Get.snackbar(
                      'Something went wrong', 'Please try again later');
                  log('$e');
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
                'Mark Completed',
                style: TextStyle(color: Colors.green),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showBarberData(BuildContext context) {
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
                            'assets/images/login_screen/barber.jpeg',
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
                      () => Text(barberName.value),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
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
                      () => Text('${appointmentsIdInFirebase.length}'),
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
