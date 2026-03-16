import 'package:flutter/material.dart';
import 'package:acme_killer_mobile_app/core/constants/app_colors.dart';

class AlertBanner extends StatelessWidget {
  final String message;
  final Color color;
  final IconData icon;
  final String actionLabel;
  final VoidCallback? onAction;

  const AlertBanner({
    super.key,
    required this.message,
    required this.color,
    required this.icon,
    this.actionLabel = 'View',
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message,
                style: TextStyle(color: color, fontSize: 12, height: 1.4)),
          ),
          GestureDetector(
            onTap: onAction,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(actionLabel,
                      style: TextStyle(
                          color: color,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(width: 3),
                  Icon(Icons.arrow_forward_ios_rounded, size: 9, color: color),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
