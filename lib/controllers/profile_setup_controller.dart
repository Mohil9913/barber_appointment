import 'dart:io';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ProfileSetupController extends GetxController {
  Rx<String?> userType = Rx<String?>(null);
  Rx<String?> name = Rx<String?>(null);
  Rx<String?> shopName = Rx<String?>(null);
  Rx<File?> selectedImage = Rx<File?>(null);
  Rx<DateTime> selectedDate = Rx<DateTime>(DateTime(DateTime.now().year - 10));
  var selectedGender = 'Male'.obs;
  var isLoading = false.obs;

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      selectedImage.value = File(pickedFile.path);
    }
  }

  void setGender(String gender) {
    selectedGender.value = gender;
  }

  Future<void> saveProfile() async {
    //TODO: Implement Save Profile Logic Here
    isLoading.value = true;
    await Future.delayed(
      Duration(seconds: 1),
    );
    isLoading.value = false;
    Get.snackbar('Profile Saved', 'Your profile is saved successfully!');
    Get.offAllNamed(
        userType.value == 'barber' ? '/manage_services' : '/customer_home');
  }
}
