import 'package:flutter/foundation.dart';
import '../domain/models/kids_money_models.dart';

class AppState extends ChangeNotifier {
  UserMode mode = UserMode.parent;
  int parentTab = 0;
  int childTab = 0;
  String selectedChildId = 'c_001';

  final children = const [
    ChildProfile(id: 'c_001', name: 'Raka', age: '8-10', avatar: '🧑🏻'),
    ChildProfile(id: 'c_002', name: 'Alya', age: '5-7', avatar: '👧🏻'),
    ChildProfile(id: 'c_003', name: 'Dimas', age: '11-12', avatar: '👦🏻'),
  ];

  final balances = <String, WalletBalance>{
    'c_001': const WalletBalance(spend: 50000, save: 150000, share: 50000),
    'c_002': const WalletBalance(spend: 70000, save: 120000, share: 30000),
    'c_003': const WalletBalance(),
  };

  final goals = const <String, SavingsGoal>{
    'c_001': SavingsGoal(title: 'Sepeda Baru Polygon', current: 450000, target: 1000000),
    'c_002': SavingsGoal(title: 'Boneka Kelinci', current: 120000, target: 200000),
  };

  ChildProfile get selectedChild => children.firstWhere((item) => item.id == selectedChildId);
  WalletBalance get selectedBalance => balances[selectedChildId]!;
  SavingsGoal? get selectedGoal => goals[selectedChildId];

  void selectChild(String id) { selectedChildId = id; notifyListeners(); }
  void selectParentTab(int index) { parentTab = index; notifyListeners(); }
  void selectChildTab(int index) { childTab = index; notifyListeners(); }
  void enterChildMode() { mode = UserMode.child; notifyListeners(); }
  void enterParentMode() { mode = UserMode.parent; notifyListeners(); }

  void addIncome(int amount, {WalletType wallet = WalletType.save}) {
    final current = selectedBalance;
    balances[selectedChildId] = switch (wallet) {
      WalletType.spend => current.copyWith(spend: current.spend + amount),
      WalletType.save => current.copyWith(save: current.save + amount),
      WalletType.share => current.copyWith(share: current.share + amount),
    };
    notifyListeners();
  }
}
