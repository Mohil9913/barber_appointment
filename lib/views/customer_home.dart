import 'package:barber_appointment/controllers/profile_setup_controller.dart';
import 'package:barber_appointment/widgets/circular_avatar_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomerHome extends StatelessWidget {
  CustomerHome({super.key});

  final ProfileSetupController profileSetupController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Barber Appointment'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              child: Card(
                color: Colors.deepPurple.withValues(alpha: 0.3),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      CircularAvatarImage(
                        image: 'assets/images/login_screen/customer.jpeg',
                        radius: 55,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        '${profileSetupController.name.value}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.history),
              title: const Text('Previous Appointments'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.edit),
              title: const Text('Edit Profile'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                profileSetupController.logoutUser();
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Text('No Appointments'),
      ),
    );
  }
}
