import 'package:flutter/material.dart';
import 'package:accountanter/theme/app_colors.dart';

class KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color borderColor;
  final String change; // Still accepting for placeholder
  final bool isPositiveChange; // Still accepting for placeholder


  const KpiCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.borderColor,
    this.change = '', // Default to empty
    this.isPositiveChange = true, // Default
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: borderColor, width: 4)),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        ),
        child: SingleChildScrollView(
          child: Padding(
          padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: textTheme.bodyMedium),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.muted,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon, size: 20, color: AppColors.mutedForeground),
                    ),
                  ],
                ),
              const SizedBox(height: 12),
                Text(
                  value,
                  style: textTheme.headlineMedium?.copyWith(
                    fontFamily: 'monospace',
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 4),
                // We keep this part for the placeholder data in other sections
                // but it will be empty for the live data for now.
                if (change.isNotEmpty)
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: change,
                          style: TextStyle(
                            color: isPositiveChange ? AppColors.success : AppColors.destructive,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextSpan(
                          text: ' from last month',
                          style: textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}