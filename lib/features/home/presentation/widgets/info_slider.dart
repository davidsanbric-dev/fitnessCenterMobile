import 'package:portfolio_mobile_app/app/config/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class InfoSlide {
  const InfoSlide({
    required this.title,
    required this.description,
    required this.callToAction,
    required this.imageAsset,
    this.imageAspectRatio,
  });

  final String title;
  final String description;
  final String callToAction;
  final String imageAsset;
  final double? imageAspectRatio;
}

class InfoSlider extends StatefulWidget {
  const InfoSlider({super.key, required this.slides});

  final List<InfoSlide> slides;

  @override
  State<InfoSlider> createState() => _InfoSliderState();
}

class _InfoSliderState extends State<InfoSlider> {
  static const double _footerHeight = 52;
  // Default matches the bundled asset (width / height).
  static const double _defaultImageAspectRatio = 1857 / 571;
  late final PageController _controller;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.slides.isEmpty) {
      return const SizedBox.shrink();
    }

    const accent = AppTheme.brandBlue;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final currentSlide = widget.slides[_currentIndex];
        final imageAspectRatio =
            currentSlide.imageAspectRatio ?? _defaultImageAspectRatio;
        final imageHeight = width / imageAspectRatio;
        final sliderHeight = imageHeight + _footerHeight;

        return Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: sliderHeight,
              child: PageView.builder(
                controller: _controller,
                padEnds: false,
                onPageChanged: (index) => setState(() => _currentIndex = index),
                itemCount: widget.slides.length,
                itemBuilder: (context, index) {
                  final slide = widget.slides[index];
                  final itemAspectRatio =
                      slide.imageAspectRatio ?? _defaultImageAspectRatio;
                  final itemImageHeight = width / itemAspectRatio;

                  return _SlideCard(
                    slide: slide,
                    imageHeight: itemImageHeight,
                    footerHeight: _footerHeight,
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.slides.length, (index) {
                final isActive = index == _currentIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: isActive ? 18 : 8,
                  decoration: BoxDecoration(
                    color: isActive ? accent : Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(8),
                  ),
                );
              }),
            ),
          ],
        );
      },
    );
  }
}

class _SlideCard extends StatelessWidget {
  const _SlideCard({
    required this.slide,
    required this.imageHeight,
    required this.footerHeight,
  });

  final InfoSlide slide;
  final double imageHeight;
  final double footerHeight;

  @override
  Widget build(BuildContext context) {
    const accent = AppTheme.brandBlue;
    final textTheme = Theme.of(context).textTheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: accent.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: imageHeight,
              child: ClipRRect(
                child: Image.asset(
                  slide.imageAsset,
                  fit: BoxFit.fitWidth,
                  errorBuilder: (context, error, stackTrace) {
                    return DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        border: Border.all(
                          color: accent.withValues(alpha: 0.4),
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          LucideIcons.imageOff,
                          color: AppTheme.brandBlue,
                          size: 36,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(
              height: footerHeight,
              child: Container(
                padding: const EdgeInsets.fromLTRB(10, 0, 16, 0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                  border: Border.all(color: accent.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            slide.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.titleMedium?.copyWith(
                              color: Colors.grey.shade800,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            slide.description,
                            maxLines: 1,
                            style: textTheme.bodyMedium?.copyWith(
                              color: Colors.grey.shade800,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          slide.callToAction,
                          style: GoogleFonts.poppins(
                            textStyle: textTheme.bodyLarge,
                            color: accent,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            decoration: TextDecoration.underline,
                            decorationColor: accent,
                            decorationThickness: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
