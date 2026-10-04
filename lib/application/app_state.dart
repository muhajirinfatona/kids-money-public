import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/money_repository.dart';
import '../domain/models/kids_money_models.dart';

class AppState extends ChangeNotifier {
  AppState({SupabaseClient? client}) : _client = client, auth = client == null ? null : AuthRepository(client), data = client == null ? null : MoneyRepository(client) {
    if (_client != null) {
      _session = _client!.auth.currentSession;
      if (_session != null) load();
      _client!.auth.onAuthStateChange.listen((event) {
        _session = event.session;
        if (_session != null) load();
        notifyListeners();
      });
    }
  }

  final SupabaseClient? _client;
  final AuthRepository? auth;
  final MoneyRepository? data;
  Session? _session;
  bool loading = false;
  String? error;
  UserMode mode = UserMode.parent;
  int parentTab = 0;
  int childTab = 0;
  String selectedChildId = 'local-1';
  List<ChildProfile> children = const [ChildProfile(id: 'local-1', name: 'Raka', age: '8-10', avatar: '🧑🏻')];
  final balances = <String, WalletBalance>{'local-1': const WalletBalance(spend: 50000, save: 150000, share: 50000)};
  final goals = <String, List<SavingsGoal>>{};
  final transactions = <String, List<MoneyTransaction>>{};
  final tasks = <String, List<MoneyTask>>{};

  bool get isConfigured => _client != null;
  bool get isSignedIn => _session != null;
  ChildProfile get selectedChild => children.firstWhere((item) => item.id == selectedChildId, orElse: () => children.first);
  WalletBalance get selectedBalance => balances[selectedChildId] ?? const WalletBalance();
  SavingsGoal? get selectedGoal => (goals[selectedChildId] ?? const <SavingsGoal>[]).firstOrNull;

  Future<void> load() async {
    if (data == null || !isSignedIn) return;
    loading = true; error = null; notifyListeners();
    try {
      children = await data!.children();
      if (children.isNotEmpty) selectedChildId = children.first.id;
      for (final child in children) {
        balances[child.id] = await data!.balance(child.id);
        transactions[child.id] = await data!.transactions(child.id);
        tasks[child.id] = await data!.tasks(child.id);
        goals[child.id] = await data!.goals(child.id);
      }
    } catch (e) { error = 'Data belum dapat dimuat: $e'; }
    loading = false; notifyListeners();
  }

  Future<void> signIn(String email, String password) async { await auth!.signIn(email, password); }
  Future<void> signUp(String email, String password, String name) async { await auth!.signUp(email, password, name); }
  Future<void> signOut() async { await auth?.signOut(); mode = UserMode.parent; notifyListeners(); }

  Future<void> addChild(String name, String age, String avatar) async {
    if (data != null && isSignedIn) { final child = await data!.createChild(name: name, age: age, avatar: avatar); children = [...children, child]; balances[child.id] = const WalletBalance(); selectedChildId = child.id; }
    else { final child = ChildProfile(id: 'local-${children.length + 1}', name: name, age: age, avatar: avatar); children = [...children, child]; balances[child.id] = const WalletBalance(); selectedChildId = child.id; }
    notifyListeners();
  }

  Future<void> addTransaction({required String description, required int amount, required WalletType wallet, required TransactionType type}) async {
    final current = selectedBalance;
    final delta = type == TransactionType.income ? amount : -amount;
    balances[selectedChildId] = switch (wallet) {
      WalletType.spend => current.copyWith(spend: current.spend + delta),
      WalletType.save => current.copyWith(save: current.save + delta),
      WalletType.share => current.copyWith(share: current.share + delta),
    };
    final transaction = MoneyTransaction(id: DateTime.now().toIso8601String(), description: description, amount: amount, type: type, wallet: wallet);
    transactions[selectedChildId] = [transaction, ...(transactions[selectedChildId] ?? const [])];
    if (data != null && isSignedIn) await data!.addTransaction(childId: selectedChildId, description: description, amount: amount, wallet: wallet, type: type);
    notifyListeners();
  }

  Future<void> addTask(String title, int reward) async {
    final task = MoneyTask(id: DateTime.now().toIso8601String(), title: title, reward: reward, status: TaskStatus.active);
    tasks[selectedChildId] = [task, ...(tasks[selectedChildId] ?? const [])];
    if (data != null && isSignedIn) await data!.createTask(childId: selectedChildId, title: title, reward: reward);
    notifyListeners();
  }

  Future<void> addGoal(String title, int target) async {
    final goal = SavingsGoal(id: DateTime.now().toIso8601String(), title: title, current: 0, target: target);
    goals[selectedChildId] = [goal, ...(goals[selectedChildId] ?? const [])];
    if (data != null && isSignedIn) await data!.createGoal(childId: selectedChildId, title: title, target: target);
    notifyListeners();
  }

  void selectChild(String id) { selectedChildId = id; notifyListeners(); }
  void enterChildMode() { mode = UserMode.child; notifyListeners(); }
  void enterParentMode() { mode = UserMode.parent; notifyListeners(); }
}

extension FirstOrNull<T> on Iterable<T> { T? get firstOrNull => isEmpty ? null : first; }
