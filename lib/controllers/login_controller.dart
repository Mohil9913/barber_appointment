import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  var isPhoneNumberTextFieldVisible = true.obs;
  var isOtpTextFieldVisible = false.obs;
  var isLoading = false.obs;
  var otpGenerated = false.obs;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _verificationId = '';

  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  void confirmationDialog(BuildContext context) {
    Get.defaultDialog(
      title: 'Confirm Number',
      titlePadding: const EdgeInsets.only(
        top: 30,
      ),
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
                  const TextSpan(text: 'Please confirm that '),
                  TextSpan(
                    text: '+91 ${phoneNumberController.text} ',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const TextSpan(
                      text: 'is your phone number for current login.'),
                ],
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    if (Get.isDialogOpen ?? false) {
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
                  child: const Text(
                    'Back',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    if (Get.isDialogOpen ?? false) {
                      Get.back();
                    }
                    try {
                      await sendOtp(phoneNumberController.text);
                    } catch (e) {
                      Get.snackbar('Error', 'Failed to send OTP: $e');
                    }
                  },
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        12,
                      ),
                    ),
                  ),
                  child: const Text(
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

  Future<void> checkIfExist() async {
    if (FirebaseAuth.instance.currentUser == null) {
      Future.delayed(Duration.zero, () => Get.offAllNamed('/login_screen'));
      return;
    }
    final loginAs = await checkIfNewUser();

    if (loginAs == 'barber') {
      Get.offAllNamed('/barber_home');
    } else if (loginAs == 'customer') {
      Get.offAllNamed('/customer_home');
    } else {
      Get.offAllNamed('/login_screen');
    }
  }

  Future<String> checkIfNewUser() async {
    final userNumber = FirebaseAuth.instance.currentUser!.phoneNumber;

    try {
      DocumentReference barberDocRef =
          _firestore.collection('barber').doc(userNumber);
      DocumentSnapshot docSnapshot = await barberDocRef.get();

      if (docSnapshot.exists) {
        return 'barber';
      } else {
        barberDocRef = _firestore.collection('customer').doc(userNumber);
        docSnapshot = await barberDocRef.get();
        if (docSnapshot.exists) {
          return 'customer';
        }
      }
      return 'new';
    } catch (e) {
      log('Error checking document existence: $e');
      isPhoneNumberTextFieldVisible.value = true;
      isOtpTextFieldVisible.value = false;
      otpGenerated.value = false;
      Get.snackbar('Something Went Wrong', 'Please again later');
      isLoading.value = false;
      return 'error';
    }
  }

  void redirectUser() async {
    final loginAs = await checkIfNewUser();
    isPhoneNumberTextFieldVisible.value = true;
    isOtpTextFieldVisible.value = false;
    otpGenerated.value = false;
    Get.snackbar('Welcome', 'Login completed, OTP verified');
    isLoading.value = false;
    if (loginAs == 'new') {
      Get.offAllNamed('/user_selection');
    } else if (loginAs == 'barber') {
      Get.offAllNamed('/barber_home');
    } else if (loginAs == 'customer') {
      Get.offAllNamed('/customer_home');
    }
  }

  Future<void> sendOtp(String? phoneNumber) async {
    try {
      isPhoneNumberTextFieldVisible.value = false;
      isLoading.value = true;

      await _auth.verifyPhoneNumber(
        phoneNumber: '+91$phoneNumber',
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
          redirectUser();
        },
        verificationFailed: (FirebaseAuthException e) {
          log('Verification Failed. Code: ${e.code}, Message: ${e.message}'); // Add this log
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
      log('Error in sendOtp: $e'); // Add this log
      Get.snackbar('Error', 'Failed to send OTP: $e');
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
      otpController.text = '';
      redirectUser();
    } catch (e) {
      Get.snackbar('Invalid OTP', 'Please enter the correct OTP');
      isLoading.value = false;
    }
  }
}
