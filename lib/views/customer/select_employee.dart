import 'package:barber_appointment/controllers/customer_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SelectEmployee extends StatelessWidget {
  SelectEmployee({super.key});

  final CustomerController customerController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Choose Barber for Service'),
      ),
      body: FutureBuilder(
        future: customerController.fetchEmployee(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              customerController.isLoading.value) {
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
                if (customerController.employeesInFirebase.isEmpty) {
                  return Center(
                    child: Text(
                      'No Employees in "${customerController.shopsInFirebase[customerController.selectedShopIndex.value]['name']}"',
                    ),
                  );
                }
                return customerController.isLoading.value
                    ? Center(child: CupertinoActivityIndicator())
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount:
                              customerController.employeesInFirebase.length,
                          itemBuilder: (context, index) {
                            final employee =
                                customerController.employeesInFirebase[index];
                            return Card(
                              child: InkWell(
                                onTap: () {
                                  customerController.calculateTimeAndPrice(
                                      context, index);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    // Ensures alignment for rows
                                    children: [
                                      Text(
                                        '${index + 1}. ',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge,
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${employee['employeeName']}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleLarge,
                                            ),
                                            SizedBox(height: 5),
                                            if (employee['skills'] != null &&
                                                employee['skills']
                                                    .isNotEmpty) ...[
                                              Text(
                                                'Recommended: ',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium,
                                              ),
                                              SizedBox(height: 5),
                                              // Space between label and skills
                                              Wrap(
                                                spacing: 5.0,
                                                // Space between skill items
                                                runSpacing: 5.0,
                                                // Space between lines
                                                children: List<Widget>.generate(
                                                  employee['skills'].length,
                                                  (skillIndex) => Chip(
                                                    label: Text(
                                                        employee['skills']
                                                            [skillIndex]),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ],
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
