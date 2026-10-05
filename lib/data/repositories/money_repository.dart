import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/kids_money_models.dart';

class MoneyRepository {
  MoneyRepository(this.client);
  final SupabaseClient client;

  Future<List<ChildProfile>> children() async => (await client.from('children').select('id,name,age_group,avatar').order('created_at')).map((r) => ChildProfile.fromMap(Map<String, dynamic>.from(r))).toList();

  Future<ChildProfile> createChild({required String name, required String age, required String avatar}) async {
    final row = await client.from('children').insert({'name': name.trim(), 'age_group': age.replaceAll('-', '_'), 'avatar': avatar}).select('id,name,age_group,avatar').single();
    return ChildProfile.fromMap(Map<String, dynamic>.from(row));
  }

  Future<WalletBalance> balance(String childId) async {
    final rows = await client.from('wallets').select('wallet_type,balance').eq('child_id', childId);
    final values = <String, dynamic>{for (final row in rows) row['wallet_type'] as String: row['balance']};
    return WalletBalance.fromMap({'spend': values['spend'], 'save': values['save'], 'share': values['share']});
  }

  Future<List<MoneyTransaction>> transactions(String childId) async => (await client.from('transactions').select('id,description,amount,type,wallet_type').eq('child_id', childId).order('created_at', ascending: false).limit(50)).map((r) => MoneyTransaction.fromMap(Map<String, dynamic>.from(r))).toList();

  Future<void> addTransaction({required String childId, required String description, required int amount, required WalletType wallet, required TransactionType type}) async {
    await client.rpc('record_transaction', params: {
      'p_child_id': childId,
      'p_type': type.name,
      'p_amount': amount,
      'p_wallet_type': wallet.name,
      'p_description': description.trim(),
    });
  }

  Future<List<MoneyTask>> tasks(String childId) async => (await client.from('tasks').select('id,title,reward_amount,status').eq('child_id', childId).order('created_at')).map((r) => MoneyTask.fromMap(Map<String, dynamic>.from(r))).toList();

  Future<void> createTask({required String childId, required String title, required int reward}) async => client.from('tasks').insert({'child_id': childId, 'title': title.trim(), 'reward_amount': reward, 'status': TaskStatus.active.name});

  Future<List<SavingsGoal>> goals(String childId) async => (await client.from('savings_goals').select('id,title,current_amount,target_amount').eq('child_id', childId).order('created_at')).map((r) => SavingsGoal.fromMap(Map<String, dynamic>.from(r))).toList();

  Future<void> createGoal({required String childId, required String title, required int target}) async => client.from('savings_goals').insert({'child_id': childId, 'title': title.trim(), 'target_amount': target});
}
