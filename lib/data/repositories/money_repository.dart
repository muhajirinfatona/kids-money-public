import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/kids_money_models.dart';

class MoneyRepository {
  MoneyRepository(this.client);
  final SupabaseClient client;

  Future<List<ChildProfile>> children() async => (await client.from('children').select('id,name,age_group,avatar').order('created_at')).map((r) => ChildProfile.fromMap(Map<String, dynamic>.from(r))).toList();

  Future<ChildProfile> createChild({required String name, required String age, required String avatar}) async {
    final row = await client.from('children').insert({'name': name.trim(), 'age_group': age, 'avatar': avatar}).select('id,name,age_group,avatar').single();
    return ChildProfile.fromMap(Map<String, dynamic>.from(row));
  }

  Future<WalletBalance> balance(String childId) async {
    final rows = await client.from('wallets').select('wallet_type,balance').eq('child_id', childId);
    final values = <String, dynamic>{for (final row in rows) row['wallet_type'] as String: row['balance']};
    return WalletBalance.fromMap({'spend': values['spend'], 'save': values['save'], 'share': values['share']});
  }

  Future<List<MoneyTransaction>> transactions(String childId) async => (await client.from('transactions').select('id,description,amount,type,wallet').eq('child_id', childId).order('created_at', ascending: false).limit(50)).map((r) => MoneyTransaction.fromMap(Map<String, dynamic>.from(r))).toList();

  Future<void> addTransaction({required String childId, required String description, required int amount, required WalletType wallet, required TransactionType type}) async {
    final current = await client.from('wallets').select('balance').eq('child_id', childId).eq('wallet_type', wallet.name).single();
    final next = (current['balance'] as num).toInt() + (type == TransactionType.income ? amount : -amount);
    if (next < 0) throw StateError('Saldo ${wallet.name} tidak mencukupi.');
    await client.from('transactions').insert({'child_id': childId, 'description': description.trim(), 'amount': amount, 'wallet': wallet.name, 'type': type.name});
    await client.from('wallets').update({'balance': next}).eq('child_id', childId).eq('wallet_type', wallet.name);
  }

  Future<List<MoneyTask>> tasks(String childId) async => (await client.from('tasks').select('id,title,reward,status').eq('child_id', childId).order('created_at')).map((r) => MoneyTask.fromMap(Map<String, dynamic>.from(r))).toList();

  Future<void> createTask({required String childId, required String title, required int reward}) async => client.from('tasks').insert({'child_id': childId, 'title': title.trim(), 'reward': reward, 'status': TaskStatus.active.name});

  Future<List<SavingsGoal>> goals(String childId) async => (await client.from('savings_goals').select('id,title,current_amount,target_amount').eq('child_id', childId).order('created_at')).map((r) => SavingsGoal.fromMap(Map<String, dynamic>.from(r))).toList();

  Future<void> createGoal({required String childId, required String title, required int target}) async => client.from('savings_goals').insert({'child_id': childId, 'title': title.trim(), 'target_amount': target});
}
