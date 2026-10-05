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

  factory ChildProfile.fromMap(Map<String, dynamic> map) => ChildProfile(
        id: map['id'].toString(),
        name: map['name'] as String? ?? 'Anak',
        age: (map['age_group'] as String? ?? '5_7').replaceAll('_', '-'),
        avatar: map['avatar'] as String? ?? '🙂',
      );
}

class WalletBalance {
  const WalletBalance({this.spend = 0, this.save = 0, this.share = 0});
  final int spend;
  final int save;
  final int share;
  int get total => spend + save + share;

  WalletBalance copyWith({int? spend, int? save, int? share}) => WalletBalance(
        spend: spend ?? this.spend,
        save: save ?? this.save,
        share: share ?? this.share,
      );

  factory WalletBalance.fromMap(Map<String, dynamic> map) => WalletBalance(
        spend: (map['spend'] as num?)?.toInt() ?? 0,
        save: (map['save'] as num?)?.toInt() ?? 0,
        share: (map['share'] as num?)?.toInt() ?? 0,
      );
}

class SavingsGoal {
  const SavingsGoal({required this.id, required this.title, required this.current, required this.target});
  final String id;
  final String title;
  final int current;
  final int target;
  double get progress => target == 0 ? 0 : (current / target).clamp(0, 1).toDouble();

  factory SavingsGoal.fromMap(Map<String, dynamic> map) => SavingsGoal(
        id: map['id'].toString(),
        title: map['title'] as String? ?? 'Target tabungan',
        current: (map['current_amount'] as num?)?.toInt() ?? 0,
        target: (map['target_amount'] as num?)?.toInt() ?? 0,
      );
}

class MoneyTransaction {
  const MoneyTransaction({required this.id, required this.description, required this.amount, required this.type, required this.wallet});
  final String id;
  final String description;
  final int amount;
  final TransactionType type;
  final WalletType wallet;

  factory MoneyTransaction.fromMap(Map<String, dynamic> map) => MoneyTransaction(
        id: map['id'].toString(),
        description: map['description'] as String? ?? 'Transaksi',
        amount: (map['amount'] as num?)?.toInt() ?? 0,
        type: map['type'] == 'expense' ? TransactionType.expense : TransactionType.income,
        wallet: WalletType.values.firstWhere((w) => w.name == (map['wallet_type'] ?? map['wallet']), orElse: () => WalletType.save),
      );
}

class MoneyTask {
  const MoneyTask({required this.id, required this.title, required this.reward, required this.status});
  final String id;
  final String title;
  final int reward;
  final TaskStatus status;

  factory MoneyTask.fromMap(Map<String, dynamic> map) => MoneyTask(
        id: map['id'].toString(),
        title: map['title'] as String? ?? 'Misi baru',
        reward: ((map['reward_amount'] ?? map['reward']) as num?)?.toInt() ?? 0,
        status: TaskStatus.values.firstWhere((s) => s.name == (map['status'] as String?)?.replaceAll('waiting_approval', 'waitingApproval'), orElse: () => TaskStatus.active),
      );
}
