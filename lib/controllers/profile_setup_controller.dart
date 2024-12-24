import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileSetupController extends GetxController {
  final userNumber = FirebaseAuth.instance.currentUser!.phoneNumber;
  Rx<String?> userType = Rx<String?>(null);
  Rx<String?> name = Rx<String?>(null);
  Rx<String?> shopName = Rx<String?>(null);
  Rx<File?> selectedImage = Rx<File?>(null);
  Rx<DateTime> selectedDate = Rx<DateTime>(DateTime(DateTime.now().year - 10));
  var selectedGender = 'Male'.obs;
  var isLoading = false.obs;

  final SupabaseClient supabaseClient;

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

  Future<void> saveProfile() async {
    uploadImageToBucket();

    // Get.offAllNamed(userType.value == 'barber' ? '/manage_services' : '/customer_home');
  }
}
