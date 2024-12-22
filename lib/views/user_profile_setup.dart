import 'package:barber_appointment/controllers/profile_setup_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserProfileSetup extends StatelessWidget {
  UserProfileSetup({super.key});

  final ProfileSetupController profileSetupController =
      Get.put(ProfileSetupController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Customer Profile Setup',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(
          15,
          0,
          15,
          15,
        ),
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 40,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Obx(() {
                      return Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: profileSetupController.selectedImage.value ==
                                    null
                                ? AssetImage(
                                    'assets/images/login_screen/customer.jpeg')
                                : FileImage(profileSetupController
                                    .selectedImage.value!) as ImageProvider,
                            fit: BoxFit
                                .cover, // Ensures the image covers the circle
                          ),
                        ),
                      );
                    }),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.deepPurple,
                        ),
                        padding: const EdgeInsets.all(8),
                        child: InkWell(
                          onTap: () async {
                            await profileSetupController.pickImage();
                          },
                          child: const Icon(
                            Icons.upload_rounded,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                TextField(
                  decoration: InputDecoration(
                    label: Text(
                      'My Name',
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  padding: EdgeInsets.all(
                    8,
                  ),
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    border: Border.all(
                      color: Colors.white30,
                    ),
                    borderRadius: BorderRadius.circular(
                      20,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'My Birth Date',
                      ),
                      Container(
                        margin: EdgeInsets.only(
                          top: 10,
                        ),
                        height: 150,
                        child: CupertinoDatePicker(
                            mode: CupertinoDatePickerMode.date,
                            initialDateTime: DateTime(
                              DateTime.now().year - 10,
                            ),
                            minimumDate: DateTime(DateTime.now().year - 100),
                            maximumDate: DateTime(DateTime.now().year - 5),
                            onDateTimeChanged: (DateTime dob) {
                              profileSetupController.selectedDate.value = dob;
                            }),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          12,
                        ),
                      ),
                    ),
                    child: Text(
                      'Save',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
