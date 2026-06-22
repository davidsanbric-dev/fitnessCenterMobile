import 'package:fitnesscenter_mobile/app/core/constants/app_strings.dart';
import 'package:flutter/material.dart';

class GreetingMessage extends StatelessWidget {
  const GreetingMessage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          AppStrings.loadWelcomeTitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          AppStrings.loadWelcomeSubtitle,
          textAlign: TextAlign.center,
          style:
              Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w300,
                letterSpacing: 0.2,
                fontSize: 23,
              ) ??
              const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w300,
              ),
        ),
      ],
    );
  }
}
