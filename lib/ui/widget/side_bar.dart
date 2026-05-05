import 'dart:io';

import 'package:colourmaster/ui/cash_redeem_history_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../main_screen.dart';
import '../../utils/constants.dart';
import '../../utils/premium_theme.dart';
import '../../utils/utilsMethods.dart';
import '../product_qr_redeem_history_screen.dart';
import '../product_redeem_points_screen.dart';
import '../profile_screen.dart';

Widget sideBar(BuildContext context) {
  return SafeArea(
    top: true,
    child: Drawer(
      backgroundColor: PremiumTheme.backgroundColor,
      child: Column(
        children: [
          // Header Section
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: PremiumTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Color Master',
                  style: PremiumTheme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: PremiumTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                FutureBuilder<String?>(
                  future: getUserName(),
                  builder: (context, snapshot) {
                    return Text(
                      snapshot.data ?? 'User',
                      style: PremiumTheme.textTheme.bodyMedium?.copyWith(
                        color: PremiumTheme.textSecondary,
                      ),
                    );
                  },
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms),
          
          // Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildMenuItem(
                  context,
                  icon: Icons.home_rounded,
                  title: 'Home',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MainScreen(0, ""))),
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.person_rounded,
                  title: 'Profile',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen())),
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.account_balance_rounded,
                  title: 'Cash Redeem',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MainScreen(4, ""))),
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.history_rounded,
                  title: 'Cash Redeem History',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CashRedeemHistoryScreen())),
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.inventory_2_rounded,
                  title: 'Products Redeem Points',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProductRedeemPointScreen())),
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.qr_code_rounded,
                  title: 'Product QR Redeem History',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProductQRRedeemHistoryScreen())),
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.card_giftcard_rounded,
                  title: 'Gift Redeem',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MainScreen(1, ""))),
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.redeem_rounded,
                  title: 'Redeem History',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MainScreen(3, ""))),
                ),
                const SizedBox(height: 16),
                _buildMenuItem(
                  context,
                  icon: Icons.description_rounded,
                  title: 'Terms & Condition',
                  onTap: () => redirectToBrowser(Uri.parse(termConditionURL)),
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.share_rounded,
                  title: 'Share Application',
                  onTap: () => Share.share("Color Master App android: $androidMarketAppUrl \n \n Color Master App iOS: $iOsMarketAppUrl"),
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.star_rounded,
                  title: 'Rate Application',
                  onTap: () => redirectToBrowser(Uri.parse(Platform.isIOS ? iOsMarketAppUrl : androidMarketAppUrl)),
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.contact_support_rounded,
                  title: 'Contact Us',
                  onTap: () => openEmail(contactUSEmailAddress),
                ),
                const SizedBox(height: 16),
                _buildMenuItem(
                  context,
                  icon: Icons.logout_rounded,
                  title: 'Logout',
                  onTap: () => logOutDialog(context),
                  isDestructive: true,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildMenuItem(
  BuildContext context, {
  required IconData icon,
  required String title,
  required VoidCallback onTap,
  bool isDestructive = false,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 8),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDestructive 
                      ? PremiumTheme.errorColor.withOpacity(0.1)
                      : PremiumTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: isDestructive ? PremiumTheme.errorColor : PremiumTheme.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: PremiumTheme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isDestructive ? PremiumTheme.errorColor : PremiumTheme.textPrimary,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: PremiumTheme.textTertiary,
              ),
            ],
          ),
        ),
      ),
    ),
  ).animate().fadeIn(delay: 100.ms);
}
