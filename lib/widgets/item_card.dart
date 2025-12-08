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

  final VoidCallback? onEdit; // Optional edit callback

  const ItemCard({
    super.key,
    required this.name,
    required this.date,
    required this.quantity,
    required this.price,
    this.onEdit,
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
    return Card(
      // Space between cards in list
      margin: EdgeInsets.only(bottom: 1, top: 1, left: 0, right: 0),

      shape: RoundedRectangleBorder(
        side: BorderSide(color: const Color.fromARGB(255, 105, 99, 97)),
        borderRadius: BorderRadius.circular(10),
      ),

      color: const Color.fromARGB(255, 24, 8, 2),

      child: Padding(
        padding: const EdgeInsets.all(16.0),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // ==================================================================
            // 🛒 ITEM ICON
            // ==================================================================
            Container(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.1,
                child: Icon(Icons.shopping_cart, color: Colors.white54),
              ),
            ),

            // ==================================================================
            // 📝 ITEM NAME + DATE SECTION
            // ==================================================================
            Container(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.4,

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // SINGLE-LINE SCROLLABLE ITEM NAME
                    Api.oneLineScroll(
                      widget.name,
                      TextStyle(
                        color: Colors.white,
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
                      TextStyle(fontSize: 11, color: Colors.white54),
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
            Container(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.17,
                child: Text("qty: ${widget.quantity}"),
              ),
            ),

            // ==================================================================
            // 💰 PRICE DISPLAY (price × quantity)
            // ==================================================================
            Container(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.15,
                child: Text(
                  "₹${widget.price * widget.quantity}",
                  textAlign: TextAlign.right,
                  style: TextStyle(color: Colors.white),
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
      ),
    );
  }
}
