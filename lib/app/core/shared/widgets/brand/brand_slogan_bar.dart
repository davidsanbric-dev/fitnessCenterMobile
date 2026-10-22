import 'package:fitnesscenter_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:fitnesscenter_mobile/app/config/app_theme.dart';
import 'package:fitnesscenter_mobile/app/core/constants/app_strings.dart';

class BrandSloganBar extends StatelessWidget {
  final double widthFactor;

  const BrandSloganBar({super.key, this.widthFactor = 1});

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      alignment: Alignment.centerLeft,
      widthFactor: widthFactor,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.brandAccentColor(context),
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(50),
            bottomRight: Radius.circular(50),
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: AppStrings.brandName,
                style: AppTheme.brandNameSmall,
              ),
              TextSpan(
                text: ' ${AppLocalizations.of(context).brandSlogan}',
                style: AppTheme.orangeBarTextNormal,
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
