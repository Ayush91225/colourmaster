import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../provider/user_provider.dart';
import '../utils/sharedPreferenceKey.dart';
import '../utils/premium_theme.dart';
import '../utils/utilsMethods.dart';
import 'widget/premium_shimmer.dart';
import 'widget/app_header.dart';

class RedeemRequestScreen extends StatefulWidget {
  const RedeemRequestScreen({super.key});
  @override
  State<RedeemRequestScreen> createState() => _State();
}

class _State extends State<RedeemRequestScreen> {
  final _pointCtrl = TextEditingController();
  final _formKey   = GlobalKey<FormState>();
  String _token = '', _mode = 'Account';
  int _available = 0;
  final _modes = ['UPI', 'Account', 'Cash'];

  @override
  void initState() {
    super.initState();
    _pointCtrl.addListener(_onPointsChanged);
    _init();
  }

  void _onPointsChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(TOKEN) ?? '';
    final p = Provider.of<UserProvider>(context, listen: false);
    if (await check()) {
      await p.fetchDashboard(context, _token);
      setState(() {
        _available = double.tryParse(
            p.dashboardData?.data?.user?.balance?.toString() ?? '0')?.toInt() ?? 0;
      });
    } else {
      showWarningToast('No network connection');
    }
  }

  @override
  void dispose() {
    _pointCtrl.removeListener(_onPointsChanged);
    _pointCtrl.dispose();
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
            appHeader(context: context, title: 'Cash Redeem'),
            if (p.isLoading)
              SliverPadding(
                padding: EdgeInsets.all(16 * s),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    PremiumShimmer.card(height: 100 * s),
                    SizedBox(height: 12 * s),
                    PremiumShimmer.card(height: 60 * s),
                    SizedBox(height: 12 * s),
                    PremiumShimmer.card(height: 130 * s),
                    SizedBox(height: 12 * s),
                    PremiumShimmer.card(height: 130 * s),
                  ]),
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(16 * s, 16 * s, 16 * s, 40 * s),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _balanceCard(p, s),
                    SizedBox(height: 10 * s),
                    _rateCard(s),
                    SizedBox(height: 20 * s),
                    Form(
                      key: _formKey,
                      child: Column(children: [
                        _modeSelector(s),
                        SizedBox(height: 12 * s),
                        _pointsInput(s),
                        SizedBox(height: 24 * s),
                        _submitButton(p, s),
                        SizedBox(height: 40 * s),
                      ]),
                    ),
                  ]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _balanceCard(UserProvider p, double s) {
    if (p.dashboardData == null) return const SizedBox();
    return Container(
      padding: EdgeInsets.all(20 * s),
      decoration: BoxDecoration(
        color: AppTheme.black2,
        borderRadius: BorderRadius.circular(20 * s),
        border: Border.all(color: AppTheme.orange.withOpacity(0.2)),
      ),
      child: Row(children: [
        Container(
          width: 48 * s, height: 48 * s,
          decoration: BoxDecoration(
            color: AppTheme.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14 * s),
          ),
          child: Icon(Icons.account_balance_wallet_outlined, color: AppTheme.orange, size: 22 * s),
        ),
        SizedBox(width: 16 * s),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Available Balance',
              style: TextStyle(fontSize: 11 * s, color: AppTheme.white30)),
          SizedBox(height: 4 * s),
          Text('${p.dashboardData!.data!.user!.balance} PTS',
              style: TextStyle(fontSize: 26 * s, fontWeight: FontWeight.w800, color: AppTheme.white)),
        ]),
      ]),
    );
  }

  Widget _rateCard(double s) => Container(
    padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 14 * s),
    decoration: BoxDecoration(
      color: AppTheme.black2,
      borderRadius: BorderRadius.circular(16 * s),
      border: Border.all(color: AppTheme.black5),
    ),
    child: Row(children: [
      Icon(Icons.currency_exchange_rounded, color: AppTheme.white30, size: 16 * s),
      SizedBox(width: 10 * s),
      Text('Conversion Rate', style: TextStyle(fontSize: 13 * s, color: AppTheme.white60)),
      const Spacer(),
      Text('1 PTS = ₹1.00',
          style: TextStyle(fontSize: 14 * s, fontWeight: FontWeight.w700, color: AppTheme.white)),
    ]),
  );

  Widget _modeSelector(double s) => Container(
    padding: EdgeInsets.all(16 * s),
    decoration: BoxDecoration(
      color: AppTheme.black2,
      borderRadius: BorderRadius.circular(20 * s),
      border: Border.all(color: AppTheme.black5),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Redeem Mode',
          style: TextStyle(fontSize: 12 * s, fontWeight: FontWeight.w600,
              color: AppTheme.white30, letterSpacing: 0.5)),
      SizedBox(height: 12 * s),
      Row(children: _modes.map((m) {
        final sel = m == _mode;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _mode = m),
            child: Container(
              margin: EdgeInsets.only(right: m != _modes.last ? 8 * s : 0),
              padding: EdgeInsets.symmetric(vertical: 14 * s),
              decoration: BoxDecoration(
                color: sel ? AppTheme.orange.withOpacity(0.08) : AppTheme.black3,
                borderRadius: BorderRadius.circular(14 * s),
                border: Border.all(
                    color: sel ? AppTheme.orange.withOpacity(0.4) : AppTheme.black5),
              ),
              child: Column(children: [
                Icon(_modeIcon(m), size: 20 * s,
                    color: sel ? AppTheme.orange : AppTheme.white30),
                SizedBox(height: 6 * s),
                Text(m, style: TextStyle(fontSize: 12 * s, fontWeight: FontWeight.w600,
                    color: sel ? AppTheme.orange : AppTheme.white30)),
              ]),
            ),
          ),
        );
      }).toList()),
    ]),
  );

  Widget _pointsInput(double s) => Container(
    padding: EdgeInsets.all(16 * s),
    decoration: BoxDecoration(
      color: AppTheme.black2,
      borderRadius: BorderRadius.circular(20 * s),
      border: Border.all(color: AppTheme.black5),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Points to Redeem',
          style: TextStyle(fontSize: 12 * s, fontWeight: FontWeight.w600,
              color: AppTheme.white30, letterSpacing: 0.5)),
      SizedBox(height: 10 * s),
      TextFormField(
        controller: _pointCtrl,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: TextStyle(fontSize: 15 * s, color: AppTheme.white),
        decoration: InputDecoration(
          hintText: 'Enter points',
          prefixIcon: Icon(Icons.toll_rounded, size: 18 * s, color: AppTheme.white30),
          suffixText: 'PTS',
          suffixStyle: TextStyle(fontSize: 13 * s, fontWeight: FontWeight.w600, color: AppTheme.white30),
        ),
        validator: (v) {
          if (v == null || v.isEmpty) return 'Points required';
          if (_available < int.parse(v)) return 'Insufficient points (max $_available)';
          return null;
        },
      ),
      if (_pointCtrl.text.isNotEmpty) ...[
        SizedBox(height: 12 * s),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: 10 * s),
          decoration: BoxDecoration(
            color: AppTheme.orange.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12 * s),
            border: Border.all(color: AppTheme.orange.withOpacity(0.2)),
          ),
          child: Row(children: [
            Icon(Icons.info_outline_rounded, color: AppTheme.orange, size: 14 * s),
            SizedBox(width: 8 * s),
            Text('You will receive: ₹${_pointCtrl.text}',
                style: TextStyle(fontSize: 13 * s, fontWeight: FontWeight.w600, color: AppTheme.orange)),
          ]),
        ),
      ],
    ]),
  );

  Widget _submitButton(UserProvider p, double s) => GestureDetector(
    onTap: () => _submit(p),
    child: Container(
      width: double.infinity,
      height: 52 * s,
      decoration: BoxDecoration(
        color: AppTheme.orange,
        borderRadius: BorderRadius.circular(16 * s),
      ),
      alignment: Alignment.center,
      child: Text('Submit Redeem Request',
          style: TextStyle(fontSize: 15 * s, fontWeight: FontWeight.w700, color: Colors.white)),
    ),
  );

  IconData _modeIcon(String m) {
    switch (m) {
      case 'UPI': return Icons.qr_code_rounded;
      case 'Account': return Icons.account_balance_rounded;
      default: return Icons.money_rounded;
    }
  }

  void _submit(UserProvider p) {
    if (_formKey.currentState!.validate()) {
      check().then((ok) async {
        if (ok) {
          FocusManager.instance.primaryFocus?.unfocus();
          await p.redemptionRequest(context, _mode, _token, _pointCtrl.text.trim(), '');
        } else {
          showWarningToast('No network connection');
        }
      });
    }
  }
}
