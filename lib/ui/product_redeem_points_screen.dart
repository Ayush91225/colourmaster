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
import 'widget/premium_buttons.dart' as btn;
import 'full_screen_image.dart';

class ProductRedeemPointScreen extends StatefulWidget {
  const ProductRedeemPointScreen({super.key});
  @override
  State<ProductRedeemPointScreen> createState() => _State();
}

class _State extends State<ProductRedeemPointScreen> {
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
    p.productArr = [];
    if (await check()) {
      await p.fetchProductList(context, _token, '', '');
    } else {
      showWarningToast('No network connection');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.black,
      body: Consumer<UserProvider>(
        builder: (_, p, __) => CustomScrollView(
          slivers: [
            appHeader(context: context, title: 'Product Coupons'),

            if (p.isLoading)
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: PremiumShimmer.card(height: 110),
                    ),
                    childCount: 5,
                  ),
                ),
              )
            else if (p.productArr.isEmpty)
              SliverFillRemaining(child: _empty())
            else
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => _productCard(p.productArr[i]),
                    childCount: p.productArr.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _productCard(ProductData d) {
    final earned  = d.earnPoints ?? 0;
    final needed  = d.points ?? 0;
    final canRedeem = earned >= needed;
    final progress = needed > 0 ? (earned / needed).clamp(0.0, 1.0) : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.black2,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [AppTheme.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(
                      builder: (_) => FullScreenImage(
                          imageUrl: d.imageUrl.toString(),
                          title: d.name.toString()))),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      width: 72, height: 72,
                      child: Image.network(
                        d.imageUrl.toString(),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: AppTheme.black1,
                          child: const Icon(Icons.image_not_supported_outlined,
                              color: AppTheme.textMuted, size: 28),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(d.name.toString(),
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary),
                          maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 6),
                      Row(children: [
                        _chip('${d.points} PTS needed', AppTheme.orange),
                        const SizedBox(width: 6),
                        _chip('Earned: $earned', AppTheme.white.withOpacity(0.5)),
                      ]),
                      const SizedBox(height: 4),
                      Text('Expiry: ${lastTransactionDate(d.expiryDate)}',
                          style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                    ],
                  ),
                ),

                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: canRedeem
                        ? AppTheme.orange.withOpacity(0.1)
                        : AppTheme.black4,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: canRedeem
                          ? AppTheme.orange.withOpacity(0.3)
                          : AppTheme.black5),
                  ),
                  child: Text(
                    canRedeem ? 'Ready' : 'Pending',
                    style: TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w700,
                      color: canRedeem ? AppTheme.orange : AppTheme.white.withOpacity(0.3),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Progress bar
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Progress',
                        style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                    Text('$earned / $needed PTS',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary)),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: AppTheme.black4,
                    valueColor: AlwaysStoppedAnimation(
                        canRedeem ? AppTheme.orange : AppTheme.white.withOpacity(0.3)),
                  ),
                ),
              ],
            ),
          ),

          // Redeem button
          if (canRedeem)
            Padding(
              padding: const EdgeInsets.all(14),
              child: btn.PremiumButton(
                text: 'Redeem Now',
                width: double.infinity,
                height: 42,
                onPressed: () => _confirmRedeem(d),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
              child: Text(
                'Need ${needed - earned} more points to redeem',
                style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
              ),
            ),
        ],
      ),
    );
  }

  Widget _chip(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(5),
      border: Border.all(color: color.withOpacity(0.15)),
    ),
    child: Text(label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
  );

  Widget _empty() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 64, height: 64,
          decoration: BoxDecoration(
            color: AppTheme.black3,
            borderRadius: BorderRadius.circular(20)),
          child: Icon(Icons.inventory_2_outlined, size: 28, color: AppTheme.white.withOpacity(0.2)),
        ),
        const SizedBox(height: 16),
        const Text('No Products Available',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.white)),
        const SizedBox(height: 6),
        Text('Product coupons will appear here',
            style: TextStyle(fontSize: 13, color: AppTheme.white.withOpacity(0.3))),
      ],
    ),
  );

  void _confirmRedeem(ProductData d) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Redeem Product',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        content: Text('Redeem "${d.name}" for ${d.points} PTS?',
            style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
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
                style: TextStyle(color: AppTheme.accent, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
