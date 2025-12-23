import 'package:budget_book_app/blocs/budgets/models/budget_input.dart';
import 'package:flutter/material.dart';

class SetBudgetDialogBox extends StatefulWidget {
  final int currentMonthlyBudget;
  final int currentWeeklyBudget;
  final int currentDailyBudget;

  const SetBudgetDialogBox({
    super.key,
    required this.currentMonthlyBudget,
    required this.currentWeeklyBudget,
    required this.currentDailyBudget,
  });

  @override
  State<SetBudgetDialogBox> createState() => _SetBudgetDialogBoxState();
}

class _SetBudgetDialogBoxState extends State<SetBudgetDialogBox> {
  late final TextEditingController monthBudgetCtrl;
  late final TextEditingController weekBudgetCtrl;
  late final TextEditingController dayBudgetCtrl;

  @override
  void initState() {
    super.initState();
    monthBudgetCtrl = TextEditingController(
      text: widget.currentMonthlyBudget.toString(),
    );
    weekBudgetCtrl = TextEditingController(
      text: widget.currentWeeklyBudget.toString(),
    );
    dayBudgetCtrl = TextEditingController(
      text: widget.currentDailyBudget.toString(),
    );
  }

  @override
  void dispose() {
    monthBudgetCtrl.dispose();
    weekBudgetCtrl.dispose();
    dayBudgetCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final myThemeVar = Theme.of(context);

    return AlertDialog(
      backgroundColor: myThemeVar.cardColor,
      title: Column(
        children: [
          Text(
            'Monthly Budget',
            style: TextStyle(color: myThemeVar.colorScheme.primary),
            textAlign: TextAlign.center,
          ),
          // Text(
          //   'Current Budget: ${widget.currentMonthlyBudget}',
          //   style: myThemeVar.textTheme.bodySmall,
          //   textAlign: TextAlign.center,
          // ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,

        children: [
          //Monthly budget
          TextField(
            controller: monthBudgetCtrl,
            onTap: () {
              monthBudgetCtrl.selection = TextSelection(
                baseOffset: 0,
                extentOffset: monthBudgetCtrl.text.length,
              );
            },

            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: myThemeVar.textTheme.bodySmall,
            decoration: InputDecoration(
              labelText: "Enter Monthly Budget",
              labelStyle: myThemeVar.textTheme.bodySmall,
              // floatingLabelBehavior: FloatingLabelBehavior.never,
            ),
          ),
          //Weekly budget
          TextField(
            controller: weekBudgetCtrl,
            onTap: () {
              weekBudgetCtrl.selection = TextSelection(
                baseOffset: 0,
                extentOffset: weekBudgetCtrl.text.length,
              );
            },

            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: myThemeVar.textTheme.bodySmall,
            decoration: InputDecoration(
              labelText: "Enter Weekly Budget",
              labelStyle: myThemeVar.textTheme.bodySmall,
              // floatingLabelBehavior: FloatingLabelBehavior.never,
            ),
          ),

          //Daily budget
          TextField(
            controller: dayBudgetCtrl,
            onTap: () {
              dayBudgetCtrl.selection = TextSelection(
                baseOffset: 0,
                extentOffset: dayBudgetCtrl.text.length,
              );
            },

            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: myThemeVar.textTheme.bodySmall,
            decoration: InputDecoration(
              labelText: "Enter Daily Budget",
              labelStyle: myThemeVar.textTheme.bodySmall,
              // floatingLabelBehavior: FloatingLabelBehavior.never,
            ),
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      actions: [
        /// CANCEL
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: TextStyle(color: myThemeVar.colorScheme.primary),
          ),
        ),

        /// SAVE
        TextButton(
          onPressed: () {
            int? monthsBudget = int.tryParse(monthBudgetCtrl.text);
            int? weeksBudget = int.tryParse(weekBudgetCtrl.text);
            int? daysBudget = int.tryParse(dayBudgetCtrl.text);

            // if (budget == null || budget <= 0) {
            //   ScaffoldMessenger.of(context).showSnackBar(
            //     SnackBar(
            //       content: const Text("Please enter a valid budget"),
            //       backgroundColor: myThemeVar.colorScheme.primary,
            //     ),
            //   );
            //   return;
            // }
            // ---- VALIDATION ----
            // if (monthsBudget == null ||
            //     weeksBudget == null ||
            //     daysBudget == null) {
            //   ScaffoldMessenger.of(context).showSnackBar(
            //     SnackBar(
            //       behavior: SnackBarBehavior.floating,
            //       margin: const EdgeInsets.only(
            //         left: 16,
            //         right: 16,
            //         bottom: 80, // 👈 push it ABOVE the FAB
            //       ),
            //       content: const Text("Please enter valid numbers"),
            //       backgroundColor: myThemeVar.colorScheme.onPrimary,
            //     ),
            //   );
            //   return;
            // }
            monthsBudget ??= 0;
            weeksBudget ??= 0;
            daysBudget ??= 0;

            // if (month <= 0 || week <= 0 || day <= 0) {
            //   ScaffoldMessenger.of(context).showSnackBar(
            //     SnackBar(
            //       content: const Text("Budgets must be greater than zero"),
            //       backgroundColor: myThemeVar.colorScheme.primary,
            //     ),
            //   );
            //   return;
            // }

            // Promote to non-null
            final int month = monthsBudget;
            final int week = weeksBudget;
            final int day = daysBudget;

            Navigator.pop(
              context,
              BudgetInput(month: month, week: week, day: day),
            ); // SEND BACK
          },
          child: Text(
            'Save',
            style: TextStyle(color: myThemeVar.colorScheme.primary),
          ),
        ),
      ],
    );
  }
}
