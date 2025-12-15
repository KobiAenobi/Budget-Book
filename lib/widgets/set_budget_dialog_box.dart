import 'package:flutter/material.dart';

class SetBudgetDialogBox extends StatefulWidget {
  final int currentBudget;

  const SetBudgetDialogBox({super.key, required this.currentBudget});

  @override
  State<SetBudgetDialogBox> createState() => _SetBudgetDialogBoxState();
}

class _SetBudgetDialogBoxState extends State<SetBudgetDialogBox> {
  late final TextEditingController budgetCtrl;

  @override
  void initState() {
    super.initState();
    budgetCtrl = TextEditingController(text: widget.currentBudget.toString());
  }

  @override
  void dispose() {
    budgetCtrl.dispose();
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
          Text(
            'Current Budget: ${widget.currentBudget}',
            style: myThemeVar.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
      content: TextField(
        controller: budgetCtrl,
        onTap: () {
          budgetCtrl.selection = TextSelection(
            baseOffset: 0,
            extentOffset: budgetCtrl.text.length,
          );
        },

        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: myThemeVar.textTheme.bodySmall,
        decoration: InputDecoration(
          labelText: "Enter Budget",
          labelStyle: myThemeVar.textTheme.bodySmall,
          // floatingLabelBehavior: FloatingLabelBehavior.never,
        ),
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
            final int? budget = int.tryParse(budgetCtrl.text);

            // if (budget == null || budget <= 0) {
            //   ScaffoldMessenger.of(context).showSnackBar(
            //     SnackBar(
            //       content: const Text("Please enter a valid budget"),
            //       backgroundColor: myThemeVar.colorScheme.primary,
            //     ),
            //   );
            //   return;
            // }

            Navigator.pop(context, budget); // SEND BACK
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
