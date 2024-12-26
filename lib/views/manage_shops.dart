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
              return Obx(() {
                if (shopsController.shops.isEmpty) {
                  return const Center(
                    child: Text(
                        'No shops on your profile! Add by clicking \'+\' Button'),
                  );
                }
                return ListView.builder(
                    itemCount: shopsController.shops.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(shopsController.shops[index]),
                      );
                    });
              });
            }
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.toNamed('/add_shop');
        },
        child: Icon(CupertinoIcons.plus),
      ),
    );
  }
}
