import 'package:barber_appointment/controllers/manage_shop_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ManageShops extends StatelessWidget {
  ManageShops({super.key});

  final ManageShopController manageShopController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage your Shops'),
      ),
      body: FutureBuilder(
        future: manageShopController.fetchShops(),
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
                if (manageShopController.shopsInFirebase.isEmpty) {
                  return const Center(
                    child: Text(
                      'No shops on your profile! Add by clicking \'+\' Button',
                    ),
                  );
                }
                return manageShopController.isLoading.value
                    ? Center(child: CupertinoActivityIndicator())
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: ListView.builder(
                          itemCount:
                              manageShopController.shopsInFirebase.length,
                          itemBuilder: (context, index) {
                            final shop =
                                manageShopController.shopsInFirebase[index];
                            return Card(
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: InkWell(
                                        onTap: () {
                                          manageShopController.showShopDetails(
                                              context, index);
                                        },
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              textAlign: TextAlign.left,
                                              shop['name'],
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleLarge,
                                            ),
                                            Text(
                                              'Appointments: ${shop['appointments'].length}\nServices: ${shop['services'].length}\nEmployees: ${shop['employees'].length}',
                                              style:
                                                  TextStyle(color: Colors.grey),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Checkbox(
                                        value: shop['status'],
                                        onChanged: (value) {
                                          manageShopController.toggleShopStatus(
                                              index, value!);
                                        }),
                                  ],
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          shopsController.shopNameController.clear();
          shopsController.services.clear();
          shopsController.employees.clear();
          shopsController.latitude.value = '';
          shopsController.longitude.value = '';
          Get.toNamed('/add_shop', arguments: {'isEdit': false});
        },
        child: Icon(CupertinoIcons.plus),
      ),
    );
  }
}
