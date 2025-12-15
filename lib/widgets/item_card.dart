import 'package:budget_book_app/apis/api.dart';
import 'package:flutter/material.dart';
import 'package:budget_book_app/helper/date_time_helper.dart';
import 'package:google_fonts/google_fonts.dart';

/// ============================================================================
/// ITEM CARD WIDGET
/// ----------------------------------------------------------------------------
/// A UI card that displays:
///  • Item name
///  • Formatted date/time
///  • Quantity
///  • Total price (price × quantity)
///  • (Optional) Edit callback
///
/// This widget is reused in list views on the Homescreen.
/// NOTHING modified — only comments added.
/// ============================================================================
class ItemCard extends StatefulWidget {
  final String name; // Item name
  final DateTime date; // Purchase date
  final int quantity; // Quantity of item
  final int price; // Price per unit

  final double containerHeight;
  final double containerWidth;

  final VoidCallback? onEdit; // Optional edit callback

  final bool isRight;

  const ItemCard({
    super.key,
    required this.name,
    required this.date,
    required this.quantity,
    required this.price,
    this.onEdit,
    required this.containerHeight,
    required this.containerWidth,
    required this.isRight,
  });

  @override
  State<ItemCard> createState() => _ItemCardState();
}

class _ItemCardState extends State<ItemCard> {
  // ==========================================================================
  // COMMENTED-OUT MONTH LISTS (Kept exactly as provided)
  // ==========================================================================

  // static const List<String> monthNames = [
  //   "January",
  //   "February",
  //   "March",
  //   "April",
  //   "May",
  //   "June",
  //   "July",
  //   "August",
  //   "September",
  //   "October",
  //   "November",
  //   "December",
  // ];

  // static const List<String> monthNames = [
  //   "Jan",
  //   "Feb",
  //   "Mar",
  //   "Apr",
  //   "May",
  //   "Jun",
  //   "Jul",
  //   "Aug",
  //   "Sep",
  //   "Oct",
  //   "Nov",
  //   "Dec",
  // ];

  /// ========================================================================
  /// 🖥 BUILD METHOD — Constructs the card UI
  /// ========================================================================
  @override
  Widget build(BuildContext context) {
    final myThemeVar = Theme.of(context);
    return SizedBox(
      // height: 90,
      child: Card(
        // Space between cards in list
        margin: EdgeInsets.only(bottom: 1, top: 1, left: 1, right: 1),

        shape: RoundedRectangleBorder(
          side: widget.isRight
              ? BorderSide(color: Colors.transparent, width: 0)
              : BorderSide(color: myThemeVar.dividerColor, width: 1),
          borderRadius: widget.isRight
              ? BorderRadius.circular(0)
              : BorderRadius.circular(15),
        ),

        // color: const Color.fromARGB(255, 24, 8, 2),
        color: myThemeVar.cardColor,
        child: Padding(
          padding: const EdgeInsets.all(16.0),

          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // ==================================================================
              // 🛒 ITEM ICON
              // ==================================================================
              SizedBox(
                width: widget.containerWidth * 0.1,
                child: Icon(
                  Icons.shopping_cart,
                  color: myThemeVar.iconTheme.color,
                ),
              ),

              // ==================================================================
              // 📝 ITEM NAME + DATE SECTION
              // ==================================================================
              Flexible(
                child: SizedBox(
                  width: widget.containerWidth * 0.4,

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // SINGLE-LINE SCROLLABLE ITEM NAME
                      Api.oneLineScroll(
                        widget.name,
                        TextStyle(
                          color: myThemeVar.colorScheme.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          fontFamily: GoogleFonts.manrope().fontFamily,
                        ),
                      ),

                      // ----------------------------------------------------------------
                      // Formatted date/time below item name
                      // formatDateTime() is your custom helper function
                      // ----------------------------------------------------------------
                      Api.oneLineScroll(
                        formatDateTime(widget.date),
                        TextStyle(
                          fontSize: 11,
                          color: myThemeVar.colorScheme.secondary,
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
              ),

              // ==================================================================
              // 📦 QUANTITY DISPLAY
              // ==================================================================
              Flexible(
                child: SizedBox(
                  width: widget.containerWidth * 0.17,
                  child: Text(
                    "qty: ${widget.quantity}",
                    style: TextStyle(
                      color: myThemeVar.colorScheme.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      fontFamily: GoogleFonts.manrope().fontFamily,
                    ),
                  ),
                ),
              ),

              // ==================================================================
              // 💰 PRICE DISPLAY (price × quantity)
              // ==================================================================
              Flexible(
                child: SizedBox(
                  width: widget.containerWidth * 0.15,
                  child: SingleChildScrollView(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "₹${widget.price * widget.quantity}",
                        textAlign: TextAlign.right,
                        style: TextStyle(color: myThemeVar.colorScheme.primary),
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
      ),
    );
  }
}
