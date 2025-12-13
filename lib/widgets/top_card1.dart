// import 'dart:nativewrappers/_internal/vm/lib/math_patch.dart';

import 'package:budget_book_app/helper/measureSize.dart';
import 'package:budget_book_app/models/budget_item.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:lottie/lottie.dart';
import 'dart:developer' show log;

class TopCard1 extends StatefulWidget {
  final double containeHeight;
  final double containeWidth;
  const TopCard1({
    super.key,
    required this.containeHeight,
    required this.containeWidth,
  });

  @override
  State<TopCard1> createState() => _TopCard1State();
}

class _TopCard1State extends State<TopCard1> {
  Size? expenseContSize;
  Size? expenseFittedBoxSize;
  Size? grandTotalSize;
  Size? mainContainerSize;

  final itemsBox = Hive.box<BudgetItem>('itemsBox');

  static const List<String> monthNames = [
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

  @override
  Widget build(BuildContext context) {
    final myThemeVar = Theme.of(context);
    final items = itemsBox.values.toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

    int currentMonth = DateTime.now().month;
    int grandTotal = 0;
    int monthlyBudget = 12000;

    for (var item in items) {
      if (item.dateTime.month == currentMonth) {
        grandTotal += item.price * item.quantity;
      }
    }

    double percentUsed = grandTotal / monthlyBudget;

    Color getBudgetColor(double percent) {
      if (percent < 0.5) return Color.fromARGB(255, 19, 173, 99);
      if (percent < 0.8) return Colors.orange;
      return const Color.fromARGB(255, 199, 27, 15);
    }

    String getMood(double percent) {
      if (percent < 0.5) return "assets/lottie/relax.json";
      if (percent < 0.8) return "assets/lottie/worried_sitting_forward.json";
      return "assets/lottie/worried.json";
    }

    //MAIN CONTAINER
    return MeasureSize(
      onChange: (size) {
        if (mainContainerSize != size) {
          setState(() {
            mainContainerSize = size;
            log("\nMain Container Size: $mainContainerSize");
          });
        }
      },
      child: Container(
        // color: Colors.blueAccent,
        // decoration: BoxDecoration(),

        //MAIN STACK
        child: Stack(
          children: [
            //
            //LAYER 1  The Mood Lottie
            Positioned(
              // top: mainContainerSize == null
              //     ? 0
              //     : mainContainerSize!.height - 400,
              child: Align(
                alignment: Alignment.topRight,
                child: Container(
                  // alignment: Alignment.topRight,
                  // height: 250.5,
                  // height: mainContainerSize == null
                  //     ? 0
                  //     : mainContainerSize!.height * 0.65,
                  // color: Colors.green,
                  child: Lottie.asset(
                    getMood(percentUsed),
                    height: mainContainerSize == null
                        ? 0
                        : mainContainerSize!.height * 0.75,
                  ),
                ),
              ),
            ),

            //TOTAL TEXT ABOVE
            Column(
              children: [
                //TOTAL
                Flexible(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      height: mainContainerSize == null
                          ? 0
                          : mainContainerSize!.height * 0.5,

                      width: mainContainerSize == null
                          ? 0
                          : mainContainerSize!.width * 0.5,
                      padding: EdgeInsets.only(left: 5),
                      // color: Colors.amber,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: Stack(
                            children: [
                              Text(
                                "Total",
                                style: TextStyle(
                                  fontFamily: "Impact",
                                  fontWeight: FontWeight.bold,
                                  fontSize: 1000,
                                  foreground: Paint()
                                    ..style = PaintingStyle.stroke
                                    ..strokeWidth = 15
                                    ..color = myThemeVar.colorScheme.onPrimary,
                                ),
                              ),
                              Text(
                                "Total",
                                style: TextStyle(
                                  fontFamily: "Impact",
                                  fontWeight: FontWeight.bold,
                                  fontSize: 1000,
                                  color: myThemeVar.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                //EXPENSE AND GRAND TOTAL
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    //EXPENSE
                    Container(
                      // color: Colors.red,
                      // alignment: Alignment.bottomCenter,
                      height: mainContainerSize == null
                          ? 0
                          : mainContainerSize!.height * 0.5,
                      width: mainContainerSize == null
                          ? 0
                          : mainContainerSize!.width * 0.65,
                      padding: EdgeInsets.all(3),
                    ),

                    //GRAND TOTAL
                    Flexible(
                      child: Container(
                        padding: EdgeInsets.only(left: 5, top: 5),
                        height: expenseFittedBoxSize == null
                            ? 0
                            : expenseFittedBoxSize!.height,
                        width: mainContainerSize == null
                            ? 0
                            : mainContainerSize!.width * 0.35,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            //LAYER 3 4 & 5

            //layer 3
            // Positioned(
            //   bottom: expenseFittedBoxSize == null
            //       ? 0
            //       : expenseFittedBoxSize!.height / 1.6,
            //   // right: expenseContSize == null ? 0 : expenseContSize!.width,
            //   child: Container(
            //     alignment: Alignment.centerLeft,
            //     width: expenseFittedBoxSize == null
            //         ? 0
            //         : expenseFittedBoxSize!.width,
            //     height: mainContainerSize == null
            //         ? 0
            //         : mainContainerSize!.height * 0.32,
            //     // color: Colors.white38,
            //     child: percentUsed < 0.5
            //         ? Lottie.asset(
            //             "assets/lottie/cat_playing.json",
            //             // height: expenseFittedBoxSize == null
            //             //     ? 0
            //             //     : expenseFittedBoxSize!.height / 1.5,
            //           )
            //         : Text(""),
            //   ),
            // ),

            //WORRIED CAT
            Positioned(
              bottom: expenseFittedBoxSize == null
                  ? 0
                  : expenseFittedBoxSize!.height / 2.1,
              child: Container(
                alignment: Alignment.centerRight,
                width: expenseFittedBoxSize == null
                    ? 0
                    : expenseFittedBoxSize!.width,
                height: mainContainerSize == null
                    ? 0
                    : mainContainerSize!.height * 0.6,
                // color: Colors.white38,
                child: percentUsed >= 0.5 && percentUsed < 0.8
                    ? Lottie.asset(
                        "assets/lottie/worried_cat.json",
                        // height: expenseFittedBoxSize == null
                        //     ? 0
                        //     : expenseFittedBoxSize!.height,
                      )
                    : Text(""),
              ),
            ),

            //ANGRY CAT
            Positioned(
              bottom: expenseFittedBoxSize == null
                  ? 0
                  : expenseFittedBoxSize!.height / 2.1,
              // left: expenseFittedBoxSize == null
              //     ? 0
              //     : expenseFittedBoxSize!.height,
              //  -
              //       (expenseContSize!.height -
              //           expenseFittedBoxSize!.height),
              child: Container(
                // color: Colors.white,
                alignment: Alignment.centerRight,
                width: expenseFittedBoxSize == null
                    ? 0
                    : expenseFittedBoxSize!.width,
                height: mainContainerSize == null
                    ? 0
                    : mainContainerSize!.height * 0.6,

                // color: Colors.white38,
                child: percentUsed >= 0.8
                    ? Lottie.asset(
                        "assets/lottie/angry_cat.json",
                        // height: 207
                      )
                    : Text(""),
              ),
            ),

            //LAYER 4 TOTAL EXPENSE & GRAND TOTAL TEXT
            Column(
              children: [
                //TOTAL
                Flexible(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      height: mainContainerSize == null
                          ? 0
                          : mainContainerSize!.height * 0.5,

                      width: mainContainerSize == null
                          ? 0
                          : mainContainerSize!.width * 0.5,
                      padding: EdgeInsets.only(left: 5),

                      // color: Colors.amber,
                    ),
                  ),
                ),

                //EXPENSE AND GRAND TOTAL
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    //EXPENSE
                    MeasureSize(
                      onChange: (size) {
                        if (expenseContSize != size) {
                          setState(() {
                            expenseContSize = size;
                            log("expense size: $size");
                          });
                        }
                      },
                      child: Container(
                        // color: Colors.green,
                        // alignment: Alignment.bottomCenter,
                        height: mainContainerSize == null
                            ? 0
                            : mainContainerSize!.height * 0.5,
                        width: mainContainerSize == null
                            ? 0
                            : mainContainerSize!.width * 0.65,
                        padding: EdgeInsets.all(3),
                        // color: Colors.blue,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: MeasureSize(
                            onChange: (size) {
                              if (expenseFittedBoxSize != size) {
                                setState(() {
                                  expenseFittedBoxSize = size;
                                  log("expense fitted box size: $size");
                                });
                              }
                            },
                            child: FittedBox(
                              fit: BoxFit.contain,
                              child: Stack(
                                children: [
                                  Text(
                                    "Expense",
                                    style: TextStyle(
                                      fontFamily: "Impact",
                                      fontWeight: FontWeight.bold,
                                      fontSize: 1000,
                                      foreground: Paint()
                                        ..style = PaintingStyle.stroke
                                        ..strokeWidth = 15
                                        ..color =
                                            myThemeVar.colorScheme.onPrimary,
                                    ),
                                  ),
                                  Text(
                                    "Expense",
                                    style: TextStyle(
                                      color: myThemeVar.colorScheme.primary,
                                      fontFamily: "Impact",
                                      fontWeight: FontWeight.bold,
                                      fontSize: 1000,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    //GRAND TOTAL
                    Flexible(
                      child: Container(
                        padding: EdgeInsets.only(left: 5, top: 5, right: 3),
                        height: expenseFittedBoxSize == null
                            ? 0
                            : expenseFittedBoxSize!.height,
                        width: mainContainerSize == null
                            ? 0
                            : mainContainerSize!.width * 0.35,
                        // color: Colors.white38,
                        // padding: EdgeInsets.only(top: 12, right: 5),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: Stack(
                              children: [
                                Text(
                                  "₹$grandTotal",
                                  style: TextStyle(
                                    fontFamily:
                                        GoogleFonts.poppins().fontFamily,

                                    fontWeight: FontWeight.w900,
                                    fontSize: 1000,
                                    foreground: Paint()
                                      ..style = PaintingStyle.stroke
                                      ..strokeWidth = 15
                                      ..color = myThemeVar.colorScheme.primary,
                                  ),
                                ),
                                Text(
                                  "₹$grandTotal",
                                  style: TextStyle(
                                    color: getBudgetColor(percentUsed),
                                    fontFamily:
                                        GoogleFonts.poppins().fontFamily,

                                    fontWeight: FontWeight.w900,
                                    fontSize: 1000,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            //LAYER 5 chill cat playing
            Positioned(
              bottom: expenseFittedBoxSize == null
                  ? 0
                  : expenseFittedBoxSize!.height / 1.6,
              // right: expenseContSize == null ? 0 : expenseContSize!.width,
              child: Container(
                alignment: Alignment.centerLeft,
                width: expenseFittedBoxSize == null
                    ? 0
                    : expenseFittedBoxSize!.width,
                height: mainContainerSize == null
                    ? 0
                    : mainContainerSize!.height * 0.32,
                // color: Colors.white38,
                child: percentUsed < 0.5
                    ? Lottie.asset(
                        "assets/lottie/cat_playing.json",
                        // height: expenseFittedBoxSize == null
                        //     ? 0
                        //     : expenseFittedBoxSize!.height / 1.5,
                      )
                    : Text(""),
              ),
            ),

            //BALL
            Positioned(
              bottom: expenseFittedBoxSize == null
                  ? 0
                  : expenseFittedBoxSize!.height / 1.6,
              // right: expenseContSize == null ? 0 : expenseContSize!.width,
              child: Container(
                alignment: Alignment.centerLeft,
                width: expenseFittedBoxSize == null
                    ? 0
                    : expenseFittedBoxSize!.width,
                height: mainContainerSize == null
                    ? 0
                    : mainContainerSize!.height * 0.32,
                // color: Colors.white38,
                child: percentUsed > 0.5
                    ? Lottie.asset(
                        "assets/lottie/ball.json",
                        // height: expenseFittedBoxSize == null
                        //     ? 0
                        //     : expenseFittedBoxSize!.height / 1.5,
                      )
                    : Text(""),
              ),
            ),

            //LAYER 3 4 & 5
            //TOP LAYERS START CAT LOTTIES

            //   //CHILL CAT
            //   Positioned(
            //     bottom: expenseFittedBoxSize == null
            //         ? 0
            //         : expenseFittedBoxSize!.height / 1.6,
            //     // right: expenseContSize == null ? 0 : expenseContSize!.width,
            //     child: Container(
            //       alignment: Alignment.centerLeft,
            //       width: expenseFittedBoxSize == null
            //           ? 0
            //           : expenseFittedBoxSize!.width,
            //       height: mainContainerSize == null
            //           ? 0
            //           : mainContainerSize!.height * 0.32,
            //       // color: Colors.white38,
            //       child: percentUsed < 0.5
            //           ? Lottie.asset(
            //               "assets/lottie/cat_playing.json",
            //               // height: expenseFittedBoxSize == null
            //               //     ? 0
            //               //     : expenseFittedBoxSize!.height / 1.5,
            //             )
            //           : Text(""),
            //     ),
            //   ),

            //   //WORRIED CAT
            //   Positioned(
            //     bottom: expenseFittedBoxSize == null
            //         ? 0
            //         : expenseFittedBoxSize!.height / 2,
            //     child: Container(
            //       alignment: Alignment.centerRight,
            //       width: expenseFittedBoxSize == null
            //           ? 0
            //           : expenseFittedBoxSize!.width,
            //       height: mainContainerSize == null
            //           ? 0
            //           : mainContainerSize!.height * 0.5,
            //       // color: Colors.white38,
            //       child: percentUsed >= 0.5 && percentUsed < 0.8
            //           ? Lottie.asset(
            //               "assets/lottie/worried_cat.json",
            //               // height: expenseFittedBoxSize == null
            //               //     ? 0
            //               //     : expenseFittedBoxSize!.height,
            //             )
            //           : Text(""),
            //     ),
            //   ),

            //   //ANGRY CAT
            //   Positioned(
            //     bottom: expenseFittedBoxSize == null
            //         ? 0
            //         : expenseFittedBoxSize!.height / 1.5,
            //     //  -
            //     //       (expenseContSize!.height -
            //     //           expenseFittedBoxSize!.height),
            //     child: Container(
            //       alignment: Alignment.centerRight,
            //       width: expenseFittedBoxSize == null
            //           ? 0
            //           : expenseFittedBoxSize!.width,
            //       height: mainContainerSize == null
            //           ? 0
            //           : mainContainerSize!.height * 0.4,

            //       // color: Colors.white38,
            //       child: percentUsed >= 0.8
            //           ? Lottie.asset(
            //               "assets/lottie/angry_cat.json",
            //               // height: 207
            //             )
            //           : Text(""),
            //     ),
            //   ),
          ],
        ),
      ),
    );
  }
}
