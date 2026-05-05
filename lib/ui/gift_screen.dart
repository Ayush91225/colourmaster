// ignore_for_file: depend_on_referenced_packages
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../models/GiftData.dart';
import '../provider/user_provider.dart';
import '../utils/sharedPreferenceKey.dart';
import '../utils/premium_theme.dart';
import '../utils/utilsMethods.dart';
import 'widget/premium_cards.dart';
import 'widget/premium_shimmer.dart';
import 'widget/premium_buttons.dart' as premium;
import 'full_screen_image.dart';

class GiftScreen extends StatefulWidget {
  const GiftScreen({super.key});
  @override
  State<StatefulWidget> createState() => _GiftScreenState();
}

class _GiftScreenState extends State<GiftScreen> {
  SharedPreferences? sharedPreferences;
  var userToken = "";

  @override
  void initState() {
    super.initState();
    initializePreference().whenComplete(() {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      check().then((internet) async {
        if (internet) {
          userProvider.giftData = GiftData();
          await userProvider.fetchGiftList(context, userToken);
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
    return Consumer<UserProvider>(
      builder: (context, UserProvider userProvider, child) {
        return userProvider.isLoading
            ? _buildLoadingState()
            : _buildContent(userProvider);
      },
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: List.generate(
          4,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: PremiumShimmer.card(height: 160),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(UserProvider userProvider) {
    if (userProvider.giftData?.data == null || userProvider.giftData!.data!.isEmpty) {
      return _buildEmptyState();
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: ListView.builder(
        itemCount: userProvider.giftData!.data!.length,
        itemBuilder: (context, index) => _buildGiftCard(
          userProvider.giftData!.data![index],
          index,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.card_giftcard_rounded,
            size: 64,
            color: PremiumTheme.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'No Gifts Available',
            style: PremiumTheme.textTheme.headlineSmall?.copyWith(
              color: PremiumTheme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Gift rewards will appear here when available',
            style: PremiumTheme.textTheme.bodyMedium?.copyWith(
              color: PremiumTheme.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildGiftCard(GiftListData giftData, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: PremiumCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FullScreenImage(
                          imageUrl: giftData.imageUrl.toString(),
                          title: giftData.name.toString(),
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
                        giftData.imageUrl.toString(),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.card_giftcard_rounded,
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
                        giftData.name.toString(),
                        style: PremiumTheme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: PremiumTheme.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildInfoChip(
                            'Worth',
                            '₹${giftData.worthPrice}',
                            PremiumTheme.successColor,
                          ),
                          const SizedBox(width: 12),
                          _buildInfoChip(
                            'Points',
                            '${giftData.points} PTS',
                            PremiumTheme.primaryColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: premium.PremiumButton(
                text: 'Redeem Gift',
                icon: Icons.card_giftcard_rounded,
                onPressed: () => _showRedeemDialog(giftData),
              ),
            ),
          ],
        ),
      ).animate().fadeIn(delay: (100 * index).ms),
    );
  }

  Widget _buildInfoChip(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: PremiumTheme.textTheme.bodySmall?.copyWith(
            color: PremiumTheme.textTertiary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            value,
            style: PremiumTheme.textTheme.titleSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  void _showRedeemDialog(GiftListData giftData) {
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
                Icons.card_giftcard_rounded,
                color: PremiumTheme.primaryColor,
                size: 30,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Redeem Gift',
              style: PremiumTheme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: PremiumTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Are you sure you want to redeem this gift?',
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
                            "gift",
                            userToken,
                            giftData.points,
                            giftData.id,
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