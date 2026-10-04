import 'package:supabase_flutter/supabase_flutter.dart';

class ChildrenRepository {
  ChildrenRepository(this.client);
  final SupabaseClient client;

  Future<List<Map<String, dynamic>>> listMine() async {
    final response = await client
        .from('children')
        .select('id, name, age_group, avatar, created_at')
        .order('created_at');
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> create({
    required String name,
    required String ageGroup,
    String avatar = 'face',
  }) async {
    final user = client.auth.currentUser;
    if (user == null) throw StateError('Login diperlukan sebelum membuat profil anak.');
    final response = await client.from('children').insert({
      'user_id': user.id,
      'name': name,
      'age_group': ageGroup,
      'avatar': avatar,
    }).select().single();
    return Map<String, dynamic>.from(response);
  }
}
