import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../SqlLiteHelper/db_helper.dart';
import '../model/transaction_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DBHelper db = DBHelper();
  Map<String, double> expenseSummary = {};
  Map<String, Color> expenseColors = {};

  @override
  void initState() {
    super.initState();
    loadGraphData();
  }

  Color generateColor() {
    final random = Random();
    return Color.fromARGB(
      255,
      random.nextInt(180),
      random.nextInt(180),
      random.nextInt(180),
    );
  }

  Future<void> loadGraphData() async {
    final transactions = await db.getTransactions();
    final now = DateTime.now();

    Map<String, double> temp = {};

    for (var t in transactions) {
      DateTime d = DateTime.parse(t.date);

      if (d.month == now.month && d.year == now.year) {
        temp[t.expenseName] =
            (temp[t.expenseName] ?? 0) + double.parse(t.amount.toString());

        expenseColors.putIfAbsent(t.expenseName, () => generateColor());
      }
    }

    setState(() => expenseSummary = temp);
  }

  @override
  Widget build(BuildContext context) {
    final bars = expenseSummary.entries.toList();

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [

              const SizedBox(height: 10),

              const Text(
                "Expense Overview",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              // White Card Container like screenshot
              Container(
                height: 350,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      spreadRadius: 1,
                      offset: Offset(0, 4),
                    )
                  ],
                ),
                padding: const EdgeInsets.all(16),

                child: bars.isEmpty
                    ? const Center(child: Text("No Data For Current Month"))
                    : BarChart(
                  BarChartData(
                    maxY: (expenseSummary.values.isEmpty)
                        ? 100
                        : expenseSummary.values.reduce((a, b) => a > b ? a : b) + 50,

                    gridData: FlGridData(
                      show: true,
                      drawHorizontalLine: true,
                      horizontalInterval: 50,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: Colors.grey.shade300,
                        strokeWidth: 1,
                      ),
                    ),

                    borderData: FlBorderData(show: false),

                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            int index = value.toInt();
                            if (index >= bars.length) return Container();
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                bars[index].key,
                                style: const TextStyle(fontSize: 12),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 35,
                        ),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),

                    barGroups: List.generate(
                      bars.length,
                          (i) => BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: bars[i].value,
                            width: 35,
                            borderRadius: BorderRadius.circular(6),
                            color: expenseColors[bars[i].key],
                          ),
                        ],
                        showingTooltipIndicators: [0],
                      ),
                    ),

                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        // tooltipBgColor: Colors.transparent, // use tooltipBgColor instead of backgroundColor
                        tooltipPadding: EdgeInsets.zero,    // use tooltipPadding instead of padding
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          return BarTooltipItem(
                            rod.toY.toString(),
                            const TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    ),


                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
