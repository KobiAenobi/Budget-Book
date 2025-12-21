import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimeAgoText extends StatefulWidget {
  final DateTime date;
  final TextStyle? style;

  const TimeAgoText({
    super.key,
    required this.date,
    this.style,
  });

  @override
  State<TimeAgoText> createState() => _TimeAgoTextState();
}

class _TimeAgoTextState extends State<TimeAgoText> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Update the text every 1 minute
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // YOUR EXACT LOGIC, moved inside the widget
  String _formatDateTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return "Just now";
    }
    if (difference.inMinutes < 60) {
      return "${difference.inMinutes} min ago";
    }

    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return "Today, ${DateFormat('h:mm a').format(date)}";
    }
    if (dateOnly == yesterday) {
      return "Yesterday, ${DateFormat('h:mm a').format(date)}";
    }
    if (difference.inDays < 7) {
      return "${DateFormat('EEEE').format(date)}, ${DateFormat('h:mm a').format(date)}";
    }
    return DateFormat("dd MMMM yyyy").format(date);
  }

  @override
  Widget build(BuildContext context) {
    // We wrap it in SingleChildScrollView to match your 'oneLineScroll' style
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Text(
        _formatDateTime(widget.date),
        style: widget.style,
        maxLines: 1,
        overflow: TextOverflow.visible,
      ),
    );
  }
}