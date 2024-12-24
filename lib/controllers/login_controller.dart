import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  var isPhoneNumberTextFieldVisible = true.obs;
  var isOtpTextFieldVisible = false.obs;
  var isLoading = false.obs;
  var otpGenerated = false.obs;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _verificationId = '';

  Future<void> sendOtp(String? phoneNumber) async {
    isPhoneNumberTextFieldVisible.value = false;
    isLoading.value = true;

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: '+91$phoneNumber',
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
          Get.snackbar('Success', 'Auto-login completed');
          Get.offAllNamed('/user_selection');
          isLoading.value = false;
        },
        verificationFailed: (FirebaseAuthException e) {
          isPhoneNumberTextFieldVisible.value = true;
          Get.snackbar('Error', e.message ?? 'Verification Failed');
          isLoading.value = false;
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          isPhoneNumberTextFieldVisible.value = false;
          isOtpTextFieldVisible.value = true;
          otpGenerated.value = true;
          Get.snackbar('OTP Sent', 'Please check your SMS');
          isLoading.value = false;
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
          isLoading.value = false;
        },
      );
    } catch (e) {
      Get.snackbar('Invalid OTP', 'Please enter the correct OTP');
      isLoading.value = false;
    }
  }

  Future<void> verifyOtp(String otp) async {
    isLoading.value = true;

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: otp,
      );

      await _auth.signInWithCredential(credential);

      Get.snackbar('Success', 'You are now logged in');
      isLoading.value = false;
      Get.offAllNamed('/user_selection');
    } catch (e) {
      Get.snackbar('Invalid OTP', 'Please enter the correct OTP');
      isLoading.value = false;
    }
  }
}
