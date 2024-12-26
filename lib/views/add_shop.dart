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
  final TextEditingController employeeRecommendedServiceController =
      TextEditingController();
  final TextEditingController serviceNameController = TextEditingController();
  final TextEditingController servicePriceController = TextEditingController();
  final TextEditingController serviceTimeController = TextEditingController();

  void confirmDeleteEmployee(BuildContext context, int index) {
    Get.defaultDialog(
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

  void addEmployeeDialog(BuildContext context) {
    Get.defaultDialog(
      title: 'Add Employee',
      titlePadding: EdgeInsets.only(
        top: 30,
      ),
      content: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 10.0,
          horizontal: 20.0,
        ),
        child: Column(
          children: [
            TextField(
              autofocus: true,
              textInputAction: TextInputAction.next,
              controller: employeeNameController,
              decoration: InputDecoration(
                label: Text(
                  'Employee Name',
                ),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            TextField(
              autofocus: true,
              textInputAction: TextInputAction.next,
              controller: employeeRecommendedServiceController,
              decoration: InputDecoration(
                label: Text(
                  'Recommended Service (if any)',
                ),
              ),
            ),
            SizedBox(
              height: 20,
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
                    if (Get.isDialogOpen == true) {
                      Get.back();
                    }
                    employeeNameController.text = '';
                    employeeRecommendedServiceController.text = '';
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
                                shopsController.employeeExitTime.value!.hour &&
                            shopsController.employeeEntryTime.value!.minute >=
                                shopsController
                                    .employeeExitTime.value!.minute)) {
                      Get.snackbar('Please verify time',
                          'Entry time should be smaller than Exit time!');
                      return;
                    }

                    if (Get.isDialogOpen == true) {
                      Get.back();
                    }
                    shopsController.employees.add({
                      "employeeStatus": true,
                      "employeeName": employeeNameController.text.trim(),
                      "recommendedServices":
                          employeeRecommendedServiceController.text.trim(),
                      "entryTime": shopsController.employeeEntryTime.value,
                      "exitTime": shopsController.employeeExitTime.value,
                    });
                    employeeNameController.text = '';
                    employeeRecommendedServiceController.text = '';
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
                    'Add Employee',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void editEmployeeDialog(BuildContext context, int index) {
    employeeNameController.text =
        shopsController.employees[index]['employeeName'];
    employeeRecommendedServiceController.text =
        shopsController.employees[index]['recommendedServices'];
    shopsController.employeeEntryTime.value =
        shopsController.employees[index]['entryTime'];
    shopsController.employeeExitTime.value =
        shopsController.employees[index]['exitTime'];

    Get.defaultDialog(
      title: 'Edit ${shopsController.employees[index]['employeeName']}',
      titlePadding: EdgeInsets.only(
        top: 30,
      ),
      content: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 10.0,
          horizontal: 20.0,
        ),
        child: Column(
          children: [
            TextField(
              autofocus: true,
              textInputAction: TextInputAction.next,
              controller: employeeNameController,
              decoration: InputDecoration(
                label: Text(
                  'Employee Name',
                ),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            TextField(
              autofocus: true,
              textInputAction: TextInputAction.next,
              controller: employeeRecommendedServiceController,
              decoration: InputDecoration(
                label: Text(
                  'Recommended Service (if any)',
                ),
              ),
            ),
            SizedBox(
              height: 20,
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
                    if (Get.isDialogOpen == true) {
                      Get.back();
                    }
                    employeeNameController.text = '';
                    employeeRecommendedServiceController.text = '';
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
                                shopsController.employeeExitTime.value!.hour &&
                            shopsController.employeeEntryTime.value!.minute >=
                                shopsController
                                    .employeeExitTime.value!.minute)) {
                      Get.snackbar('Please verify time',
                          'Entry time should be smaller than Exit time!');
                      return;
                    }
                    if (Get.isDialogOpen == true) {
                      Get.back();
                    }
                    shopsController.employees[index] = {
                      "employeeStatus": true,
                      "employeeName": employeeNameController.text.trim(),
                      "recommendedServices":
                          employeeRecommendedServiceController.text.trim(),
                      "entryTime": shopsController.employeeEntryTime.value,
                      "exitTime": shopsController.employeeExitTime.value,
                    };
                    employeeNameController.text = '';
                    employeeRecommendedServiceController.text = '';
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
    );
  }

  void confirmDeleteService(BuildContext context, int index) {
    Get.defaultDialog(
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

  void addServiceDialog(BuildContext context) {
    Get.defaultDialog(
      title: 'Add Service',
      titlePadding: EdgeInsets.only(
        top: 30,
      ),
      content: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 10.0,
          horizontal: 20.0,
        ),
        child: Column(
          children: [
            TextField(
              autofocus: true,
              textInputAction: TextInputAction.next,
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
              autofocus: true,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
              ],
              textInputAction: TextInputAction.next,
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
              autofocus: true,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
              ],
              textInputAction: TextInputAction.next,
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
                    if (Get.isDialogOpen == true) {
                      Get.back();
                    }
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
                      Get.snackbar('Provide Name', 'Service must have a name!');
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
                      Get.snackbar('Invalid Time', 'Please enter a valid !');
                      return;
                    }
                    if (Get.isDialogOpen == true) {
                      Get.back();
                    }

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
    );
  }

  void editServiceDialog(BuildContext context, int index) {
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

    Get.defaultDialog(
      title: 'Edit Service',
      titlePadding: EdgeInsets.only(
        top: 30,
      ),
      content: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 10.0,
          horizontal: 20.0,
        ),
        child: Column(
          children: [
            TextField(
              autofocus: true,
              textInputAction: TextInputAction.next,
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
              autofocus: true,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
              ],
              textInputAction: TextInputAction.next,
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
              autofocus: true,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
              ],
              textInputAction: TextInputAction.next,
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
                    if (Get.isDialogOpen == true) {
                      Get.back();
                    }
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
                      Get.snackbar('Provide Name', 'Service must have a name!');
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
                      Get.snackbar('Invalid Time', 'Please enter a valid !');
                      return;
                    }
                    if (Get.isDialogOpen == true) {
                      Get.back();
                    }

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
                TextField(
                  autofocus: true,
                  textInputAction: TextInputAction.next,
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
                                                  editServiceDialog(
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
                                        addServiceDialog(context);
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
                                              '[${MaterialLocalizations.of(context).formatTimeOfDay(employee['entryTime'])} - ${MaterialLocalizations.of(context).formatTimeOfDay(employee['exitTime'])}]\n${employee['recommendedServices']}'),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: Icon(
                                                  Icons.edit,
                                                  color: Colors.blue,
                                                ),
                                                onPressed: () {
                                                  editEmployeeDialog(
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
                                        addEmployeeDialog(context);
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
