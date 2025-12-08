class BankModel {
  int? id;
  String bankName;
  String accountType;
  double openingBalance;

  BankModel({
    this.id,
    required this.bankName,
    required this.accountType,
    required this.openingBalance,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bankName': bankName,
      'accountType': accountType,
      'openingBalance': openingBalance,
    };
  }

  factory BankModel.fromMap(Map<String, dynamic> map) {
    return BankModel(
      id: map['id'],
      bankName: map['bankName'],
      accountType: map['accountType'],
      openingBalance: map['openingBalance'],
    );
  }
}
