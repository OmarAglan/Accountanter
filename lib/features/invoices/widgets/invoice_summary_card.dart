import 'package:flutter/material.dart';

class InvoiceSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const InvoiceSummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        // Applying FittedBox to prevent overflow by scaling down the content
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                value,
                style: textTheme.headlineSmall?.copyWith(
                  fontFamily: 'monospace',
                  color: color,
                  fontSize: 24,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}