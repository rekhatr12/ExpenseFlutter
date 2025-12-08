class ExpenseModel {
  int? id;
  String name;
  String category;

  ExpenseModel({this.id, required this.name, required this.category});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
    };
  }

  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id'],
      name: map['name'],
      category: map['category'],
    );
  }
}
