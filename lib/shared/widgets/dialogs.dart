import 'package:flutter/material.dart';

/// Error Dialog
class ErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;
  final String? retryLabel;

  const ErrorDialog({
    super.key,
    this.title = 'Error',
    required this.message,
    this.onRetry,
    this.retryLabel = 'Retry',
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(
        child: Text(message),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        if (onRetry != null)
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onRetry!.call();
            },
            child: Text(retryLabel ?? 'Retry'),
          ),
      ],
    );
  }

  /// Show error dialog
  static Future<void> show(
    BuildContext context, {
    String title = 'Error',
    required String message,
    VoidCallback? onRetry,
    String? retryLabel,
  }) {
    return showDialog(
      context: context,
      builder: (context) => ErrorDialog(
        title: title,
        message: message,
        onRetry: onRetry,
        retryLabel: retryLabel,
      ),
    );
  }
}

/// Success Dialog
class SuccessDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? buttonLabel;
  final VoidCallback? onDismiss;

  const SuccessDialog({
    super.key,
    required this.title,
    required this.message,
    this.buttonLabel = 'OK',
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(title)),
        ],
      ),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onDismiss?.call();
          },
          child: Text(buttonLabel ?? 'OK'),
        ),
      ],
    );
  }

  /// Show success dialog
  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    String? buttonLabel,
    VoidCallback? onDismiss,
  }) {
    return showDialog(
      context: context,
      builder: (context) => SuccessDialog(
        title: title,
        message: message,
        buttonLabel: buttonLabel,
        onDismiss: onDismiss,
      ),
    );
  }
}

/// Confirmation Dialog
class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? confirmLabel;
  final String? cancelLabel;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final Color? confirmColor;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
    required this.onConfirm,
    this.onCancel,
    this.confirmColor,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onCancel?.call();
          },
          child: Text(cancelLabel ?? 'Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirm.call();
          },
          style: TextButton.styleFrom(
            foregroundColor: confirmColor ?? Theme.of(context).colorScheme.error,
          ),
          child: Text(confirmLabel ?? 'Confirm'),
        ),
      ],
    );
  }

  /// Show confirmation dialog
  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
    String? confirmLabel,
    String? cancelLabel,
    Color? confirmColor,
  }) {
    return showDialog(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        onConfirm: onConfirm,
        onCancel: onCancel,
        confirmColor: confirmColor,
      ),
    );
  }
}
