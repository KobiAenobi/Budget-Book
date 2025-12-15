import 'dart:developer' show log;

import 'package:budget_book_app/widgets/add_item_dialog_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

SpeedDial buildSpeedDial() {
  return SpeedDial(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0), // Custom shape
    ),
    animatedIcon: AnimatedIcons.menu_close,
    // animatedIconTheme: IconThemeData(size: 28.0),
    backgroundColor: const Color.fromARGB(255, 42, 53, 42),
    foregroundColor: Colors.white,

    visible: true,
    curve: Curves.bounceInOut,
    children: [
      SpeedDialChild(
        child: Icon(Icons.chrome_reader_mode, color: Colors.white),
        backgroundColor: Colors.green,
        onTap: () {
          log('Pressed Set Budget');
        },
        label: 'Set Budget',
        labelStyle: TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
        labelBackgroundColor: Colors.black,
      ),
      SpeedDialChild(
        child: Icon(Icons.create, color: Colors.white),
        backgroundColor: Colors.green,
        onTap: () {
          log('Pressed Add Item');
          AddItemDialogBox();
        },
        label: 'Add Item',
        labelStyle: TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
        labelBackgroundColor: Colors.black,
      ),
      // SpeedDialChild(
      //       child: Icon(Icons.laptop_chromebook, color: Colors.white),
      //       backgroundColor: Colors.green,
      //       onTap: () => log('Pressed Code'),
      //       label: 'Code',
      //       labelStyle:TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
      //       labelBackgroundColor: Colors.black,
      // ),
    ],
  );
}
