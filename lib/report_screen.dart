import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import '../model/transaction_model.dart';
import '../model/expense_model.dart';
import '../model/bank_model.dart';
import 'SqlLiteHelper/db_helper.dart';
import 'package:excel/excel.dart' as ex;
import 'package:path_provider/path_provider.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  DBHelper db = DBHelper();

  List<TransactionModel> allTransactions = [];
  List<TransactionModel> filtered = [];

  List<ExpenseModel> expenses = [];
  List<BankModel> banks = [];

  String? selectedExpense;
  String? selectedBank;
  DateTime? fromDate;
  DateTime? toDate;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    expenses = await db.getExpenses();
    banks = await db.getBanks();
    allTransactions = await db.getTransactions();
    filtered = List.from(allTransactions);
    setState(() {});
  }

  void applyFilter() {
    filtered = allTransactions.where((t) {
      bool matchesExpense = selectedExpense == null || t.expenseName == selectedExpense;
      bool matchesBank = selectedBank == null || t.bankName == selectedBank;

      bool matchesFrom = fromDate == null ||
          DateTime.parse(t.date).isAfter(fromDate!.subtract(const Duration(days: 1)));
      bool matchesTo = toDate == null ||
          DateTime.parse(t.date).isBefore(toDate!.add(const Duration(days: 1)));

      return matchesExpense && matchesBank && matchesFrom && matchesTo;
    }).toList();

    setState(() {});
  }

  // Future<void> downloadExcel() async {
  //   if (filtered.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("No data to export")),
  //     );
  //     return;
  //   }
  //
  //   final excel = ex.Excel.createExcel();
  //   final sheet = excel['Report'];
  //
  //   // Header
  //   sheet.appendRow(["Expense", "Date", "Amount", "Payment Mode", "Bank", "Remarks"]);
  //
  //   // Rows
  //   for (var t in filtered) {
  //     sheet.appendRow([
  //       ex.TextCellValue(t.expenseName),
  //       ex.TextCellValue(t.date),
  //       ex.TextCellValue(t.amount.toString()),
  //       ex.TextCellValue(t.paymentMode),
  //       ex.TextCellValue(t.bankName),
  //       ex.TextCellValue(t.remarks),
  //     ]);
  //   }
  //
  //   // Save file
  //   final directory = await getExternalStorageDirectory();
  //   final filePath = "${directory!.path}/ExpenseReport.xlsx";
  //
  //   final bytes = excel.save();
  //   if (bytes == null) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("Failed to create Excel file")),
  //     );
  //     return;
  //   }
  //
  //   final file = File(filePath);
  //   await file.writeAsBytes(bytes, flush: true);
  //
  //   // Share
  //   Share.shareXFiles([XFile(filePath)], text: "Expense Report Downloaded");
  //
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(content: Text("Excel saved at: $filePath")),
  //   );
  // }


  Future<void> downloadExcel() async {
    if (filtered.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No data to export")),
      );
      return;
    }

    final excel = ex.Excel.createExcel();
    final sheet = excel['Sheet1'];  // Use default sheet

    // Header
    sheet.appendRow([
      "Expense",
      "Date",
      "Amount",
      "Payment Mode",
      "Bank",
      "Remarks",
    ]);

    // Data rows
    for (var t in filtered) {
      sheet.appendRow([
        t.expenseName,
        t.date,
        t.amount.toString(),
        t.paymentMode,
        t.bankName,
        t.remarks ?? "",
      ]);
    }

    // Save file
    final directory = await getExternalStorageDirectory();
    final filePath =
        "${directory!.path}/ExpenseReport_${DateTime.now().millisecondsSinceEpoch}.xlsx";

    final bytes = excel.save();
    final file = File(filePath);

    await file.writeAsBytes(bytes!, flush: true);

    Share.shareXFiles([XFile(filePath)], text: "Expense Report");

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Excel saved at: $filePath")),
    );
  }




  Future pickDate(bool isFrom) async {
    DateTime? picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        if (isFrom) fromDate = picked;
        else toDate = picked;
      });
      applyFilter();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            // Expense + Bank Filter
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField(
                    decoration: const InputDecoration(
                      labelText: "Expense",
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    value: selectedExpense,
                    items: expenses
                        .map((e) =>
                        DropdownMenuItem(value: e.name, child: Text(e.name)))
                        .toList(),
                    onChanged: (v) {
                      setState(() => selectedExpense = v);
                      applyFilter();
                    },
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: DropdownButtonFormField(
                    decoration: const InputDecoration(
                      labelText: "Bank",
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    value: selectedBank,
                    items: banks
                        .map((b) =>
                        DropdownMenuItem(value: b.bankName, child: Text(b.bankName)))
                        .toList(),
                    onChanged: (v) {
                      setState(() => selectedBank = v);
                      applyFilter();
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            // Date Filter
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => pickDate(true),
                    child: Container(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                      decoration: BoxDecoration(
                          border: Border.all(),
                          borderRadius: BorderRadius.circular(5)),
                      child: Text(
                        fromDate == null
                            ? "From Date"
                            : fromDate.toString().split(" ")[0],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: GestureDetector(
                    onTap: () => pickDate(false),
                    child: Container(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                      decoration: BoxDecoration(
                          border: Border.all(),
                          borderRadius: BorderRadius.circular(5)),
                      child: Text(
                        toDate == null ? "To Date" : toDate.toString().split(" ")[0],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: applyFilter,
                    child: const Text("Search"),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: OutlinedButton(
                    onPressed: downloadExcel,
                    child: const Text("Excel"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Data Table
            Expanded(
              child: Container(
                decoration:
                BoxDecoration(border: Border.all(color: Colors.grey.shade300)),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: MaterialStateProperty.all(Colors.green.shade100),
                      columns: const [
                        DataColumn(label: Text("Expense")),
                        DataColumn(label: Text("Date")),
                        DataColumn(label: Text("Amount")),
                        DataColumn(label: Text("Mode")),
                        DataColumn(label: Text("Bank")),
                        DataColumn(label: Text("Remarks")),
                      ],
                      rows: filtered
                          .map(
                            (t) => DataRow(cells: [
                          DataCell(Text(t.expenseName)),
                          DataCell(Text(t.date)),
                          DataCell(Text("₹${t.amount}")),
                          DataCell(Text(t.paymentMode)),
                          DataCell(Text(t.bankName)),
                          DataCell(Text(t.remarks)),
                        ]),
                      )
                          .toList(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
