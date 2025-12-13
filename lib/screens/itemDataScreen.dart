import 'package:flutter/material.dart';

class Itemdatascreen extends StatefulWidget {
  const Itemdatascreen({super.key});

  @override
  State<Itemdatascreen> createState() => _ItemdatascreenState();
}

class _ItemdatascreenState extends State<Itemdatascreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color.fromARGB(255, 77, 65, 29),
        child: Text("hello  why"),
      ),
    );
  }
}
