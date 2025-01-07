import 'package:barber_appointment/controllers/login_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LauncherScreen extends StatelessWidget {
  LauncherScreen({super.key});

  final loginController = Get.find<LoginController>();

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration.zero, () async {
      await loginController.checkIfExist();
    });

    return Scaffold(
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CupertinoActivityIndicator(),
            SizedBox(width: 10),
            Text('Connecting Server please wait...'),
          ],
        ),
      ),
    );
  }
}
