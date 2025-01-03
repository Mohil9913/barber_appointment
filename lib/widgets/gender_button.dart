import 'package:barber_appointment/controllers/profile_setup_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GenderButton extends StatelessWidget {
  final String label;

  const GenderButton({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final ProfileSetupController profileSetupController =
        Get.find<ProfileSetupController>();

    return Obx(() {
      bool isSelected = profileSetupController.selectedGender.value == label;

      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isSelected ? Colors.purple.withValues(alpha: 0.4) : Colors.grey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              12,
            ),
          ),
        ),
        onPressed: () {
          profileSetupController.setGender(label);
        },
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      );
    });
  }
}
