import 'package:barber_appointment/widgets/circular_avatar_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BarberProfileSetup extends StatelessWidget {
  BarberProfileSetup({super.key});

  String _userName = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Barber Login')),
      body: Center(
        child: Form(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              15,
              0,
              15,
              15,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.purpleAccent.withValues(
                  alpha: 0.05,
                ),
                borderRadius: BorderRadius.circular(
                  20,
                ),
              ),
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularAvatarImage(
                      image: 'assets/images/login_screen/barber.jpg',
                      radius: 100,
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        label: Text(
                          'Your Name',
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          Get.snackbar(
                            'Empty Form',
                            'Please enter Your Name',
                          );
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _userName = value!;
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        label: Text(
                          'Shop Name',
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          Get.snackbar(
                            'Empty Form',
                            'Please enter your Shop Name',
                          );
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _userName = value!;
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
