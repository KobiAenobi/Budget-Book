import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MonthCard extends StatefulWidget {
  final String month;
  final int total;
  final double containerHeight;
  final double containerWidth;
  final Color monthCardColor;
  final int colorDuration;
  const MonthCard({
    super.key,
    required this.month,
    required this.total,
    required this.containerHeight,
    required this.containerWidth,
    required this.monthCardColor,
    required this.colorDuration,
  });

  @override
  State<MonthCard> createState() => _MonthCardState();
}

class _MonthCardState extends State<MonthCard> {
  @override
  Widget build(BuildContext context) {
    final myThemeVar = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ==================================================================
          // ITEM ICON
          // ==================================================================
          Container(
            // decoration: BoxDecoration(color: Colors.black),
            constraints: BoxConstraints(
              maxHeight: 45,
              maxWidth: widget.containerWidth * 0.5,
            ),
            child: FittedBox(
              child: Text(
                widget.month,
                // style: TextStyle(fontSize: 500, color: Colors.white54, fontFamily: 'Impact',),
                style: GoogleFonts.prociono(
                  fontSize: 500,
                  color: myThemeVar.colorScheme.onPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),

          Flexible(
            child: Container(
              // decoration: BoxDecoration(color: Colors.amber),
              constraints: BoxConstraints(
                maxHeight: 30,
                maxWidth: widget.containerWidth * 0.4,
              ),
              child: FittedBox(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "₹${widget.total.toString()}",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: myThemeVar.colorScheme.onPrimary,
                      fontFamily: GoogleFonts.prociono().fontFamily,
                      fontWeight: FontWeight.w600,
                      fontSize: 500,
                    ),
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
