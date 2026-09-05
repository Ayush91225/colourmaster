import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:colourmaster/ui/cash_redeem_history_screen.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../main_screen.dart';
import '../../utils/constants.dart';
import '../../utils/premium_theme.dart';
import '../../utils/sharedPreferenceKey.dart';
import '../../utils/utilsMethods.dart';
import '../product_qr_redeem_history_screen.dart';
import '../product_redeem_points_screen.dart';
import '../profile_screen.dart';

Widget sideBar(BuildContext context) {
  final sw = MediaQuery.of(context).size.width;
  return Drawer(
    backgroundColor: AppTheme.black,
    width: sw * 0.78,
    child: const _SideBarContent(),
  );
}

class _SideBarContent extends StatefulWidget {
  const _SideBarContent();
  @override
  State<_SideBarContent> createState() => _SideBarContentState();
}

class _SideBarContentState extends State<_SideBarContent> {
  String _name = '', _phone = '', _photo = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      _name  = p.getString(FULLNAME) ?? 'User';
      _phone = p.getString(USERMOBILE) ?? '';
      _photo = p.getString(USERPHOTO) ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final s = (sw / 390).clamp(0.8, 1.3);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _profile(context, s),
        Expanded(
          child: ListView(
            padding: EdgeInsets.only(top: 8 * s, bottom: 24 * s),
            children: [
              _section('NAVIGATE', s),
              _item(context, Icons.home_outlined, 'Home', s,
                  () => Navigator.pushReplacement(context,
                      MaterialPageRoute(
                          builder: (_) => const MainScreen(0, '')))),
              _item(context, Icons.person_outline_rounded, 'Profile', s,
                  () => Navigator.push(context,
                      MaterialPageRoute(
                          builder: (_) => const ProfileScreen()))),
              SizedBox(height: 4 * s),
              _section('REWARDS', s),
              _item(context, Icons.account_balance_outlined, 'Cash Redeem', s,
                  () => Navigator.push(context,
                      MaterialPageRoute(
                          builder: (_) => const MainScreen(4, '')))),
              _item(context, Icons.history_outlined, 'Cash History', s,
                  () => Navigator.push(context,
                      MaterialPageRoute(
                          builder: (_) => const CashRedeemHistoryScreen()))),
              _item(context, Icons.inventory_2_outlined, 'Product Points', s,
                  () => Navigator.push(context,
                      MaterialPageRoute(
                          builder: (_) => const ProductRedeemPointScreen()))),
              _item(context, Icons.qr_code_outlined, 'Product QR History', s,
                  () => Navigator.push(context,
                      MaterialPageRoute(
                          builder: (_) => const ProductQRRedeemHistoryScreen()))),
              _item(context, Icons.card_giftcard_outlined, 'Gift Redeem', s,
                  () => Navigator.push(context,
                      MaterialPageRoute(
                          builder: (_) => const MainScreen(1, '')))),
              _item(context, Icons.receipt_long_outlined, 'Redeem History', s,
                  () => Navigator.push(context,
                      MaterialPageRoute(
                          builder: (_) => const MainScreen(3, '')))),
              SizedBox(height: 4 * s),
              _section('MORE', s),
              _item(context, Icons.description_outlined, 'Terms & Conditions', s,
                  () => redirectToBrowser(Uri.parse(termConditionURL))),
              _item(context, Icons.share_outlined, 'Share App', s,
                  () => Share.share(
                      'Color Master App android: $androidMarketAppUrl\n\nColor Master App iOS: $iOsMarketAppUrl')),
              _item(context, Icons.star_outline_rounded, 'Rate App', s,
                  () => redirectToBrowser(Uri.parse(
                      Platform.isIOS ? iOsMarketAppUrl : androidMarketAppUrl))),
              _item(context, Icons.support_agent_outlined, 'Contact Us', s,
                  () => openEmail(contactUSEmailAddress)),
              SizedBox(height: 4 * s),
              _divider(s),
              _item(context, Icons.logout_rounded, 'Log out', s,
                  () => logOutDialog(context),
                  destructive: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _profile(BuildContext context, double s) {
    final avatarSize = 56 * s;
    return Container(
      color: AppTheme.black,
      padding: EdgeInsets.fromLTRB(
          20 * s, MediaQuery.of(context).padding.top + 24 * s, 20 * s, 20 * s),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        GestureDetector(
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const ProfileScreen())),
          child: Container(
            width: avatarSize, height: avatarSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.black3,
              border: Border.all(
                  color: AppTheme.orange.withOpacity(0.4), width: 2),
            ),
            child: ClipOval(
              child: _photo.isNotEmpty && _photo != 'null'
                  ? CachedNetworkImage(
                      imageUrl: _photo,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => _avatarFallback(s))
                  : _avatarFallback(s),
            ),
          ),
        ),
        SizedBox(height: 12 * s),
        Text(_name,
            style: TextStyle(
                fontSize: 17 * s,
                fontWeight: FontWeight.w700,
                color: AppTheme.white),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
        SizedBox(height: 2 * s),
        Text(_phone.isNotEmpty ? '+91 $_phone' : 'Colour Master Member',
            style: TextStyle(
                fontSize: 13 * s,
                color: AppTheme.white.withOpacity(0.35),
                fontWeight: FontWeight.w400),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
        SizedBox(height: 16 * s),
        Container(height: 1, color: AppTheme.black5.withOpacity(0.6)),
      ]),
    );
  }

  Widget _avatarFallback(double s) =>
      Icon(Icons.person_rounded, color: AppTheme.white30, size: 28 * s);
}

Widget _section(String label, double s) {
  return Padding(
    padding: EdgeInsets.fromLTRB(20 * s, 12 * s, 20 * s, 4 * s),
    child: Text(label,
        style: TextStyle(
            fontSize: 10 * s,
            fontWeight: FontWeight.w700,
            color: AppTheme.white.withOpacity(0.2),
            letterSpacing: 1.2)),
  );
}

Widget _divider(double s) {
  return Container(
    height: 1,
    margin: EdgeInsets.symmetric(horizontal: 20 * s, vertical: 4 * s),
    color: AppTheme.black5.withOpacity(0.5),
  );
}

Widget _item(
  BuildContext ctx,
  IconData icon,
  String title,
  double s,
  VoidCallback onTap, {
  bool destructive = false,
}) {
  final textColor = destructive ? AppTheme.red : AppTheme.white;
  final iconColor = destructive
      ? AppTheme.red.withOpacity(0.8)
      : AppTheme.white.withOpacity(0.45);

  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      splashColor: AppTheme.orange.withOpacity(0.04),
      highlightColor: AppTheme.orange.withOpacity(0.03),
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: 20 * s, vertical: 12 * s),
        child: Row(children: [
          Icon(icon, size: 19 * s, color: iconColor),
          SizedBox(width: 16 * s),
          Expanded(
            child: Text(title,
                style: TextStyle(
                    fontSize: 15 * s,
                    fontWeight: FontWeight.w500,
                    color: textColor),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ),
        ]),
      ),
    ),
  );
}
