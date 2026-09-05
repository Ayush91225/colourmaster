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
  void initState() {
    super.initState();
    _init();
  }

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
            appHeader(
              context: context,
              title: 'Gifts',
              onMenuTap: widget.onMenuTap,
            ),

            // ── Balance row ──────────────────────────────────────────────
            if (!p.isLoading &&
                p.dashboardData?.data?.user?.balance != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                      16 * s, 16 * s, 16 * s, 0),
                  child: Row(children: [
                    Expanded(child: _balanceTile(
                      'Available Points',
                      '${p.dashboardData!.data!.user!.balance} PTS',
                      false, s,
                    )),
                    SizedBox(width: 10 * s),
                    Expanded(child: _balanceTile(
                      'Gift Balance',
                      '${p.dashboardData?.data?.giftBalance ?? 0} PTS',
                      true, s,
                    )),
                  ]),
                ),
              ),

            // ── Content ──────────────────────────────────────────────────
            if (p.isLoading)
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                    16 * s, 16 * s, 16 * s, 0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => Padding(
                      padding: EdgeInsets.only(bottom: 12 * s),
                      child: PremiumShimmer.card(height: 260 * s),
                    ),
                    childCount: 3,
                  ),
                ),
              )
            else if (p.giftData?.data == null ||
                p.giftData!.data!.isEmpty)
              SliverFillRemaining(child: _empty(s))
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                    16 * s, 16 * s, 16 * s, 100 * s),
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

  Widget _balanceTile(
      String label, String value, bool accent, double s) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: 14 * s, vertical: 12 * s),
      decoration: BoxDecoration(
        color: AppTheme.black2,
        borderRadius: BorderRadius.circular(12 * s),
        border: Border.all(
          color: accent
              ? AppTheme.orange.withOpacity(0.25)
              : AppTheme.black5,
        ),
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 10 * s,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.white.withOpacity(0.35))),
            SizedBox(height: 4 * s),
            Text(value,
                style: TextStyle(
                    fontSize: 16 * s,
                    fontWeight: FontWeight.w700,
                    color: accent ? AppTheme.orange : AppTheme.white)),
          ]),
    );
  }

  Widget _empty(double s) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 64 * s, height: 64 * s,
          decoration: BoxDecoration(
            color: AppTheme.black3,
            borderRadius: BorderRadius.circular(16 * s),
          ),
          child: Icon(Icons.card_giftcard_outlined,
              size: 28 * s,
              color: AppTheme.white.withOpacity(0.25)),
        ),
        SizedBox(height: 16 * s),
        Text('No Gifts Available',
            style: TextStyle(
                fontSize: 16 * s,
                fontWeight: FontWeight.w600,
                color: AppTheme.white)),
        SizedBox(height: 6 * s),
        Text('Gift rewards will appear here',
            style: TextStyle(
                fontSize: 13 * s,
                color: AppTheme.white.withOpacity(0.35))),
      ],
    ),
  );

  Widget _giftCard(GiftListData gift, UserProvider p, double s) {
    final pts =
        int.tryParse(gift.points?.toString() ?? '0') ?? 0;
    final balance = int.tryParse(
            p.dashboardData?.data?.user?.balance?.toString() ??
                '0') ??
        0;
    final canRedeem = balance >= pts;
    // Image height = 44% of card width (full width minus padding)
    final sw = MediaQuery.of(context).size.width;
    final imgH = (sw - 32 * s) * 0.44;

    return Container(
      margin: EdgeInsets.only(bottom: 12 * s),
      decoration: BoxDecoration(
        color: AppTheme.black2,
        borderRadius: BorderRadius.circular(14 * s),
        border: Border.all(color: AppTheme.black5),
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            GestureDetector(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => FullScreenImage(
                          imageUrl: gift.imageUrl.toString(),
                          title: gift.name.toString()))),
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(
                    top: Radius.circular(14 * s)),
                child: SizedBox(
                  height: imgH,
                  width: double.infinity,
                  child: Image.network(
                    gift.imageUrl.toString(),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppTheme.black3,
                      child: Icon(Icons.card_giftcard_outlined,
                          color: AppTheme.white.withOpacity(0.2),
                          size: 36 * s),
                    ),
                  ),
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(14 * s),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(gift.name.toString(),
                        style: TextStyle(
                            fontSize: 15 * s,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.white),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    SizedBox(height: 10 * s),

                    Row(children: [
                      // Points badge
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10 * s, vertical: 4 * s),
                        decoration: BoxDecoration(
                          color: AppTheme.orange.withOpacity(0.1),
                          borderRadius:
                              BorderRadius.circular(6 * s),
                          border: Border.all(
                              color:
                                  AppTheme.orange.withOpacity(0.2)),
                        ),
                        child: Text('${gift.points} PTS',
                            style: TextStyle(
                                fontSize: 12 * s,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.orange)),
                      ),
                      SizedBox(width: 8 * s),
                      // Worth badge
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10 * s, vertical: 4 * s),
                        decoration: BoxDecoration(
                          color: AppTheme.black4,
                          borderRadius:
                              BorderRadius.circular(6 * s),
                        ),
                        child: Text('₹${gift.worthPrice}',
                            style: TextStyle(
                                fontSize: 12 * s,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.white
                                    .withOpacity(0.6))),
                      ),
                      const Spacer(),
                      if (!canRedeem)
                        Flexible(
                          child: Text(
                              'Need ${pts - balance} more',
                              style: TextStyle(
                                  fontSize: 11 * s,
                                  color: AppTheme.white
                                      .withOpacity(0.3)),
                              overflow: TextOverflow.ellipsis),
                        ),
                    ]),
                    SizedBox(height: 12 * s),

                    SizedBox(
                      width: double.infinity,
                      height: 44 * s,
                      child: canRedeem
                          ? GestureDetector(
                              onTap: () => _confirmRedeem(gift),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppTheme.orange,
                                  borderRadius:
                                      BorderRadius.circular(
                                          10 * s),
                                ),
                                alignment: Alignment.center,
                                child: Text('Redeem Gift',
                                    style: TextStyle(
                                        fontSize: 14 * s,
                                        fontWeight:
                                            FontWeight.w700,
                                        color: AppTheme.black)),
                              ),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                color: AppTheme.black4,
                                borderRadius:
                                    BorderRadius.circular(10 * s),
                                border: Border.all(
                                    color: AppTheme.black5),
                              ),
                              alignment: Alignment.center,
                              child: Text('Insufficient Points',
                                  style: TextStyle(
                                      fontSize: 14 * s,
                                      fontWeight: FontWeight.w500,
                                      color: AppTheme.white
                                          .withOpacity(0.25))),
                            ),
                    ),
                  ]),
            ),
          ]),
    );
  }

  void _confirmRedeem(GiftListData gift) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Redeem Gift',
            style: TextStyle(
                fontSize: 17, fontWeight: FontWeight.w700)),
        content: Text(
            'Redeem "${gift.name}" for ${gift.points} PTS?',
            style: TextStyle(
                fontSize: 14,
                color: AppTheme.white.withOpacity(0.6))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: TextStyle(
                    color: AppTheme.white.withOpacity(0.4))),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              if (await check()) {
                final p = Provider.of<UserProvider>(context,
                    listen: false);
                await p.redemptionRequest(
                    context, 'gift', _token, gift.points, gift.id);
              } else {
                showWarningToast('No network connection');
              }
            },
            child: const Text('Redeem',
                style: TextStyle(
                    color: AppTheme.orange,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
