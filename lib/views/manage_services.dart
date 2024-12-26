import 'package:barber_appointment/controllers/profile_setup_controller.dart';
import 'package:barber_appointment/controllers/services_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class ManageServices extends StatelessWidget {
  ManageServices({super.key});

  final ServicesController servicesController = Get.put(ServicesController());
  final ProfileSetupController profileSetupController = Get.find();

  final TextEditingController serviceNameController = TextEditingController();
  final TextEditingController servicePriceController = TextEditingController();
  final TextEditingController serviceTimeController = TextEditingController();

  void addServiceDialog(BuildContext context) {
    Get.defaultDialog(
      title: 'New Service',
      titlePadding: EdgeInsets.only(
        top: 30,
      ),
      barrierDismissible: false,
      content: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 10.0,
          horizontal: 30.0,
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
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                // FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                FilteringTextInputFormatter.digitsOnly,
              ],
              controller: servicePriceController,
              decoration: InputDecoration(
                label: Text(
                  'Service Price',
                ),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            TextField(
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                // FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                FilteringTextInputFormatter.digitsOnly,
              ],
              controller: serviceTimeController,
              decoration: InputDecoration(
                label: Text(
                  'Service Required Minutes',
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
                    servicesController.addService(
                        serviceNameController.text,
                        int.parse(servicePriceController.text),
                        int.parse(serviceTimeController.text));
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
                    'Add',
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
    serviceNameController.text = servicesController.services[index]['name'];
    servicePriceController.text =
        servicesController.services[index]['price'].toString();
    serviceTimeController.text =
        servicesController.services[index]['minutes'].toString();

    Get.defaultDialog(
      title: 'Edit Service',
      titlePadding: EdgeInsets.only(
        top: 30,
      ),
      barrierDismissible: false,
      content: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 10.0,
          horizontal: 30.0,
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
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
              ],
              controller: servicePriceController,
              decoration: InputDecoration(
                label: Text(
                  'Service Price',
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
              controller: serviceTimeController,
              decoration: InputDecoration(
                label: Text(
                  'Service Required Minutes',
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
                    // Update the service details
                    servicesController.services[index]['name'] =
                        serviceNameController.text;
                    servicesController.services[index]['price'] =
                        int.parse(servicePriceController.text);
                    servicesController.services[index]['minutes'] =
                        int.parse(serviceTimeController.text);

                    servicesController.services.refresh();

                    if (Get.isDialogOpen == true) {
                      Get.back();
                    }
                    serviceNameController.text = '';
                    servicePriceController.text = '';
                    serviceTimeController.text = '';
                    Get.snackbar('Service Updated',
                        '${serviceNameController.text} has been updated');
                  },
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        12,
                      ),
                    ),
                    backgroundColor: Colors.green,
                  ),
                  child: Text(
                    'Save',
                    style: TextStyle(
                      color: Colors.white,
                    ),
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
    return Placeholder();
    // return Scaffold(
    //   appBar: AppBar(
    //     title: Obx(
    //       () => Text(
    //         'Manage Services for ${profileSetupController.shopName.value}',
    //       ),
    //     ),
    //   ),
    //   body: Obx(
    //     () => ListView.builder(
    //       itemCount: servicesController.services.length,
    //       itemBuilder: (context, index) {
    //         final service = servicesController.services[index];
    //         return Dismissible(
    //           key: Key(service['name']),
    //           background: Container(
    //             color: Colors.blueAccent,
    //             alignment: Alignment.centerLeft,
    //             padding: EdgeInsets.symmetric(horizontal: 20),
    //             child: Icon(
    //               Icons.edit,
    //             ),
    //           ),
    //           secondaryBackground: Container(
    //             color: Colors.red,
    //             alignment: Alignment.centerRight,
    //             padding: EdgeInsets.symmetric(horizontal: 20),
    //             child: Icon(Icons.delete),
    //           ),
    //           confirmDismiss: (direction) async {
    //             if (direction == DismissDirection.startToEnd) {
    //               editServiceDialog(context, index);
    //               return false;
    //             } else if (direction == DismissDirection.endToStart) {
    //               bool? confirmDelete = await Get.defaultDialog<bool>(
    //                 title: 'Confirm Delete',
    //                 titlePadding: EdgeInsets.only(top: 30),
    //                 barrierDismissible: false,
    //                 content: Padding(
    //                   padding: const EdgeInsets.symmetric(
    //                       vertical: 10.0, horizontal: 30.0),
    //                   child: Row(
    //                     mainAxisAlignment: MainAxisAlignment.end,
    //                     children: [
    //                       TextButton(
    //                         onPressed: () => Get.back(result: false),
    //                         child: Text(
    //                           'Cancel',
    //                           style: TextStyle(color: Colors.grey),
    //                         ),
    //                       ),
    //                       TextButton(
    //                         onPressed: () => Get.back(result: true),
    //                         style: TextButton.styleFrom(
    //                             backgroundColor: Colors.red),
    //                         child: Text('Delete'),
    //                       ),
    //                     ],
    //                   ),
    //                 ),
    //               );
    //               return confirmDelete ?? false;
    //             }
    //             return false;
    //           },
    //           onDismissed: (direction) {
    //             if (direction == DismissDirection.endToStart) {
    //               servicesController.deleteService(index);
    //             }
    //           },
    //           child: CheckboxListTile(
    //             title: Text(service['name']),
    //             subtitle: Text('Time: ${service['minutes']} Minutes'),
    //             value: service['selected'],
    //             secondary: Text('₹ ${service['price']}'),
    //             onChanged: (value) {
    //               servicesController.toggleService(index);
    //             },
    //             controlAffinity: ListTileControlAffinity.leading,
    //           ),
    //         );
    //       },
    //     ),
    //   ),
    //   floatingActionButton: FloatingActionButton(
    //     onPressed: () {
    //       addServiceDialog(context);
    //     },
    //     child: Icon(CupertinoIcons.plus),
    //   ),
    // );
  }
}
