import 'package:flutter/material.dart';
import 'SqlLiteHelper/db_helper.dart';
import 'model/expense_model.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  final TextEditingController expenseNameController = TextEditingController();
  String? selectedCategory;
  ExpenseModel? editingExpense;

  final List<String> categories = [
    "Food",
    "Transport",
    "Utilities",
    "Entertainment",
    "Health",
    "Other"
  ];

  final DBHelper dbHelper = DBHelper();
  List<ExpenseModel> expenseList = [];

  @override
  void initState() {
    super.initState();
    loadExpenses();
  }

  void loadExpenses() async {
    expenseList = await dbHelper.getExpenses();
    setState(() {});
  }

  void saveExpense() async {
    if (expenseNameController.text.isEmpty || selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields!")),
      );
      return;
    }

    // If editing, update instead of insert
    if (editingExpense != null) {
      await dbHelper.updateExpense(
        ExpenseModel(
          id: editingExpense!.id,
          name: expenseNameController.text,
          category: selectedCategory!,
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Expense Updated!")),
      );

      editingExpense = null;   // exit edit mode
    } else {
      // Insert new expense
      await dbHelper.insertExpense(
        ExpenseModel(
          name: expenseNameController.text,
          category: selectedCategory!,
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Expense Saved!")),
      );
    }

    resetFields();
    loadExpenses();
  }


  void resetFields() {
    setState(() {
      expenseNameController.clear();
      selectedCategory = null;
      editingExpense = null;   // exit edit mode
    });
  }

  void deleteExpense(int id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirm Delete"),
          content: const Text("Do you want to delete this expense?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                await dbHelper.deleteExpense(id);
                Navigator.of(context).pop();
                loadExpenses(); // Refresh list
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Expense deleted")),
                );
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }


  void editExpense(ExpenseModel expense) {
    setState(() {
      editingExpense = expense;
      expenseNameController.text = expense.name;
      selectedCategory = expense.category;
    });
  }


  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          children: [

            TextField(
              controller: expenseNameController,
              decoration: const InputDecoration(
                labelText: "Expense Name",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: const InputDecoration(
                labelText: "Category",
                border: OutlineInputBorder(),
              ),
              items: categories.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value;
                });
              },
            ),

            const SizedBox(height: 15),

            // Row(
            //   children: [
            //     Expanded(
            //       child: ElevatedButton(
            //         onPressed: saveExpense,
            //         style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            //         child: Text(editingExpense == null ? "Save" : "Update"),
            //       ),
            //     ),
            //     const SizedBox(width: 10),
            //     Expanded(
            //       child: ElevatedButton(
            //         onPressed: resetFields,
            //         style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            //         child: const Text("Reset"),
            //       ),
            //     ),
            //   ],
            // ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center, // center the buttons
              children: [
                ElevatedButton(
                  onPressed: saveExpense,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1D69F6),
                    minimumSize: const Size(80, 40), // width, height
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6), // box-like shape
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: Text(editingExpense == null ? "Save" : "Update"),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: resetFields,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF666667),
                    minimumSize: const Size(80, 40),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Text("Reset"),
                ),
              ],
            ),


            const SizedBox(height: 20),

            const Text(
              "Saved Expenses",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: expenseList.length,
              itemBuilder: (context, index) {
                final exp = expenseList[index];
                return Card(
                  child: ListTile(
                    title: Text(exp.name),
                    subtitle: Text(exp.category),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.green),
                          onPressed: () => editExpense(exp),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deleteExpense(exp.id!),
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
    );
  }
}
