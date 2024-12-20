import 'package:barber_appointment/controllers/login_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final LoginController loginController = Get.put(LoginController());

  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController otpController = TextEditingController();

  void confirmationDialog(BuildContext context) {
    Get.defaultDialog(
      title: 'Confirm Number',
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
            Text(
              'Please confirm that +91 "${phoneNumberController.text}" is your phone number for current login.',
              style: Theme.of(context).textTheme.bodyLarge,
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
                    loginController.isLoading.value = true;
                    if (Get.isDialogOpen == true) {
                      Get.back();
                    }
                    await loginController.sendOtp(phoneNumberController.text);
                    loginController.isLoading.value = false;
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
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(
              image: AssetImage(
                'assets/images/login_screen/login.png',
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Text(
              'Please Login',
              style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(
              height: 30,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Obx(
                () => TextField(
                  autofocus: false,
                  controller: phoneNumberController,
                  keyboardType: TextInputType.number,
                  enabled: loginController.isPhoneNumberTextFieldVisible.value,
                  inputFormatters: <TextInputFormatter>[
                    // FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: InputDecoration(
                    hintText: '10 Digit Phone Number',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Obx(
              () => loginController.otpGenerated.value == true
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: TextField(
                        controller: otpController,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          // FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          hintText: '6 Digit OTP',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    )
                  : Container(),
            ),
            SizedBox(
              height: 10,
            ),
            Obx(
              () => TextButton(
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      12,
                    ),
                  ),
                ),
                onPressed: () {
                  if (phoneNumberController.text.length != 10) {
                    Get.snackbar(
                      'Invalid Number',
                      'Please enter valid 10 digit phone number.',
                    );
                    return;
                  }
                  loginController.otpGenerated.value
                      ? otpController.text.length == 6
                          ? loginController.resetValues(otpController.text)
                          : Get.snackbar(
                              'Invalid OTP', 'Please enter valid 6 digit OTP')
                      : confirmationDialog(context);
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 50,
                  ),
                  child: loginController.isLoading.value
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CupertinoActivityIndicator(),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              'Generating OTP...',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        )
                      : Text(
                          loginController.otpGenerated.value
                              ? 'Verify'
                              : 'Send OTP',
                        ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

/*

Get.dialog(
                      Material(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 40),
                              child: Container(
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    children: [
                                      const SizedBox(height: 10),
                                      const Text(
                                        "Please confirm +91 is your number.",
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 20),
                                      //Buttons
                                      Row(
                                        children: [
                                          Expanded(
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                minimumSize: const Size(0, 45),
                                                backgroundColor:
                                                    Colors.transparent,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                              onPressed: () {
                                                Get.back();
                                              },
                                              child: const Text(
                                                'Back',
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                minimumSize: const Size(0, 45),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                              onPressed: () {
                                                Get.back();
                                                loginController.sendOtp();
                                              },
                                              child: const Text(
                                                'Confirm',
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
 */
