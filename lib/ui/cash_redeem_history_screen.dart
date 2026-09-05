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

class CashRedeemHistoryScreen extends StatefulWidget {
  const CashRedeemHistoryScreen({super.key});
  @override
  State<CashRedeemHistoryScreen> createState() => _State();
}

class _State extends State<CashRedeemHistoryScreen> {
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
      await p.fetchCashTransactionList(context, _token, '', '');
    } else {
      showWarningToast('No network connection');
    }
  }

  @override
  void dispose() {
    _startCtrl.dispose();
    _endCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final s = (sw / 390).clamp(0.8, 1.3);

    return Scaffold(
      backgroundColor: AppTheme.black,
      body: Consumer<UserProvider>(
        builder: (_, p, __) => CustomScrollView(
          slivers: [
            appHeader(context: context, title: 'Cash History'),

            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                  16 * s, 16 * s, 16 * s, 0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  if (!p.isLoading && p.transactionDataArr.isNotEmpty)
                    _summaryCard(p.transactionDataArr, s),
                  _dateFilter(p, s),
                  SizedBox(height: 16 * s),
                  if (p.isLoading)
                    ...List.generate(5, (_) => Padding(
                      padding: EdgeInsets.only(bottom: 10 * s),
                      child: PremiumShimmer.card(height: 88 * s),
                    ))
                  else if (p.transactionDataArr.isEmpty)
                    _empty(s)
                  else ...[
                    Text('${p.transactionDataArr.length} transactions',
                        style: TextStyle(
                            fontSize: 12 * s,
                            color: AppTheme.white.withOpacity(0.3),
                            fontWeight: FontWeight.w500)),
                    SizedBox(height: 10 * s),
                    ...p.transactionDataArr.map((t) => _txCard(t, s)),
                  ],
                  SizedBox(height: 60 * s),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Summary card ──────────────────────────────────────────────────────────────
  Widget _summaryCard(List<TransactionData> list, double s) {
    final approved = list.where((t) =>
        t.status == 'approved' || t.status == 'completed').length;
    final pending  = list.where((t) => t.status == 'pending').length;
    final rejected = list.where((t) => t.status == 'rejected').length;

    return Container(
      margin: EdgeInsets.only(bottom: 12 * s),
      padding: EdgeInsets.symmetric(
          vertical: 16 * s, horizontal: 8 * s),
      decoration: BoxDecoration(
        color: AppTheme.black2,
        borderRadius: BorderRadius.circular(14 * s),
        border: Border.all(color: AppTheme.black5),
      ),
      child: Row(children: [
        _statCol('Total', '${list.length}', AppTheme.white, s),
        _vDivider(),
        _statCol('Approved', '$approved', AppTheme.orange, s),
        _vDivider(),
        _statCol('Pending', '$pending',
            AppTheme.white.withOpacity(0.5), s),
        _vDivider(),
        _statCol('Rejected', '$rejected',
            AppTheme.white.withOpacity(0.3), s),
      ]),
    );
  }

  Widget _statCol(String label, String val, Color color, double s) =>
      Expanded(
        child: Column(children: [
          Text(val,
              style: TextStyle(
                  fontSize: 20 * s,
                  fontWeight: FontWeight.w800,
                  color: color)),
          SizedBox(height: 3 * s),
          Text(label,
              style: TextStyle(
                  fontSize: 10 * s,
                  color: AppTheme.white.withOpacity(0.3))),
        ]),
      );

  Widget _vDivider() => Container(
      width: 1, height: 32,
      color: AppTheme.black5.withOpacity(0.6));

  // ── Date filter ───────────────────────────────────────────────────────────────
  Widget _dateFilter(UserProvider p, double s) => Container(
    padding: EdgeInsets.all(14 * s),
    decoration: BoxDecoration(
      color: AppTheme.black2,
      borderRadius: BorderRadius.circular(12 * s),
      border: Border.all(color: AppTheme.black5),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(Icons.filter_list_rounded,
            size: 15 * s, color: AppTheme.white.withOpacity(0.35)),
        SizedBox(width: 6 * s),
        Text('Filter by Date',
            style: TextStyle(
                fontSize: 13 * s,
                fontWeight: FontWeight.w600,
                color: AppTheme.white)),
        const Spacer(),
        if (_startDate.isNotEmpty || _endDate.isNotEmpty)
          GestureDetector(
            onTap: () {
              setState(() {
                _startDate = ''; _endDate = '';
                _startCtrl.clear(); _endCtrl.clear();
              });
              _fetch(p);
            },
            child: Text('Clear',
                style: TextStyle(
                    fontSize: 12 * s,
                    color: AppTheme.orange,
                    fontWeight: FontWeight.w600)),
          ),
      ]),
      SizedBox(height: 12 * s),
      Row(children: [
        Expanded(child: _datePicker('Start', _startCtrl,
            () => _pickStart(p), s)),
        SizedBox(width: 10 * s),
        Expanded(child: _datePicker('End', _endCtrl,
            () => _pickEnd(p), s)),
      ]),
    ]),
  );

  Widget _datePicker(String label, TextEditingController ctrl,
      VoidCallback onTap, double s) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: TextStyle(
              fontSize: 10 * s,
              color: AppTheme.white.withOpacity(0.3),
              fontWeight: FontWeight.w500)),
      SizedBox(height: 5 * s),
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: 12 * s, vertical: 10 * s),
          decoration: BoxDecoration(
            color: AppTheme.black3,
            borderRadius: BorderRadius.circular(8 * s),
            border: Border.all(color: AppTheme.black5),
          ),
          child: Row(children: [
            Expanded(
              child: Text(
                ctrl.text.isEmpty ? 'Select' : ctrl.text,
                style: TextStyle(
                    fontSize: 13 * s,
                    color: ctrl.text.isEmpty
                        ? AppTheme.white.withOpacity(0.25)
                        : AppTheme.white,
                    fontWeight: FontWeight.w500),
              ),
            ),
            Icon(Icons.calendar_today_outlined,
                size: 13 * s,
                color: AppTheme.white.withOpacity(0.3)),
          ]),
        ),
      ),
    ]);
  }

  // ── Transaction card ──────────────────────────────────────────────────────────
  Widget _txCard(TransactionData tx, double s) {
    final isCredit = tx.type == 'credit';
    final statusColor = _statusColor(tx);
    final statusText  = _statusText(tx);
    final icon        = _statusIcon(tx);

    return Container(
      margin: EdgeInsets.only(bottom: 10 * s),
      padding: EdgeInsets.all(14 * s),
      decoration: BoxDecoration(
        color: AppTheme.black2,
        borderRadius: BorderRadius.circular(12 * s),
        border: Border.all(color: AppTheme.black5),
      ),
      child: Row(children: [
        Container(
          width: 40 * s, height: 40 * s,
          decoration: BoxDecoration(
            color: AppTheme.black4,
            borderRadius: BorderRadius.circular(10 * s),
          ),
          child: Icon(icon,
              color: AppTheme.white.withOpacity(0.4), size: 18 * s),
        ),
        SizedBox(width: 12 * s),
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.transactionId?.toString() ?? '—',
                    style: TextStyle(
                        fontSize: 13 * s,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.white)),
                SizedBox(height: 2 * s),
                Text(tx.remark?.toString() ?? '',
                    style: TextStyle(
                        fontSize: 12 * s,
                        color: AppTheme.white.withOpacity(0.35)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                SizedBox(height: 2 * s),
                Text(
                    '${lastTransactionDate(tx.createdAt)}  ·  ${getFormattedTime(tx.createdAt)}',
                    style: TextStyle(
                        fontSize: 11 * s,
                        color: AppTheme.white.withOpacity(0.25))),
              ]),
        ),
        SizedBox(width: 10 * s),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(
            isCredit ? '+${tx.points}' : '-${tx.points}',
            style: TextStyle(
                fontSize: 15 * s,
                fontWeight: FontWeight.w700,
                color: isCredit
                    ? AppTheme.white
                    : AppTheme.white.withOpacity(0.4)),
          ),
          SizedBox(height: 5 * s),
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: 8 * s, vertical: 3 * s),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4 * s),
              border: Border.all(
                  color: statusColor.withOpacity(0.2)),
            ),
            child: Text(statusText,
                style: TextStyle(
                    fontSize: 10 * s,
                    fontWeight: FontWeight.w700,
                    color: statusColor)),
          ),
        ]),
      ]),
    );
  }

  Widget _empty(double s) => Padding(
    padding: EdgeInsets.symmetric(vertical: 48 * s),
    child: Column(children: [
      Container(
        width: 64 * s, height: 64 * s,
        decoration: BoxDecoration(
          color: AppTheme.black3,
          borderRadius: BorderRadius.circular(16 * s),
        ),
        child: Icon(Icons.receipt_long_outlined,
            size: 28 * s, color: AppTheme.white.withOpacity(0.2)),
      ),
      SizedBox(height: 14 * s),
      Text('No Transactions Found',
          style: TextStyle(
              fontSize: 15 * s,
              fontWeight: FontWeight.w600,
              color: AppTheme.white)),
      SizedBox(height: 6 * s),
      Text('Your cash redeem history will appear here',
          style: TextStyle(
              fontSize: 13 * s,
              color: AppTheme.white.withOpacity(0.3))),
    ]),
  );

  // ── Status helpers ────────────────────────────────────────────────────────────
  Color _statusColor(TransactionData t) {
    switch (t.status) {
      case 'approved': case 'completed': return AppTheme.orange;
      case 'rejected': return AppTheme.white.withOpacity(0.3);
      default: return AppTheme.white.withOpacity(0.5);
    }
  }

  String _statusText(TransactionData t) {
    switch (t.status) {
      case 'approved': return 'Approved';
      case 'rejected': return 'Rejected';
      case 'completed': return 'Completed';
      default: return 'Pending';
    }
  }

  IconData _statusIcon(TransactionData t) {
    switch (t.status) {
      case 'approved': case 'completed':
        return Icons.check_circle_outline_rounded;
      case 'rejected': return Icons.cancel_outlined;
      default: return Icons.schedule_rounded;
    }
  }

  Future<void> _pickStart(UserProvider p) async {
    final d = await showDatePicker(
      context: context,
      initialDate: _lastStart,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (d != null) {
      _lastStart = d;
      _startDate = DateFormat('yyyy-MM-dd').format(d);
      _startCtrl.text = DateFormat('dd/MM/yyyy').format(d);
      _fetch(p);
    }
  }

  Future<void> _pickEnd(UserProvider p) async {
    final d = await showDatePicker(
      context: context,
      initialDate: _lastEnd,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
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
        await p.fetchCashTransactionList(
            context, _token, _startDate, _endDate);
      } else {
        showWarningToast('No network connection');
      }
    });
  }
}
