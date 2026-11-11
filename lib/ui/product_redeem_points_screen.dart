import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/Product.dart';
import '../provider/user_provider.dart';
import '../utils/sharedPreferenceKey.dart';
import '../utils/premium_theme.dart';
import '../utils/utilsMethods.dart';
import 'widget/premium_shimmer.dart';
import 'widget/app_header.dart';
import 'full_screen_image.dart';

class ProductRedeemPointScreen extends StatefulWidget {
  const ProductRedeemPointScreen({super.key});
  @override
  State<ProductRedeemPointScreen> createState() => _State();
}

class _State extends State<ProductRedeemPointScreen> {
  String _token = '';

  @override
  void initState() { super.initState(); _init(); }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(TOKEN) ?? '';
    final p = Provider.of<UserProvider>(context, listen: false);
    p.productArr = [];
    if (await check()) {
      await p.fetchProductList(context, _token, '', '');
    } else {
      showWarningToast('No network connection');
    }
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
            appHeader(context: context, title: 'Product Coupons'),
            if (p.isLoading)
              SliverPadding(
                padding: EdgeInsets.all(16 * s),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => Padding(
                      padding: EdgeInsets.only(bottom: 14 * s),
                      child: PremiumShimmer.card(height: 120 * s),
                    ),
                    childCount: 5,
                  ),
                ),
              )
            else if (p.productArr.isEmpty)
              SliverFillRemaining(child: _empty(s))
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(16 * s, 16 * s, 16 * s, 80 * s),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => _productCard(p.productArr[i], s),
                    childCount: p.productArr.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _productCard(ProductData d, double s) {
    final earned    = d.earnPoints ?? 0;
    final needed    = d.points ?? 0;
    final canRedeem = earned >= needed;
    final progress  = needed > 0 ? (earned / needed).clamp(0.0, 1.0) : 0.0;

    return Container(
      margin: EdgeInsets.only(bottom: 14 * s),
      decoration: BoxDecoration(
        color: AppTheme.black2,
        borderRadius: BorderRadius.circular(20 * s),
        border: Border.all(color: AppTheme.black5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // ── Top row ──────────────────────────────────────────────────────────
        Padding(
          padding: EdgeInsets.all(14 * s),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Image
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => FullScreenImage(
                      imageUrl: d.imageUrl.toString(), title: d.name.toString()))),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14 * s),
                child: SizedBox(
                  width: 72 * s, height: 72 * s,
                  child: Image.network(
                    d.imageUrl.toString(),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppTheme.black4,
                      child: Icon(Icons.image_not_supported_outlined,
                          color: AppTheme.white30, size: 28 * s),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12 * s),

            // Info
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(d.name.toString(),
                    style: TextStyle(fontSize: 14 * s, fontWeight: FontWeight.w600, color: AppTheme.white),
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                SizedBox(height: 8 * s),
                Wrap(spacing: 6 * s, runSpacing: 4 * s, children: [
                  _chip('${d.points} PTS needed', AppTheme.orange, s),
                  _chip('Earned: $earned', AppTheme.white60, s),
                ]),
                SizedBox(height: 4 * s),
                Text('Expiry: ${lastTransactionDate(d.expiryDate)}',
                    style: TextStyle(fontSize: 11 * s, color: AppTheme.white30)),
              ]),
            ),

            // Status badge
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 4 * s),
              decoration: BoxDecoration(
                color: canRedeem ? AppTheme.orange.withOpacity(0.1) : AppTheme.black4,
                borderRadius: BorderRadius.circular(20 * s),
                border: Border.all(
                    color: canRedeem ? AppTheme.orange.withOpacity(0.3) : AppTheme.black5),
              ),
              child: Text(
                canRedeem ? 'Ready' : 'Pending',
                style: TextStyle(fontSize: 11 * s, fontWeight: FontWeight.w700,
                    color: canRedeem ? AppTheme.orange : AppTheme.white30),
              ),
            ),
          ]),
        ),

        // ── Progress ──────────────────────────────────────────────────────────
        Padding(
          padding: EdgeInsets.fromLTRB(14 * s, 0, 14 * s, 14 * s),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Progress', style: TextStyle(fontSize: 11 * s, color: AppTheme.white30)),
              Text('$earned / $needed PTS',
                  style: TextStyle(fontSize: 11 * s, fontWeight: FontWeight.w600, color: AppTheme.white60)),
            ]),
            SizedBox(height: 8 * s),
            ClipRRect(
              borderRadius: BorderRadius.circular(6 * s),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6 * s,
                backgroundColor: AppTheme.black4,
                valueColor: AlwaysStoppedAnimation(
                    canRedeem ? AppTheme.orange : AppTheme.orange.withOpacity(0.35)),
              ),
            ),
            SizedBox(height: 14 * s),

            // Button
            canRedeem
                ? GestureDetector(
                    onTap: () => _confirmRedeem(d),
                    child: Container(
                      width: double.infinity,
                      height: 46 * s,
                      decoration: BoxDecoration(
                        color: AppTheme.orange,
                        borderRadius: BorderRadius.circular(14 * s),
                      ),
                      alignment: Alignment.center,
                      child: Text('Redeem Now',
                          style: TextStyle(fontSize: 14 * s, fontWeight: FontWeight.w700, color: Colors.white)),
                    ),
                  )
                : Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 12 * s),
                    decoration: BoxDecoration(
                      color: AppTheme.black3,
                      borderRadius: BorderRadius.circular(14 * s),
                      border: Border.all(color: AppTheme.black5),
                    ),
                    alignment: Alignment.center,
                    child: Text('Need ${needed - earned} more points',
                        style: TextStyle(fontSize: 13 * s, color: AppTheme.white30)),
                  ),
          ]),
        ),
      ]),
    );
  }

  Widget _chip(String label, Color color, double s) => Container(
    padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 3 * s),
    decoration: BoxDecoration(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(20 * s),
      border: Border.all(color: color.withOpacity(0.15)),
    ),
    child: Text(label, style: TextStyle(fontSize: 11 * s, fontWeight: FontWeight.w600, color: color)),
  );

  Widget _empty(double s) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
        width: 72 * s, height: 72 * s,
        decoration: BoxDecoration(color: AppTheme.black3, borderRadius: BorderRadius.circular(20 * s)),
        child: Icon(Icons.inventory_2_outlined, size: 32 * s, color: AppTheme.white30),
      ),
      SizedBox(height: 16 * s),
      Text('No Products Available',
          style: TextStyle(fontSize: 16 * s, fontWeight: FontWeight.w600, color: AppTheme.white)),
      SizedBox(height: 6 * s),
      Text('Product coupons will appear here',
          style: TextStyle(fontSize: 13 * s, color: AppTheme.white30)),
    ]),
  );

  void _confirmRedeem(ProductData d) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Redeem Product',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.white)),
        content: Text('Redeem "${d.name}" for ${d.points} PTS?',
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
                await p.redemptionRequest(context, 'product', _token, d.points, d.id);
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
