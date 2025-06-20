// lib/providers/calculator_provider.dart
import 'dart:math' as math; // For pi, e, sqrt, log, etc.
import 'package:flutter/material.dart'; // For ThemeMode
import 'package:math_expressions/math_expressions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CalculatorProvider with ChangeNotifier {
  String _equation = "0";
  String _result = "0";
  String _expression = "";
  List<String> _history = [];
  ThemeMode _themeMode = ThemeMode.dark; // Default to dark
  bool _showScientificFeatures = false; // <<< --- ADDED THIS LINE

  // --- Getters ---
  String get equation => _equation;
  String get result => _result;
  List<String> get history => List.unmodifiable(_history);
  ThemeMode get themeMode => _themeMode;
  bool get showScientificFeatures => _showScientificFeatures; // <<< --- ADDED THIS LINE

  // For trigonometric functions, decide on degrees or radians
  // Let's assume degrees for input and convert to radians for math functions
  bool _isDegrees = true; // True for degrees, false for radians

  CalculatorProvider() {
    _loadHistory();
    _loadThemePreference();
    // Optionally, load the scientific mode preference here too
    // _loadScientificModePreference();
  }

  // <<< --- ADDED THIS METHOD --- >>>
  void toggleScientificFeatures() async {
    _showScientificFeatures = !_showScientificFeatures;
    // Optionally, save this preference
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.setBool('show_scientific', _showScientificFeatures);
    notifyListeners();
  }

  // Optional: Method to load scientific mode preference
  // Future<void> _loadScientificModePreference() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   _showScientificFeatures = prefs.getBool('show_scientific') ?? false;
  //   notifyListeners();
  // }

  void toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', _themeMode == ThemeMode.light ? 'light' : 'dark');
    notifyListeners();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    String? theme = prefs.getString('theme_mode');
    if (theme == 'light') {
      _themeMode = ThemeMode.light;
    } else {
      _themeMode = ThemeMode.dark; // Default to dark if not set
    }
    notifyListeners();
  }

  void _addHistoryEntry(String entry) {
    _history.insert(0, entry);
    if (_history.length > 30) {
      _history.removeLast();
    }
    _saveHistory();
    notifyListeners();
  }

  void clearHistory() {
    _history.clear();
    _saveHistory();
    notifyListeners();
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('calculator_history', _history);
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    _history = prefs.getStringList('calculator_history') ?? [];
    notifyListeners();
  }


  // --- Helper for Degrees/Radians ---
  double _toRadians(double degrees) => degrees * (math.pi / 180);
  double _toDegrees(double radians) => radians * (180 / math.pi);

  // --- Button Press Logic ---
  void buttonPressed(String buttonText) {
    // --- Clear Functions ---
    if (buttonText == "AC") {
      _equation = "0";
      _result = "0";
      _expression = "";
    } else if (buttonText == "C") {
      if (_equation.isNotEmpty && _equation != "0") {
        _equation = _equation.substring(0, _equation.length - 1);
        if (_equation.isEmpty) { // Also trim internal expression when clearing last char
          _equation = "0";
          _expression = ""; // Reset expression if equation becomes 0
        } else {
          _expression = _expression.substring(0, _expression.length - 1);
        }
      }
    }
    // --- Equals ---
    else if (buttonText == "=") {
      // Prepare expression: replace user-friendly symbols with math_expressions compatible ones
      _expression = _equation
          .replaceAll('×', '*')
          .replaceAll('÷', '/')
          .replaceAll('√', 'sqrt') // Assuming sqrt(number) format
          .replaceAll('π', math.pi.toString()) // Replace with actual value
          .replaceAll('e', math.e.toString())   // Replace with actual value
          .replaceAllMapped(RegExp(r'sin\(([^)]+)\)'), (match) { // sin(value)
        double val = double.parse(match.group(1)!);
        return math.sin(_isDegrees ? _toRadians(val) : val).toString();
      })
          .replaceAllMapped(RegExp(r'cos\(([^)]+)\)'), (match) { // cos(value)
        double val = double.parse(match.group(1)!);
        return math.cos(_isDegrees ? _toRadians(val) : val).toString();
      })
          .replaceAllMapped(RegExp(r'tan\(([^)]+)\)'), (match) { // tan(value)
        double val = double.parse(match.group(1)!);
        return math.tan(_isDegrees ? _toRadians(val) : val).toString();
      })
          .replaceAllMapped(RegExp(r'ln\(([^)]+)\)'), (match) { // ln(value)
        double val = double.parse(match.group(1)!);
        return math.log(val).toString(); // math.log is natural log
      })
          .replaceAllMapped(RegExp(r'log\(([^)]+)\)'), (match) { // log(value) base 10
        double val = double.parse(match.group(1)!);
        return (math.log(val) / math.ln10).toString();
      })
          .replaceAllMapped(RegExp(r'(\d+)!'), (match) { // Factorial: number!
        int num = int.parse(match.group(1)!);
        return _factorial(num).toString();
      });
      // Power (^) is usually handled directly by math_expressions

      try {
        Parser p = Parser();
        Expression exp = p.parse(_expression);
        ContextModel cm = ContextModel();
        // math_expressions handles basic arithmetic, power (^), and common functions like sqrt if formatted as sqrt(value)
        // For pi and e, we've replaced them with their values, so they are just numbers to the parser.

        double evalResult = exp.evaluate(EvaluationType.REAL, cm);

        String formattedResult = _formatResult(evalResult);
        String historyEntry = "$_equation = $formattedResult";
        _result = formattedResult;
        _addHistoryEntry(historyEntry);
        _equation = _result; // Allow chaining
        _expression = _result; // Prepare for next operation

      } catch (e) {
        _result = "Error"; // Simplified error
        // For debugging: _result = "Error: ${e.toString()}";
      }
    }
    // --- Scientific Functions & Constants ---
    // These now mostly append to the equation string.
    // The actual calculation happens when '=' is pressed.
    else if (buttonText == "√") {
      _appendToEquation("√("); // Expect user to add number and )
    } else if (buttonText == "sin" || buttonText == "cos" || buttonText == "tan" || buttonText == "ln" || buttonText == "log") {
      _appendToEquation("$buttonText(");
    } else if (buttonText == "!") {
      _appendToEquation("!"); // Typically suffix
    } else if (buttonText == "π") {
      _appendToEquation("π");
    } else if (buttonText == "e") {
      _appendToEquation("e");
    } else if (buttonText == "^") {
      _appendToEquation("^");
    } else if (buttonText == "(") {
      _appendToEquation("(");
    } else if (buttonText == ")") {
      _appendToEquation(")");
    }
    // --- Default: Append to equation (Numbers, Operators, Decimal) ---
    else {
      _appendToEquation(buttonText);
    }
    notifyListeners();
  }

  void _appendToEquation(String text) {
    if (_result == _equation && !_isOperator(text) && text != "(" && text != "√(") {
      // If the current equation is a result from previous calculation,
      // and user types a number (not operator or opening function/paren), start a new equation.
      _equation = text;
    } else if (_equation == "0" && text != "." && !_isOperator(text) && text != "(" && text != "√(" && text != "π" && text != "e") {
      // If equation is "0" and new input is not decimal, operator, or opening function, replace "0"
      _equation = text;
    } else {
      _equation += text;
    }
    // Simple update for internal expression. More complex parsing might be needed.
    // _expression = _equation.replaceAll('×', '*').replaceAll('÷', '/');
  }


  bool _isOperator(String buttonText) {
    return buttonText == "+" || buttonText == "−" || buttonText == "×" || buttonText == "÷" || buttonText == "^" || buttonText == "%";
  }

  String _formatResult(double evalResult) {
    if (evalResult.isNaN || evalResult.isInfinite) return "Error";
    // Check if the number is very close to an integer.
    if ((evalResult - evalResult.truncate()).abs() < 1e-9) { // Using a small epsilon
      return evalResult.truncate().toString();
    }
    // Format to a certain number of decimal places, then remove trailing zeros and dot.
    String formatted = evalResult.toStringAsFixed(7); // Max 7 decimal places
    formatted = formatted.replaceAll(RegExp(r'0*$'), ''); // Remove trailing zeros
    formatted = formatted.replaceAll(RegExp(r'\.$'), '');   // Remove trailing decimal point
    return formatted;
  }

  int _factorial(int n) {
    if (n < 0) throw ArgumentError("Factorial of negative number is undefined");
    if (n > 20) throw ArgumentError("Factorial of large number not supported"); // Prevent overflow/long computation
    if (n == 0) return 1;
    int result = 1;
    for (int i = 2; i <= n; i++) {
      result *= i;
    }
    return result;
  }
}