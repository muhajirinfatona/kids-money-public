import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'application/app_state.dart';
import 'core/config/supabase_config.dart';
import 'core/theme/app_theme.dart';
import 'domain/models/kids_money_models.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SupabaseConfig.validate();
  if (SupabaseConfig.isConfigured) await Supabase.initialize(url: SupabaseConfig.url, anonKey: SupabaseConfig.publishableKey);
  runApp(KidsMoneyApp(state: AppState(client: SupabaseConfig.isConfigured ? Supabase.instance.client : null)));
}

class KidsMoneyApp extends StatelessWidget {
  const KidsMoneyApp({required this.state, super.key});
  final AppState state;
  @override Widget build(BuildContext context) => AnimatedBuilder(animation: state, builder: (_, __) => MaterialApp(debugShowCheckedModeBanner: false, theme: AppTheme.light(), home: state.isConfigured && !state.isSignedIn ? LoginPage(state: state) : HomePage(state: state)));
}

class LoginPage extends StatefulWidget {
  const LoginPage({required this.state, super.key}); final AppState state;
  @override State<LoginPage> createState() => _LoginPageState();
}
class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController(), password = TextEditingController(), name = TextEditingController();
  bool register = false, busy = false, showPassword = false;
  Future<void> submit() async {
    if (register && name.text.trim().isEmpty) { _message('Nama orang tua wajib diisi.'); return; }
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email.text.trim())) { _message('Masukkan alamat email yang valid.'); return; }
    if (password.text.length < 6) { _message('Password harus terdiri dari minimal 6 karakter.'); return; }
    setState(() => busy = true);
    try { if (register) await widget.state.signUp(email.text, password.text, name.text); else await widget.state.signIn(email.text, password.text); if (mounted && register) _message('Akun dibuat. Periksa email bila konfirmasi diaktifkan.'); }
    catch (e) { if (mounted) _message(friendlyAuthError(e)); }
    if (mounted) setState(() => busy = false);
  }
  @override void dispose() { email.dispose(); password.dispose(); name.dispose(); super.dispose(); }
  void _message(String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset('assets/branding/kids_money_logo.png', height: 92, fit: BoxFit.contain),
                  const SizedBox(height: 8),
                  const SizedBox(height: 6),
                  Text(register ? 'Buat akun orang tua' : 'Kelola uang anak dengan aman', style: const TextStyle(color: AppTheme.muted)),
                  const SizedBox(height: 28),
                  if (register) TextField(controller: name, decoration: const InputDecoration(labelText: 'Nama orang tua', prefixIcon: Icon(Icons.person))),
                  if (register) const SizedBox(height: 12),
                  TextField(controller: email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email))),
                  const SizedBox(height: 12),
                  TextField(controller: password, obscureText: !showPassword, decoration: InputDecoration(labelText: 'Password', prefixIcon: const Icon(Icons.lock), suffixIcon: IconButton(tooltip: showPassword ? 'Sembunyikan password' : 'Tampilkan password', onPressed: () => setState(() => showPassword = !showPassword), icon: Icon(showPassword ? Icons.visibility_off : Icons.visibility))),),
                  const SizedBox(height: 20),
                  FilledButton(onPressed: busy ? null : submit, child: Text(busy ? 'Memproses...' : register ? 'Daftar' : 'Masuk')),
                  TextButton(onPressed: busy ? null : () => setState(() => register = !register), child: Text(register ? 'Sudah punya akun? Masuk' : 'Belum punya akun? Daftar')),
                  if (!widget.state.isConfigured) const Padding(padding: EdgeInsets.only(top: 16), child: Text('Mode demo aktif karena Supabase belum dikonfigurasi.', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.muted))),
                ],
              ),
            ),
          ),
        ),
      );
}

class HomePage extends StatelessWidget {
  const HomePage({required this.state, super.key}); final AppState state;
  @override Widget build(BuildContext context) => state.mode == UserMode.parent ? ParentPage(state: state) : ChildPage(state: state);
}

class ParentPage extends StatelessWidget {
  const ParentPage({required this.state, super.key}); final AppState state;
  static const tabs = ['Dashboard', 'Anak', 'Transaksi', 'Misi', 'Target'];
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Kids Money'), actions: [IconButton(onPressed: () => state.signOut(), icon: const Icon(Icons.logout)), FilledButton.icon(onPressed: state.enterChildMode, icon: const Icon(Icons.games, size: 18), label: const Text('Mode Anak'))]), body: Column(children: [SizedBox(height: 54, child: ListView.builder(scrollDirection: Axis.horizontal, itemCount: tabs.length, itemBuilder: (_, i) => ChoiceChip(label: Text(tabs[i]), selected: state.parentTab == i, onSelected: (_) { state.parentTab = i; state.notifyListeners(); }))), Expanded(child: RefreshIndicator(onRefresh: state.load, child: ListView(padding: const EdgeInsets.all(16), children: [_ChildPicker(state: state), const SizedBox(height: 16), _ParentContent(state: state)]))) ]));
}

