import 'package:barber_appointment/controllers/customer_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SelectService extends StatelessWidget {
  SelectService({super.key});

  final CustomerController customerController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Choose Services'),
      ),
      body: FutureBuilder(
        future: customerController.fetchServices(),
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
            return Obx(
              () {
                if (customerController.servicesInFirebase.isEmpty) {
                  return Center(
                    child: Text(
                      'No Services in "${customerController.shopsInFirebase[customerController.selectedIndex.value]['name']}"',
                    ),
                  );
                }
                return customerController.isLoading.value
                    ? Center(child: CupertinoActivityIndicator())
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount:
                                  customerController.servicesInFirebase.length,
                              itemBuilder: (context, index) {
                                final service = customerController
                                    .servicesInFirebase[index];
                                return Obx(() => CheckboxListTile(
                                      value: customerController.checkServices(
                                          service['serviceName']),
                                      onChanged: (value) {
                                        customerController.toggleService(
                                            service['serviceName']);
                                      },
                                      title: Text(
                                        textAlign: TextAlign.left,
                                        '${service['serviceName']} | ₹${service['servicePrice']}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge,
                                      ),
                                    ));
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                              child: SizedBox(
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: () {
                                    if (customerController
                                        .services.isNotEmpty) {
                                      Get.toNamed('/select_employee');
                                    } else {
                                      Get.snackbar('No Service Selected',
                                          'At-least choose 1 service');
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10.0,
                                      horizontal: 30.0,
                                    ),
                                    child: Text('Next'),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
              },
            );
          }
        },
      ),
    );
  }
}
