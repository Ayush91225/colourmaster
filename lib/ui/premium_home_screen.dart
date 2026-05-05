import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:colourmaster/main_screen.dart';
import 'package:colourmaster/ui/product_qr_redeem_history_screen.dart';
import 'package:colourmaster/ui/profile_screen.dart';
import 'package:colourmaster/ui/widget/premium_cards.dart';
import 'package:colourmaster/ui/widget/premium_shimmer.dart';
import 'package:colourmaster/utils/premium_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../provider/user_provider.dart';
import '../utils/sharedPreferenceKey.dart';
import '../utils/utilsMethods.dart';
import '../utils/constants.dart';
import 'cash_redeem_history_screen.dart';
import 'product_redeem_points_screen.dart';

class PremiumHomeScreen extends StatefulWidget {
  const PremiumHomeScreen({super.key});
  
  @override
  State<PremiumHomeScreen> createState() => _PremiumHomeScreenState();
}

class _PremiumHomeScreenState extends State<PremiumHomeScreen> {
  SharedPreferences? sharedPreferences;
  var userToken = "";
  var userPhoto = "";
  bool isLoading = true;
  int currentSliderIndex = 0;

  @override
  void initState() {
    super.initState();
    initializePreference().whenComplete(() {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      check().then((internet) async {
        if (internet) {
          await userProvider.fetchDashboard(context, userToken);
          setState(() {
            isLoading = false;
          });
        } else {
          showWarningToast("No network connection");
          setState(() {
            isLoading = false;
          });
        }
      });
    });
  }

  Future<void> initializePreference() async {
    sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      userToken = sharedPreferences!.getString(TOKEN)!;
      userPhoto = sharedPreferences!.getString(USERPHOTO) ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, UserProvider userProvider, child) {
        return Scaffold(
          backgroundColor: PremiumTheme.backgroundColor,
          body: RefreshIndicator(
            onRefresh: () async {
              setState(() {
                isLoading = true;
              });
              await userProvider.fetchDashboard(context, userToken);
              setState(() {
                isLoading = false;
              });
            },
            color: PremiumTheme.primaryColor,
            child: CustomScrollView(
              slivers: [
                _buildAppBar(),
                SliverPadding(
                  padding: const EdgeInsets.all(24),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildProfileSection(userProvider),
                      const SizedBox(height: 24),
                      _buildBalanceCards(userProvider),
                      const SizedBox(height: 24),
                      _buildLastTransaction(userProvider),
                      const SizedBox(height: 24),
                      _buildSliders(userProvider),
                      const SizedBox(height: 24),
                      _buildQuickActions(),
                      const SizedBox(height: 100),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 60,
      floating: false,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Container(),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          'Colour Master',
          style: PremiumTheme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: PremiumTheme.textPrimary,
          ),
        ).animate().fadeIn(delay: 200.ms),
      ),
    );
  }

  Widget _buildProfileSection(UserProvider userProvider) {
    if (isLoading) {
      return PremiumShimmer.profileHeader();
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: PremiumTheme.primaryColor.withOpacity(0.1),
            ),
            child: ClipOval(
              child: userPhoto.isNotEmpty && userPhoto != "null"
                  ? CachedNetworkImage(
                      imageUrl: userPhoto,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Icon(
                        Icons.person_rounded,
                        color: PremiumTheme.primaryColor,
                        size: 28,
                      ),
                      errorWidget: (context, url, error) => Icon(
                        Icons.person_rounded,
                        color: PremiumTheme.primaryColor,
                        size: 28,
                      ),
                    )
                  : Icon(
                      Icons.person_rounded,
                      color: PremiumTheme.primaryColor,
                      size: 28,
                    ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back',
                  style: PremiumTheme.textTheme.bodyMedium?.copyWith(
                    color: PremiumTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  sharedPreferences?.getString(FULLNAME) ?? 'User',
                  style: PremiumTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
            icon: Icon(
              Icons.settings_rounded,
              color: PremiumTheme.textSecondary,
              size: 20,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildBalanceCards(UserProvider userProvider) {
    if (isLoading) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: PremiumShimmer.dashboardCard()),
              const SizedBox(width: 12),
              Expanded(child: PremiumShimmer.dashboardCard()),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: PremiumShimmer.dashboardCard()),
              const SizedBox(width: 12),
              Expanded(child: PremiumShimmer.dashboardCard()),
            ],
          ),
        ],
      );
    }

