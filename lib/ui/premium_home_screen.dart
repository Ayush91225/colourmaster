import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:colourmaster/main_screen.dart';
import 'package:colourmaster/ui/product_qr_redeem_history_screen.dart';
import 'package:colourmaster/ui/profile_screen.dart';
import 'package:colourmaster/ui/widget/premium_shimmer.dart';
import 'package:colourmaster/utils/premium_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../provider/user_provider.dart';
import '../utils/constants.dart';
import '../utils/sharedPreferenceKey.dart';
import '../utils/utilsMethods.dart';
import 'cash_redeem_history_screen.dart';
import 'full_screen_image.dart';
import 'product_redeem_points_screen.dart';

class PremiumHomeScreen extends StatefulWidget {
  final VoidCallback? onMenuTap;
  const PremiumHomeScreen({super.key, this.onMenuTap});
  @override
  State<PremiumHomeScreen> createState() => _State();
}

class _State extends State<PremiumHomeScreen> {
  SharedPreferences? _prefs;
  String _token = '', _photo = '', _name = '', _city = '';
  bool _loading = true;
  int _slide = 0;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = _prefs!.getString(TOKEN) ?? '';
      _photo = _prefs!.getString(USERPHOTO) ?? '';
      _name  = _prefs!.getString(FULLNAME) ?? 'User';
      _city  = _prefs!.getString('user_city') ?? 'India';
    });
    final p = Provider.of<UserProvider>(context, listen: false);
    if (await check()) {
      await p.fetchDashboard(context, _token);
    } else {
      showWarningToast('No network connection');
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    // Base design width = 390. Scale everything relative to actual width.
    final sw = MediaQuery.of(context).size.width;
    final s = (sw / 390).clamp(0.8, 1.3);

    return Consumer<UserProvider>(
      builder: (_, provider, __) => Scaffold(
        backgroundColor: AppTheme.black,
        body: RefreshIndicator(
          color: AppTheme.orange,
          backgroundColor: AppTheme.black2,
          onRefresh: () async {
            setState(() => _loading = true);
            await provider.fetchDashboard(context, _token);
            setState(() => _loading = false);
          },
          child: CustomScrollView(
            slivers: [
              _header(provider, s),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _heroPoints(provider, s),
                    _statsRow(provider, s),
                    _lastTx(provider, s),
                    _sliders(provider, s),
                    _quickActions(s),
                    SizedBox(height: 100 * s),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ───────────────────────────────────────────────────────────────────
  Widget _header(UserProvider provider, double s) {
    final avatarSize = 38 * s;
    return SliverAppBar(
      pinned: true,
      floating: false,
      backgroundColor: AppTheme.black,
      elevation: 0,
      toolbarHeight: 60 * s,
      leading: const SizedBox(),
      flexibleSpace: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16 * s),
          child: Row(
            children: [
              // Hamburger
              GestureDetector(
                onTap: widget.onMenuTap,
                child: Container(
                  width: avatarSize, height: avatarSize,
                  decoration: BoxDecoration(
                    color: AppTheme.black3,
                    borderRadius: BorderRadius.circular(9 * s),
                    border: Border.all(color: AppTheme.black5),
                  ),
                  child: Icon(Icons.menu_rounded,
                      size: 18 * s, color: AppTheme.white),
                ),
              ),
              SizedBox(width: 12 * s),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Good ${_timeGreeting()}',
                        style: TextStyle(
                            fontSize: 11 * s,
                            color: AppTheme.white.withOpacity(0.35),
                            fontWeight: FontWeight.w400)),
                    Text(_name,
                        style: TextStyle(
                            fontSize: 15 * s,
                            color: AppTheme.white,
                            fontWeight: FontWeight.w700),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              // Avatar
              GestureDetector(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen())),
                child: Container(
                  width: avatarSize, height: avatarSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.black3,
                    border: Border.all(
                        color: AppTheme.orange.withOpacity(0.5), width: 1.5),
                  ),
                  child: ClipOval(
                    child: _photo.isNotEmpty && _photo != 'null'
                        ? CachedNetworkImage(
                            imageUrl: _photo,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => _avatarIcon(s))
                        : _avatarIcon(s),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
            height: 1, color: AppTheme.black5.withOpacity(0.5)),
      ),
    );
  }

  String _timeGreeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'morning';
    if (h < 17) return 'afternoon';
    return 'evening';
  }

  Widget _avatarIcon(double s) =>
      Icon(Icons.person_rounded, color: AppTheme.white30, size: 20 * s);

  // ── Hero points card ──────────────────────────────────────────────────────────
  Widget _heroPoints(UserProvider p, double s) {
    final pad = 16 * s;
    if (_loading) {
      return Padding(
        padding: EdgeInsets.fromLTRB(pad, 20 * s, pad, 0),
        child: PremiumShimmer.card(height: 130 * s),
      );
    }
    final d = p.dashboardData?.data;
    final balance = d?.user?.balance ?? 0;
    final lifetime = d?.lifeTimBalance ?? 0;

    return Padding(
      padding: EdgeInsets.fromLTRB(pad, 20 * s, pad, 0),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20 * s),
        decoration: BoxDecoration(
          color: AppTheme.black2,
          borderRadius: BorderRadius.circular(16 * s),
          border: Border.all(color: AppTheme.black5),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: 8 * s, vertical: 4 * s),
              decoration: BoxDecoration(
                color: AppTheme.orange.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6 * s),
                border: Border.all(
                    color: AppTheme.orange.withOpacity(0.25)),
              ),
              child: Text('AVAILABLE POINTS',
                  style: TextStyle(
                      fontSize: 10 * s,
                      color: AppTheme.orange,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8)),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(
                      builder: (_) => const MainScreen(4, ''))),
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 12 * s, vertical: 6 * s),
                decoration: BoxDecoration(
                  color: AppTheme.orange,
                  borderRadius: BorderRadius.circular(8 * s),
                ),
                child: Text('Redeem',
                    style: TextStyle(
                        fontSize: 12 * s,
                        color: AppTheme.black,
                        fontWeight: FontWeight.w700)),
              ),
            ),
          ]),
          SizedBox(height: 14 * s),
          Text('$balance',
              style: TextStyle(
                  fontSize: (42 * s).clamp(32, 52),
                  fontWeight: FontWeight.w800,
                  color: AppTheme.white,
                  height: 1.0)),
          SizedBox(height: 4 * s),
          Text('$lifetime pts earned lifetime',
              style: TextStyle(
                  fontSize: 12 * s,
                  color: AppTheme.white.withOpacity(0.35),
                  fontWeight: FontWeight.w400)),
        ]),
      ),
    );
  }

  // ── Stats row ─────────────────────────────────────────────────────────────────
  Widget _statsRow(UserProvider p, double s) {
    final pad = 16 * s;
    if (_loading) {
      return Padding(
        padding: EdgeInsets.fromLTRB(pad, 12 * s, pad, 0),
        child: Row(children: [
          Expanded(child: PremiumShimmer.card(height: 72 * s)),
          SizedBox(width: 10 * s),
          Expanded(child: PremiumShimmer.card(height: 72 * s)),
        ]),
      );
    }
    final d = p.dashboardData?.data;
    if (d == null) return const SizedBox();

    return Padding(
      padding: EdgeInsets.fromLTRB(pad, 12 * s, pad, 0),
      child: Row(children: [
        Expanded(child: _miniStat(
            'Gift Balance', '${d.giftBalance ?? 0}',
            Icons.card_giftcard_outlined, s)),
        SizedBox(width: 10 * s),
        Expanded(child: _miniStat(
            'Gift Lifetime', '${d.giftLifetimeBalance ?? 0}',
            Icons.star_outline_rounded, s)),
      ]),
    );
  }

  Widget _miniStat(String label, String value, IconData icon, double s) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: 14 * s, vertical: 12 * s),
      decoration: BoxDecoration(
        color: AppTheme.black2,
        borderRadius: BorderRadius.circular(12 * s),
        border: Border.all(color: AppTheme.black5),
      ),
      child: Row(children: [
        Container(
          width: 32 * s, height: 32 * s,
          decoration: BoxDecoration(
            color: AppTheme.black4,
            borderRadius: BorderRadius.circular(8 * s),
          ),
          child: Icon(icon,
              color: AppTheme.white.withOpacity(0.45), size: 15 * s),
        ),
        SizedBox(width: 10 * s),
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: TextStyle(
                        fontSize: 16 * s,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.white)),
                Text(label,
                    style: TextStyle(
                        fontSize: 10 * s,
                        color: AppTheme.white.withOpacity(0.35),
                        fontWeight: FontWeight.w400)),
              ]),
        ),
      ]),
    );
  }

  // ── Last transaction ──────────────────────────────────────────────────────────
  Widget _lastTx(UserProvider p, double s) {
    final tx = p.dashboardData?.data?.lastTransaction;
    if (_loading || tx == null) return const SizedBox();
    final pad = 16 * s;
    return Padding(
      padding: EdgeInsets.fromLTRB(pad, 12 * s, pad, 0),
      child: GestureDetector(
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const MainScreen(4, ''))),
        child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: 14 * s, vertical: 12 * s),
          decoration: BoxDecoration(
            color: AppTheme.black2,
            borderRadius: BorderRadius.circular(12 * s),
            border: Border.all(color: AppTheme.black5),
          ),
          child: Row(children: [
            Container(
              width: 34 * s, height: 34 * s,
              decoration: BoxDecoration(
                color: AppTheme.black4,
                borderRadius: BorderRadius.circular(8 * s),
              ),
              child: Icon(Icons.history_rounded,
                  color: AppTheme.white.withOpacity(0.45), size: 16 * s),
            ),
            SizedBox(width: 12 * s),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Last Redeem',
                        style: TextStyle(
                            fontSize: 10 * s,
                            color: AppTheme.white.withOpacity(0.35))),
                    SizedBox(height: 2 * s),
                    Text(
                        '${tx.points} PTS  ·  ${lastTransactionDateOnHome(tx.createdAt)}',
                        style: TextStyle(
                            fontSize: 13 * s,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.white)),
                  ]),
            ),
            Icon(Icons.chevron_right_rounded,
                size: 18 * s, color: AppTheme.white30),
          ]),
        ),
      ),
    );
  }

  // ── Sliders ───────────────────────────────────────────────────────────────────
  Widget _sliders(UserProvider p, double s) {
    final pad = 16 * s;
    final sliderH = (MediaQuery.of(context).size.width - pad * 2) * 0.42;

    if (_loading) {
      return Padding(
        padding: EdgeInsets.fromLTRB(pad, 20 * s, pad, 0),
        child: PremiumShimmer.card(height: sliderH),
      );
    }
    final sliders = p.dashboardData?.data?.sliders;
    if (sliders == null || sliders.isEmpty) return const SizedBox();

    return Padding(
      padding: EdgeInsets.fromLTRB(0, 20 * s, 0, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: EdgeInsets.fromLTRB(pad, 0, pad, 10 * s),
          child: Text('Featured',
              style: TextStyle(
                  fontSize: 12 * s,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.white.withOpacity(0.4),
                  letterSpacing: 0.5)),
        ),
        CarouselSlider.builder(
          itemCount: sliders.length,
          itemBuilder: (_, i, __) => GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => FullScreenImage(
                    imageUrl: sliders[i].image!,
                    title: ''))),
            child: Padding(
            padding: EdgeInsets.symmetric(horizontal: pad),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14 * s),
              child: CachedNetworkImage(
                imageUrl: sliders[i].image!,
                fit: BoxFit.cover,
                width: double.infinity,
                placeholder: (_, __) =>
                    PremiumShimmer.card(height: sliderH),
                errorWidget: (_, __, ___) => Container(
                  color: AppTheme.black3,
                  child: Icon(Icons.image_not_supported_outlined,
                      color: AppTheme.white30, size: 28 * s),
                ),
              ),
            ),
          ),
          ),
          options: CarouselOptions(
            height: sliderH,
            viewportFraction: 1.0,
            autoPlay: sliders.length > 1,
            enableInfiniteScroll: sliders.length > 1,
            onPageChanged: (i, _) => setState(() => _slide = i),
          ),
        ),
        if (sliders.length > 1) ...[
          SizedBox(height: 10 * s),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(sliders.length, (i) {
              final active = i == _slide;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: active ? 16 * s : 4 * s,
                height: 4 * s,
                margin: EdgeInsets.symmetric(horizontal: 2 * s),
                decoration: BoxDecoration(
                  color: active ? AppTheme.orange : AppTheme.black5,
                  borderRadius: BorderRadius.circular(2 * s),
                ),
              );
            }),
          ),
        ],
      ]),
    );
  }

  // ── Quick actions ─────────────────────────────────────────────────────────────
  Widget _quickActions(double s) {
    final pad = 16 * s;
    final items = [
      _QA('Product\nHistory', Icons.inventory_2_outlined,
          () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => const ProductQRRedeemHistoryScreen()))),
      _QA('Cash\nRedeem', Icons.account_balance_outlined,
          () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => const CashRedeemHistoryScreen()))),
      _QA('Coupons', Icons.local_offer_outlined,
          () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => const ProductRedeemPointScreen()))),
      _QA('Support', Icons.support_agent_outlined,
          () => openEmail(contactUSEmailAddress)),
    ];

    return Padding(
      padding: EdgeInsets.fromLTRB(0, 20 * s, 0, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: EdgeInsets.fromLTRB(pad, 0, pad, 12 * s),
          child: Text('Quick Actions',
              style: TextStyle(
                  fontSize: 12 * s,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.white.withOpacity(0.4),
                  letterSpacing: 0.5)),
        ),
        Row(
          children: items.map((a) => Expanded(
            child: GestureDetector(
              onTap: a.onTap,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 6 * s),
                child: Column(children: [
                  Container(
                    width: 52 * s, height: 52 * s,
                    decoration: BoxDecoration(
                      color: AppTheme.black3,
                      borderRadius: BorderRadius.circular(14 * s),
                      border: Border.all(color: AppTheme.black5),
                    ),
                    child: Icon(a.icon,
                        color: AppTheme.white.withOpacity(0.6),
                        size: 22 * s),
                  ),
                  SizedBox(height: 8 * s),
                  Text(a.label,
                      style: TextStyle(
                          fontSize: 10 * s,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.white.withOpacity(0.4),
                          height: 1.4),
                      textAlign: TextAlign.center),
                ]),
              ),
            ),
          )).toList(),
        ),
      ]),
    );
  }
}

class _QA {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _QA(this.label, this.icon, this.onTap);
}
