import 'package:expense/home_screen.dart';
import 'package:expense/report_screen.dart';
import 'package:expense/transaction_screen.dart';
import 'package:flutter/material.dart';
import 'bank_screen.dart';
import 'expense_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expenses',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF2065E3)),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2065E3),
          foregroundColor: Colors.white,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: Color(0xFF2065E3),
          unselectedItemColor: Colors.grey,
        ),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int selectedIndex = 0;

  final List<Widget> screens = [
    const HomeScreen(),
    const ExpenseScreen(),
    const BankScreen(),
    const TransactionScreen(),
    const ReportScreen(),
  ];

  final List<String> titles = [
    "Home",
    "Expense Master",
    "Bank",
    "Transaction",
    "Report",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF2065E3),
        title: Text(titles[selectedIndex]),
      ),

      body: screens[selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Color(0xFF2065E3),
        unselectedItemColor: Colors.grey,

        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },

        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.money), label: "Expense"),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_balance), label: "Bank"),
          BottomNavigationBarItem(
              icon: Icon(Icons.swap_horiz), label: "Transaction"),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart), label: "Report"),
        ],
      ),
    );
  }
}