class _ChildPicker extends StatelessWidget {
  const _ChildPicker({required this.state}); final AppState state;
  @override Widget build(BuildContext context) => Row(children: [const Text('Anak:', style: TextStyle(fontWeight: FontWeight.bold)), const SizedBox(width: 8), Expanded(child: DropdownButton<String>(isExpanded: true, value: state.selectedChildId, items: state.children.map((c) => DropdownMenuItem(value: c.id, child: Text('${c.avatar}  ${c.name} (${c.age})'))).toList(), onChanged: (v) { if (v != null) state.selectChild(v); })), IconButton(onPressed: () => _addChild(context), icon: const Icon(Icons.person_add))]);
  Future<void> _addChild(BuildContext context) async { final result = await _form(context, 'Tambah Anak', ['Nama', 'Kelompok usia', 'Emoji avatar']); if (result != null) await state.addChild(result[0], result[1].isEmpty ? '5-7' : result[1], result[2].isEmpty ? '🙂' : result[2]); }
}

class _ParentContent extends StatelessWidget {
  const _ParentContent({required this.state}); final AppState state;
  @override Widget build(BuildContext context) { switch (state.parentTab) { case 1: return _children(context); case 2: return _transactions(context); case 3: return _tasks(context); case 4: return _goals(context); default: return _dashboard(context); } }
  Widget _dashboard(BuildContext context) { final w = state.selectedBalance; return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [_card('Total saldo ${state.selectedChild.name}', AppFormat.rupiah(w.total), Icons.account_balance_wallet), Row(children: [_stat('Jajanan', w.spend, Colors.orange), _stat('Tabungan', w.save, Colors.indigo), _stat('Berbagi', w.share, Colors.pink)]), const SizedBox(height: 14), FilledButton.icon(onPressed: () => _transaction(context), icon: const Icon(Icons.add), label: const Text('Catat transaksi')), const SizedBox(height: 8), OutlinedButton.icon(onPressed: () => _task(context), icon: const Icon(Icons.stars), label: const Text('Buat misi')), OutlinedButton.icon(onPressed: () => _goal(context), icon: const Icon(Icons.flag), label: const Text('Buat target tabungan'))]); }
  Widget _children(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Text('Profil anak (${state.children.length})', style: Theme.of(context).textTheme.titleLarge), ...state.children.map((c) => Card(child: ListTile(leading: Text(c.avatar, style: const TextStyle(fontSize: 30)), title: Text(c.name), subtitle: Text('Usia ${c.age} • ${AppFormat.rupiah(state.balances[c.id]?.total ?? 0)}'), onTap: () => state.selectChild(c.id))))]);
  Widget _transactions(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Riwayat transaksi', style: Theme.of(context).textTheme.titleLarge), IconButton(onPressed: () => _transaction(context), icon: const Icon(Icons.add))]), ...(state.transactions[state.selectedChildId] ?? const <MoneyTransaction>[]).map((t) => ListTile(leading: Icon(t.type == TransactionType.income ? Icons.arrow_downward : Icons.arrow_upward, color: t.type == TransactionType.income ? Colors.green : Colors.red), title: Text(t.description), subtitle: Text('${t.wallet.name} • ${t.type.name}'), trailing: Text('${t.type == TransactionType.income ? '+' : '-'}${AppFormat.rupiah(t.amount)}')))]);
  Widget _tasks(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Misi penghasilan', style: Theme.of(context).textTheme.titleLarge), IconButton(onPressed: () => _task(context), icon: const Icon(Icons.add))]), ...(state.tasks[state.selectedChildId] ?? const <MoneyTask>[]).map((t) => Card(child: ListTile(title: Text(t.title), subtitle: Text('Imbalan ${AppFormat.rupiah(t.reward)}'), trailing: Chip(label: Text(t.status.name)))))]);
  Widget _goals(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Target tabungan', style: Theme.of(context).textTheme.titleLarge), IconButton(onPressed: () => _goal(context), icon: const Icon(Icons.add))]), ...(state.goals[state.selectedChildId] ?? const <SavingsGoal>[]).map((g) => Card(child: ListTile(title: Text(g.title), subtitle: LinearProgressIndicator(value: g.progress), trailing: Text('${AppFormat.rupiah(g.current)} / ${AppFormat.rupiah(g.target)}'))))]);
  Widget _card(String title, String value, IconData icon) => Card(child: ListTile(leading: Icon(icon, color: AppTheme.green), title: Text(title), subtitle: Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.green))));
  Widget _stat(String title, int value, Color color) => Expanded(child: Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(children: [Icon(Icons.circle, color: color, size: 12), Text(title, style: const TextStyle(fontSize: 11)), Text(AppFormat.rupiah(value), style: const TextStyle(fontWeight: FontWeight.bold))]))));
  Future<void> _transaction(BuildContext c) async { final r = await _form(c, 'Catat Transaksi', ['Deskripsi', 'Nominal', 'Dompet spend/save/share', 'income/expense']); if (r != null) await state.addTransaction(description: r[0], amount: int.tryParse(r[1]) ?? 0, wallet: WalletType.values.firstWhere((x) => x.name == r[2], orElse: () => WalletType.save), type: r[3] == 'expense' ? TransactionType.expense : TransactionType.income); }
  Future<void> _task(BuildContext c) async { final r = await _form(c, 'Buat Misi', ['Judul misi', 'Imbalan']); if (r != null) await state.addTask(r[0], int.tryParse(r[1]) ?? 0); }
  Future<void> _goal(BuildContext c) async { final r = await _form(c, 'Buat Target', ['Nama target', 'Nominal target']); if (r != null) await state.addGoal(r[0], int.tryParse(r[1]) ?? 0); }
}

