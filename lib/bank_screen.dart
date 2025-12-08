import 'package:flutter/material.dart';
import 'SqlLiteHelper/db_helper.dart';
import 'model/bank_model.dart';

class BankScreen extends StatefulWidget {
  const BankScreen({super.key});

  @override
  State<BankScreen> createState() => _BankScreenState();
}

class _BankScreenState extends State<BankScreen> {
  final TextEditingController bankNameController = TextEditingController();
  final TextEditingController openingBalanceController = TextEditingController();
  String? selectedAccountType;

  final List<String> accountTypes = ["Saving", "Current", "Cash", "Card", "UPI"];

  final DBHelper dbHelper = DBHelper();
  List<BankModel> bankList = [];

  BankModel? editingBank;

  @override
  void initState() {
    super.initState();
    loadBanks();
  }

  void loadBanks() async {
    bankList = await dbHelper.getBanks();
    setState(() {});
  }

  void saveBank() async {
    if (bankNameController.text.isEmpty ||
        selectedAccountType == null ||
        openingBalanceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields!")),
      );
      return;
    }

    double balance = double.tryParse(openingBalanceController.text) ?? 0;

    if (editingBank != null) {
      // update
      await dbHelper.updateBank(
        BankModel(
          id: editingBank!.id,
          bankName: bankNameController.text,
          accountType: selectedAccountType!,
          openingBalance: balance,
        ),
      );
      editingBank = null;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bank Updated!")),
      );
    } else {
      // insert
      await dbHelper.insertBank(
        BankModel(
          bankName: bankNameController.text,
          accountType: selectedAccountType!,
          openingBalance: balance,
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bank Saved!")),
      );
    }

    resetFields();
    loadBanks();
  }

  void resetFields() {
    setState(() {
      bankNameController.clear();
      openingBalanceController.clear();
      selectedAccountType = null;
      editingBank = null;
    });
  }

  void editBank(BankModel bank) {
    setState(() {
      editingBank = bank;
      bankNameController.text = bank.bankName;
      selectedAccountType = bank.accountType;
      openingBalanceController.text = bank.openingBalance.toString();
    });
  }

  void deleteBank(int id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirm Delete"),
          content: const Text("Do you want to delete this bank?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                await dbHelper.deleteBank(id);
                Navigator.of(context).pop();
                loadBanks();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Bank deleted")),
                );
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          children: [
            TextField(
              controller: bankNameController,
              decoration: const InputDecoration(
                labelText: "Bank Name",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: selectedAccountType,
              decoration: const InputDecoration(
                labelText: "Account Type",
                border: OutlineInputBorder(),
              ),
              items: accountTypes.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedAccountType = value;
                });
              },
            ),

            const SizedBox(height: 12),

            TextField(
              controller: openingBalanceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Opening Balance",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            // Row(
            //   children: [
            //     Expanded(
            //       child: ElevatedButton(
            //         onPressed: saveBank,
            //         style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            //         child: Text(editingBank == null ? "Save" : "Update"),
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
                  onPressed: saveBank,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1D69F6),
                    minimumSize: const Size(80, 40), // width, height
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6), // box-like shape
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: Text(editingBank == null ? "Save" : "Update"),
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
              "Saved Banks",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: bankList.length,
              itemBuilder: (context, index) {
                final bank = bankList[index];
                return Card(
                  child: ListTile(
                    title: Text(bank.bankName),
                    subtitle: Text("${bank.accountType} | ${bank.openingBalance}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.green),
                          onPressed: () => editBank(bank),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deleteBank(bank.id!),
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
