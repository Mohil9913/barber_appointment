import 'package:barber_appointment/controllers/profile_setup_controller.dart';
import 'package:barber_appointment/widgets/gender_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ProfileSetup extends StatelessWidget {
  ProfileSetup({super.key});

  final ProfileSetupController profileSetupController =
      Get.put(ProfileSetupController());
  final List<String> genders = ['Male', 'Female'];

  void confirmationDialog(BuildContext context) {
    Get.defaultDialog(
      title: 'Confirm Your Details',
      titlePadding: EdgeInsets.only(
        top: 30,
      ),
      barrierDismissible: false,
      content: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 10.0,
          horizontal: 30.0,
        ),
        child: Column(
          children: [
            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: 'Your name is '),
                  TextSpan(
                    text: profileSetupController.name.value,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  profileSetupController.userType.value == 'barber'
                      ? TextSpan()
                      : TextSpan(text: '\nYour gender is '),
                  profileSetupController.userType.value == 'barber'
                      ? TextSpan()
                      : TextSpan(
                          text: profileSetupController.selectedGender.value,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                  profileSetupController.userType.value == 'barber'
                      ? TextSpan()
                      : TextSpan(
                          text: '\nYour birth date is ',
                        ),
                  profileSetupController.userType.value == 'barber'
                      ? TextSpan()
                      : TextSpan(
                          text: DateFormat('yyyy-MM-dd').format(
                              profileSetupController.selectedDate.value),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                  profileSetupController.userType.value == 'barber'
                      ? TextSpan(text: '\nYour shop name is ')
                      : TextSpan(),
                  profileSetupController.userType.value == 'barber'
                      ? TextSpan(
                          text: profileSetupController.shopName.value,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : TextSpan(),
                ],
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    if (Get.isDialogOpen == true) {
                      Get.back();
                    }
                  },
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        12,
                      ),
                    ),
                  ),
                  child: Text(
                    'Back',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    if (Get.isDialogOpen == true) {
                      Get.back();
                    }
                    profileSetupController.userType.value == 'barber'
                        ? profileSetupController.saveBarberProfile()
                        : profileSetupController.saveCustomerProfile();
                  },
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        12,
                      ),
                    ),
                  ),
                  child: Text(
                    'Confirm',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          profileSetupController.userType.value == 'barber'
              ? 'Barber Profile Setup'
              : 'Customer Profile Setup',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 40,
        ),
        child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
                minWidth: constraints.maxWidth,
              ),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Obx(
                      () => Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: profileSetupController
                                            .selectedImage.value ==
                                        null
                                    ? AssetImage(profileSetupController
                                                .userType.value ==
                                            'barber'
                                        ? 'assets/images/login_screen/barber.jpeg'
                                        : 'assets/images/login_screen/customer.jpeg')
                                    : FileImage(profileSetupController
                                        .selectedImage.value!) as ImageProvider,
                                fit: BoxFit
                                    .cover, // Ensures the image covers the circle
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: IgnorePointer(
                              ignoring: profileSetupController.isLoading.value,
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: profileSetupController.isLoading.value
                                      ? Colors.grey
                                      : Colors.deepPurple,
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
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    profileSetupController.userType.value == 'barber'
                        ? Container()
                        : Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GenderButton(label: 'Male'),
                                  SizedBox(width: 20),
                                  GenderButton(label: 'Female'),
                                ],
                              ),
                              SizedBox(
                                height: 20,
                              ),
                            ],
                          ),
                    TextField(
                      enabled: !profileSetupController.isLoading.value,
                      onChanged: (value) {
                        profileSetupController.name.value = value;
                      },
                      autofocus: false,
                      decoration: InputDecoration(
                        label: Text(
                          'My Name',
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    profileSetupController.userType.value == 'barber'
                        ? Column(
                            children: [
                              TextField(
                                enabled:
                                    !profileSetupController.isLoading.value,
                                autofocus: false,
                                onChanged: (value) {
                                  profileSetupController.shopName.value = value;
                                },
                                decoration: InputDecoration(
                                  label: Text(
                                    'My Shop Name',
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                            ],
                          )
                        : Container(),
                    profileSetupController.userType.value == 'barber'
                        ? Container()
                        : Container(
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
                                IgnorePointer(
                                  ignoring:
                                      profileSetupController.isLoading.value,
                                  child: Container(
                                    margin: EdgeInsets.only(
                                      top: 10,
                                    ),
                                    height: 150,
                                    child: CupertinoDatePicker(
                                        mode: CupertinoDatePickerMode.date,
                                        initialDateTime: DateTime(
                                          DateTime.now().year - 10,
                                        ),
                                        minimumDate:
                                            DateTime(DateTime.now().year - 100),
                                        maximumDate:
                                            DateTime(DateTime.now().year - 5),
                                        onDateTimeChanged: (DateTime dob) {
                                          profileSetupController
                                              .selectedDate.value = dob;
                                        }),
                                  ),
                                ),
                              ],
                            ),
                          ),
                    SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: Obx(
                        () => TextButton(
                          onPressed: () {
                            if (profileSetupController.name.value == '') {
                              Get.snackbar('Provide your name',
                                  'User name can\'t be empty');
                              return;
                            }
                            if (profileSetupController.userType.value ==
                                    'barber' &&
                                profileSetupController.shopName.value == '') {
                              Get.snackbar('Provide your shop name',
                                  'Shop name can\'t be empty');
                              return;
                            }
                            confirmationDialog(context);
                          },
                          style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                12,
                              ),
                            ),
                          ),
                          child: profileSetupController.isLoading.value
                              ? CupertinoActivityIndicator()
                              : Text(
                                  'Save',
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
