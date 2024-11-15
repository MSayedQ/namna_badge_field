import 'package:flutter/material.dart';
import 'package:namna_badge_field/namna_badge_field.dart';

class FieldBadge extends StatelessWidget {
  const FieldBadge({
    super.key,
    this.icon,
    required this.label,
    this.localize = true,
    this.endLabel,
    this.color,
  });

  final Widget? icon;
  final String label;
  final bool localize;
  final Widget? endLabel;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20,
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        children: [
          if (icon != null) icon!,
          Text(
            label,
            style: TextStyle(
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
