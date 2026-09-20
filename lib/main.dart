import 'package:flutter/material.dart';

void main() => runApp(const KidsMoneyApp());

class MoneyFormat {
  static String rupiah(num value) => 'Rp${value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(?<=\d)(?=(\d{3})+$)'), (_) => '.')}' ;
}

class Child {
  Child(this.id, this.name, this.age, this.avatar);
  final String id, name, age, avatar;
}

class Wallets {
  Wallets({this.spend = 0, this.save = 0, this.share = 0});
  int spend, save, share;
  int get total => spend + save + share;
}

class KidsMoneyApp extends StatefulWidget {
  const KidsMoneyApp({super.key});
  @override State<KidsMoneyApp> createState() => _KidsMoneyAppState();
}

class _KidsMoneyAppState extends State<KidsMoneyApp> {
  bool parentMode = true;
  int parentTab = 0, childTab = 0;
  String selectedId = 'c_001';
  final children = <Child>[
    Child('c_001', 'Raka', '8-10', '🧑🏻'),
    Child('c_002', 'Alya', '5-7', '👧🏻'),
    Child('c_003', 'Dimas', '11-12', '👦🏻'),
  ];
  final wallets = <String, Wallets>{
    'c_001': Wallets(spend: 50000, save: 150000, share: 50000),
    'c_002': Wallets(spend: 70000, save: 120000, share: 30000),
    'c_003': Wallets(),
  };
  Child get child => children.firstWhere((c) => c.id == selectedId);
  Wallets get money => wallets[selectedId]!;

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true, fontFamily: 'Arial', colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff16a34a))),
    home: parentMode ? ParentShell(state: this) : ChildShell(state: this),
  );
}

class ParentShell extends StatelessWidget {
  const ParentShell({required this.state, super.key});
  final _KidsMoneyAppState state;
  static const tabs = ['HOME', 'ANAK', 'TRANSAKSI', 'MISI', 'LAPORAN'];
  static const labels = ['Dashboard', 'Data Anak', 'Mutasi', 'Atur Misi', 'Laporan'];
  static const icons = [Icons.dashboard, Icons.child_care, Icons.receipt_long, Icons.rule, Icons.analytics];

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xfff8faf8),
    body: SafeArea(child: Column(children: [Expanded(child: _ParentBody(state: state, tab: tabs[state.parentTab])), _nav(context)])),
  );

  Widget _nav(BuildContext context) => Container(
    decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xffe2e8f0)))),
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: List.generate(labels.length, (i) {
      final active = state.parentTab == i;
      return InkWell(onTap: () { state.parentTab = i; state.setState(() {}); }, borderRadius: BorderRadius.circular(20), child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), decoration: BoxDecoration(color: active ? const Color(0xffdcfce7) : Colors.transparent, borderRadius: BorderRadius.circular(20)), child: Icon(icons[i], size: 21, color: active ? const Color(0xff15803d) : const Color(0xff64748b))),
          Text(labels[i], style: TextStyle(fontSize: 10, color: active ? const Color(0xff15803d) : const Color(0xff64748b), fontWeight: active ? FontWeight.bold : FontWeight.normal)),
        ]),
      ));
    })),
  );
}

