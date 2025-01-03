import 'package:barber_appointment/controllers/customer_controller.dart';
import 'package:barber_appointment/controllers/profile_setup_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomerHome extends StatelessWidget {
  CustomerHome({super.key});

  final ProfileSetupController profileSetupController =
      Get.find<ProfileSetupController>();
  final CustomerController customerController = Get.find<CustomerController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Barber Appointment'),
        actions: [
          Obx(
            () => IconButton(
              onPressed: () {
                customerController.showCustomerData(context);
              },
              icon: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.purpleAccent.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: 20,
                  backgroundImage: CachedNetworkImageProvider(
                        customerController.imageUrl.value,
                      ) ??
                      AssetImage('assets/images/login_screen/customer.jpeg'),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Obx(
        () => FloatingActionButton(
          onPressed: () {
            Get.toNamed('/new_appointment');
          },
          child: customerController.isLoading.value
              ? CupertinoActivityIndicator()
              : Icon(Icons.note_add_outlined),
        ),
      ),
      body: Center(
        child: Text('No Appointments Yet!'),
      ),
    );
  }
}
