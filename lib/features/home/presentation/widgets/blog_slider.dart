import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import 'package:portfolio_mobile_app/app/core/shared/schemas/blog/blog_dto.dart';
import 'package:portfolio_mobile_app/features/home/presentation/widgets/info_slider.dart';

/// Home info-slider variant backed by company-scoped blog entries. Each slide
/// shows the blog hero image and title; tapping opens a dialog with the full
/// markdown content. Read-only (the web admin owns CRUD).
class BlogSlider extends StatefulWidget {
  const BlogSlider({super.key, required this.blogs});

  final List<BlogDto> blogs;

  @override
  State<BlogSlider> createState() => _BlogSliderState();
}

class _BlogSliderState extends State<BlogSlider> {
  static const double _footerHeight = 52;
  // Match the promotional info-slider's image space so blog heroes render in the
  // same compact banner area on home.
  static const double _imageAspectRatio = InfoSlider.defaultImageAspectRatio;
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

  void _openBlog(BlogDto blog) {
    showDialog<void>(
      context: context,
      builder: (context) => _BlogDetailDialog(blog: blog),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.blogs.isEmpty) {
      return const SizedBox.shrink();
    }

    final accent = Theme.of(context).colorScheme.primary;
    final inactiveDot = Theme.of(context).dividerColor;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final imageHeight = width / _imageAspectRatio;
        final sliderHeight = imageHeight + _footerHeight;

        return Column(
          children: [
            SizedBox(
              height: sliderHeight,
              child: PageView.builder(
                controller: _controller,
                padEnds: false,
                onPageChanged: (index) => setState(() => _currentIndex = index),
                itemCount: widget.blogs.length,
                itemBuilder: (context, index) {
                  final blog = widget.blogs[index];
                  return _BlogSlideCard(
                    blog: blog,
                    imageHeight: imageHeight,
                    footerHeight: _footerHeight,
                    onTap: () => _openBlog(blog),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.blogs.length, (index) {
                final isActive = index == _currentIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: isActive ? 18 : 8,
                  decoration: BoxDecoration(
                    color: isActive ? accent : inactiveDot,
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

class _BlogSlideCard extends StatelessWidget {
  const _BlogSlideCard({
    required this.blog,
    required this.imageHeight,
    required this.footerHeight,
    required this.onTap,
  });

  final BlogDto blog;
  final double imageHeight;
  final double footerHeight;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accent = colorScheme.primary;
    final textTheme = theme.textTheme;
    final cardSurface = colorScheme.surface;
    final captionColor = colorScheme.onSurface.withValues(alpha: 0.85);

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: cardSurface,
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
                child: _BlogHeroImage(
                  url: blog.absoluteHeroImageUrl,
                  // Fit the whole hero within the info-slider image space
                  // instead of cropping it.
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(
                height: footerHeight,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(10, 0, 16, 0),
                  decoration: BoxDecoration(
                    color: cardSurface,
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
                        child: Text(
                          blog.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.titleMedium?.copyWith(
                            color: captionColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Flexible(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'Read more',
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
      ),
    );
  }
}

class _BlogHeroImage extends StatelessWidget {
  const _BlogHeroImage({required this.url, this.fit = BoxFit.cover});

  final String? url;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = colorScheme.primary;

    Widget placeholder() => DecoratedBox(
      decoration: BoxDecoration(color: colorScheme.surfaceContainerHighest),
      child: Center(
        child: Icon(LucideIcons.imageOff, color: accent, size: 36),
      ),
    );

    final imageUrl = url;
    if (imageUrl == null) {
      return placeholder();
    }

    return Image.network(
      imageUrl,
      fit: fit,
      width: double.infinity,
      loadingBuilder: (context, child, progress) {
        if (progress == null) {
          return child;
        }
        return DecoratedBox(
          decoration: BoxDecoration(color: colorScheme.surfaceContainerHighest),
          child: const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) => placeholder(),
    );
  }
}

class _BlogDetailDialog extends StatelessWidget {
  const _BlogDetailDialog({required this.blog});

  final BlogDto blog;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageUrl = blog.absoluteHeroImageUrl;

    return Dialog(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.82,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (imageUrl != null)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: _BlogHeroImage(url: imageUrl),
              ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      blog.title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 12),
                    MarkdownBody(
                      data: blog.text.isEmpty ? '_No content_' : blog.text,
                      shrinkWrap: true,
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 12, 10),
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
