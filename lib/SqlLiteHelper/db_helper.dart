import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/bank_model.dart';
import '../model/expense_model.dart';
import '../model/transaction_model.dart';

class DBHelper {
  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  initDB() async {
    String path = join(await getDatabasesPath(), "expense.db");

    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database database, int version) async {
        await database.execute("""
          CREATE TABLE expenses(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            category TEXT
          )
        """);

        // Create banks table
        await database.execute("""
        CREATE TABLE banks(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          bankName TEXT,
          accountType TEXT,
          openingBalance REAL
        )
      """);

        await database.execute("""
    CREATE TABLE transactions(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    expenseName TEXT,
    date TEXT,
    amount REAL,
    paymentMode TEXT,
    bankName TEXT,
    remarks TEXT
  )
""");
      },
    );
  }

  Future<int> insertExpense(ExpenseModel expense) async {
    final dbClient = await db;
    return await dbClient.insert("expenses", expense.toMap());
  }

  Future<List<ExpenseModel>> getExpenses() async {
    final dbClient = await db;
    var res = await dbClient.query("expenses");
    return res.map((e) => ExpenseModel.fromMap(e)).toList();
  }

  Future<int> updateExpense(ExpenseModel expense) async {
    final dbClient = await db;
    return await dbClient.update(
      "expenses",
      expense.toMap(),
      where: "id = ?",
      whereArgs: [expense.id],
    );
  }

  Future<int> deleteExpense(int id) async {
    final dbClient = await db;
    return await dbClient.delete("expenses", where: "id = ?", whereArgs: [id]);
  }


// INSERT BANK
  Future<int> insertBank(BankModel bank) async {
    final dbClient = await db;
    return await dbClient.insert("banks", bank.toMap());
  }

// GET BANKS
  Future<List<BankModel>> getBanks() async {
    final dbClient = await db;
    var res = await dbClient.query("banks");
    return res.map((e) => BankModel.fromMap(e)).toList();
  }

// UPDATE BANK
  Future<int> updateBank(BankModel bank) async {
    final dbClient = await db;
    return await dbClient.update(
      "banks",
      bank.toMap(),
      where: "id = ?",
      whereArgs: [bank.id],
    );
  }

// DELETE BANK
  Future<int> deleteBank(int id) async {
    final dbClient = await db;
    return await dbClient.delete("banks", where: "id = ?", whereArgs: [id]);
  }



  // INSERT TRANSACTION
  Future<int> insertTransaction(TransactionModel t) async {
    final dbClient = await db;
    return await dbClient.insert("transactions", t.toMap());
  }

// GET TRANSACTIONS
  Future<List<TransactionModel>> getTransactions() async {
    final dbClient = await db;
    var res = await dbClient.query("transactions");
    return res.map((e) => TransactionModel.fromMap(e)).toList();
  }

// UPDATE TRANSACTION
  Future<int> updateTransaction(TransactionModel t) async {
    final dbClient = await db;
    return await dbClient.update(
      "transactions",
      t.toMap(),
      where: "id = ?",
      whereArgs: [t.id],
    );
  }

// DELETE TRANSACTION
  Future<int> deleteTransaction(int id) async {
    final dbClient = await db;
    return await dbClient.delete("transactions", where: "id = ?", whereArgs: [id]);
  }

}
