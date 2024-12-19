import 'package:get/get.dart';

class LoginController extends GetxController {
  var isPhoneNumberTextFieldVisible = true.obs;
  var isOtpTextFieldVisible = false.obs;
  var isLoading = false.obs;
  var otpGenerated = false.obs;

  Future<void> sendOtp(String? phoneNumber) async {
    isPhoneNumberTextFieldVisible.value = false;

    await Future.delayed(
      Duration(seconds: 3),
    );

    otpGenerated.value = true;

    if (otpGenerated.value) {
      isOtpTextFieldVisible.value = true;

      Get.snackbar('OTP Sent', 'Please check your sms app for OTP');
    } else {
      isPhoneNumberTextFieldVisible.value = true;
      isOtpTextFieldVisible.value = false;

      Get.snackbar('Error', 'OTP not Generated!');
    }
  }

  void resetValues(String? otp) {
    if (otp == '123456') {
      Get.snackbar('Verified', 'You are now logged in');
      Get.toNamed('/user_selection');
    } else if (otp == '111111') {
      isPhoneNumberTextFieldVisible.value = true;
      isOtpTextFieldVisible.value = false;
      otpGenerated.value = false;
    } else {
      Get.snackbar('Invalid OTP', 'Please recheck received OTP');
    }
  }
}
