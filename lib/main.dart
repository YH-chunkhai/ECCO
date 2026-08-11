import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/quotation_provider.dart';
import 'theme/app_theme.dart';
import 'views/summary_screen.dart';
import 'views/wizard_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => QuotationProvider(),
      child: const EccoSteelApp(),
    ),
  );
}

class EccoSteelApp extends StatelessWidget {
  const EccoSteelApp({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<QuotationProvider>();

    return MaterialApp(
      title: 'ECCO',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: provider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatelessWidget {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<QuotationProvider>();
    final step = provider.currentStep;

    if (step == 7) {
      return const SummaryScreen();
    }
    return const WizardScreen();
  }
}
