// lib/widgets/history_drawer.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/calculator_provider.dart';

class HistoryDrawer extends StatelessWidget {
  const HistoryDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final calculator = Provider.of<CalculatorProvider>(context);
    final history = calculator.history;

    return Drawer(
      backgroundColor: const Color(0xFF282828),
      child: Column(
        children: <Widget>[
          AppBar(
            title: const Text(
                'Calculation History', style: TextStyle(color: Colors.white)),
            automaticallyImplyLeading: false, // No back button
            backgroundColor: Theme
                .of(context)
                .primaryColor,
            actions: [
              IconButton(
                icon: const Icon(Icons.delete_sweep, color: Colors.white),
                tooltip: 'Clear History',
                onPressed: () {
                  // Confirmation dialog
                  showDialog(
                    context: context,
                    builder: (BuildContext ctx) {
                      return AlertDialog(
                        backgroundColor: const Color(0xFF303030),
                        title: const Text('Clear History?', style: TextStyle(
                            color: Colors.white)),
                        content: const Text(
                            'Are you sure you want to delete all history entries?',
                            style: TextStyle(color: Colors.white70)),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('Cancel',
                                style: TextStyle(color: Colors.orangeAccent)),
                            onPressed: () {
                              Navigator.of(ctx).pop();
                            },
                          ),
                          TextButton(
                            child: const Text('Clear',
                                style: TextStyle(color: Colors.redAccent)),
                            onPressed: () {
                              calculator.clearHistory();
                              Navigator.of(ctx).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
          Expanded(
            child: history.isEmpty
                ? const Center(
              child: Text(
                'No history yet.',
                style: TextStyle(color: Colors.white70, fontSize: 18),
              ),
            )
                : ListView.separated(
              itemCount: history.length,
              separatorBuilder: (context, index) =>
                  Divider(color: Colors.grey[700], indent: 16, endIndent: 16),
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    history[index].split('=')[0].trim(), // Expression part
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  trailing: Text(
                    '= ${history[index].split('=')[1].trim()}', // Result part
                    style: const TextStyle(color: Colors.orangeAccent,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  // Optional: onTap to reuse history item
                  // onTap: () {
                  //   // Logic to use this history item in the calculator
                  //   // calculator.setEquationFromResult(history[index]);
                  //   Navigator.pop(context); // Close drawer
                  // },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}