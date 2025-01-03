import 'dart:developer';

import 'package:barber_appointment/controllers/manage_shop_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

class ShopsController extends GetxController {
  String? barberId;

  final ManageShopController manageShopController =
      Get.find<ManageShopController>();

  var skills = [].obs;
  RxString latitude = ''.obs;
  RxString longitude = ''.obs;
  RxInt serviceTime = 0.obs;
  RxList services = RxList();
  RxList employees = RxList();
  RxList shops = RxList();
  Rx<TimeOfDay?> employeeEntryTime = Rx<TimeOfDay?>(null);
  Rx<TimeOfDay?> employeeExitTime = Rx<TimeOfDay?>(null);
  var isLoading = false.obs;

  final TextEditingController shopNameController = TextEditingController();
  final TextEditingController employeeNameController = TextEditingController();
  final TextEditingController serviceNameController = TextEditingController();
  final TextEditingController servicePriceController = TextEditingController();

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

  void confirmDeleteService(BuildContext context, int index) {
    Get.defaultDialog(
      barrierDismissible: false,
      title: 'Delete ${services[index]['serviceName']}?',
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
              onPressed: () {
                if (Get.isDialogOpen == true) {
                  Get.back();
                }
                services.removeAt(index);
              },
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    12,
                  ),
                ),
              ),
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void addServiceBottomSheet(BuildContext context) {
    Get.bottomSheet(
      isScrollControlled: false,
      isDismissible: false,
      enableDrag: false,
      Container(
        margin: EdgeInsets.only(top: 50),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Add Service',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextField(
                  controller: serviceNameController,
                  decoration: InputDecoration(
                    label: Text(
                      'Service Name',
                    ),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                TextField(
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  controller: servicePriceController,
                  decoration: InputDecoration(
                    label: Text(
                      'Service Price ₹',
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Text("Select time slots for service. [1 slot = 30 Minutes]"),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    TextButton(
                        onPressed: () {
                          if (serviceTime.value > 0) {
                            serviceTime.value--;
                          }
                        },
                        child: Icon(CupertinoIcons.minus)),
                    SizedBox(
                      width: 10,
                    ),
                    Obx(() => Text('${serviceTime.value}')),
                    SizedBox(
                      width: 10,
                    ),
                    TextButton(
                        onPressed: () {
                          serviceTime.value++;
                        },
                        child: Icon(CupertinoIcons.plus)),
                  ],
                ),
                SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Get.back();
                        serviceNameController.text = '';
                        servicePriceController.text = '';
                        serviceTime.value = 0;
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
                      onPressed: () {
                        if (serviceNameController.text.trim().isEmpty) {
                          Get.snackbar(
                              'Provide Name', 'Service must have a name!');
                          return;
                        }
                        if (servicePriceController.text.trim().isEmpty ||
                            int.parse(servicePriceController.text) < 0) {
                          Get.snackbar(
                              'Invalid Price', 'Please enter a valid price!');
                          return;
                        }
                        if (serviceTime.value < 1) {
                          Get.snackbar('Time slots can\'t be 0',
                              'Please select required timeslots !');
                          return;
                        }
                        Get.back();

                        services.add({
                          "serviceStatus": true,
                          "serviceName": serviceNameController.text.trim(),
                          "servicePrice": servicePriceController.text.trim(),
                          "serviceTime": serviceTime.value,
                        });
                        serviceNameController.text = '';
                        servicePriceController.text = '';
                        serviceTime.value = 0;
                      },
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            12,
                          ),
                        ),
                      ),
                      child: Text(
                        'Add Service',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void editServiceBottomSheet(BuildContext context, int index) {
    serviceNameController.text = services[index]['serviceName'];
    servicePriceController.text = services[index]['servicePrice'];
    serviceTime.value = services[index]['serviceTime'];

    Get.bottomSheet(
      isScrollControlled: false,
      isDismissible: false,
      enableDrag: false,
      Container(
        margin: EdgeInsets.only(top: 50),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Text(
                  'Edit ${services[index]['serviceName']}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextField(
                  controller: serviceNameController,
                  decoration: InputDecoration(
                    label: Text(
                      'Service Name',
                    ),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                TextField(
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  controller: servicePriceController,
                  decoration: InputDecoration(
                    label: Text(
                      'Service Price ₹',
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Text("Select time slots for service. [1 slot = 30 Minutes]"),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    TextButton(
                        onPressed: () {
                          if (serviceTime.value > 0) {
                            serviceTime.value--;
                          }
                        },
                        child: Icon(CupertinoIcons.minus)),
                    SizedBox(
                      width: 10,
                    ),
                    Obx(() => Text('${serviceTime.value}')),
                    SizedBox(
                      width: 10,
                    ),
                    TextButton(
                        onPressed: () {
                          serviceTime.value++;
                        },
                        child: Icon(CupertinoIcons.plus)),
                  ],
                ),
                SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Get.back();
                        serviceNameController.text = '';
                        servicePriceController.text = '';
                        serviceTime.value = 0;
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
                      onPressed: () {
                        if (serviceNameController.text.trim().isEmpty) {
                          Get.snackbar(
                              'Provide Name', 'Service must have a name!');
                          return;
                        }
                        if (servicePriceController.text.trim().isEmpty ||
                            int.parse(servicePriceController.text) < 0) {
                          Get.snackbar(
                              'Invalid Price', 'Please enter a valid price!');
                          return;
                        }
                        if (serviceTime.value < 1) {
                          Get.snackbar('Time slots can\'t be 0',
                              'Please select required timeslots !');
                          return;
                        }
                        Get.back();

                        services[index] = {
                          "serviceStatus": true,
                          "serviceName": serviceNameController.text.trim(),
                          "servicePrice": servicePriceController.text.trim(),
                          "serviceTime": serviceTime.value,
                        };
                        serviceNameController.text = '';
                        servicePriceController.text = '';
                        serviceTime.value = 0;
                      },
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            12,
                          ),
                        ),
                      ),
                      child: Text(
                        'Update Service',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void confirmDeleteEmployee(BuildContext context, int index) {
    Get.defaultDialog(
      barrierDismissible: false,
      title: 'Delete ${employees[index]['employeeName']}?',
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
              onPressed: () {
                if (Get.isDialogOpen == true) {
                  Get.back();
                }
                employees.removeAt(index);
              },
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    12,
                  ),
                ),
              ),
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void addEmployeeBottomSheet(BuildContext context) {
    Get.bottomSheet(
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      Container(
        margin: EdgeInsets.only(top: 50),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Add Employee',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextField(
                  controller: employeeNameController,
                  decoration: InputDecoration(
                    label: Text('Employee Name'),
                  ),
                ),
                SizedBox(height: 10),
                Obx(() {
                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white30),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Text('Specialized in?'),
                        SizedBox(height: 5),
                        Column(
                          children: List.generate(
                            services.length,
                            (index) {
                              final service = services[index];
                              return CheckboxListTile(
                                value: checkSkills(service['serviceName']),
                                onChanged: (value) {
                                  toggleSkills(service['serviceName']);
                                },
                                title: Text(service['serviceName']),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                SizedBox(height: 10),
                Obx(() {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ElevatedButton(
                        onPressed: () => pickEntryTime(context),
                        child: const Icon(CupertinoIcons.clock),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        employeeEntryTime.value == null
                            ? 'Select entry time'
                            : 'Entry: ${employeeEntryTime.value!.format(context)}',
                      ),
                    ],
                  );
                }),
                SizedBox(height: 5),
                Obx(() {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ElevatedButton(
                        onPressed: () => pickExitTime(context),
                        child: const Icon(CupertinoIcons.clock),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        employeeExitTime.value == null
                            ? 'Select exit time'
                            : 'Exit: ${employeeExitTime.value!.format(context)}',
                      ),
                    ],
                  );
                }),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Get.back();
                        employeeNameController.text = '';
                        skills.clear();
                        employeeEntryTime.value = null;
                        employeeExitTime.value = null;
                      },
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        if (employeeNameController.text.trim().isEmpty) {
                          Get.snackbar(
                              'Provide Name', 'Employee must have a name!');
                          return;
                        }
                        if (employeeEntryTime.value == null ||
                            employeeExitTime.value == null) {
                          Get.snackbar('Time not Provided',
                              'Please provide employee entry and exit time!');
                          return;
                        }
                        if (employeeEntryTime.value!.hour >
                                employeeExitTime.value!.hour ||
                            (employeeEntryTime.value!.hour ==
                                    employeeExitTime.value!.hour &&
                                employeeEntryTime.value!.minute >=
                                    employeeExitTime.value!.minute)) {
                          Get.snackbar('Please verify time',
                              'Entry time should be smaller than Exit time!');
                          return;
                        }

                        employees.add({
                          "employeeStatus": true,
                          "employeeName": employeeNameController.text.trim(),
                          "skills": skills.toList(),
                          "entryTime": employeeEntryTime.value,
                          "exitTime": employeeExitTime.value,
                        });

                        Get.back();
                        employeeNameController.text = '';
                        skills.clear();
                        employeeEntryTime.value = null;
                        employeeExitTime.value = null;
                      },
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text('Add Employee'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void editEmployeeBottomSheet(BuildContext context, int index) {
    employeeNameController.text = employees[index]['employeeName'];
    skills.value = employees[index]['skills'];
    employeeEntryTime.value = employees[index]['entryTime'];
    employeeExitTime.value = employees[index]['exitTime'];

    Get.bottomSheet(
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      Container(
        margin: EdgeInsets.only(top: 50),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Text(
                  'Edit ${employees[index]['employeeName']}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextField(
                  controller: employeeNameController,
                  decoration: InputDecoration(
                    label: Text(
                      'Employee Name',
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Obx(
                  () => Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      border: Border.all(color: Colors.white30),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Text('Specialized in?'),
                        SizedBox(
                          height: 5,
                        ),
                        Column(
                          children: List.generate(
                            services.length,
                            (index) {
                              final service = services[index];
                              return CheckboxListTile(
                                value: checkSkills(service['serviceName']),
                                onChanged: (value) {
                                  toggleSkills(service['serviceName']);
                                },
                                title: Text(service['serviceName']),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Obx(() {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ElevatedButton(
                        onPressed: () => pickEntryTime(context),
                        child: const Icon(CupertinoIcons.clock),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        employeeEntryTime.value == null
                            ? 'Select entry time'
                            : 'Entry: ${employeeEntryTime.value!.format(context)}',
                      ),
                    ],
                  );
                }),
                SizedBox(
                  height: 5,
                ),
                Obx(() {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ElevatedButton(
                        onPressed: () => pickExitTime(context),
                        child: const Icon(CupertinoIcons.clock),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        employeeExitTime.value == null
                            ? 'Select exit time'
                            : 'Exit: ${employeeExitTime.value!.format(context)}',
                      ),
                    ],
                  );
                }),
                SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Get.back();
                        employeeNameController.text = '';
                        skills.clear();
                        employeeEntryTime.value = null;
                        employeeExitTime.value = null;
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
                      onPressed: () {
                        if (employeeNameController.text.trim().isEmpty) {
                          Get.snackbar(
                              'Provide Name', 'Employee must have a name!');
                          return;
                        }
                        if (employeeEntryTime.value == null ||
                            employeeExitTime.value == null) {
                          Get.snackbar('Time not Provided',
                              'Please provide employee entry and exit time!');
                          return;
                        }
                        if (employeeEntryTime.value!.hour >
                                employeeExitTime.value!.hour ||
                            (employeeEntryTime.value!.hour ==
                                    employeeExitTime.value!.hour &&
                                employeeEntryTime.value!.minute >=
                                    employeeExitTime.value!.minute)) {
                          Get.snackbar('Please verify time',
                              'Entry time should be smaller than Exit time!');
                          return;
                        }
                        Get.back();
                        employees[index] = {
                          "employeeStatus": true,
                          "employeeName": employeeNameController.text.trim(),
                          "skills": skills.toList(),
                          "entryTime": employeeEntryTime.value,
                          "exitTime": employeeExitTime.value,
                        };
                        employeeNameController.text = '';
                        skills.clear();
                        employeeEntryTime.value = null;
                        employeeExitTime.value = null;
                      },
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            12,
                          ),
                        ),
                      ),
                      child: Text(
                        'Update',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> createShopAndAddData(String? shopId) async {
    isLoading.value = true;
    barberId = FirebaseAuth.instance.currentUser!.phoneNumber;
    final shopName = shopNameController.text;
    List<String> serviceIds = [];
    List<String> employeeIds = [];
    DocumentReference? shopRef;

    try {
      if (shopId != null && shopId.isNotEmpty) {
        //when shop under update, just modify few data items in existing shop - excluding customers and appointments data
        shopRef = FirebaseFirestore.instance.collection('shop').doc(shopId);

        await shopRef.update({
          'employees': [],
          'services': [],
          'location': {"lat": latitude.value, "long": longitude.value},
          'name': shopName,
        });
      } else {
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

        //create doc for new shop in shop collection
        shopRef =
            await FirebaseFirestore.instance.collection('shop').add(shopData);

        await FirebaseFirestore.instance
            .collection('barber')
            .doc(barberId)
            .update({
          "shops": FieldValue.arrayUnion([shopRef.id])
        });
      }

      //create services in service collection and append ids to local list
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

      //create employees in employee collection and append ids to local list
      for (var employee in employees) {
        final employeeData = {
          "employeeName": employee['employeeName'],
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

      //append services & employees ids to shop lists
      await FirebaseFirestore.instance
          .collection('shop')
          .doc(shopRef.id)
          .update({
        "services": FieldValue.arrayUnion(serviceIds),
        "employees": FieldValue.arrayUnion(employeeIds)
      });

      Get.offAllNamed('/barber_home');
      Get.snackbar(
          shopId != null
              ? '$shopName updated successfully'
              : '$shopName created successfully',
          'Your shop with all services and employees is now listed!');
    } catch (e, stackTrace) {
      //if updating shop goes wrong, updates made on shop will be reverted
      if (shopId != null && shopId.isNotEmpty && shopRef != null) {
        await shopRef.update({
          'name': manageShopController.currentName,
          'employees': manageShopController.currentEmployees,
          'services': manageShopController.currentServices,
          'location': {
            "lat": manageShopController.currentLat,
            "long": manageShopController.currentLong
          },
        });
      }

      //delete partially created shop and data linked to it
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

      //removes partially created services
      for (var serviceId in serviceIds) {
        await FirebaseFirestore.instance
            .collection('service')
            .doc(serviceId)
            .delete();
      }

      //removes partially created employees
      for (var employeeId in employeeIds) {
        await FirebaseFirestore.instance
            .collection('employee')
            .doc(employeeId)
            .delete();
      }

      log('Error: $e\n\nStacktrace: $stackTrace');
      Get.snackbar(
          shopId != null ? 'Error Updating Shop' : 'Error Creating Shop', '$e');
    } finally {
      isLoading.value = false;
      manageShopController.currentId = '';
      manageShopController.currentName = '';
      manageShopController.currentEmployees = [];
      manageShopController.currentServices = [];
      manageShopController.currentLat = '';
      manageShopController.currentLong = '';
    }
  }
}
