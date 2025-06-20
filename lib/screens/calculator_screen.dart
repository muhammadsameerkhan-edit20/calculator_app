// lib/screens/calculator_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/calculator_provider.dart';
import '../widgets/calculator_button.dart';
import '../widgets/history_drawer.dart';

class CalculatorScreen extends StatelessWidget {
  const CalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final calculator = Provider.of<CalculatorProvider>(context);
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // --- Button Styling Logic ---
    Color getButtonBackgroundColor(String text) {
      if (text == 'AC' || text == 'C') {
        return isDarkMode ? const Color(0xFF616161) : Colors.grey.shade400;
      } else if (text == '=' || _isOperator(text, calculator.showScientificFeatures) || (_isScientificFunction(text) && calculator.showScientificFeatures)) {
        // Operators and active scientific functions use primary color
        return theme.colorScheme.primary;
      } else if (text == "Sci" || text == "Std") { // Special style for Sci/Std toggle
        return calculator.showScientificFeatures
            ? theme.colorScheme.primary.withOpacity(0.8) // Active scientific mode
            : (isDarkMode ? const Color(0xFF505050) : Colors.grey.shade400); // Inactive
      }
      // Default number/operand buttons
      return isDarkMode ? const Color(0xFF424242) : Colors.grey.shade300;
    }

    Color getButtonTextColor(String text) {
      if (text == '=' || _isOperator(text, calculator.showScientificFeatures) || (_isScientificFunction(text) && calculator.showScientificFeatures)) {
        return theme.colorScheme.onPrimary;
      } else if (text == "Sci" || text == "Std") {
        return calculator.showScientificFeatures ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface;
      }
      return theme.colorScheme.onSurface;
    }

    Widget buildButtonRow(List<String> buttons) {
      return Expanded(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: buttons
              .map((text) {
            VoidCallback onPressedAction;
            String buttonDisplaytext = text;

            if (text == "_TOGGLE_SCI_") { // Placeholder for our toggle button logic
              buttonDisplaytext = calculator.showScientificFeatures ? "Std" : "Sci";
              onPressedAction = () => calculator.toggleScientificFeatures();
            } else {
              onPressedAction = () => calculator.buttonPressed(text);
            }

            return CalculatorButton(
              text: buttonDisplaytext,
              onPressed: onPressedAction,
              backgroundColor: getButtonBackgroundColor(buttonDisplaytext), // Use display text for styling
              textColor: getButtonTextColor(buttonDisplaytext),
            );
          })
              .toList(),
        ),
      );
    }

    // Determine flex values based on scientific mode
    final displayFlex = calculator.showScientificFeatures ? 2 : 3;
    final buttonsFlex = calculator.showScientificFeatures ? 8 : 7; // More rows need more space

    return Scaffold(
      appBar: AppBar(
        title: Text(calculator.showScientificFeatures ? 'Scientific Calculator' : 'Standard Calculator'),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: theme.appBarTheme.elevation ?? 4.0,
        actions: [
          IconButton(
            icon: Icon(
              calculator.themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
            ),
            tooltip: 'Toggle Theme',
            onPressed: () {
              calculator.toggleTheme();
            },
          ),
        ],
      ),
      drawer: const HistoryDrawer(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
        child: Column(
          children: <Widget>[
            // --- Display Area ---
            Expanded(
              flex: displayFlex,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                alignment: Alignment.bottomRight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        calculator.equation,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontSize: calculator.showScientificFeatures ? 28 : 32, // Adjust font size
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 8),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        calculator.result,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontSize: calculator.showScientificFeatures ? 42 : 48, // Adjust font size
                        ),
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Divider(color: theme.dividerColor, height: 15, thickness: 0.8),

            // --- Button Grid ---
            Expanded(
              flex: buttonsFlex,
              child: Column(
                children: <Widget>[
                  // Conditionally Render Scientific Rows first if shown
                  if (calculator.showScientificFeatures) ...[
                    buildButtonRow(["sin", "cos", "tan", "√"]),
                    buildButtonRow(["ln", "log", "^", "!"]),
                    buildButtonRow(["π", "e", "(", ")"]),
                  ],

                  // Standard Button Rows
                  // The first row now includes the "_TOGGLE_SCI_" placeholder
                  buildButtonRow(["_TOGGLE_SCI_", "AC", "C", "%"]),
                  buildButtonRow(["7", "8", "9", "÷"]),
                  buildButtonRow(["4", "5", "6", "×"]),
                  buildButtonRow(["1", "2", "3", "−"]),
                  buildButtonRow(["0", ".", "=", "+"]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper to identify operator buttons for styling (now checks scientific mode for functions like '^')
  bool _isOperator(String text, bool isScientificMode) {
    if (text == "^") return isScientificMode; // '^' is an operator only in scientific mode
    return text == '÷' || text == '×' || text == '−' || text == '+' || text == '%';
  }

  // Helper to identify scientific function buttons for styling
  bool _isScientificFunction(String text) {
    return text == 'sin' || text == 'cos' || text == 'tan' || text == '√' ||
        text == 'ln' || text == 'log' || text == '!' || text == 'π' || text == 'e' ||
        text == '(' || text == ')';
    // Note: '^' is handled by _isOperator based on mode.
  }
}