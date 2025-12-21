import 'package:budget_book_app/UI/helper/time_ago_text_for_item_card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

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
        elevation: 0,
        // Space between cards in list
        // margin: EdgeInsets.only(bottom: 1, top: 1, left: 1, right: 1),
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),

        shape: RoundedRectangleBorder(
          side: widget.isRight
              ? BorderSide(color: Colors.transparent, width: 0)
              : BorderSide(color: myThemeVar.dividerColor, width: 1),
          borderRadius: widget.isRight
              ? BorderRadius.circular(0)
              : BorderRadius.circular(15),
        ),

        // color: Colors.transparent,
        color: myThemeVar.cardColor,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            // image: DecorationImage(
            //   image: AssetImage("assets/bg/card_paper_bg_light.jpg"),
            //   fit: BoxFit.cover,
            // ),
          ),
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
                SizedBox(
                  width: widget.containerWidth * 0.4,

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // SINGLE-LINE SCROLLABLE ITEM NAME
                      oneLineScroll(
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
                      // oneLineScroll(
                      //   formatDateTime(widget.date),
                      //   TextStyle(
                      //     fontSize: 11,
                      //     color: myThemeVar.colorScheme.secondary,
                      //   ),
                      // ),
                      // ✅ ADD THIS NEW WIDGET
                      TimeAgoText(
                        date: widget.date,
                        style: TextStyle(
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
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: GoogleFonts.poppins().fontFamily,
                          ),
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
      ),
    );
  }
}

Widget oneLineScroll(String text, TextStyle? style) {
  return SingleChildScrollView(
    scrollDirection: Axis.horizontal, // Enables LEFT↔RIGHT scroll

    child: Text(
      text,
      style: style, // Custom text styling
      maxLines: 1, // Force single line
      overflow: TextOverflow.visible, // Full text visible (no ellipsis)
    ),
  );
}

String formatDateTime(DateTime date) {
  final now = DateTime.now();
  final difference = now.difference(date);

  // ---------------------------------------------------------------------------
  // 🟢 JUST NOW — Less than 60 seconds old
  // ---------------------------------------------------------------------------
  if (difference.inSeconds < 60) {
    return "Just now";
  }

  // ---------------------------------------------------------------------------
  // 🟡 MINUTES AGO — Less than 60 minutes old
  // ---------------------------------------------------------------------------
  if (difference.inMinutes < 60) {
    return "${difference.inMinutes} min ago";
  }

  // ---------------------------------------------------------------------------
  // Normalize dates to midnight for easier comparison
  // today      = <current date at 00:00>
  // yesterday  = today - 1 day
  // dateOnly   = <item date at 00:00>
  // ---------------------------------------------------------------------------
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(Duration(days: 1));
  final dateOnly = DateTime(date.year, date.month, date.day);

  // ---------------------------------------------------------------------------
  // 🔵 TODAY — More than 1 hour ago but still today
  // Example: "Today, 3:15 PM"
  // ---------------------------------------------------------------------------
  if (dateOnly == today) {
    return "Today, ${DateFormat('h:mm a').format(date)}";
  }

  // ---------------------------------------------------------------------------
  // 🟣 YESTERDAY
  // Example: "Yesterday, 10:05 PM"
  // ---------------------------------------------------------------------------
  if (dateOnly == yesterday) {
    return "Yesterday, ${DateFormat('h:mm a').format(date)}";
  }

  // ---------------------------------------------------------------------------
  // 🟠 LAST 7 DAYS
  // Shows weekday name + time
  // Example: "Monday, 2:18 PM"
  // ---------------------------------------------------------------------------
  if (difference.inDays < 7) {
    return "${DateFormat('EEEE').format(date)}, ${DateFormat('h:mm a').format(date)}";
  }

  // ---------------------------------------------------------------------------
  // 🔴 OLDER THAN A WEEK
  // Example: "23 July 2024, 8:14 PM"
  // ---------------------------------------------------------------------------
  return DateFormat("dd MMMM yyyy").format(date);
}
