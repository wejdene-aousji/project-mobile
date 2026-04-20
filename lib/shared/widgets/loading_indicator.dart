import 'package:flutter/material.dart';

/// Custom Loading Indicator
class CustomLoadingIndicator extends StatelessWidget {
  final String? message;
  final Color? color;
  final double size;

  const CustomLoadingIndicator({
    super.key,
    this.message,
    this.color,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: size,
            width: size,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation(
                color ?? Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Page Loading Scaffold
class LoadingScaffold extends StatelessWidget {
  final String? message;
  final AppBar? appBar;

  const LoadingScaffold({
    super.key,
    this.message,
    this.appBar,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: CustomLoadingIndicator(message: message),
    );
  }
}
