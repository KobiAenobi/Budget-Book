abstract class BudgetEvent {}

class LoadBudget extends BudgetEvent {}

class AddBudgetItem extends BudgetEvent {
  final dynamic item;
  AddBudgetItem(this.item);
}

class UpdateBudgetItem extends BudgetEvent {
  final dynamic updatedItem;
  UpdateBudgetItem(this.updatedItem);
}

class DeleteBudgetItem extends BudgetEvent {
  final String itemId;
  DeleteBudgetItem(this.itemId);
}

class setMonthlyBudget extends BudgetEvent {
  final int budget;
  setMonthlyBudget(this.budget);
}

class RefreshBudget extends BudgetEvent {}

class SignInToGoogleRequested extends BudgetEvent {}

class CloudSyncRequested extends BudgetEvent {}

class SignOutRequested extends BudgetEvent {}

class LocalItemsChanged extends BudgetEvent {}
