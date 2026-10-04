enum UserMode { parent, child }
enum WalletType { spend, save, share }
enum TransactionType { income, expense }
enum TaskStatus { active, waitingApproval, completed }

class ChildProfile {
  const ChildProfile({required this.id, required this.name, required this.age, required this.avatar});
  final String id;
  final String name;
  final String age;
  final String avatar;
}

class WalletBalance {
  const WalletBalance({this.spend = 0, this.save = 0, this.share = 0});
  final int spend;
  final int save;
  final int share;
  int get total => spend + save + share;

  WalletBalance copyWith({int? spend, int? save, int? share}) => WalletBalance(
    spend: spend ?? this.spend, save: save ?? this.save, share: share ?? this.share,
  );
}

class SavingsGoal {
  const SavingsGoal({required this.title, required this.current, required this.target});
  final String title;
  final int current;
  final int target;
  double get progress => target == 0 ? 0 : (current / target).clamp(0, 1);
}

class MoneyTransaction {
  const MoneyTransaction({required this.description, required this.amount, required this.type});
  final String description;
  final int amount;
  final TransactionType type;
}

class MoneyTask {
  const MoneyTask({required this.title, required this.reward, required this.status});
  final String title;
  final int reward;
  final TaskStatus status;
}