    if (userProvider.dashboardData?.data == null) {
      return const SizedBox();
    }

    final data = userProvider.dashboardData!.data!;
    
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${data.user?.balance ?? 0}',
                      style: PremiumTheme.textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: PremiumTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Available Points',
                      style: PremiumTheme.textTheme.bodyMedium?.copyWith(
                        color: PremiumTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${data.lifeTimBalance ?? 0}',
                      style: PremiumTheme.textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: PremiumTheme.successColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Total Earned',
                      style: PremiumTheme.textTheme.bodyMedium?.copyWith(
                        color: PremiumTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${data.giftBalance ?? 0}',
                      style: PremiumTheme.textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: PremiumTheme.accentColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Gift Available',
                      style: PremiumTheme.textTheme.bodyMedium?.copyWith(
                        color: PremiumTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${data.giftLifetimeBalance ?? 0}',
                      style: PremiumTheme.textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: PremiumTheme.infoColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Gift Lifetime',
                      style: PremiumTheme.textTheme.bodyMedium?.copyWith(
                        color: PremiumTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLastTransaction(UserProvider userProvider) {
    if (isLoading || userProvider.dashboardData?.data?.lastTransaction == null) {
      return const SizedBox();
    }

    final transaction = userProvider.dashboardData!.data!.lastTransaction!;
    
    return PremiumCard(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: PremiumTheme.successColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.history_rounded,
              color: PremiumTheme.successColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Last Redeem',
                  style: PremiumTheme.textTheme.bodyMedium?.copyWith(
                    color: PremiumTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${transaction.points} PTS • ${lastTransactionDateOnHome(transaction.createdAt)}',
                  style: PremiumTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: PremiumTheme.primaryColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'Redeem',
              style: PremiumTheme.textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen(4, "")),
        );
      },
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildSliders(UserProvider userProvider) {
    if (isLoading) {
      return PremiumShimmer.card(height: 200);
    }

    if (userProvider.dashboardData?.data?.sliders?.isEmpty ?? true) {
      return const SizedBox();
    }

    final sliders = userProvider.dashboardData!.data!.sliders!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Featured',
          style: PremiumTheme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        CarouselSlider.builder(
          itemCount: sliders.length,
          itemBuilder: (BuildContext context, int itemIndex, int pageViewIndex) =>
              Container(
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CachedNetworkImage(
                imageUrl: sliders[itemIndex].image!,
                fit: BoxFit.cover,
                width: MediaQuery.of(context).size.width,
                height: 200,
                placeholder: (context, url) => PremiumShimmer.card(height: 200),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.image_not_supported),
                ),
              ),
            ),
          ),
          options: CarouselOptions(
            onPageChanged: (index, reason) {
              setState(() {
                currentSliderIndex = index;
              });
            },
            viewportFraction: 1.0,
            height: 200.0,
            autoPlay: true,
            aspectRatio: 16 / 9,
            enableInfiniteScroll: true,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: sliders.asMap().entries.map((entry) {
            return Container(
              width: 8.0,
              height: 8.0,
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: currentSliderIndex == entry.key
                    ? PremiumTheme.primaryColor
                    : Colors.grey,
              ),
            );
          }).toList(),
        ),
      ],
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: PremiumTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.3,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProductQRRedeemHistoryScreen(),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
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
                    Icon(
                      Icons.inventory_2_rounded,
                      color: PremiumTheme.primaryColor,
                      size: 28,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Product',
                      style: PremiumTheme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CashRedeemHistoryScreen(),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
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
                    Icon(
                      Icons.account_balance_rounded,
                      color: PremiumTheme.successColor,
                      size: 28,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Cash',
                      style: PremiumTheme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProductRedeemPointScreen(),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
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
                    Icon(
                      Icons.local_offer_rounded,
                      color: PremiumTheme.accentColor,
                      size: 28,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Coupon',
                      style: PremiumTheme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () => openEmail(contactUSEmailAddress),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
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
                    Icon(
                      Icons.support_agent_rounded,
                      color: PremiumTheme.infoColor,
                      size: 28,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Support',
                      style: PremiumTheme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(delay: 500.ms);
  }
}