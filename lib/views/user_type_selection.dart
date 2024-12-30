import 'package:barber_appointment/controllers/profile_setup_controller.dart';
import 'package:barber_appointment/widgets/login_choice_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserTypeSelection extends StatelessWidget {
  UserTypeSelection({super.key});

  final ProfileSetupController profileSetupController =
      Get.put(ProfileSetupController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Lets create your account. Tell me about yourself you are..?',
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                LoginChoiceButton(
                    buttonImage: 'assets/images/login_screen/barber.jpeg',
                    buttonTitle: 'Barber',
                    onPressed: () {
                      profileSetupController.userType.value = 'barber';
                      Get.toNamed(
                        '/profile_setup',
                      );
                    }),
                SizedBox(),
                LoginChoiceButton(
                    buttonImage: 'assets/images/login_screen/customer.jpeg',
                    buttonTitle: 'Customer',
                    onPressed: () {
                      profileSetupController.userType.value = 'customer';
                      Get.toNamed(
                        '/profile_setup',
                      );
                    }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
