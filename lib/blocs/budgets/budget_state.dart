// ============================================================================
// BudgetState
// ----------------------------------------------------------------------------
// Represents ONLY the data needed by the UI to render.
// No UI flags, no controllers, no widgets.
// ============================================================================

abstract class BudgetState {}

/// Initial state when app just starts
class BudgetInitial extends BudgetState {}

/// While data is being loaded from Hive / Firebase
class BudgetLoading extends BudgetState {}

/// Main state used by HomeScreen
class BudgetLoaded extends BudgetState {
  /// Flat list used by ListView.builder
  /// Contains:
  /// - String (month key: "YYYY-MM")
  /// - BudgetItem (later replaces DummyItem)
  final List<dynamic> displayList;

  /// Monthly total mapped by month key
  /// Example: { "2025-02": 1450 }
  final Map<String, int> monthlyTotal;

  final int thisMonthTotal;

  final int budgetThisMonth;

  BudgetLoaded({
    required this.displayList,
    required this.monthlyTotal,
    required this.thisMonthTotal,
    required this.budgetThisMonth,
  });
}

// class BudgetSet extends BudgetState {
//   final int budgetThisMonth;

//   BudgetSet({required this.budgetThisMonth});
// }

/// Error state (network / database / unexpected failure)
class BudgetError extends BudgetState {
  final String message;

  BudgetError(this.message);
}
