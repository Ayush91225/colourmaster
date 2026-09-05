import 'package:colourmaster/provider/user_provider.dart';
import 'package:colourmaster/ui/redeem_request_screen.dart';
import 'package:colourmaster/utils/premium_theme.dart';
import 'package:colourmaster/utils/sharedPreferenceKey.dart';
import 'package:colourmaster/utils/utilsMethods.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ui/gift_screen.dart';
import 'ui/premium_home_screen.dart';
import 'ui/qr_screen_screen.dart';
import 'ui/redeem_screen.dart';
import 'ui/widget/side_bar.dart';

class MainScreen extends StatefulWidget {
  final int? _selectedIndex;
  final String qrResult;
  const MainScreen(this._selectedIndex, this.qrResult, {super.key});
  @override
  State<MainScreen> createState() => _State();
}

class _State extends State<MainScreen> {
  int _index = 0;
  final _key = GlobalKey<ScaffoldState>();

  static List<Widget> _buildScreens(VoidCallback onMenuTap) => [
    PremiumHomeScreen(onMenuTap: onMenuTap),
    GiftScreen(onMenuTap: onMenuTap),
    const QRScreen(),
    const RedeemScreen(),
    const RedeemRequestScreen(),
  ];

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    if (widget._selectedIndex != null) _index = widget._selectedIndex!;
    _screens = _buildScreens(() => _key.currentState?.openDrawer());
    if (widget.qrResult.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _qrRedeem(widget.qrResult));
    }
  }

  Future<void> _qrRedeem(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(TOKEN) ?? '';
    if (!mounted) return;
    if (await check()) {
      await Provider.of<UserProvider>(context, listen: false)
          .redeemQRCode(context, token, id);
    } else {
      showWarningToast('No network connection');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return WillPopScope(
      onWillPop: () async {
        if (_index != 0) { setState(() => _index = 0); return false; }
        _key.currentState?.closeDrawer();
        final exit = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            title: const Text('Exit App',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            content: const Text('Are you sure you want to exit?',
                style: TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary))),
              TextButton(onPressed: () => Navigator.pop(context, true),
                  child: const Text('Exit',
                      style: TextStyle(color: AppTheme.accent, fontWeight: FontWeight.w700))),
            ],
          ),
        );
        return exit == true;
      },
      child: Scaffold(
        key: _key,
        backgroundColor: AppTheme.black,
        drawer: sideBar(context),
        body: _screens[_index],
        bottomNavigationBar: _BottomBar(
          index: _index,
          onTap: (i) => setState(() => _index = i),
          bottomPadding: bottom,
        ),
      ),
    );
  }
}

// ── Bottom bar ─────────────────────────────────────────────────────────────────
class _BottomBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;
  final double bottomPadding;
  const _BottomBar(
      {required this.index,
      required this.onTap,
      required this.bottomPadding});

  static const _items = [
    (Icons.home_rounded,                   Icons.home_outlined,                   'Home'),
    (Icons.card_giftcard_rounded,          Icons.card_giftcard_outlined,          'Gifts'),
    (Icons.qr_code_scanner_rounded,        Icons.qr_code_scanner_rounded,         'Scan'),
    (Icons.receipt_long_rounded,           Icons.receipt_long_outlined,           'History'),
    (Icons.account_balance_wallet_rounded, Icons.account_balance_wallet_outlined, 'Cash'),
  ];

  @override
  Widget build(BuildContext context) {
    final barH = 64.0 + bottomPadding;
    return Container(
      height: barH,
      decoration: BoxDecoration(
        color: AppTheme.black,
        border: Border(
            top: BorderSide(
                color: AppTheme.white.withOpacity(0.06), width: 1)),
      ),
      child: Row(
        children: List.generate(_items.length, (i) {
          // Centre slot — QR scan button
          if (i == 2) {
            return Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onTap(2),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppTheme.orange,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.orange.withOpacity(0.35),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: const Icon(Icons.qr_code_scanner_rounded,
                          color: AppTheme.black, size: 22),
                    ),
                  ],
                ),
              ),
            );
          }

          final active = index == i;
          final item = _items[i];
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onTap(i),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Active indicator pill
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: active ? 20 : 0,
                    height: 3,
                    margin: const EdgeInsets.only(bottom: 5),
                    decoration: BoxDecoration(
                      color: AppTheme.orange,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Icon(
                    active ? item.$1 : item.$2,
                    size: 22,
                    color: active
                        ? AppTheme.orange
                        : AppTheme.white.withOpacity(0.28),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.$3,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: active
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: active
                          ? AppTheme.orange
                          : AppTheme.white.withOpacity(0.28),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
