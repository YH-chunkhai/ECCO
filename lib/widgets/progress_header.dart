import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quotation_provider.dart';
import '../theme/app_theme.dart';

class ProgressHeader extends StatelessWidget {
  const ProgressHeader({super.key});

  static const List<String> stepTitles = [
    'Step 1: Choose Grade',
    'Step 2: Select Size',
    'Step 3: Sheet Dimensions',
    'Step 4: Sequential Discounts',
    'Step 5: Order Quantity',
    'Step 6: Quotation Terms',
    'Official Quotation Summary',
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<QuotationProvider>();
    final step = provider.currentStep;
    final isDark = provider.isDarkMode;

    double fillPercentage = step >= 7 ? 1.0 : step / 6.0;
    String stepTitle = stepTitles[step - 1];
    String stepCounter = step >= 7 ? 'Summary' : 'Step $step of 6';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                stepTitle,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primary,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                stepCounter,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppTheme.textDarkMuted : AppTheme.textLightMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: fillPercentage,
              minHeight: 6,
              backgroundColor: isDark ? Colors.white10 : Colors.black12,
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}