class _ParentBody extends StatelessWidget {
  const _ParentBody({required this.state, required this.tab});
  final _KidsMoneyAppState state; final String tab;
  @override
  Widget build(BuildContext context) => CustomScrollView(slivers: [SliverToBoxAdapter(child: _header(context)), SliverPadding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 32), sliver: SliverToBoxAdapter(child: _content(context)))]);

  Widget _header(BuildContext context) => Container(
    color: Colors.white, padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
    child: Column(children: [Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      CircleAvatar(radius: 21, backgroundColor: const Color(0xffdcfce7), child: const Text('👩🏻', style: TextStyle(fontSize: 22))),
      const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Wrap(spacing: 6, crossAxisAlignment: WrapCrossAlignment.center, children: [Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: const Color(0xffdcfce7), borderRadius: BorderRadius.circular(20)), child: const Text('MODE ORANG TUA', style: TextStyle(fontSize: 9, color: Color(0xff166534), fontWeight: FontWeight.bold))), Text('Keluarga Pratama', style: const TextStyle(fontSize: 12, color: Color(0xff64748b)))]),
        const Text('Rina Pratama', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ])),
      const SizedBox(width: 8),
      FilledButton.icon(onPressed: () { state.parentMode = false; state.setState(() {}); }, icon: const Icon(Icons.sports_esports, size: 16), label: const Text('Beralih Ke Anak', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)), style: FilledButton.styleFrom(backgroundColor: const Color(0xff10b981), foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)))),
    ]), const SizedBox(height: 12), _childPicker(context)]),
  );

  Widget _childPicker(BuildContext context) => SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [const Text('PILIH ANAK:', style: TextStyle(fontSize: 10, color: Color(0xff64748b), fontWeight: FontWeight.bold)), const SizedBox(width: 8), ...state.children.map((c) {
    final active = c.id == state.selectedId;
    return Padding(padding: const EdgeInsets.only(right: 7), child: OutlinedButton.icon(onPressed: () { state.selectedId = c.id; state.setState(() {}); }, icon: Text(c.avatar, style: const TextStyle(fontSize: 16)), label: Text(c.name, style: const TextStyle(fontSize: 11)), style: OutlinedButton.styleFrom(backgroundColor: active ? const Color(0xff059669) : const Color(0xfff1f5f9), foregroundColor: active ? Colors.white : const Color(0xff334155), side: BorderSide(color: active ? const Color(0xff059669) : const Color(0xffe2e8f0)), padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)))));
  }), TextButton(onPressed: () {}, child: const Text('+ Tambah', style: TextStyle(fontSize: 11, color: Color(0xff047857))))]));

  Widget _content(BuildContext context) {
    if (tab == 'ANAK') return _children();
    if (tab == 'TRANSAKSI') return _transactions();
    if (tab == 'MISI') return _missions();
    if (tab == 'LAPORAN') return _report();
    final w = state.money;
    return Column(children: [Container(width: double.infinity, padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xffe2e8f0)), boxShadow: const [BoxShadow(color: Color(0x100f172a), blurRadius: 8)]), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('TOTAL TABUNGAN ${state.child.name}', style: const TextStyle(fontSize: 10, color: Color(0xff64748b), fontWeight: FontWeight.bold)), const SizedBox(height: 5), Text(MoneyFormat.rupiah(w.total), style: const TextStyle(fontSize: 25, color: Color(0xff16a34a), fontWeight: FontWeight.w900))]), FilledButton(onPressed: () {}, style: FilledButton.styleFrom(backgroundColor: const Color(0xff10b981), foregroundColor: Colors.white), child: const Text('+ Saldo'))])), const SizedBox(height: 12), Row(children: [Expanded(child: _quick(Icons.add_task, 'Buat Misi Baru')), const SizedBox(width: 8), Expanded(child: _quick(Icons.stars, 'Tambah Target'))])]);
  }
  Widget _quick(IconData icon, String text) => OutlinedButton.icon(onPressed: () {}, icon: Icon(icon, color: const Color(0xff16a34a)), label: Text(text, style: const TextStyle(fontSize: 11, color: Color(0xff1e293b))), style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(13), side: const BorderSide(color: Color(0xffe2e8f0)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))));
  Widget _children() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Daftar Anak', style: TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 10), ...state.children.map((c) => Card(child: ListTile(leading: Text(c.avatar, style: const TextStyle(fontSize: 28)), title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text('Usia ${c.age} tahun'), trailing: Text(MoneyFormat.rupiah(state.wallets[c.id]!.total), style: const TextStyle(color: Color(0xff16a34a), fontWeight: FontWeight.bold))))) ]);
  Widget _transactions() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Riwayat Transaksi - ${state.child.name}', style: const TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 10), ...['Uang saku mingguan', 'Membantu cuci mobil', 'Beli camilan sore', 'Hasil jualan pembatas buku'].map((x) => Card(child: ListTile(leading: const CircleAvatar(backgroundColor: Color(0xffdcfce7), child: Icon(Icons.payments, color: Color(0xff15803d))), title: Text(x, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)), subtitle: const Text('September 2026 • Dompet SAVE', style: TextStyle(fontSize: 10)), trailing: const Text('+Rp50.000', style: TextStyle(color: Color(0xff16a34a), fontWeight: FontWeight.bold))))) ]);
  Widget _missions() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Kelola Misi', style: TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 10), ...['Menyapu Halaman Depan', 'Merapikan Tempat Tidur', 'Menata Rak Buku'].map((x) => Card(child: ListTile(title: Text(x, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)), subtitle: const Text('Imbalan: Rp10.000', style: TextStyle(color: Color(0xff047857), fontSize: 11)), trailing: const Chip(label: Text('Berjalan', style: TextStyle(fontSize: 10)))))) ]);
  Widget _report() { final w = state.money; return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Ringkasan Keuangan', style: TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 10), Row(children: [_stat('JAJANGAN', w.spend, const Color(0xfffff7ed)), _stat('TABUNGAN', w.save, const Color(0xffeef2ff)), _stat('BERBAGI', w.share, const Color(0xfffdf2f8))])]); }
  Widget _stat(String title, int value, Color color) => Expanded(child: Container(margin: const EdgeInsets.only(right: 6), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)), child: Column(children: [Text(title, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)), const SizedBox(height: 5), Text(MoneyFormat.rupiah(value), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900))])));
}

