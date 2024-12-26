import 'dart:developer';

import 'package:barber_appointment/controllers/shops_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class AddShop extends StatelessWidget {
  AddShop({super.key});

  final ShopsController shopsController = Get.put(ShopsController());

  final TextEditingController shopNameController = TextEditingController();
  final TextEditingController employeeNameController = TextEditingController();
  final TextEditingController serviceNameController = TextEditingController();
  final TextEditingController servicePriceController = TextEditingController();
  final TextEditingController serviceTimeController = TextEditingController();

  void confirmDeleteService(BuildContext context, int index) {
    Get.defaultDialog(
      barrierDismissible: false,
      title: 'Delete ${shopsController.services[index]['serviceName']}?',
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
                shopsController.services.removeAt(index);
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
                TextField(
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  controller: serviceTimeController,
                  decoration: InputDecoration(
                    label: Text(
                      'Minutes Required',
                    ),
                  ),
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
                        serviceTimeController.text = '';
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
                        if (serviceTimeController.text.trim().isEmpty ||
                            int.parse(serviceTimeController.text) < 1) {
                          Get.snackbar(
                              'Invalid Time', 'Please enter a valid !');
                          return;
                        }
                        Get.back();

                        shopsController.services.add({
                          "serviceStatus": true,
                          "serviceName": serviceNameController.text.trim(),
                          "servicePrice": servicePriceController.text.trim(),
                          "serviceTime": shopsController.calculateTimeSlots(
                              int.parse(serviceTimeController.text.trim())),
                        });
                        serviceNameController.text = '';
                        servicePriceController.text = '';
                        serviceTimeController.text = '';
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
    serviceNameController.text = shopsController.services[index]['serviceName'];
    servicePriceController.text =
        shopsController.services[index]['servicePrice'];

    final serviceTime = shopsController.services[index]['serviceTime'];
    if (serviceTime is int) {
      serviceTimeController.text = (30 * serviceTime).toString();
    } else if (serviceTime is String) {
      serviceTimeController.text = (30 * int.parse(serviceTime)).toString();
    } else {
      serviceTimeController.text = '0';
    }

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
                  'Edit ${shopsController.services[index]['serviceName']}',
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
                TextField(
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  controller: serviceTimeController,
                  decoration: InputDecoration(
                    label: Text(
                      'Minutes Required',
                    ),
                  ),
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
                        serviceTimeController.text = '';
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
                        if (serviceTimeController.text.trim().isEmpty ||
                            int.parse(serviceTimeController.text) < 1) {
                          Get.snackbar(
                              'Invalid Time', 'Please enter a valid !');
                          return;
                        }

                        Get.back();

                        shopsController.services[index] = {
                          "serviceStatus": true,
                          "serviceName": serviceNameController.text.trim(),
                          "servicePrice": servicePriceController.text.trim(),
                          "serviceTime": shopsController.calculateTimeSlots(
                              int.parse(serviceTimeController.text.trim())),
                        };
                        serviceNameController.text = '';
                        servicePriceController.text = '';
                        serviceTimeController.text = '';
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
      title: 'Delete ${shopsController.employees[index]['employeeName']}?',
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
                shopsController.employees.removeAt(index);
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
                            shopsController.services.length,
                            (index) {
                              final service = shopsController.services[index];
                              return CheckboxListTile(
                                value: shopsController
                                    .checkSkills(service['serviceName']),
                                onChanged: (value) {
                                  shopsController
                                      .toggleSkills(service['serviceName']);
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
                        onPressed: () => shopsController.pickEntryTime(context),
                        child: const Icon(CupertinoIcons.clock),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        shopsController.employeeEntryTime.value == null
                            ? 'Select entry time'
                            : 'Entry: ${shopsController.employeeEntryTime.value!.format(context)}',
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
                        onPressed: () => shopsController.pickExitTime(context),
                        child: const Icon(CupertinoIcons.clock),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        shopsController.employeeExitTime.value == null
                            ? 'Select exit time'
                            : 'Exit: ${shopsController.employeeExitTime.value!.format(context)}',
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
                        shopsController.skills.clear();
                        shopsController.employeeEntryTime.value = null;
                        shopsController.employeeExitTime.value = null;
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
                        if (shopsController.employeeEntryTime.value == null ||
                            shopsController.employeeExitTime.value == null) {
                          Get.snackbar('Time not Provided',
                              'Please provide employee entry and exit time!');
                          return;
                        }
                        if (shopsController.employeeEntryTime.value!.hour >
                                shopsController.employeeExitTime.value!.hour ||
                            (shopsController.employeeEntryTime.value!.hour ==
                                    shopsController
                                        .employeeExitTime.value!.hour &&
                                shopsController
                                        .employeeEntryTime.value!.minute >=
                                    shopsController
                                        .employeeExitTime.value!.minute)) {
                          Get.snackbar('Please verify time',
                              'Entry time should be smaller than Exit time!');
                          return;
                        }

                        shopsController.employees.add({
                          "employeeStatus": true,
                          "employeeName": employeeNameController.text.trim(),
                          "skills": shopsController.skills.toList(),
                          "entryTime": shopsController.employeeEntryTime.value,
                          "exitTime": shopsController.employeeExitTime.value,
                        });

                        Get.back();
                        employeeNameController.text = '';
                        shopsController.skills.clear();
                        shopsController.employeeEntryTime.value = null;
                        shopsController.employeeExitTime.value = null;
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
    employeeNameController.text =
        shopsController.employees[index]['employeeName'];
    shopsController.skills.value = shopsController.employees[index]['skills'];
    shopsController.employeeEntryTime.value =
        shopsController.employees[index]['entryTime'];
    shopsController.employeeExitTime.value =
        shopsController.employees[index]['exitTime'];

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
                  'Edit ${shopsController.employees[index]['employeeName']}',
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
                            shopsController.services.length,
                            (index) {
                              final service = shopsController.services[index];
                              return CheckboxListTile(
                                value: shopsController
                                    .checkSkills(service['serviceName']),
                                onChanged: (value) {
                                  shopsController
                                      .toggleSkills(service['serviceName']);
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
                        onPressed: () => shopsController.pickEntryTime(context),
                        child: const Icon(CupertinoIcons.clock),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        shopsController.employeeEntryTime.value == null
                            ? 'Select entry time'
                            : 'Entry: ${shopsController.employeeEntryTime.value!.format(context)}',
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
                        onPressed: () => shopsController.pickExitTime(context),
                        child: const Icon(CupertinoIcons.clock),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        shopsController.employeeExitTime.value == null
                            ? 'Select exit time'
                            : 'Exit: ${shopsController.employeeExitTime.value!.format(context)}',
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
                        shopsController.skills.clear();
                        shopsController.employeeEntryTime.value = null;
                        shopsController.employeeExitTime.value = null;
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
                        if (shopsController.employeeEntryTime.value == null ||
                            shopsController.employeeExitTime.value == null) {
                          Get.snackbar('Time not Provided',
                              'Please provide employee entry and exit time!');
                          return;
                        }
                        if (shopsController.employeeEntryTime.value!.hour >
                                shopsController.employeeExitTime.value!.hour ||
                            (shopsController.employeeEntryTime.value!.hour ==
                                    shopsController
                                        .employeeExitTime.value!.hour &&
                                shopsController
                                        .employeeEntryTime.value!.minute >=
                                    shopsController
                                        .employeeExitTime.value!.minute)) {
                          Get.snackbar('Please verify time',
                              'Entry time should be smaller than Exit time!');
                          return;
                        }
                        Get.back();
                        shopsController.employees[index] = {
                          "employeeStatus": true,
                          "employeeName": employeeNameController.text.trim(),
                          "skills": shopsController.skills.toList(),
                          "entryTime": shopsController.employeeEntryTime.value,
                          "exitTime": shopsController.employeeExitTime.value,
                        };
                        employeeNameController.text = '';
                        shopsController.skills.clear();
                        shopsController.employeeEntryTime.value = null;
                        shopsController.employeeExitTime.value = null;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('List your shop'),
      ),
      body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Card(
                  child: Obx(
                    () => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: Text(
                              textAlign: TextAlign.center,
                              softWrap: true,
                              // overflow: TextOverflow.ellipsis,
                              // maxLines: 4,
                              shopsController.longitude.value.trim().isEmpty
                                  ? 'Please fetch current location as shop location'
                                  : 'Location Fetched\n${shopsController.latitude.value} - ${shopsController.longitude.value}',
                            ),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  12,
                                ),
                              ),
                            ),
                            onPressed: () {
                              shopsController.fetchLocation();
                            },
                            child: shopsController.isLoading.value
                                ? CupertinoActivityIndicator()
                                : Text(
                                    'Fetch Location',
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                TextField(
                  controller: shopNameController,
                  decoration: InputDecoration(
                    label: Text(
                      'Shop Name',
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    border: Border.all(
                      color: Colors.white30,
                    ),
                    borderRadius: BorderRadius.circular(
                      20,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Obx(
                          () => Text(
                            shopsController.employees.isEmpty
                                ? 'Add Services to shop'
                                : 'Services in shop',
                          ),
                        ),
                        IgnorePointer(
                          ignoring: shopsController.isLoading.value,
                          child: Container(
                            margin: EdgeInsets.only(
                              top: 10,
                            ),
                            child: Obx(
                              () => Column(
                                children: [
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: shopsController.services.length,
                                    itemBuilder: (context, index) {
                                      final service =
                                          shopsController.services[index];
                                      return Card(
                                        child: ListTile(
                                          leading: Checkbox(
                                            value: service['serviceStatus'],
                                            onChanged: (value) {
                                              shopsController
                                                  .toggleService(index);
                                            },
                                          ),
                                          title: Text(
                                            service['serviceName'],
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          subtitle: Text(
                                              '₹${service['servicePrice']}\nTime Slots: ${service['serviceTime']}'),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: Icon(
                                                  Icons.edit,
                                                  color: Colors.blue,
                                                ),
                                                onPressed: () {
                                                  editServiceBottomSheet(
                                                      context, index);
                                                },
                                              ),
                                              IconButton(
                                                icon: Icon(
                                                  Icons.delete_forever,
                                                  color: Colors.red,
                                                ),
                                                onPressed: () {
                                                  confirmDeleteService(
                                                      context, index);
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  SizedBox(
                                    width: double.infinity,
                                    child: TextButton(
                                      onPressed: () {
                                        addServiceBottomSheet(context);
                                      },
                                      child: Text('Add'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    border: Border.all(
                      color: Colors.white30,
                    ),
                    borderRadius: BorderRadius.circular(
                      20,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Obx(
                          () => Text(
                            shopsController.employees.isEmpty
                                ? 'Add employees to shop'
                                : 'Employees in shop',
                          ),
                        ),
                        IgnorePointer(
                          ignoring: shopsController.isLoading.value,
                          child: Container(
                            margin: EdgeInsets.only(
                              top: 10,
                            ),
                            child: Obx(
                              () => Column(
                                children: [
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: shopsController.employees.length,
                                    itemBuilder: (context, index) {
                                      final employee =
                                          shopsController.employees[index];
                                      return Card(
                                        child: ListTile(
                                          leading: Checkbox(
                                            value: employee['employeeStatus'],
                                            onChanged: (value) {
                                              shopsController
                                                  .toggleEmployee(index);
                                            },
                                          ),
                                          title: Text(
                                            employee['employeeName'],
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          subtitle: Text(
                                              'Time: [${MaterialLocalizations.of(context).formatTimeOfDay(employee['entryTime'])} - ${MaterialLocalizations.of(context).formatTimeOfDay(employee['exitTime'])}]\nSpecialized: ${employee['skills']}'),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: Icon(
                                                  Icons.edit,
                                                  color: Colors.blue,
                                                ),
                                                onPressed: () {
                                                  editEmployeeBottomSheet(
                                                      context, index);
                                                },
                                              ),
                                              IconButton(
                                                icon: Icon(
                                                  Icons.delete_forever,
                                                  color: Colors.red,
                                                ),
                                                onPressed: () {
                                                  confirmDeleteEmployee(
                                                      context, index);
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  SizedBox(
                                    width: double.infinity,
                                    child: TextButton(
                                      onPressed: () {
                                        shopsController.services.isEmpty
                                            ? Get.snackbar('No Services',
                                                'Please add services before listing employee')
                                            : addEmployeeBottomSheet(context);
                                      },
                                      child: Text('Add'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                SizedBox(
                  width: double.infinity,
                  child: Obx(
                    () => TextButton(
                      onPressed: () {
                        if (shopNameController.text.trim().isEmpty) {
                          Get.snackbar('Error', 'Shop name cannot be empty.');
                          return;
                        }
                        if (shopsController.services.isEmpty) {
                          Get.snackbar('0 Services',
                              'Atlest 1 service needed to register shop');
                          return;
                        }
                        if (shopsController.employees.isEmpty) {
                          Get.snackbar('0 Employees',
                              'Atlest 1 Employee needed to register shop');
                          return;
                        }
                        if (shopsController.latitude.value.trim().isEmpty ||
                            shopsController.longitude.value.trim().isEmpty) {
                          Get.snackbar('Fetch Location to add shop',
                              'Your current location will be marked as shop location');
                          return;
                        }
                        log('\n\n\n\nbarber id: ${shopsController.barberId}\n\nname: ${shopNameController.text.trim()}\n\nservices: ${shopsController.services}\n\nemployees: ${shopsController.employees}\n\nshop location: ${shopsController.latitude.value.trim()} - ${shopsController.longitude.value.trim()}\n\n\n\n');
                      },
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            12,
                          ),
                        ),
                      ),
                      child: shopsController.isLoading.value
                          ? CupertinoActivityIndicator()
                          : Text(
                              'Add Shop',
                            ),
                    ),
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
