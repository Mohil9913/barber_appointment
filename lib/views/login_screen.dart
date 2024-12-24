import 'package:barber_appointment/controllers/login_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final LoginController loginController = Get.put(LoginController());
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

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
            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: 'Please confirm that '),
                  TextSpan(
                    text: '+91 ${phoneNumberController.text} ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(text: 'is your phone number for current login.'),
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
                    await loginController.sendOtp(phoneNumberController.text);
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
          horizontal: 30,
        ),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image(
                        image: AssetImage(
                          'assets/images/login_screen/login.png',
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        'Let\'s make you look awesome',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium!
                            .copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                        ),
                        child: Obx(
                          () => Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  Get.snackbar('Only Serving in India for now',
                                      'Service not available for other regions');
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 15.4,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                      4,
                                    ),
                                    border: Border.all(
                                      color: !loginController
                                              .isPhoneNumberTextFieldVisible
                                              .value
                                          ? Colors.grey.withValues(
                                              alpha: 0.2,
                                            )
                                          : Colors.grey,
                                    ),
                                  ),
                                  child: Text(
                                    '+91',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: !loginController
                                              .isPhoneNumberTextFieldVisible
                                              .value
                                          ? Colors.grey.withValues(
                                              alpha: 0.6,
                                            )
                                          : Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              Expanded(
                                child: TextField(
                                  autofocus: false,
                                  controller: phoneNumberController,
                                  keyboardType: TextInputType.number,
                                  maxLength: 10,
                                  enabled: loginController
                                      .isPhoneNumberTextFieldVisible.value,
                                  inputFormatters: <TextInputFormatter>[
                                    // FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  decoration: InputDecoration(
                                    hintText: '10 Digit Phone Number',
                                    border: OutlineInputBorder(),
                                    counterText: '',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Obx(
                        () => loginController.otpGenerated.value == true
                            ? Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 10,
                                ),
                                child: TextField(
                                  maxLength: 6,
                                  autofocus: true,
                                  controller: otpController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    // FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  decoration: InputDecoration(
                                    hintText: '6 Digit OTP',
                                    border: OutlineInputBorder(),
                                    counterText: '',
                                  ),
                                ),
                              )
                            : Container(),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              12,
                            ),
                          ),
                        ),
                        onPressed: () {
                          if (!loginController.otpGenerated.value) {
                            confirmationDialog(context);
                          } else {
                            loginController.verifyOtp(otpController.text);
                          }
                        },
                        child: Obx(
                          () => Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 50,
                            ),
                            child: loginController.isLoading.value == true
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CupertinoActivityIndicator(),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        loginController.otpGenerated.value
                                            ? 'Verifying OTP...'
                                            : 'Generating OTP...',
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
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
