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
    final effectiveAccent = accentColor ?? theme.colorScheme.primary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: effectiveAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, size: 18, color: effectiveAccent),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                if (copyPayload != null && copyPayload!.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.copy_rounded, size: 20),
                    tooltip: 'Copy result',
                    visualDensity: VisualDensity.compact,
                    onPressed: () {
                      AppUtils.copyToClipboard(
                        context,
                        copyPayload!,
                        message: 'Copied "$primaryValue" to clipboard',
                      );
                    },
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              primaryValue,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            if (subtitle != null && subtitle!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                subtitle!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
                ),
              ),
            ],
            if (content != null) ...[
              const SizedBox(height: 12),
              content!,
            ],
          ],
        ),
      ),
    );
  }
}
