// ============================================================================
// BudgetBloc
// ----------------------------------------------------------------------------
// Handles BudgetEvent → BudgetState transitions.
// Business logic lives here, NOT in UI.
// ============================================================================

import 'dart:async';
import 'dart:developer';

import 'package:budget_book_app/blocs/budgets/models/budget_item.dart';
import 'package:budget_book_app/blocs/budgets/repository/budget_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'budget_event.dart';
import 'budget_state.dart';

class BudgetBloc extends Bloc<BudgetEvent, BudgetState> {
  final BudgetRepository repository;
  late final StreamSubscription<BoxEvent> _hiveSub;
  late final StreamSubscription<BoxEvent> _settingsSub;

  BudgetBloc(this.repository) : super(BudgetInitial()) {
    log("from: budget_bloc.dart - BUDGET BLOC CREATED");

    // --------------------------------------------------
    // 1️⃣ REGISTER ALL HANDLERS FIRST
    // --------------------------------------------------
    on<LoadBudget>(_reloadFromHive);
    on<LocalItemsChanged>(_reloadFromHive);
    on<RefreshBudget>((_, __) => add(LoadBudget()));

    on<AddBudgetItem>((event, _) async {
      await repository.addItems(event.item);
    });

    on<UpdateBudgetItem>((event, _) async {
      await repository.updateItem(event.updatedItem);
    });

    on<DeleteBudgetItem>((event, _) async {
      await repository.deleteItem(event.itemId);
    });

    on<SetBudgets>((event, _) async {
      await repository.setBudget(
        event.monthBudget,
        event.weekBudget,
        event.dayBudget,
      );

      log(
        "budget from BudgetBloc.dart: month: ${event.monthBudget}, week: ${event.weekBudget}, day: ${event.dayBudget}",
      );

      // emit(BudgetSet(budgetThisMonth: event.budget));
    });

    on<SignInToGoogleRequested>((event, emit) async {
      final userCred = await repository.signInWithGoogle();
      if (userCred == null) return;

      await repository.currentUserData();
      await repository.initialSync();
      await repository.syncLocalItemsToCloud();


      await repository.startSync();
    });

    on<SignOutRequested>((event, emit) async {
      await repository.stopSync();

      await FirebaseAuth.instance.signOut();
      await GoogleSignIn.instance.signOut();
      await GoogleSignIn.instance.disconnect();

      log("from budget_bloc.dart: 👋 User signed out safely");
    });

    // --------------------------------------------------
    // 2️⃣ NOW it is safe to add events
    // --------------------------------------------------
    add(LoadBudget());

    // --------------------------------------------------
    // 3️⃣ NOW start Hive listener
    // --------------------------------------------------
    _hiveSub = repository.box.watch().listen((_) {
      add(LocalItemsChanged());
    });
    _settingsSub = repository.settingsBox.watch().listen((_) {
      add(LocalItemsChanged());
    });
  }

  void _reloadFromHive(BudgetEvent event, Emitter<BudgetState> emit) {
    if (state is BudgetInitial) {
      emit(BudgetLoading());
    }

    final items = repository.getAllItems();
    final result = _buildDisplayData(items);

    // 🔥 CALCULATE CURRENT MONTH TOTAL
    final now = DateTime.now();

    final currentMonthTotal = items
        .where(
          (item) =>
              item.dateTime.year == now.year &&
              item.dateTime.month == now.month,
        )
        .fold<int>(0, (sum, item) => sum + (item.price * item.quantity));

    final currentDayTotal = items
        .where(
          (item) =>
              item.dateTime.year == now.year &&
              item.dateTime.month == now.month &&
              item.dateTime.day == now.day,
        )
        .fold<int>(0, (sum, item) => sum + (item.price * item.quantity));

    //Calculating start and end of this week
    final startOfWeek = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));

    final endOfWeek = startOfWeek.add(const Duration(days: 7));

    final currentWeekTotal = items
        .where((item) {
          final date = item.dateTime;
          return date.isAfter(
                startOfWeek.subtract(const Duration(seconds: 1)),
              ) &&
              date.isBefore(endOfWeek);
        })
        .fold<int>(0, (sum, item) => sum + (item.price * item.quantity));

    log(
      "TopCard1 total (current month): ₹$currentMonthTotal",
      name: "BudgetBloc",
    );

    // 🔥 READ BUDGET FROM STORAGE
    // int monthlyBudget = repository.monthlyBudget;
    // log("from budget_bloc.dart: monthlyBudget: $monthlyBudget");

    emit(
      BudgetLoaded(
        displayList: result['displayList'],
        monthlyTotal: result['monthlyTotal'],
        thisMonthTotal: currentMonthTotal,
        thisWeekTotal: currentWeekTotal,
        thisDayTotal: currentDayTotal,
        budgetThisMonth: repository.monthlyBudget,
        budgetThisWeek: repository.weeklyBudget,
        budgetThisDay: repository.dailyBudget,
      ),
    );
  }

  @override
  Future<void> close() {
    _hiveSub.cancel();
    _settingsSub.cancel();
    return super.close();
  }
}

Map<String, dynamic> _buildDisplayData(List<BudgetItem> items) {
  // Sort newest → oldest
  items.sort((a, b) => b.dateTime.compareTo(a.dateTime));

  final Map<String, List<BudgetItem>> grouped = {};
  final Map<String, int> monthlyTotal = {};
  final List<dynamic> displayList = [];

  for (final item in items) {
    final key =
        "${item.dateTime.year}-${item.dateTime.month.toString().padLeft(2, '0')}";

    grouped.putIfAbsent(key, () => []);
    grouped[key]!.add(item);
  }

  grouped.forEach((monthKey, monthItems) {
    int total = 0;

    for (final item in monthItems) {
      total += item.price * item.quantity;
    }

    monthlyTotal[monthKey] = total;
    displayList.add(monthKey);
    displayList.addAll(monthItems);
  });

  return {'displayList': displayList, 'monthlyTotal': monthlyTotal};
}
