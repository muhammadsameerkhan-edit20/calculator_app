// lib/widgets/calculator_button.dart
import 'package:flutter/material.dart';

class CalculatorButton extends StatelessWidget {
  final String text;
  final Color? textColor;
  final Color? backgroundColor;
  final VoidCallback onPressed;
  final double? fontSize;

  const CalculatorButton({
    super.key,
    required this.text,
    this.textColor, // Will be provided by CalculatorScreen based on theme
    this.backgroundColor, // Will be provided by CalculatorScreen
    required this.onPressed,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Use default text style from theme, allow override for specific needs
    final buttonTextStyle = theme.textTheme.titleLarge?.copyWith(
      color: textColor ?? theme.colorScheme.onSurface, // Default if not provided
      fontSize: fontSize ?? theme.textTheme.titleLarge?.fontSize,
      fontWeight: FontWeight.w500,
    );

    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(5.0), // Slightly reduced margin
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? theme.colorScheme.surface, // Default if not provided
            foregroundColor: textColor ?? theme.colorScheme.onSurface, // For ripple, focus
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0), // Adjusted padding
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0), // Slightly smaller radius
            ),
            elevation: 1,
          ),
          child: Text(
            text,
            style: buttonTextStyle,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}