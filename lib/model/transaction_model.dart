class TransactionModel {
  int? id;
  String expenseName;
  String date;
  double amount;
  String paymentMode;
  String bankName;
  String remarks;

  TransactionModel({
    this.id,
    required this.expenseName,
    required this.date,
    required this.amount,
    required this.paymentMode,
    required this.bankName,
    required this.remarks,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "expenseName": expenseName,
      "date": date,
      "amount": amount,
      "paymentMode": paymentMode,
      "bankName": bankName,
      "remarks": remarks,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map["id"],
      expenseName: map["expenseName"],
      date: map["date"],
      amount: map["amount"],
      paymentMode: map["paymentMode"],
      bankName: map["bankName"],
      remarks: map["remarks"],
    );
  }
}
