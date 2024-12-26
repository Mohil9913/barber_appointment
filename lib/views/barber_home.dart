import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BarberHome extends StatelessWidget {
  const BarberHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Appointment Dashboard'),
      ),
      body: Column(
        children: [
          TextButton(
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Get.toNamed('/manage_shops');
            },
            child: Text(
              'Manage Shop(s)',
            ),
          ),
        ],
      ),
    );
  }
}
