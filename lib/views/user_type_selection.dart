import 'package:barber_appointment/widgets/login_choice_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserTypeSelection extends StatelessWidget {
  const UserTypeSelection({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Login as..?',
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
                  buttonImage: 'assets/images/login_screen/barber.jpg',
                  buttonTitle: 'Barber',
                  onPressed: () => Get.toNamed('barber_login'),
                ),
                SizedBox(),
                LoginChoiceButton(
                  buttonImage: 'assets/images/login_screen/customer.jpg',
                  buttonTitle: 'Customer',
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
