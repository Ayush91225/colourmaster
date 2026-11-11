import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/Transaction.dart';
import '../provider/user_provider.dart';
import '../utils/sharedPreferenceKey.dart';
import '../utils/premium_theme.dart';
import '../utils/utilsMethods.dart';
import 'widget/premium_shimmer.dart';
import 'widget/app_header.dart';

class ProductQRRedeemHistoryScreen extends StatefulWidget {
  const ProductQRRedeemHistoryScreen({super.key});
  @override
  State<ProductQRRedeemHistoryScreen> createState() => _State();
}

class _State extends State<ProductQRRedeemHistoryScreen> {
  final _startCtrl = TextEditingController();
  final _endCtrl   = TextEditingController();
  String _token = '', _startDate = '', _endDate = '';
  DateTime _lastStart = DateTime.now().subtract(const Duration(days: 1));
  DateTime _lastEnd   = DateTime.now().subtract(const Duration(days: 1));

  @override
  void initState() { super.initState(); _init(); }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(TOKEN) ?? '';
    final p = Provider.of<UserProvider>(context, listen: false);
    p.transactionDataArr = [];
    if (await check()) {
      await p.fetchProductTransactionList(context, _token, '', '');
    } else {
      showWarningToast('No network connection');
    }
  }

  @override
  void dispose() { _startCtrl.dispose(); _endCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final s = (sw / 390).clamp(0.8, 1.3);

    return Scaffold(
      backgroundColor: AppTheme.black,
      body: Consumer<UserProvider>(
        builder: (_, p, __) => CustomScrollView(
          slivers: [
            appHeader(context: context, title: 'QR History'),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16 * s, 16 * s, 16 * s, 40 * s),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  if (p.isLoading) ...[
                    PremiumShimmer.card(height: 80 * s),
                    SizedBox(height: 12 * s),
                    PremiumShimmer.card(height: 90 * s),
                    SizedBox(height: 16 * s),
                    ...List.generate(5, (_) => Padding(
                      padding: EdgeInsets.only(bottom: 10 * s),
                      child: PremiumShimmer.card(height: 88 * s),
                    )),
                  ] else ...[
                    if (p.transactionDataArr.isNotEmpty) _summaryCard(p.transactionDataArr, s),
                    SizedBox(height: 12 * s),
                    _dateFilter(p, s),
                    SizedBox(height: 16 * s),
                    if (p.transactionDataArr.isEmpty)
                      _empty(s)
                    else ...[
                      Text('${p.transactionDataArr.length} scans',
                          style: TextStyle(fontSize: 12 * s, color: AppTheme.white30, fontWeight: FontWeight.w500)),
                      SizedBox(height: 10 * s),
                      ...p.transactionDataArr.map((t) => _txCard(t, s)),
                    ],
                  ],
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard(List<TransactionData> list, double s) {
    final pts = list.fold<int>(0, (a, t) => a + (int.tryParse(t.points?.toString() ?? '0') ?? 0));
    return Container(
      padding: EdgeInsets.symmetric(vertical: 18 * s, horizontal: 8 * s),
      decoration: BoxDecoration(
        color: AppTheme.black2,
        borderRadius: BorderRadius.circular(20 * s),
        border: Border.all(color: AppTheme.black5),
      ),
      child: Row(children: [
        _stat('Scans',     '${list.length}', AppTheme.white,  s),
        _vDiv(),
        _stat('Total PTS', '$pts',           AppTheme.orange, s),
      ]),
    );
  }

  Widget _stat(String l, String v, Color c, double s) => Expanded(child: Column(children: [
    Text(v, style: TextStyle(fontSize: 20 * s, fontWeight: FontWeight.w800, color: c)),
    SizedBox(height: 3 * s),
    Text(l, style: TextStyle(fontSize: 10 * s, color: AppTheme.white30)),
  ]));

  Widget _vDiv() => Container(width: 1, height: 32, color: AppTheme.black5);

  Widget _dateFilter(UserProvider p, double s) => Container(
    padding: EdgeInsets.all(16 * s),
    decoration: BoxDecoration(
      color: AppTheme.black2,
      borderRadius: BorderRadius.circular(20 * s),
      border: Border.all(color: AppTheme.black5),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(Icons.calendar_month_outlined, size: 15 * s, color: AppTheme.white30),
        SizedBox(width: 6 * s),
        Text('Filter by Date',
            style: TextStyle(fontSize: 13 * s, fontWeight: FontWeight.w600, color: AppTheme.white)),
        const Spacer(),
        if (_startDate.isNotEmpty || _endDate.isNotEmpty)
          GestureDetector(
            onTap: () {
              setState(() { _startDate = ''; _endDate = ''; _startCtrl.clear(); _endCtrl.clear(); });
              _fetch(p);
            },
            child: Text('Clear', style: TextStyle(fontSize: 12 * s, color: AppTheme.orange, fontWeight: FontWeight.w600)),
          ),
      ]),
      SizedBox(height: 12 * s),
      Row(children: [
        Expanded(child: _datePicker('From', _startCtrl, () => _pickStart(p), s)),
        SizedBox(width: 10 * s),
        Expanded(child: _datePicker('To', _endCtrl, () => _pickEnd(p), s)),
      ]),
    ]),
  );

  Widget _datePicker(String label, TextEditingController ctrl, VoidCallback onTap, double s) =>
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(fontSize: 10 * s, color: AppTheme.white30, fontWeight: FontWeight.w500)),
      SizedBox(height: 5 * s),
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12 * s, vertical: 11 * s),
          decoration: BoxDecoration(
            color: AppTheme.black3,
            borderRadius: BorderRadius.circular(12 * s),
            border: Border.all(color: AppTheme.black5),
          ),
          child: Row(children: [
            Expanded(child: Text(
              ctrl.text.isEmpty ? 'Select date' : ctrl.text,
              style: TextStyle(fontSize: 12 * s,
                  color: ctrl.text.isEmpty ? AppTheme.white30 : AppTheme.white,
                  fontWeight: FontWeight.w500),
            )),
            Icon(Icons.calendar_today_outlined, size: 13 * s, color: AppTheme.white30),
          ]),
        ),
      ),
    ]);

  Widget _txCard(TransactionData tx, double s) {
    final isCredit = tx.type == 'credit';
    return Container(
      margin: EdgeInsets.only(bottom: 10 * s),
      padding: EdgeInsets.all(14 * s),
      decoration: BoxDecoration(
        color: AppTheme.black2,
        borderRadius: BorderRadius.circular(16 * s),
        border: Border.all(color: AppTheme.black5),
      ),
      child: Row(children: [
        Container(
          width: 42 * s, height: 42 * s,
          decoration: BoxDecoration(
            color: AppTheme.orange.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12 * s),
          ),
          child: Icon(Icons.qr_code_rounded, color: AppTheme.orange, size: 18 * s),
        ),
        SizedBox(width: 12 * s),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(tx.productName ?? 'QR Redeem',
              style: TextStyle(fontSize: 13 * s, fontWeight: FontWeight.w600, color: AppTheme.white)),
          SizedBox(height: 2 * s),
          if ((tx.transactionId ?? '').isNotEmpty)
            Text(tx.transactionId!,
                style: TextStyle(fontSize: 11 * s, color: AppTheme.white30),
                maxLines: 1, overflow: TextOverflow.ellipsis),
          SizedBox(height: 2 * s),
          Text('${lastTransactionDate(tx.createdAt)}  ·  ${getFormattedTime(tx.createdAt)}',
              style: TextStyle(fontSize: 11 * s, color: AppTheme.white30)),
        ])),
        SizedBox(width: 10 * s),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(isCredit ? '+${tx.points}' : '-${tx.points}',
              style: TextStyle(fontSize: 15 * s, fontWeight: FontWeight.w700, color: AppTheme.orange)),
          SizedBox(height: 6 * s),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 3 * s),
            decoration: BoxDecoration(
              color: AppTheme.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20 * s),
              border: Border.all(color: AppTheme.orange.withOpacity(0.2)),
            ),
            child: Text('Success',
                style: TextStyle(fontSize: 10 * s, fontWeight: FontWeight.w700, color: AppTheme.orange)),
          ),
        ]),
      ]),
    );
  }

  Widget _empty(double s) => Padding(
    padding: EdgeInsets.symmetric(vertical: 60 * s),
    child: Column(children: [
      Container(
        width: 72 * s, height: 72 * s,
        decoration: BoxDecoration(color: AppTheme.black3, borderRadius: BorderRadius.circular(20 * s)),
        child: Icon(Icons.qr_code_scanner_rounded, size: 32 * s, color: AppTheme.white30),
      ),
      SizedBox(height: 16 * s),
      Text('No QR Transactions',
          style: TextStyle(fontSize: 15 * s, fontWeight: FontWeight.w600, color: AppTheme.white)),
      SizedBox(height: 6 * s),
      Text('Scan a QR code to earn points',
          style: TextStyle(fontSize: 13 * s, color: AppTheme.white30)),
    ]),
  );

  Future<void> _pickStart(UserProvider p) async {
    final d = await showDatePicker(context: context, initialDate: _lastStart, firstDate: DateTime(2020), lastDate: DateTime.now());
    if (!mounted || d == null) return;
    _lastStart = d; _startDate = DateFormat('yyyy-MM-dd').format(d); _startCtrl.text = DateFormat('dd/MM/yyyy').format(d); _fetch(p);
  }

  Future<void> _pickEnd(UserProvider p) async {
    final d = await showDatePicker(context: context, initialDate: _lastEnd, firstDate: DateTime(2020), lastDate: DateTime.now());
    if (!mounted || d == null) return;
    _lastEnd = d; _endDate = DateFormat('yyyy-MM-dd').format(d); _endCtrl.text = DateFormat('dd/MM/yyyy').format(d); _fetch(p);
  }

  void _fetch(UserProvider p) {
    check().then((ok) async {
      if (!mounted) return;
      if (ok) { p.transactionDataArr = []; await p.fetchProductTransactionList(context, _token, _startDate, _endDate); }
      else showWarningToast('No network connection');
    });
  }
}
