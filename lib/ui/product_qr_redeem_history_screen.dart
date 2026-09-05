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
  void initState() {
    super.initState();
    _init();
  }

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
    return Scaffold(
      backgroundColor: AppTheme.black,
      body: Consumer<UserProvider>(
        builder: (_, p, __) => CustomScrollView(
          slivers: [
            appHeader(context: context, title: 'QR History'),

            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  if (!p.isLoading && p.transactionDataArr.isNotEmpty)
                    _summaryCard(p.transactionDataArr),
                  _dateFilter(p),
                  const SizedBox(height: 16),
                  if (p.isLoading)
                    ...List.generate(5, (_) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: PremiumShimmer.card(height: 88),
                    ))
                  else if (p.transactionDataArr.isEmpty)
                    _empty()
                  else ...[
                    Text('${p.transactionDataArr.length} transactions',
                        style: const TextStyle(fontSize: 12, color: AppTheme.textMuted,
                            fontWeight: FontWeight.w500)),
                    const SizedBox(height: 10),
                    ...p.transactionDataArr.map(_txCard),
                  ],
                  const SizedBox(height: 40),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard(List<TransactionData> list) {
    final pts = list.fold<int>(0, (s, t) =>
        s + (int.tryParse(t.points?.toString() ?? '0') ?? 0));
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: AppTheme.black2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.black5),
      ),
      child: Row(children: [
        _sum('Scans', '${list.length}', AppTheme.white),
        _div(),
        _sum('Total PTS', '$pts', AppTheme.orange),
      ]),
    );
  }

  Widget _sum(String l, String v, Color c) => Expanded(child: Column(children: [
    Text(v, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: c)),
    const SizedBox(height: 3),
    Text(l, style: TextStyle(fontSize: 10, color: AppTheme.white.withOpacity(0.3))),
  ]));

  Widget _div() => Container(width: 1, height: 32, color: AppTheme.black5.withOpacity(0.6));

  Widget _dateFilter(UserProvider p) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppTheme.black2, borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppTheme.black5)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(Icons.filter_list_rounded, size: 15, color: AppTheme.white.withOpacity(0.35)),
        const SizedBox(width: 6),
        Text('Filter by Date',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.white)),
        const Spacer(),
        if (_startDate.isNotEmpty || _endDate.isNotEmpty)
          GestureDetector(
            onTap: () {
              setState(() { _startDate = ''; _endDate = ''; _startCtrl.clear(); _endCtrl.clear(); });
              _fetch(p);
            },
            child: const Text('Clear',
                style: TextStyle(fontSize: 12, color: AppTheme.orange, fontWeight: FontWeight.w600)),
          ),
      ]),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: _datePicker('Start', _startCtrl, () => _pickStart(p))),
        const SizedBox(width: 10),
        Expanded(child: _datePicker('End', _endCtrl, () => _pickEnd(p))),
      ]),
    ]),
  );

  Widget _datePicker(String label, TextEditingController ctrl, VoidCallback onTap) =>
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(fontSize: 10, color: AppTheme.white.withOpacity(0.3), fontWeight: FontWeight.w500)),
      const SizedBox(height: 5),
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppTheme.black3, borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.black5)),
          child: Row(children: [
            Expanded(child: Text(ctrl.text.isEmpty ? 'Select' : ctrl.text,
                style: TextStyle(fontSize: 13,
                    color: ctrl.text.isEmpty ? AppTheme.white.withOpacity(0.25) : AppTheme.white,
                    fontWeight: FontWeight.w500))),
            Icon(Icons.calendar_today_outlined, size: 13, color: AppTheme.white.withOpacity(0.3)),
          ]),
        ),
      ),
    ]);

  Widget _txCard(TransactionData tx) {
    final isCredit = tx.type == 'credit';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.black2, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.black5)),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: AppTheme.black4,
            borderRadius: BorderRadius.circular(10)),
          child: Icon(Icons.qr_code_rounded, color: AppTheme.white.withOpacity(0.4), size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(tx.productName ?? 'QR Redeem',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.white)),
          const SizedBox(height: 2),
          Text(tx.transactionId ?? '',
              style: TextStyle(fontSize: 12, color: AppTheme.white.withOpacity(0.35)),
              maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text('${lastTransactionDate(tx.createdAt)}  ·  ${getFormattedTime(tx.createdAt)}',
              style: TextStyle(fontSize: 11, color: AppTheme.white.withOpacity(0.25))),
        ])),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(isCredit ? '+${tx.points}' : '-${tx.points}',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                  color: isCredit ? AppTheme.white : AppTheme.white.withOpacity(0.4))),
          const SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppTheme.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppTheme.orange.withOpacity(0.2))),
            child: const Text('Success',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.orange)),
          ),
        ]),
      ]),
    );
  }

  Widget _empty() => Container(
    padding: const EdgeInsets.symmetric(vertical: 48),
    child: Column(children: [
      Container(
        width: 64, height: 64,
        decoration: BoxDecoration(
          color: AppTheme.black3,
          borderRadius: BorderRadius.circular(16)),
        child: Icon(Icons.qr_code_scanner_rounded, size: 28, color: AppTheme.white.withOpacity(0.2)),
      ),
      const SizedBox(height: 14),
      const Text('No QR Transactions',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.white)),
      const SizedBox(height: 6),
      Text('Scan a QR code to earn points',
          style: TextStyle(fontSize: 13, color: AppTheme.white.withOpacity(0.3))),
    ]),
  );

  Future<void> _pickStart(UserProvider p) async {
    final d = await showDatePicker(
      context: context, initialDate: _lastStart,
      firstDate: DateTime(2020), lastDate: DateTime.now());
    if (d != null) {
      _lastStart = d;
      _startDate = DateFormat('yyyy-MM-dd').format(d);
      _startCtrl.text = DateFormat('dd/MM/yyyy').format(d);
      _fetch(p);
    }
  }

  Future<void> _pickEnd(UserProvider p) async {
    final d = await showDatePicker(
      context: context, initialDate: _lastEnd,
      firstDate: DateTime(2020), lastDate: DateTime.now());
    if (d != null) {
      _lastEnd = d;
      _endDate = DateFormat('yyyy-MM-dd').format(d);
      _endCtrl.text = DateFormat('dd/MM/yyyy').format(d);
      _fetch(p);
    }
  }

  void _fetch(UserProvider p) {
    check().then((ok) async {
      if (ok) {
        p.transactionDataArr = [];
        await p.fetchProductTransactionList(context, _token, _startDate, _endDate);
      } else {
        showWarningToast('No network connection');
      }
    });
  }
}
