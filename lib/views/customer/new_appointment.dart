import 'package:barber_appointment/controllers/customer_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NewAppointment extends StatelessWidget {
  NewAppointment({super.key});

  final CustomerController customerController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Nearby Shop'),
      ),
      body: FutureBuilder(
        future: customerController.fetchShops(),
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
                if (customerController.shopsInFirebase.isEmpty) {
                  return const Center(
                    child: Text(
                      'No shops nearby!',
                    ),
                  );
                }
                return customerController.isLoading.value
                    ? Center(child: CupertinoActivityIndicator())
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: ListView.builder(
                          itemCount: customerController.shopsInFirebase.length,
                          itemBuilder: (context, index) {
                            final shop =
                                customerController.shopsInFirebase[index];
                            return Card(
                              child: InkWell(
                                onTap: () {
                                  customerController.selectedShopIndex.value =
                                      index;
                                  Get.toNamed('/select_service');
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Expanded(
                                    child: Row(
                                      children: [
                                        Text(
                                          '${index + 1}. ',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge,
                                        ),
                                        Text(
                                          textAlign: TextAlign.left,
                                          shop['name'],
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
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
