import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/GiftData.dart';
import '../provider/user_provider.dart';
import '../utils/sharedPreferenceKey.dart';
import '../utils/premium_theme.dart';
import '../utils/utilsMethods.dart';
import 'widget/premium_shimmer.dart';
import 'widget/app_header.dart';
import 'full_screen_image.dart';

class GiftScreen extends StatefulWidget {
  final VoidCallback? onMenuTap;
  const GiftScreen({super.key, this.onMenuTap});
  @override
  State<GiftScreen> createState() => _State();
}

class _State extends State<GiftScreen> {
  String _token = '';

  @override
  void initState() { super.initState(); _init(); }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(TOKEN) ?? '';
    final p = Provider.of<UserProvider>(context, listen: false);
    p.giftData = GiftData();
    if (await check()) {
      await p.fetchGiftList(context, _token);
    } else {
      showWarningToast('No network connection');
    }
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final s = (sw / 390).clamp(0.8, 1.3);

    return Consumer<UserProvider>(
      builder: (_, p, __) => Scaffold(
        backgroundColor: AppTheme.black,
        body: CustomScrollView(
          slivers: [
            appHeader(context: context, title: 'Gifts', onMenuTap: widget.onMenuTap),

            // ── Balance row ──────────────────────────────────────────────────
            if (!p.isLoading && p.dashboardData?.data?.user?.balance != null)
              SliverToBoxAdapter(child: _balanceRow(p, s)),

            // ── Loading shimmer ──────────────────────────────────────────────
            if (p.isLoading)
              SliverPadding(
                padding: EdgeInsets.fromLTRB(16 * s, 16 * s, 16 * s, 0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => Padding(
                      padding: EdgeInsets.only(bottom: 16 * s),
                      child: _shimmerCard(s),
                    ),
                    childCount: 3,
                  ),
                ),
              )
            else if (p.giftData?.data == null || p.giftData!.data!.isEmpty)
              SliverFillRemaining(child: _empty(s))
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(16 * s, 16 * s, 16 * s, 100 * s),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => _giftCard(p.giftData!.data![i], p, s),
                    childCount: p.giftData!.data!.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Balance row ───────────────────────────────────────────────────────────────
  Widget _balanceRow(UserProvider p, double s) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16 * s, 16 * s, 16 * s, 0),
      child: Container(
        padding: EdgeInsets.all(18 * s),
        decoration: BoxDecoration(
          color: AppTheme.black2,
          borderRadius: BorderRadius.circular(20 * s),
          border: Border.all(color: AppTheme.black5),
        ),
        child: Row(children: [
          Expanded(child: _balanceStat(
            'Available Points',
            '${p.dashboardData!.data!.user!.balance}',
            Icons.toll_rounded,
            AppTheme.white,
            s,
          )),
          Container(width: 1, height: 40 * s, color: AppTheme.black5),
          Expanded(child: _balanceStat(
            'Gift Balance',
            '${p.dashboardData?.data?.giftBalance ?? 0}',
            Icons.card_giftcard_outlined,
            AppTheme.orange,
            s,
          )),
        ]),
      ),
    );
  }

  Widget _balanceStat(String label, String value, IconData icon, Color color, double s) {
    return Column(children: [
      Container(
        width: 36 * s, height: 36 * s,
        decoration: BoxDecoration(
          color: color == AppTheme.orange
              ? AppTheme.orange.withOpacity(0.1)
              : AppTheme.black4,
          borderRadius: BorderRadius.circular(10 * s),
        ),
        child: Icon(icon, size: 17 * s, color: color),
      ),
      SizedBox(height: 8 * s),
      Text('$value PTS',
          style: TextStyle(fontSize: 17 * s, fontWeight: FontWeight.w800, color: color)),
      SizedBox(height: 2 * s),
      Text(label,
          style: TextStyle(fontSize: 10 * s, color: AppTheme.white30, fontWeight: FontWeight.w400),
          textAlign: TextAlign.center),
    ]);
  }

