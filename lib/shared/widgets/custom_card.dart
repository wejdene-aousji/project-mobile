import 'package:flutter/material.dart';

/// Custom Card Widget
class CustomCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final Color? backgroundColor;
  final double elevation;
  final BorderRadius? borderRadius;

  const CustomCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.backgroundColor,
    this.elevation = 2,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation,
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
      margin: margin,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius ?? BorderRadius.circular(8),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

/// Chip Widget
class CustomChip extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;

  const CustomChip({
    super.key,
    required this.label,
    this.onTap,
    this.onDelete,
    this.backgroundColor,
    this.textColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      onDeleted: onDelete,
      backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.surfaceVariant,
      labelStyle: TextStyle(
        color: textColor ?? Theme.of(context).colorScheme.onSurface,
      ),
      avatar: icon != null ? Icon(icon) : null,
    );
  }
}
