import 'package:barber_appointment/widgets/circular_avatar_image.dart';
import 'package:flutter/material.dart';

class LoginChoiceButton extends StatelessWidget {
  const LoginChoiceButton({
    super.key,
    required this.buttonImage,
    required this.buttonTitle,
    required this.onPressed,
  });

  final String buttonImage;
  final String buttonTitle;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.purpleAccent.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CircularAvatarImage(
                image: buttonImage,
                radius: 65,
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                buttonTitle,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