  // ── Shimmer card ──────────────────────────────────────────────────────────────
  Widget _shimmerCard(double s) {
    final sw = MediaQuery.of(context).size.width;
    final imgH = (sw - 32 * s) * 0.50;
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.black2,
        borderRadius: BorderRadius.circular(20 * s),
        border: Border.all(color: AppTheme.black5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        PremiumShimmer.card(height: imgH, borderRadius: BorderRadius.zero),
        Padding(
          padding: EdgeInsets.all(14 * s),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            PremiumShimmer.text(width: double.infinity, height: 16 * s),
            SizedBox(height: 8 * s),
            PremiumShimmer.text(width: 120 * s, height: 12 * s),
            SizedBox(height: 14 * s),
            PremiumShimmer.card(height: 44 * s),
          ]),
        ),
      ]),
    );
  }

  // ── Empty state ───────────────────────────────────────────────────────────────
  Widget _empty(double s) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
        width: 72 * s, height: 72 * s,
        decoration: BoxDecoration(
          color: AppTheme.black3,
          borderRadius: BorderRadius.circular(20 * s),
        ),
        child: Icon(Icons.card_giftcard_outlined, size: 32 * s, color: AppTheme.white30),
      ),
      SizedBox(height: 16 * s),
      Text('No Gifts Available',
          style: TextStyle(fontSize: 16 * s, fontWeight: FontWeight.w600, color: AppTheme.white)),
      SizedBox(height: 6 * s),
      Text('Gift rewards will appear here',
          style: TextStyle(fontSize: 13 * s, color: AppTheme.white30)),
    ]),
  );

  // ── Gift card ─────────────────────────────────────────────────────────────────
  Widget _giftCard(GiftListData gift, UserProvider p, double s) {
    final pts     = int.tryParse(gift.points?.toString() ?? '0') ?? 0;
    final balance = int.tryParse(p.dashboardData?.data?.user?.balance?.toString() ?? '0') ?? 0;
    final canRedeem = balance >= pts;
    final sw = MediaQuery.of(context).size.width;
    final imgH = (sw - 32 * s) * 0.50;

    return Container(
      margin: EdgeInsets.only(bottom: 16 * s),
      decoration: BoxDecoration(
        color: AppTheme.black2,
        borderRadius: BorderRadius.circular(20 * s),
        border: Border.all(color: AppTheme.black5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // ── Image ──────────────────────────────────────────────────────────
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => FullScreenImage(
                  imageUrl: gift.imageUrl.toString(),
                  title: gift.name.toString()))),
          child: SizedBox(
            height: imgH, width: double.infinity,
            child: Image.network(
              gift.imageUrl.toString(),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: AppTheme.black4,
                child: Icon(Icons.card_giftcard_outlined,
                    color: AppTheme.white30, size: 40 * s),
              ),
            ),
          ),
        ),

        // ── Info ───────────────────────────────────────────────────────────
        Padding(
          padding: EdgeInsets.all(16 * s),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            // Name
            Text(gift.name.toString(),
                style: TextStyle(fontSize: 16 * s, fontWeight: FontWeight.w700, color: AppTheme.white),
                maxLines: 2, overflow: TextOverflow.ellipsis),
            SizedBox(height: 12 * s),

            // Badges row
            Row(children: [
              _badge('${gift.points} PTS', AppTheme.orange, s),
              SizedBox(width: 8 * s),
              _badge('₹${gift.worthPrice}', AppTheme.white60, s, filled: false),
              const Spacer(),
              if (!canRedeem)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 4 * s),
                  decoration: BoxDecoration(
                    color: AppTheme.black4,
                    borderRadius: BorderRadius.circular(20 * s),
                  ),
                  child: Text('Need ${pts - balance} more',
                      style: TextStyle(fontSize: 10 * s, color: AppTheme.white30, fontWeight: FontWeight.w500)),
                ),
            ]),
            SizedBox(height: 14 * s),

            // Progress bar (shows how close user is)
            if (!canRedeem) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(4 * s),
                child: LinearProgressIndicator(
                  value: pts > 0 ? (balance / pts).clamp(0.0, 1.0) : 0,
                  minHeight: 5 * s,
                  backgroundColor: AppTheme.black4,
                  valueColor: AlwaysStoppedAnimation(AppTheme.orange.withOpacity(0.5)),
                ),
              ),
              SizedBox(height: 14 * s),
            ],

            // Redeem button
            SizedBox(
              width: double.infinity,
              height: 48 * s,
              child: canRedeem
                  ? GestureDetector(
                      onTap: () => _confirmRedeem(gift),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.orange,
                          borderRadius: BorderRadius.circular(14 * s),
                        ),
                        alignment: Alignment.center,
                        child: Text('Redeem Gift',
                            style: TextStyle(fontSize: 14 * s, fontWeight: FontWeight.w700, color: Colors.white)),
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        color: AppTheme.black3,
                        borderRadius: BorderRadius.circular(14 * s),
                        border: Border.all(color: AppTheme.black5),
                      ),
                      alignment: Alignment.center,
                      child: Text('Insufficient Points',
                          style: TextStyle(fontSize: 14 * s, fontWeight: FontWeight.w500, color: AppTheme.white30)),
                    ),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _badge(String label, Color color, double s, {bool filled = true}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 5 * s),
      decoration: BoxDecoration(
        color: filled ? color.withOpacity(0.1) : AppTheme.black4,
        borderRadius: BorderRadius.circular(20 * s),
        border: filled ? Border.all(color: color.withOpacity(0.2)) : null,
      ),
      child: Text(label,
          style: TextStyle(fontSize: 12 * s, fontWeight: FontWeight.w600, color: color)),
    );
  }

  void _confirmRedeem(GiftListData gift) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Redeem Gift',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        content: Text('Redeem "${gift.name}" for ${gift.points} PTS?',
            style: TextStyle(fontSize: 14, color: AppTheme.white60)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppTheme.white30)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              if (await check()) {
                final p = Provider.of<UserProvider>(context, listen: false);
                await p.redemptionRequest(context, 'gift', _token, gift.points, gift.id);
              } else {
                showWarningToast('No network connection');
              }
            },
            child: const Text('Redeem',
                style: TextStyle(color: AppTheme.orange, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
