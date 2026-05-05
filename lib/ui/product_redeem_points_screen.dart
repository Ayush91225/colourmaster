// ignore_for_file: depend_on_referenced_packages
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../models/Product.dart';
import '../provider/user_provider.dart';
import '../utils/sharedPreferenceKey.dart';
import '../utils/premium_theme.dart';
import '../utils/utilsMethods.dart';
import 'widget/premium_cards.dart';
import 'widget/premium_shimmer.dart';
import 'widget/premium_buttons.dart' as premium;
import 'full_screen_image.dart';

class ProductRedeemPointScreen extends StatefulWidget {
  const ProductRedeemPointScreen({super.key});
  @override
  State<StatefulWidget> createState() => _ProductRedeemPointScreenState();
}

class _ProductRedeemPointScreenState extends State<ProductRedeemPointScreen> {
  SharedPreferences? sharedPreferences;
  var userToken = "";

  @override
  void initState() {
    super.initState();
    initializePreference().whenComplete(() {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      check().then((internet) async {
        if (internet) {
          userProvider.productArr = [];
          await userProvider.fetchProductList(context, userToken, "", "");
        } else {
          showWarningToast("No network connection");
        }
      });
    });
  }

  Future<void> initializePreference() async {
    sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      userToken = sharedPreferences!.getString(TOKEN)!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PremiumTheme.backgroundColor,
      body: SafeArea(
        child: Consumer<UserProvider>(
          builder: (context, UserProvider userProvider, child) {
            return userProvider.isLoading
                ? CustomScrollView(
                    slivers: [
                      _buildAppBar(),
                      SliverPadding(
                        padding: const EdgeInsets.all(24),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: PremiumShimmer.card(height: 120),
                            ),
                            childCount: 6,
                          ),
                        ),
                      ),
                    ],
                  )
                : CustomScrollView(
                    slivers: [
                      _buildAppBar(),
                      userProvider.productArr.isNotEmpty
                          ? SliverPadding(
                              padding: const EdgeInsets.all(24),
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) => _buildProductCard(
                                    userProvider.productArr[index],
                                    index,
                                  ),
                                  childCount: userProvider.productArr.length,
                                ),
                              ),
                            )
                          : SliverFillRemaining(
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.inventory_2_outlined,
                                      size: 64,
                                      color: PremiumTheme.textTertiary,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No Products Available',
                                      style: PremiumTheme.textTheme.headlineSmall?.copyWith(
                                        color: PremiumTheme.textSecondary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                    ],
                  );
          },
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 60,
      floating: false,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: true,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          'Product Redeem',
          style: PremiumTheme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: PremiumTheme.textPrimary,
          ),
        ).animate().fadeIn(delay: 200.ms),
      ),
    );
  }

  Widget _buildProductCard(ProductData productData, int index) {
    int earnPoint = productData.earnPoints ?? 0;
    int point = productData.points ?? 0;
    bool canRedeem = earnPoint >= point;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: PremiumCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FullScreenImage(
                      imageUrl: productData.imageUrl.toString(),
                      title: productData.name.toString(),
                    ),
                  ),
                );
              },
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade100,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    productData.imageUrl.toString(),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.image_not_supported_outlined,
                        color: PremiumTheme.textTertiary,
                        size: 32,
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productData.name.toString(),
                    style: PremiumTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: PremiumTheme.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: PremiumTheme.successColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Earn: ${productData.earnPoints ?? 0}',
                          style: PremiumTheme.textTheme.bodySmall?.copyWith(
                            color: PremiumTheme.successColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: PremiumTheme.errorColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Need: ${productData.remainingPoints ?? 0}',
                          style: PremiumTheme.textTheme.bodySmall?.copyWith(
                            color: PremiumTheme.errorColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Expiry: ${lastTransactionDate(productData.expiryDate)} | ${getFormattedTime(productData.expiryDate)}',
                    style: PremiumTheme.textTheme.bodySmall?.copyWith(
                      color: PremiumTheme.textTertiary,
                    ),
                  ),
                  if (canRedeem) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: premium.PremiumButton(
                        text: 'Redeem Now',
                        height: 40,
                        onPressed: () => _showRedeemDialog(productData),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: PremiumTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${productData.points} PTS',
                    style: PremiumTheme.textTheme.titleSmall?.copyWith(
                      color: PremiumTheme.primaryColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (!canRedeem) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: PremiumTheme.warningColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Insufficient',
                      style: PremiumTheme.textTheme.bodySmall?.copyWith(
                        color: PremiumTheme.warningColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ).animate().fadeIn(delay: (100 * index).ms),
    );
  }

  void _showRedeemDialog(ProductData productData) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: PremiumTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(
                Icons.redeem_rounded,
                color: PremiumTheme.primaryColor,
                size: 30,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Redeem Product',
              style: PremiumTheme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: PremiumTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Are you sure you want to redeem this product?',
              style: PremiumTheme.textTheme.bodyMedium?.copyWith(
                color: PremiumTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: premium.PremiumButton(
                    text: 'Cancel',
                    isOutlined: true,
                    onPressed: () => Navigator.pop(dialogContext),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: premium.PremiumButton(
                    text: 'Redeem',
                    onPressed: () async {
                      Navigator.pop(dialogContext);
                      check().then((internet) async {
                        if (internet) {
                          FocusManager.instance.primaryFocus?.unfocus();
                          final userProvider = Provider.of<UserProvider>(
                            context,
                            listen: false,
                          );
                          await userProvider.redemptionRequest(
                            context,
                            "product",
                            userToken,
                            productData.points,
                            productData.id,
                          );
                        } else {
                          showWarningToast("No network connection");
                        }
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}