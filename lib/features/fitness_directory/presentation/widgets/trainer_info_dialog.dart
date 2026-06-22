import 'package:fitnesscenter_mobile/app/config/app_theme.dart';
import 'package:fitnesscenter_mobile/app/core/shared/schemas/trainer/trainer_directory_dto.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

/// Read-only profile dialog for a directory trainer: circular photo, name,
/// discipline/club and bio. Opened from the trainers table info button.
class TrainerInfoDialog extends StatelessWidget {
  const TrainerInfoDialog({super.key, required this.trainer});

  final TrainerDirectoryDto trainer;

  static Future<void> show(BuildContext context, TrainerDirectoryDto trainer) {
    return showDialog<void>(
      context: context,
      builder: (_) => TrainerInfoDialog(trainer: trainer),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = AppTheme.brandAccentColor(context);
    final photoUrl = trainer.absolutePhotoUrl;
    final bio = trainer.bio.trim();
    final discipline = trainer.disciplineName.trim();
    final subtitle = [if (discipline.isNotEmpty) discipline].join(' · ');

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 48,
              backgroundColor: accent.withValues(alpha: 0.12),
              foregroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
              child: photoUrl == null
                  ? Icon(LucideIcons.user, size: 40, color: accent)
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              trainer.trainerName,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodySmall?.color,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 16),
            Flexible(
              child: SingleChildScrollView(
                child: Text(
                  bio.isNotEmpty ? bio : 'No bio available for this trainer.',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
