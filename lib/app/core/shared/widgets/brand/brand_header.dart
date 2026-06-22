import 'package:fitnesscenter_mobile/app/core/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:fitnesscenter_mobile/app/config/app_theme.dart';
import 'package:fitnesscenter_mobile/app/core/shared/widgets/brand/brand_logo.dart';

class BrandHeader extends StatelessWidget {
  final String variant; // 'small' o 'large'
  final bool includeLogo;

  const BrandHeader({
    super.key,
    this.variant = 'large',
    this.includeLogo = true,
  });

  @override
  Widget build(BuildContext context) {
    late final TextStyle textStyle;
    late final EdgeInsets logoPadding;
    late final double logoHeight;

    switch (variant) {
      case 'small':
        textStyle = AppTheme.brandNameSmall;
        logoPadding = const EdgeInsets.only(top: 14.0);
        logoHeight = 40.0;
        break;
      case 'extralarge':
        textStyle = AppTheme.brandNameExtraLarge;
        logoPadding = const EdgeInsets.only(top: 28.0);
        logoHeight = 64.0;
        break;
      default:
        textStyle = AppTheme.brandNameLarge;
        logoPadding = const EdgeInsets.only(top: 32.0);
        logoHeight = 50.0;
        break;
    }

    final spacing = variant == 'extralarge' ? 10.0 : 8.0;

    return Padding(
      padding: logoPadding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (includeLogo) BrandLogo(height: logoHeight),
          if (includeLogo) SizedBox(width: spacing),
          Flexible(
            child: RichText(
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: textStyle,
                children: const [
                  // TextSpan(text: AppStrings.brandSubtitle),
                  TextSpan(text: AppStrings.brandName),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
