import 'dart:developer';

import 'package:barber_appointment/controllers/shops_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddShop extends StatelessWidget {
  AddShop({super.key});

  final ShopsController shopsController = Get.put(ShopsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('List your shop'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (shopsController.shopNameController.text.trim().isEmpty) {
            Get.snackbar('No Name', 'Shop name cannot be empty.');
            return;
          }
          if (shopsController.services.isEmpty) {
            Get.snackbar(
                '0 Services', 'Atlest 1 service needed to register shop');
            return;
          }
          if (shopsController.employees.isEmpty) {
            Get.snackbar(
                '0 Employees', 'Atlest 1 Employee needed to register shop');
            return;
          }
          if (shopsController.latitude.value.trim().isEmpty ||
              shopsController.longitude.value.trim().isEmpty) {
            Get.snackbar('Fetch Location to add shop',
                'Your current location will be marked as shop location');
            return;
          }
          log('\n\n\n\nbarber id: ${shopsController.barberId}\n\nname: ${shopsController.shopNameController.text.trim()}\n\nservices: ${shopsController.services}\n\nemployees: ${shopsController.employees}\n\nshop location: ${shopsController.latitude.value.trim()} - ${shopsController.longitude.value.trim()}\n\n\n\n');
          shopsController.createShopAndAddData();
        },
        child: Obx(
          () => shopsController.isLoading.value
              ? CupertinoActivityIndicator()
              : Icon(Icons.save),
        ),
      ),
      body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 20,
                ),
                TextField(
                  focusNode: FocusNode(),
                  controller: shopsController.shopNameController,
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
                                                  shopsController
                                                      .editServiceBottomSheet(
                                                          context, index);
                                                },
                                              ),
                                              IconButton(
                                                icon: Icon(
                                                  Icons.delete_forever,
                                                  color: Colors.red,
                                                ),
                                                onPressed: () {
                                                  shopsController
                                                      .confirmDeleteService(
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
                                        shopsController
                                            .addServiceBottomSheet(context);
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
                                            employee['skills'].isEmpty
                                                ? 'Time: [${MaterialLocalizations.of(context).formatTimeOfDay(employee['entryTime'])} - ${MaterialLocalizations.of(context).formatTimeOfDay(employee['exitTime'])}]'
                                                : 'Time: [${MaterialLocalizations.of(context).formatTimeOfDay(employee['entryTime'])} - ${MaterialLocalizations.of(context).formatTimeOfDay(employee['exitTime'])}]\nSpecialized: ${employee['skills']}',
                                          ),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: Icon(
                                                  Icons.edit,
                                                  color: Colors.blue,
                                                ),
                                                onPressed: () {
                                                  shopsController
                                                      .editEmployeeBottomSheet(
                                                          context, index);
                                                },
                                              ),
                                              IconButton(
                                                icon: Icon(
                                                  Icons.delete_forever,
                                                  color: Colors.red,
                                                ),
                                                onPressed: () {
                                                  shopsController
                                                      .confirmDeleteEmployee(
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
                                            : shopsController
                                                .addEmployeeBottomSheet(
                                                    context);
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
                  height: 20,
                ),
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
              ],
            ),
          )),
    );
  }
}
