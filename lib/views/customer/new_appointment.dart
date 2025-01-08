import 'package:barber_appointment/controllers/customer_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NewAppointment extends StatelessWidget {
  NewAppointment({super.key});

  final CustomerController customerController = Get.find();
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Nearby Shop'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60.0),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search shops...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: (value) {
                customerController.filterShops(value);
              },
            ),
          ),
        ),
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
                if (customerController.shopsSortedByDistance.isEmpty) {
                  return const Center(
                    child: Text('No shops found!'),
                  );
                }
                return customerController.isLoading.value
                    ? Center(child: CupertinoActivityIndicator())
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: ListView.builder(
                          itemCount:
                              customerController.shopsSortedByDistance.length,
                          itemBuilder: (context, index) {
                            final shop =
                                customerController.shopsSortedByDistance[index];
                            return Card(
                              child: InkWell(
                                onTap: () {
                                  customerController.selectedShopIndex.value =
                                      customerController.shopsInFirebase
                                          .indexOf(shop);
                                  Get.toNamed('/select_service');
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(15.0),
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
                                        '${shop['name']} | ${shop['distance']} away',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge,
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