class ChildShell extends StatelessWidget {
  const ChildShell({required this.state, super.key}); final _KidsMoneyAppState state;
  @override Widget build(BuildContext context) => Scaffold(backgroundColor: const Color(0xffeff6ff), body: SafeArea(child: Column(children: [Expanded(child: CustomScrollView(slivers: [SliverToBoxAdapter(child: _header()), SliverPadding(padding: const EdgeInsets.all(16), sliver: SliverToBoxAdapter(child: _body()))])), _nav()] )));
  Widget _header() => Container(padding: const EdgeInsets.fromLTRB(20, 20, 20, 22), decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xff10b981), Color(0xff0d9488), Color(0xff16a34a)]), borderRadius: BorderRadius.vertical(bottom: Radius.circular(36))), child: Column(children: [Row(children: [Text(state.child.avatar, style: const TextStyle(fontSize: 42)), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Wrap(spacing: 6, children: [Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: const Color(0xffffd54f), borderRadius: BorderRadius.circular(12)), child: const Text('MODE ANAK', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),), Text('Halo, ${state.child.name}! 👋', style: const TextStyle(color: Color(0xffd1fae5), fontSize: 12, fontWeight: FontWeight.bold))]), const Text('Petualangan Keuanganku', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800))])), IconButton(onPressed: () { state.parentMode = true; state.setState(() {}); }, icon: const Icon(Icons.lock, color: Color(0xffffd54f)))]), const SizedBox(height: 16), Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white.withOpacity(.95), borderRadius: BorderRadius.circular(24)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('TOTAL UANGKU', style: TextStyle(fontSize: 10, color: Color(0xff64748b), fontWeight: FontWeight.bold)), Text(MoneyFormat.rupiah(state.money.total), style: const TextStyle(fontSize: 25, color: Color(0xff059669), fontWeight: FontWeight.w900))]), FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.auto_awesome, size: 17), label: const Text('Tanya AI', style: TextStyle(fontSize: 11)), style: FilledButton.styleFrom(backgroundColor: const Color(0xffffc107), foregroundColor: Colors.black))]))]));
  Widget _body() { final w = state.money; return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('3 DOMPET UANGKU', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xff64748b))), const SizedBox(height: 6), Row(children: [_wallet('Jajangan', w.spend, const Color(0xffffedd5), const Color(0xff9a3412)), _wallet('Tabungan', w.save, const Color(0xffe0e7ff), const Color(0xff3730a3)), _wallet('Berbagi', w.share, const Color(0xffffe7f3), const Color(0xff9d174d))]), const SizedBox(height: 16), Container(width: double.infinity, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xfffff7ed), borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xfffed7aa), width: 2)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('🎯 TARGET UTAMA', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xff92400e))), const SizedBox(height: 8), const Text('Sepeda Baru Polygon', style: TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 8), ClipRRect(borderRadius: BorderRadius.circular(8), child: const LinearProgressIndicator(value: .45, minHeight: 10, color: Color(0xffffb300), backgroundColor: Color(0xffffe5b4))), const SizedBox(height: 8), const Text('Rp450.000 dari Rp1.000.000', style: TextStyle(fontSize: 11, color: Color(0xff92400e), fontWeight: FontWeight.bold))])), const SizedBox(height: 16), const Text('AKSI CEPAT', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xff166534))), const SizedBox(height: 8), GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 1.5, children: [_action(Icons.add_circle, 'Aku Dapat Uang'), _action(Icons.remove_circle, 'Aku Beli Sesuatu'), _action(Icons.stars, 'Misi Penghasilan'), _action(Icons.help_outline, 'Boleh Beli?')])]); }
  Widget _wallet(String title, int value, Color bg, Color fg) => Expanded(child: Container(margin: const EdgeInsets.only(right: 6), padding: const EdgeInsets.all(10), height: 100, decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(18)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Icon(title == 'Tabungan' ? Icons.savings : title == 'Jajangan' ? Icons.shopping_bag : Icons.favorite, color: fg, size: 20), Text(title, style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.bold)), Text(MoneyFormat.rupiah(value), style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w900))])));
  Widget _action(IconData icon, String title) => Card(child: InkWell(onTap: () {}, borderRadius: BorderRadius.circular(16), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: const Color(0xff059669), size: 28), const SizedBox(height: 6), Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xff166534)))])));
  Widget _nav() => Container(padding: const EdgeInsets.symmetric(vertical: 7), decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xff059669), Color(0xff0f766e)]), border: Border(top: BorderSide(color: Color(0xffffd54f), width: 3)), borderRadius: BorderRadius.vertical(top: Radius.circular(26))), child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: ['Dompetku', 'Impianku', 'Misiku', 'Teman AI', 'Prestasi'].asMap().entries.map((e) => InkWell(onTap: () {}, child: Column(children: [Icon([Icons.account_balance_wallet, Icons.stars, Icons.sports_esports, Icons.auto_awesome, Icons.military_tech][e.key], color: Colors.amber.shade300, size: 21), Text(e.value, style: const TextStyle(color: Colors.white, fontSize: 10))]))).toList());
}
