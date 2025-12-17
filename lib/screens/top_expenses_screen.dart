import 'package:animations/animations.dart';
import 'package:budget_book_app/apis/api.dart';
import 'package:budget_book_app/models/budget_item.dart';
import 'package:budget_book_app/screens/itemDataScreen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';

class TopExpensesScreen extends StatefulWidget {
  final double containerHeight;

  final double containerWidth;

  const TopExpensesScreen({
    super.key,
    required this.containerHeight,
    required this.containerWidth,
  });

  @override
  State<TopExpensesScreen> createState() => _TopExpensesScreenState();
}

class _TopExpensesScreenState extends State<TopExpensesScreen> {
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
    final now = DateTime.now();
    final currentMonthKey =
        "${now.year}-${now.month.toString().padLeft(2, '0')}";

    // ---------------------------------------------------------
    // Convert Hive box to list & sort newest → oldest
    // ---------------------------------------------------------
    final items = itemsBox.values.toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

    final currMont = DateTime.now().month;

    final Map<String, int> totalSpentByItem = {};
    final Map<String, int> totalQtyByItem = {};

    for (final item in items) {
      if (item.dateTime.month == currMont) {
        totalSpentByItem[item.name] =
            (totalSpentByItem[item.name] ?? 0) + (item.price * item.quantity);

        totalQtyByItem[item.name] =
            (totalQtyByItem[item.name] ?? 0) + (item.quantity);
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

    final List<MapEntry<String, int>> sortedExpenseList =
        totalSpentByItem.entries.toList()
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

    final myThemeVar = Theme.of(context);
    return Scaffold(
      extendBody: true,
      backgroundColor: myThemeVar.cardColor,
      appBar: AppBar(
        backgroundColor: myThemeVar.cardColor,
        surfaceTintColor: Colors.transparent,
        title: Text(
          "Top Expenses",
          style: TextStyle(
            fontFamily: GoogleFonts.workSans().fontFamily,
            fontWeight: FontWeight.w900,
            fontSize: myThemeVar.textTheme.bodyLarge!.fontSize,
          ),
        ),
      ),

      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [myThemeVar.cardColor, myThemeVar.cardColor],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //Top Expense Container
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.2,
              color: Colors.transparent,
              // height: MediaQuery.of(context).size.height * 0.25,
              // color: Colors.blue,
              padding: EdgeInsets.only(left: 5, right: 5, bottom: 10),

              // alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.1,
                      child: FittedBox(
                        child: Text(
                          "Top Expenses",
                          style: TextStyle(
                            color: myThemeVar.colorScheme.primary,
                            fontFamily: "Impact",
                            fontWeight: FontWeight.bold,
                            fontSize: 1000,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Flexible(
                  //   child: SizedBox(
                  //     height: MediaQuery.of(context).size.height * 0.15,
                  //     child: FittedBox(
                  //       child: Text(
                  //         "Expenses",
                  //         style: TextStyle(
                  //           color: myThemeVar.colorScheme.primary,
                  //           fontFamily: "Impact",
                  //           fontWeight: FontWeight.bold,
                  //           fontSize: 1000,
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  FittedBox(
                    child: Text(
                      "of ${formatMonth(currentMonthKey)}",
                      style: myThemeVar.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),

            //
            Expanded(
              // flex: 3,
              child: Container(
                child: ListView.builder(
                  itemCount: sortedExpenseList.length,
                  itemBuilder: (context, index) {
                    final entry = sortedExpenseList[index];

                    final itemName = entry.key;
                    final totalPrice = entry.value;

                    final totalQty = totalQtyByItem[itemName];
                    //////////////////////////////////////////
                    return OpenContainer(
                      closedElevation: 0,
                      closedColor: Colors.transparent,
                      closedBuilder: (context, action) {
                        return Card(
                          // Space between cards in list
                          margin: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            // side: widget.isRight
                            //     ? BorderSide(color: Colors.transparent, width: 0)
                            side: BorderSide(
                              color: myThemeVar.dividerColor,
                              width: 1,
                            ),
                            // borderRadius: widget.isRight
                            //     ? BorderRadius.circular(0)
                            borderRadius: BorderRadius.circular(15),
                          ),
                          // color: const Color.fromARGB(255, 24, 8, 2),
                          color: myThemeVar.cardColor,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                // ==================================================================
                                // Sno.
                                // ==================================================================
                                SizedBox(
                                  width: widget.containerWidth * 0.1,
                                  child: Text(
                                    "${index + 1}.",
                                    style: TextStyle(
                                      fontSize: 11,
                                      // fontWeight: FontWeight.bold,
                                      fontFamily:
                                          GoogleFonts.manrope().fontFamily,
                                    ),
                                  ),
                                ),
                                // ==================================================================
                                // 📝 ITEM NAME + Qty bought
                                // ==================================================================
                                SizedBox(
                                  width: widget.containerWidth * 0.6,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // SINGLE-LINE SCROLLABLE ITEM NAME
                                      Api.oneLineScroll(
                                        itemName,
                                        TextStyle(
                                          color: myThemeVar.colorScheme.primary,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          fontFamily:
                                              GoogleFonts.manrope().fontFamily,
                                        ),
                                      ),

                                      // ----------------------------------------------------------------
                                      // Formatted date/time below item name
                                      // formatDateTime() is your custom helper function
                                      // ----------------------------------------------------------------
                                      Api.oneLineScroll(
                                        totalQty == 1
                                            ? "Only Once this month"
                                            : totalQty == 2
                                            ? "Only Twice this month"
                                            : "${totalQty} times this month",
                                        TextStyle(
                                          fontSize: 11,
                                          // fontFamily:
                                          //     GoogleFonts.manrope().fontFamily,
                                          color:
                                              myThemeVar.colorScheme.secondary,
                                        ),
                                      ),
                                      // ----------------------------------------------------------------
                                      // COMMENTED OUT — EXACTLY KEPT AS PROVIDED
                                      // ----------------------------------------------------------------
                                      // Text(
                                      //   "${widget.date.day} ${monthNames[widget.date.month - 1]} ",
                                      // ),
                                    ],
                                  ),
                                ),
                                // Spacer(),
                                // ==================================================================
                                // 📦 QUANTITY DISPLAY
                                // ==================================================================
                                // Flexible(
                                //   child: SizedBox(
                                //     width: widget.containerWidth * 0,
                                //     child: Text(
                                //       // "qty: ${3}",
                                //       "",
                                //       style: TextStyle(
                                //         color: myThemeVar.colorScheme.primary,
                                //         fontSize: 14,
                                //         fontWeight: FontWeight.w700,
                                //         fontFamily:
                                //             GoogleFonts.manrope().fontFamily,
                                //       ),
                                //     ),
                                //   ),
                                // ),
                                // ==================================================================
                                // 💰 PRICE DISPLAY (price × quantity)
                                // ==================================================================
                                Flexible(
                                  child: SizedBox(
                                    width: widget.containerWidth * 0.15,
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        "₹${totalPrice}",
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          fontSize: 12,
                                          // fontWeight: FontWeight.bold,
                                          fontFamily:
                                              GoogleFonts.poppins().fontFamily,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                // ==================================================================
                                // COMMENTED OUT EDIT ICON BUTTON (Kept untouched)
                                // ==================================================================
                                // IconButton(
                                //   icon: Icon(Icons.edit, color: Colors.white),
                                //   onPressed: widget.onEdit,
                                // ),
                              ],
                            ),
                            // child: Row(
                            //   children: [
                            //     // ICON
                            //     Expanded(
                            //       flex: 1,
                            //       child: Icon(Icons.shopping_cart, color: Colors.white54),
                            //     ),
                            //     // NAME + DATE
                            //     Expanded(
                            //       flex: 4,
                            //       child: Column(
                            //         crossAxisAlignment: CrossAxisAlignment.start,
                            //         children: [
                            //           Api.oneLineScroll(
                            //             widget.name,
                            //             TextStyle(
                            //               color: Colors.white,
                            //               fontSize: 14,
                            //               fontWeight: FontWeight.w700,
                            //               fontFamily: GoogleFonts.manrope().fontFamily,
                            //             ),
                            //           ),
                            //           Api.oneLineScroll(
                            //             formatDateTime(widget.date),
                            //             TextStyle(fontSize: 11, color: Colors.white54),
                            //           ),
                            //         ],
                            //       ),
                            //     ),
                            //     // QTY
                            //     Expanded(
                            //       flex: 2,
                            //       child: Text(
                            //         "qty: ${widget.quantity}",
                            //         style: TextStyle(color: Colors.white),
                            //       ),
                            //     ),
                            //     // PRICE
                            //     Expanded(
                            //       flex: 2,
                            //       child: Text(
                            //         "₹${widget.price * widget.quantity}",
                            //         textAlign: TextAlign.right,
                            //         style: TextStyle(color: Colors.white),
                            //       ),
                            //     ),
                            //   ],
                            // ),
                          ),
                        );
                      },
                      openBuilder: (context, action) {
                        return Itemdatascreen(
                          containerHeight: MediaQuery.of(context).size.height,
                          containerWidth: MediaQuery.of(context).size.width,
                          itemName: itemName,
                        );
                      },
                    );
                    // Card(
                    //   color: myThemeVar.cardColor,
                    //   elevation: 0,
                    //   // margin: EdgeInsets.all(5),
                    //   // color: Colors.red,
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.start,
                    //     children: [
                    //       SizedBox(width: 20),
                    //       Text(
                    //         "${index + 1}",
                    //         style: TextStyle(
                    //           color: myThemeVar.colorScheme.primary,
                    //           fontSize: 14,
                    //           fontWeight: FontWeight.w700,
                    //           fontFamily: GoogleFonts.manrope().fontFamily,
                    //         ),
                    //       ),
                    //       SizedBox(width: 20),

                    //       Text(
                    //         "${itemName}",
                    //         style: TextStyle(
                    //           color: myThemeVar.colorScheme.primary,
                    //           fontSize: 14,
                    //           fontWeight: FontWeight.w700,
                    //           fontFamily: GoogleFonts.manrope().fontFamily,
                    //         ),
                    //       ),
                    //       Spacer(),

                    //       Text(
                    //         "${totalPrice}",
                    //         style: TextStyle(
                    //           color: myThemeVar.colorScheme.primary,
                    //           fontSize: 14,
                    //           fontWeight: FontWeight.w700,
                    //           fontFamily: GoogleFonts.manrope().fontFamily,
                    //         ),
                    //       ),
                    //       SizedBox(width: 20),
                    //     ],
                    //   ),
                    // );
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
      ),
    );
  }
}
