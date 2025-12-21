import 'dart:developer' show log;

import 'package:budget_book_app/blocs/budgets/budget_bloc.dart';
import 'package:budget_book_app/blocs/budgets/budget_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TestHomeScreen extends StatefulWidget {
  const TestHomeScreen({super.key});

  @override
  State<TestHomeScreen> createState() => _TestHomeScreenState();
}

class _TestHomeScreenState extends State<TestHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<BudgetBloc, BudgetState>(
        builder: (context, state) {
          if (state is BudgetInitial || state is BudgetLoading) {
            log("budget loading");
            return Center(child: CircularProgressIndicator());
          }

          if (state is BudgetLoaded) {
            log("budget loaded");
            final displayList = state.displayList;
            final monthlyTotal = state.monthlyTotal;

            if (displayList.isEmpty) {
              log("displayList.isEmpty");
              return Container(child: Center(child: Text("displayList.isEmpty")));
            } else {
              return Container(child: Center(child: Text("WORKING")));
            }
          }

          return Container(child: Center(child: Text("Oops")));
        },
      ),
    );
  }
}
