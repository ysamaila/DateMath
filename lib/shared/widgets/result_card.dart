import 'package:flutter/material.dart';
import '../../core/utils/app_utils.dart';

class ResultCard extends StatelessWidget {
  final String title;
  final String primaryValue;
  final String? subtitle;
  final Widget? content;
  final String? copyPayload;
  final Color? accentColor;
  final IconData? icon;

  const ResultCard({
    super.key,
    required this.title,
    required this.primaryValue,
    this.subtitle,
    this.content,
    this.copyPayload,
    this.accentColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: 18,
                    color: accentColor ?? theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (copyPayload != null && copyPayload!.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.copy_outlined, size: 18),
                    tooltip: 'Copy',
                    visualDensity: VisualDensity.compact,
                    onPressed: () {
                      AppUtils.copyToClipboard(
                        context,
                        copyPayload!,
                        message: 'Copied to clipboard',
                      );
                    },
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              primaryValue,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            if (subtitle != null && subtitle!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            if (content != null) ...[
              const SizedBox(height: 10),
              content!,
            ],
          ],
        ),
      ),
    );
  }
}
