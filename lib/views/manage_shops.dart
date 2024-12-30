import 'package:barber_appointment/controllers/shops_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ManageShops extends StatelessWidget {
  ManageShops({super.key});

  final ShopsController shopsController = Get.put(ShopsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage your Shops'),
      ),
      body: FutureBuilder(
        future: shopsController.fetchShops(),
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
                if (shopsController.shops.isEmpty) {
                  return const Center(
                    child: Text(
                        'No shops on your profile! Add by clicking \'+\' Button'),
                  );
                }
                return shopsController.isLoading.value
                    ? Center(child: CupertinoActivityIndicator())
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: ListView.builder(
                          itemCount: shopsController.shops.length,
                          itemBuilder: (context, index) {
                            final shop = shopsController.shops[index];
                            return Card(
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Checkbox(
                                        value: shop['status'],
                                        onChanged: (value) {
                                          shopsController.toggleShopStatus(
                                              index, value!);
                                        }),
                                    Expanded(
                                      child: InkWell(
                                        onTap: () {},
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
          Get.toNamed('/add_shop');
        },
        child: Icon(CupertinoIcons.plus),
      ),
    );
  }
}