class ChildPage extends StatelessWidget {
  const ChildPage({required this.state, super.key}); final AppState state;
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text('Halo, ${state.selectedChild.name}!'), leading: IconButton(onPressed: state.enterParentMode, icon: const Icon(Icons.lock))),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(child: ListTile(leading: Text(state.selectedChild.avatar, style: const TextStyle(fontSize: 40)), title: const Text('Total uangku'), subtitle: Text(AppFormat.rupiah(state.selectedBalance.total), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppTheme.green)))),
            const SizedBox(height: 12),
            const Text('Dompetku', style: TextStyle(fontWeight: FontWeight.bold)),
            _wallet('Jajanan', state.selectedBalance.spend),
            _wallet('Tabungan', state.selectedBalance.save),
            _wallet('Berbagi', state.selectedBalance.share),
            const SizedBox(height: 12),
            const Text('Misi aktif', style: TextStyle(fontWeight: FontWeight.bold)),
            ...(state.tasks[state.selectedChildId] ?? const <MoneyTask>[]).map((t) => ListTile(leading: const Icon(Icons.stars, color: Colors.amber), title: Text(t.title), trailing: Text(AppFormat.rupiah(t.reward)))),
          ],
        ),
      );
  Widget _wallet(String name, int value) => Card(child: ListTile(title: Text(name), trailing: Text(AppFormat.rupiah(value), style: const TextStyle(fontWeight: FontWeight.bold))));
}

Future<List<String>?> _form(BuildContext context, String title, List<String> labels) async { final controllers = labels.map((_) => TextEditingController()).toList(); return showDialog<List<String>>(context: context, builder: (c) => AlertDialog(title: Text(title), content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [for (var i = 0; i < labels.length; i++) Padding(padding: const EdgeInsets.only(bottom: 10), child: TextField(controller: controllers[i], decoration: InputDecoration(labelText: labels[i])))])), actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('Batal')), FilledButton(onPressed: () => Navigator.pop(c, controllers.map((x) => x.text.trim()).toList()), child: const Text('Simpan'))])); }

String friendlyAuthError(Object error) {
  final raw = error.toString().toLowerCase();
  if (raw.contains('socketexception') || raw.contains('failed host lookup') || raw.contains('network is unreachable') || raw.contains('timeout')) {
    return 'Tidak dapat terhubung ke server. Periksa koneksi internet, DNS, atau coba lagi beberapa saat.';
  }
  if (raw.contains('user already registered') || raw.contains('already registered')) return 'Email tersebut sudah terdaftar. Silakan masuk atau gunakan email lain.';
  if (raw.contains('invalid login credentials')) return 'Email atau password tidak sesuai.';
  if (raw.contains('password should be at least')) return 'Password harus terdiri dari minimal 6 karakter.';
  if (raw.contains('email not confirmed')) return 'Email belum dikonfirmasi. Periksa inbox email Anda.';
  if (raw.contains('rate limit')) return 'Terlalu banyak percobaan. Tunggu sebentar lalu coba lagi.';
  return 'Pendaftaran belum berhasil. Periksa data Anda lalu coba lagi.';
}
