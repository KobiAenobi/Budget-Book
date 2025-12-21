import 'package:hive/hive.dart';

part 'budget_item.g.dart';


@HiveType(typeId: 1)
class BudgetItem extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int quantity;

  @HiveField(3)
  int price;

  @HiveField(4)
  DateTime dateTime;

  @HiveField(5)
  String imagePath;


  BudgetItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.price,
    required this.dateTime,
    required this.imagePath,
  });

  // --------------------------------------------------------
  // FIRESTORE: Convert model → Map (UPLOAD to Firestore)
  // --------------------------------------------------------
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'price': price,
      'dateTime': dateTime.toIso8601String(),
      'imagePath': imagePath,
    };
  }

  // --------------------------------------------------------
  // FIRESTORE: Convert Map → model (DOWNLOAD from Firestore)
  // --------------------------------------------------------
  factory BudgetItem.fromMap(Map<String, dynamic> map) {
    return BudgetItem(
      id: map['id'],
      name: map['name'],
      quantity: map['quantity'],
      price: map['price'],
      dateTime: DateTime.parse(map['dateTime']),
      imagePath: map['imagePath'],
    );
  }
}