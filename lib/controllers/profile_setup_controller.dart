import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileSetupController extends GetxController {
  final userNumber = FirebaseAuth.instance.currentUser!.phoneNumber;
  Rx<String?> userType = Rx<String?>(null);
  Rx<String?> name = Rx<String?>(null);
  Rx<File?> selectedImage = Rx<File?>(null);
  Rx<DateTime> selectedDate = Rx<DateTime>(DateTime(DateTime.now().year - 10));
  var selectedGender = 'Male'.obs;
  var isLoading = false.obs;

  final SupabaseClient supabaseClient;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ProfileSetupController()
      : supabaseClient = SupabaseClient(
          'https://msnezhmleqfesejpcnkm.supabase.co',
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1zbmV6aG1sZXFmZXNlanBjbmttIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzUwMjI1MTcsImV4cCI6MjA1MDU5ODUxN30.AuV-UTqP8ufTzWB85-HYp9QCJe7fB_WMWJSCq_wLtNc',
        );

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      selectedImage.value = File(pickedFile.path);
    }
  }

  Future<String?> uploadImageToBucket() async {
    final bucketName =
        userType.value == 'barber' ? 'shop_images' : 'customer_images';
    isLoading.value = true;
    try {
      if (selectedImage.value == null) {
        Get.snackbar('Error', 'No image selected to upload.');
        isLoading.value = false;
        return null;
      }

      final String fileName =
          '$userNumber+${DateTime.now().millisecondsSinceEpoch}.jpg';

      final String filePath =
          await supabaseClient.storage.from(bucketName).upload(
                fileName,
                selectedImage.value!,
                fileOptions: const FileOptions(upsert: true),
              );

      final String publicUrl =
          supabaseClient.storage.from(bucketName).getPublicUrl(filePath);

      isLoading.value = false;
      return publicUrl;
    } catch (e) {
      isLoading.value = false;
      print('Error uploading image: $e');
      Get.snackbar('Upload Error', 'Failed to upload image. Please try again.');
      return null;
    }
  }

  void setGender(String gender) {
    selectedGender.value = gender;
  }

  Future<void> saveBarberProfile() async {
    isLoading.value = true;

    try {
      if (userNumber == null || userNumber!.isEmpty) {
        Get.offAllNamed('/login_screen');
        Get.snackbar('Something went wrong',
            'User logged out unexpectedly! Please login again');
        return;
      }

      DocumentReference barberDoc =
          _firestore.collection('barber').doc(userNumber);

      DocumentSnapshot docSnapshot = await barberDoc.get();

      if (docSnapshot.exists) {
        isLoading.value = false;
        Get.offAllNamed('/barber_home');
      } else {
        final profilePicture = await uploadImageToBucket();

        await barberDoc.set({
          'barberId': userNumber,
          'imageUrl': profilePicture,
          'barberName': name.value,
          'shops': [],
        });
        isLoading.value = false;
        Get.offAllNamed('/barber_home');
      }
    } catch (e) {
      isLoading.value = false;
      log('Error Creating Barber: $e');
      Get.snackbar('Error Creating User',
          'Failed to create new user. Please try again.');
    }
  }

  Future<void> saveCustomerProfile() async {
    isLoading.value = true;

    try {
      if (userNumber == null || userNumber!.isEmpty) {
        Get.offAllNamed('/login_screen');
        Get.snackbar('Something went wrong',
            'User logged out unexpectedly! Please login again');
        return;
      }

      DocumentReference customerDoc =
          _firestore.collection('customer').doc(userNumber);

      DocumentSnapshot docSnapshot = await customerDoc.get();

      if (docSnapshot.exists) {
        isLoading.value = false;
        Get.offAllNamed('/customer_home');
      } else {
        final profilePicture = await uploadImageToBucket();

        await customerDoc.set({
          'customerId': userNumber,
          'imageUrl': profilePicture,
          'customerName': name.value,
          'customerGender': selectedGender.value,
          'customerDOB': selectedDate.value,
          'appointments': [],
        });
        isLoading.value = false;
        Get.offAllNamed('/customer_home');
      }
    } catch (e) {
      isLoading.value = false;
      log('Error creating Customer: $e');
      Get.snackbar('Error Creating User',
          'Failed to create new user. Please try again.');
    }
  }

  Future<void> logoutUser() async {
    await FirebaseAuth.instance.signOut();
    Get.snackbar('Logged out', 'You account is now logged out successfully!');
    Get.offAllNamed('login_screen');
  }
}
