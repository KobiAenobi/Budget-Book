import 'dart:developer';

import 'package:budget_book_app/apis/api.dart';
import 'package:budget_book_app/helper/date_time_helper.dart';
import 'package:budget_book_app/models/budget_item.dart';
import 'package:budget_book_app/widgets/month_card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';

class Itemdatascreen extends StatefulWidget {
  final double containerHeight;

  final double containerWidth;

  final String itemName;

  const Itemdatascreen({
    super.key,
    required this.containerHeight,
    required this.containerWidth,
    required this.itemName,
  });

  @override
  State<Itemdatascreen> createState() => _ItemdatascreenState();
}

class _ItemdatascreenState extends State<Itemdatascreen> {
  //FORMMATTED MONTH AND YEAR FOR THE LISTVIEWBUILDER
  String formatMonth(String key) {
    final year = int.parse(key.split('-')[0]);
    final month = int.parse(key.split('-')[1]);

    const monthNames = [
      "", // index 0 unused
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];

    return "${monthNames[month]} $year";
  }

  /// Hive box reference
  final itemsBox = Hive.box<BudgetItem>('itemsBox');
  @override
  Widget build(BuildContext context) {
    log("Item Name: ${widget.itemName}");
    // ---------------------------------------------------------
    // Convert Hive box to list & sort newest → oldest
    // ---------------------------------------------------------
    final items = itemsBox.values.toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

    final currMont = DateTime.now().month;

    final grouped = Api.groupItemsByMonth(items);

    final List<dynamic> displayList = [];

    grouped.forEach((monthKey, monthItems) {
      final filteredItems = monthItems
          .where(
            (item) =>
                item.name.trim().toLowerCase() ==
                widget.itemName.trim().toLowerCase(),
          )
          .toList();

      if (filteredItems.isEmpty) return;

      final total = filteredItems.fold<int>(
        0,
        (sum, item) => sum + (item.price * item.quantity),
      );

      final totalQty = filteredItems.fold<int>(
        0,
        (sum, item) => sum + item.quantity,
      );

      // 👉 Month header
      displayList.add({
        'month': monthKey,
        'total': total,
        'totalQty': totalQty,
      });

      // 👉 Items
      displayList.addAll(filteredItems);
    });

    final int overallTotalQty = displayList.whereType<BudgetItem>().fold<int>(
      0,
      (sum, item) => sum + item.quantity,
    );

    // final Map<String, int> totalSpentByItem = {};
    final List<dynamic> ItemList = [];

    for (final item in items) {
      if (item.dateTime.month == currMont &&
          item.name.trim().toLowerCase() ==
              widget.itemName.trim().toLowerCase()) {
        ItemList.add(item);
        log("item added: ${item.name}");
      }
      // log("items: ${item.name}");
    }
    // log("list lenght: ${ItemList.length}");

    // final topEntry = totalSpentByItem.entries.reduce(
    //   (a, b) => a.value >= b.value ? a : b,
    // );

    // final SortedEntries = totalSpentByItem.entries.toList()
    //   ..sort((a, b) => b.value.compareTo(a.value));

    // if (SortedEntries.isNotEmpty) {
    //   log("top ex: ${SortedEntries[0].key} ,${SortedEntries[0].value}");
    // }

    // final List<MapEntry<String, int>> sortedExpenseList =
    //     totalSpentByItem.entries.toList()
    //       ..sort((a, b) => b.value.compareTo(a.value));

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
    // num grandTotal = 0;
    // for (var item in ItemList) {
    //   grandTotal += item.price * item.quantity;
    // }

    final now = DateTime.now();
    final int currMonthQty = items
        .where((item) {
          return item.dateTime.year == now.year &&
              item.dateTime.month == now.month &&
              item.name.trim().toLowerCase() ==
                  widget.itemName.trim().toLowerCase();
        })
        .fold<int>(0, (sum, item) => sum + item.quantity);
    // final currentMonthKey =
    //     "${now.year}-${now.month.toString().padLeft(2, '0')}";

    final myThemeVar = Theme.of(context);
    return Scaffold(
      extendBody: true,
      backgroundColor: myThemeVar.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: myThemeVar.scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        title: Text(
          "Item Information",
          style: TextStyle(
            fontFamily: GoogleFonts.workSans().fontFamily,
            fontWeight: FontWeight.w900,
            fontSize: myThemeVar.textTheme.bodyLarge!.fontSize,
          ),
        ),
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //Top Expense Container
          Container(
            // height: MediaQuery.of(context).size.height * 0.5,
            // width: double.infinity,
            // height: MediaQuery.of(context).size.height * 0.25,
            // color: Colors.red,
            // height: MediaQuery.of(context).size.height * 0.25,
            // color: Colors.blue,
            padding: EdgeInsets.only(left: 5, right: 5),
            // alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.only(left: 10),
                  height: 100,
                  child: FittedBox(
                    child: Text(
                      "${widget.itemName}",
                      style: TextStyle(
                        color: myThemeVar.colorScheme.primary,
                        fontFamily: "Impact",
                        fontWeight: FontWeight.bold,
                        fontSize: 1000,
                      ),
                    ),
                  ),
                ),

                Row(
                  children: [
                    // Container(
                    //   width: MediaQuery.of(context).size.width * 0.5,
                    //   // height: MediaQuery.of(context).size.height * 0.5,
                    //   child: FittedBox(
                    //     child: Text(
                    //       "",

                    //       style: TextStyle(
                    //         color: myThemeVar.colorScheme.primary,
                    //         fontFamily: "Impact",
                    //         fontWeight: FontWeight.bold,
                    //         fontSize: 1000,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    Flexible(
                      child: FittedBox(
                        child: Container(
                          padding: EdgeInsets.only(left: 10),
                          child: currMonthQty == 1
                              ? Text(
                                  "Only one this month",
                                  //   in\n${formatMonth("${DateTime.now().year}-${DateTime.now().month}")}",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontFamily:
                                        GoogleFonts.manrope().fontFamily,
                                  ),
                                )
                              : currMonthQty == 2
                              ? Text(
                                  "Only two this month",
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontFamily:
                                        GoogleFonts.manrope().fontFamily,
                                  ),
                                )
                              : Text(
                                  "${currMonthQty} this month",
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontFamily:
                                        GoogleFonts.manrope().fontFamily,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Text(
                //   "Expenses",
                //   style: TextStyle(
                //     color: myThemeVar.colorScheme.primary,
                //     fontFamily: "Impact",
                //     fontWeight: FontWeight.bold,
                //     fontSize: 1000,
                //   ),
                // ),
              ],
            ),
          ),

          //
          Flexible(
            child: Container(
              child: Column(
                children: [
                  // Container(
                  //   padding: EdgeInsets.only(
                  //     left: 10,
                  //     right: 30,
                  //     top: 10,
                  //     bottom: 10,
                  //   ),
                  //   width: double.infinity,
                  //   child: Text(
                  //     "$grandTotal",
                  //     textAlign: TextAlign.right,
                  //     style: TextStyle(
                  //       fontFamily: GoogleFonts.manrope().fontFamily,
                  //     ),
                  //   ),
                  // ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: displayList.length,
                      itemBuilder: (context, index) {
                        final entry = displayList[index];

                        // ================= MONTH CARD =================
                        if (entry is Map) {
                          return MonthCard(
                            month: formatMonth(entry['month']),
                            total: entry['total'],
                            qtyByMonth: entry['totalQty'],
                            containerHeight: 60,
                            containerWidth: double.infinity,
                            monthCardColor: myThemeVar.cardColor,
                            colorDuration: 300,
                          );
                        }

                        // ================= ITEM CARD =================
                        if (entry is BudgetItem) {
                          final serialNo =
                              displayList
                                  .sublist(0, index)
                                  .where((e) => e is BudgetItem)
                                  .length +
                              1;
                          final itm = entry;

                          return Card(
                            color: myThemeVar.cardColor,
                            margin: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                              side: BorderSide(
                                color: Theme.of(context).dividerColor,
                                width: 1,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  // SERIAL NO
                                  SizedBox(
                                    width: widget.containerWidth * 0.1,
                                    child: Text(
                                      "$serialNo.",
                                      style: TextStyle(
                                        fontSize: 11,
                                        // fontWeight: FontWeight.bold,
                                        fontFamily:
                                            GoogleFonts.manrope().fontFamily,
                                      ),
                                    ),
                                  ),

                                  // ITEM NAME + DATE
                                  SizedBox(
                                    width: widget.containerWidth * 0.4,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Api.oneLineScroll(
                                          itm.name,
                                          TextStyle(
                                            color:
                                                myThemeVar.colorScheme.primary,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            fontFamily: GoogleFonts.manrope()
                                                .fontFamily,
                                          ),
                                        ),
                                        Api.oneLineScroll(
                                          formatDateTime(itm.dateTime),
                                          TextStyle(
                                            fontSize: 11,
                                            color: myThemeVar
                                                .colorScheme
                                                .secondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // QTY
                                  Flexible(
                                    child: SizedBox(
                                      width: widget.containerWidth * 0.14,
                                      child: Text(
                                        "qty:${itm.quantity}",
                                        style: TextStyle(
                                          color: myThemeVar.colorScheme.primary,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          fontFamily:
                                              GoogleFonts.manrope().fontFamily,
                                        ),
                                      ),
                                    ),
                                  ),

                                  // PRICE
                                  Flexible(
                                    child: SizedBox(
                                      width: widget.containerWidth * 0.15,
                                      child: Text(
                                        "₹${itm.price * itm.quantity}",
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          // color: myThemeVar.colorScheme.primary,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          fontFamily:
                                              GoogleFonts.manrope().fontFamily,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ],
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
