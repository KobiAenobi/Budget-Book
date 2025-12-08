import 'package:budget_book_app/models/budget_item.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class TopCard2 extends StatefulWidget {
  const TopCard2({super.key});

  @override
  State<TopCard2> createState() => _TopCard2State();
}

class _TopCard2State extends State<TopCard2> {
  /// Hive box reference
  final itemsBox = Hive.box<BudgetItem>('itemsBox');

  @override
  Widget build(BuildContext context) {
    // ---------------------------------------------------------
    // Convert Hive box to list & sort newest → oldest
    // ---------------------------------------------------------
    final items = itemsBox.values.toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

    // ---------------------------------------------------------
    // Calculate Grand Total
    // ---------------------------------------------------------
    int grandTotal = 0;
    for (var item in items) {
      grandTotal += item.price * item.quantity;
    }
    //Top Card Design
    return Container(
      // margin: EdgeInsets.only(bottom: 0, top: 5, left: 0, right: 0),
      // shape: RoundedRectangleBorder(
      //   side: BorderSide(color: const Color.fromARGB(255, 105, 99, 97)),
      //   borderRadius: BorderRadius.circular(10),
      // ),
      color: const Color.fromARGB(255, 24, 8, 2),
      child: Column(
        children: [
          //Top Expense Container
          Expanded(
            child: Container(
              padding: EdgeInsets.only(left: 5, right: 5),
              alignment: Alignment.centerLeft,
              child: FittedBox(
                child: Text(
                  "Top Expense",
                  style: TextStyle(
                    color: Colors.white70,
                    fontFamily: "Impact",
                    fontWeight: FontWeight.bold,
                    fontSize: 50,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
