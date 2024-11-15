import 'package:flutter/material.dart';
import 'package:namna_badge_field/namna_badge_field.dart';

class FieldBadge extends StatelessWidget {
  const FieldBadge({
    required this.label,
    super.key,
    this.icon,
    this.localize = true,
    this.endLabel,
    this.color,
    this.height,
    this.style,
  });

  final String label;
  //?coming soon
  final bool localize;
  final Widget? icon;
  final Widget? endLabel;
  final Color? color;
  final double? height;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 20,
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        children: [
          if (icon != null) icon!,
          Text(
            label,
            style: style ??
                TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
          ),
          5.spaceW,
          endLabel ?? const SizedBox.shrink(),
        ],
      ),
    );
  }
}
