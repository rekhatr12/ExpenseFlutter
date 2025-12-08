import 'package:flutter/material.dart';
import '../model/expense_model.dart';
import '../model/bank_model.dart';
import '../model/transaction_model.dart';
import 'SqlLiteHelper/db_helper.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  final DBHelper dbHelper = DBHelper();

  String? selectedExpense;
  String? selectedBank;
  String? selectedPaymentMode;

  DateTime selectedDate = DateTime.now();

  TextEditingController amountController = TextEditingController();
  TextEditingController remarksController = TextEditingController();

  List<ExpenseModel> expenses = [];
  List<BankModel> banks = [];
  List<TransactionModel> transactions = [];

  int? editingId;

  @override
  void initState() {
    super.initState();
    loadMasterData();
    loadTransactions();
  }

  loadMasterData() async {
    expenses = await dbHelper.getExpenses();
    banks = await dbHelper.getBanks();
    setState(() {});
  }

  loadTransactions() async {
    transactions = await dbHelper.getTransactions();
    setState(() {});
  }

  resetForm() {
    selectedExpense = null;
    selectedBank = null;
    selectedPaymentMode = null;
    amountController.clear();
    remarksController.clear();
    selectedDate = DateTime.now();
    editingId = null;
    setState(() {});
  }

  saveTransaction() async {
    if (selectedExpense == null ||
        selectedPaymentMode == null ||
        amountController.text.isEmpty) return;

    TransactionModel model = TransactionModel(
      id: editingId,
      expenseName: selectedExpense!,
      date: selectedDate.toIso8601String().split("T")[0],
      amount: double.tryParse(amountController.text) ?? 0,
      paymentMode: selectedPaymentMode!,
      bankName: selectedBank ?? "",
      remarks: remarksController.text,
    );

    if (editingId == null) {
      await dbHelper.insertTransaction(model);
    } else {
      await dbHelper.updateTransaction(model);
    }

    resetForm();
    loadTransactions();
  }

  editTransaction(TransactionModel t) {
    editingId = t.id;
    selectedExpense = t.expenseName;
    selectedBank = t.bankName;
    selectedPaymentMode = t.paymentMode;
    amountController.text = t.amount.toString();
    remarksController.text = t.remarks;
    selectedDate = DateTime.parse(t.date);

    setState(() {});
  }

  deleteTransaction(int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Delete Transaction"),
        content: Text("Are you sure you want to delete this transaction?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel")),
          TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await dbHelper.deleteTransaction(id);
                loadTransactions();
              },
              child: Text("Delete"))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: Text("Transaction")),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField(
                  decoration: const InputDecoration(
                    labelText: "Expense",
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    border: OutlineInputBorder(),
                  ),
                  value: selectedExpense,
                  items: expenses
                      .map((e) =>
                      DropdownMenuItem(value: e.name, child: Text(e.name)))
                      .toList(),
                  onChanged: (val) => setState(() => selectedExpense = val),
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Date: ${selectedDate.toString().split(' ')[0]}",
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        DateTime? d = await showDatePicker(
                          context: context,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                          initialDate: selectedDate,
                        );
                        if (d != null) setState(() => selectedDate = d);
                      },
                      child: const Text("Pick Date"),
                    )
                  ],
                ),

                const SizedBox(height: 8),

                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Amount",
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 8),

                DropdownButtonFormField(
                  decoration: const InputDecoration(
                    labelText: "Payment Mode",
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    border: OutlineInputBorder(),
                  ),
                  value: selectedPaymentMode,
                  items: [
                    "Cash",
                    "Card",
                    "UPI",
                    "NetBanking",
                    "Cheque",
                  ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (v) => setState(() => selectedPaymentMode = v),
                ),

                const SizedBox(height: 8),

                DropdownButtonFormField(
                  decoration: const InputDecoration(
                    labelText: "Bank",
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    border: OutlineInputBorder(),
                  ),
                  value: selectedBank,
                  items: banks
                      .map((b) => DropdownMenuItem(
                    value: b.bankName,
                    child: Text(b.bankName),
                  ))
                      .toList(),
                  onChanged: (v) => setState(() => selectedBank = v),
                ),

                const SizedBox(height: 8),

                TextField(
                  controller: remarksController,
                  decoration: const InputDecoration(
                    labelText: "Remarks",
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 12),

                // Row(
                //   children: [
                //     Expanded(
                //       child: ElevatedButton(
                //         onPressed: saveTransaction,
                //         style: ElevatedButton.styleFrom(
                //             backgroundColor: Colors.green,
                //             padding: const EdgeInsets.symmetric(vertical: 10)),
                //         child: const Text("Save"),
                //       ),
                //     ),
                //     const SizedBox(width: 10),
                //     Expanded(
                //       child: ElevatedButton(
                //         onPressed: resetForm,
                //         style: ElevatedButton.styleFrom(
                //           backgroundColor: Colors.red,
                //           padding: const EdgeInsets.symmetric(vertical: 10),
                //         ),
                //         child: const Text("Reset"),
                //       ),
                //     ),
                //   ],
                // ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center, // center buttons
                  children: [
                    ElevatedButton(
                      onPressed: saveTransaction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF1D69F6),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(80, 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6), // box shape
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      child: const Text("Save"),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: resetForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF8B8C8E),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(80, 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      child: const Text("Reset"),
                    ),
                  ],
                ),


                const SizedBox(height: 15),

                const Text(
                  "Transactions",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 6),

                ListView.builder(
                  itemCount: transactions.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final t = transactions[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        dense: true,
                        title: Text(
                          "${t.expenseName} - ₹${t.amount}",
                          style: const TextStyle(fontSize: 14),
                        ),
                        subtitle: Text(
                          "${t.date} | ${t.paymentMode}",
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, size: 20),
                              onPressed: () => editTransaction(t),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                              onPressed: () => deleteTransaction(t.id!),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
    );
  }
}
