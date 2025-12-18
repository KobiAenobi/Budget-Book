import 'dart:developer';

import 'package:animations/animations.dart';
import 'package:budget_book_app/apis/api.dart';
import 'package:budget_book_app/models/budget_item.dart';
import 'package:budget_book_app/screens/top_expenses_screen.dart';
import 'package:budget_book_app/widgets/item_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class TopCard2 extends StatefulWidget {
  final double containerHeight;
  final double containerWidth;
  const TopCard2({
    super.key,
    required this.containerHeight,
    required this.containerWidth,
  });

  @override
  State<TopCard2> createState() => _TopCard2State();
}

class _TopCard2State extends State<TopCard2> {
  /// Hive box reference
  final itemsBox = Hive.box<BudgetItem>('itemsBox');
  List<MapEntry<String, int>> sortedExpenseList = [];

  @override
  void initState() {
    super.initState();
    _prepareData();
    itemsBox.listenable().addListener(_onItemsChanged);
  }

  void _onItemsChanged() {
    setState(() {
      _prepareData();
    });
  }

  @override
  void dispose() {
    itemsBox.listenable().removeListener(_onItemsChanged);
    super.dispose();
  }

  void _prepareData() {
    // ---------------------------------------------------------
    // Convert Hive box to list & sort newest → oldest
    // ---------------------------------------------------------
    final items = itemsBox.values.toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

    final currMont = DateTime.now().month;

    final Map<String, int> totalSpentByItem = {};

    for (final item in items) {
      if (item.dateTime.month == currMont) {
        totalSpentByItem[item.name] =
            (totalSpentByItem[item.name] ?? 0) + (item.price * item.quantity);
      }
    }

    // final topEntry = totalSpentByItem.entries.reduce(
    //   (a, b) => a.value >= b.value ? a : b,
    // );

    // final SortedEntries = totalSpentByItem.entries.toList()
    //   ..sort((a, b) => b.value.compareTo(a.value));

    // if (SortedEntries.isNotEmpty) {
    //   log("top ex: ${SortedEntries[0].key} ,${SortedEntries[0].value}");
    // }

    sortedExpenseList = totalSpentByItem.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // final List<BudgetItem> sortedByExpense = items.where((item) {
    //   return item.dateTime.month == currMont;
    // }).toList();

    // sortedByExpense.sort((a, b) {
    //   return (b.price * b.quantity).compareTo(a.price * a.quantity);
    // });

    // log("top expense: ${sortedByExpense[0].quantity}");
    // final topItem = sortedByExpense[0];
    // log(
    //   "top expense: ₹${topItem.price * topItem.quantity} "
    //   "(price=${topItem.price}, qty=${topItem.quantity})",
    // );

    // final List<BudgetItem> sortedByExpense =items.where((item)=>item.dateTime.month==currMont).toList();

    // sortedByExpense.sort((a, b){
    //   return (b.price*b.quantity).compareTo(a.price*a.quantity);
    // });

    //
    // final Map<String, int> topExpenseItems;

    // items.forEach(){

    // }

    // ---------------------------------------------------------
    // Calculate Grand Total
    // ---------------------------------------------------------
    int grandTotal = 0;
    for (var item in items) {
      grandTotal += item.price * item.quantity;
    }
  }

  @override
  Widget build(BuildContext context) {
    final myThemeVar = Theme.of(context);
    //Top Card Design
    return Container(
      // margin: EdgeInsets.only(bottom: 0, top: 5, left: 0, right: 0),
      // shape: RoundedRectangleBorder(
      //   side: BorderSide(color: const Color.fromARGB(255, 105, 99, 97)),
      //   borderRadius: BorderRadius.circular(10),
      // ),
      color: Colors.transparent,
      // color: myThemeVar.cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //Top Expense Container
          Container(
            // color: Colors.blue,
            padding: EdgeInsets.only(left: 5, right: 5),
            // alignment: Alignment.centerLeft,
            child: FittedBox(
              child: Text(
                "Top Expenses",
                style: TextStyle(
                  color: myThemeVar.colorScheme.primary,
                  fontFamily: "Impact",
                  fontWeight: FontWeight.bold,
                  fontSize: 50,
                ),
              ),
            ),
          ),

          //
          Expanded(
            child: Container(
              padding: EdgeInsets.only(top: 5, bottom: 5),
              color: Colors.transparent,
              child: OpenContainer(
                closedColor: Colors.transparent,
                closedElevation: 0,
                openElevation: 0,
                transitionType: ContainerTransitionType.fadeThrough,
                // transitionDuration: Duration(milliseconds: 250),
                closedBuilder: (context, action) {
                  //TOP EXPENSES CARD
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: BorderSide(color: myThemeVar.dividerColor),
                    ),
                    // color: Colors.transparent,
                    color: myThemeVar.scaffoldBackgroundColor,
                    elevation: 3,
                    child: Container(
                      // decoration: BoxDecoration(
                      //   borderRadius: BorderRadius.circular(15),
                      //   image: DecorationImage(
                      //     image: AssetImage("assets/bg/card_paper_bg_light.jpg"),
                      //     fit: BoxFit.cover,
                      //   ),
                      // ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final itemCount = sortedExpenseList.length.clamp(
                            1,
                            4,
                          );
                          // final itemHeight = constraints.maxHeight / itemCount;
                          final rowHeight = constraints.maxHeight / itemCount;

                          return ListView.builder(
                            // physics: const NeverScrollableScrollPhysics(),
                            // shrinkWrap: true,
                            // itemCount: itemCount,
                            itemCount: sortedExpenseList.length,
                            itemExtent: rowHeight,
                            itemBuilder: (context, index) {
                              final entry = sortedExpenseList[index];

                              final itemName = entry.key;
                              final totalPrice = entry.value;
                              //////////////////////////////////////////
                              return Card(
                                // color: myThemeVar.cardColor,
                                elevation: 0,
                                // margin: EdgeInsets.all(5),
                                color: Colors.transparent,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(width: 20),
                                    Text(
                                      "${index + 1}.",
                                      style: TextStyle(
                                        fontSize: 11,
                                        // fontWeight: FontWeight.bold,
                                        fontFamily:
                                            GoogleFonts.manrope().fontFamily,
                                      ),
                                    ),
                                    SizedBox(width: 20),

                                    Text(
                                      "${itemName}",
                                      style: TextStyle(
                                        color: myThemeVar.colorScheme.primary,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w900,
                                        fontFamily:
                                            GoogleFonts.manrope().fontFamily,
                                      ),
                                    ),
                                    Spacer(),

                                    Text(
                                      "₹${totalPrice}",
                                      style: TextStyle(
                                        fontSize: 12,
                                        // fontWeight: FontWeight.bold,
                                        fontFamily:
                                            GoogleFonts.poppins().fontFamily,
                                      ),
                                    ),
                                    SizedBox(width: 20),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  );
                },
                openBuilder: (context, action) {
                  return TopExpensesScreen(
                    containerHeight: MediaQuery.of(context).size.height,
                    containerWidth: MediaQuery.of(context).size.width,
                  );
                },
              ),
            ),
          ),

          //items
          // Container(
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //     children: [Text("SNo. "), Text("NAME: "), Text("Price")],
          //   ),
          // ),
        ],
      ),
    );
  }
}
