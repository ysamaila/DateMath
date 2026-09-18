import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class AppUtils {
  static final DateFormat shortDateFormat = DateFormat('MMM d, yyyy');
  static final DateFormat fullDateFormat = DateFormat('EEEE, MMMM d, yyyy');
  static final DateFormat isoDateFormat = DateFormat('yyyy-MM-dd');

  static String formatShort(DateTime date) => shortDateFormat.format(date);
  static String formatFull(DateTime date) => fullDateFormat.format(date);
  static String formatIso(DateTime date) => isoDateFormat.format(date);

  static void copyToClipboard(
    BuildContext context,
    String text, {
    String message = 'Copied to clipboard',
  }) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}
