// ignore_for_file: depend_on_referenced_packages
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../provider/user_provider.dart';
import '../utils/sharedPreferenceKey.dart';
import '../utils/premium_theme.dart';
import '../utils/utilsMethods.dart';
import 'widget/premium_cards.dart';
import 'widget/premium_shimmer.dart';
import 'widget/premium_buttons.dart' as premium;

class RedeemRequestScreen extends StatefulWidget {
  const RedeemRequestScreen({super.key});
  @override
  State<StatefulWidget> createState() => _RedeemRequestScreenState();
}

class _RedeemRequestScreenState extends State<RedeemRequestScreen> {
  TextEditingController pointController = TextEditingController();
  ScrollController scrollController = ScrollController();

  var userToken = "";
  var selectedValue = "Account";
  SharedPreferences? sharedPreferences;
  List<String> modeStrArr = ["UPI", "Account", "Cash"];
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  var availablePoint = 0;

  @override
  void initState() {
    super.initState();
    initializePreference().whenComplete(() {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      check().then((internet) async {
        if (internet) {
          FocusManager.instance.primaryFocus?.unfocus();
          await userProvider.fetchDashboard(context, userToken);
          setState(() {
            availablePoint = double.parse(userProvider.dashboardData!.data!.user!.balance!).toInt();
          });
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          'Color Master',
          style: PremiumTheme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: PremiumTheme.textPrimary,
          ),
        ),
      ),
      body: Consumer<UserProvider>(
        builder: (context, UserProvider userProvider, child) {
          return userProvider.isLoading
              ? SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      PremiumShimmer.card(height: 120),
                      const SizedBox(height: 20),
                      PremiumShimmer.card(height: 120),
                      const SizedBox(height: 20),
                      PremiumShimmer.card(height: 80),
                      const SizedBox(height: 20),
                      PremiumShimmer.card(height: 80),
                      const SizedBox(height: 40),
                      PremiumShimmer.card(height: 50),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _buildBalanceCard(userProvider),
                      const SizedBox(height: 20),
                      _buildConversionCard(),
                      const SizedBox(height: 24),
                      _buildRedeemForm(userProvider),
                    ],
                  ),
                );
        },
      ),
    );
  }

  Widget _buildBalanceCard(UserProvider userProvider) {
    if (userProvider.dashboardData == null) return const SizedBox();

    return PremiumCard(
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: PremiumTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.account_balance_wallet_rounded,
              color: PremiumTheme.primaryColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Available Balance',
                  style: PremiumTheme.textTheme.bodyMedium?.copyWith(
                    color: PremiumTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${userProvider.dashboardData!.data!.user!.balance.toString()} PTS',
                  style: PremiumTheme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: PremiumTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildConversionCard() {
    return PremiumCard(
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: PremiumTheme.successColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.currency_exchange_rounded,
              color: PremiumTheme.successColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Conversion Rate',
                  style: PremiumTheme.textTheme.bodyMedium?.copyWith(
                    color: PremiumTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '1.00 PTS = ₹1.00',
                  style: PremiumTheme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: PremiumTheme.successColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildRedeemForm(UserProvider userProvider) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          _buildModeSelector(),
          const SizedBox(height: 20),
          _buildPointsInput(),
          const SizedBox(height: 40),
          premium.PremiumButton(
            text: 'Submit Redeem Request',
            onPressed: () => _submitRedeemRequest(userProvider),
          ).animate().fadeIn(delay: 700.ms),
        ],
      ),
    );
  }

  Widget _buildModeSelector() {
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Redeem Mode',
            style: PremiumTheme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: PremiumTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: selectedValue,
            style: PremiumTheme.textTheme.bodyMedium,
            decoration: InputDecoration(
              hintText: "Select Mode",
              hintStyle: PremiumTheme.textTheme.bodyMedium?.copyWith(
                color: PremiumTheme.textTertiary,
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: PremiumTheme.primaryColor,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: PremiumTheme.textSecondary,
            ),
            dropdownColor: Colors.white,
            onChanged: (String? value) {
              setState(() {
                selectedValue = value!;
              });
            },
            items: modeStrArr.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Row(
                  children: [
                    Icon(
                      _getModeIcon(value),
                      color: PremiumTheme.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(value),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms);
  }

  Widget _buildPointsInput() {
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Points to Redeem',
            style: PremiumTheme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: PremiumTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: pointController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: PremiumTheme.textTheme.bodyMedium,
            validator: (String? value) {
              if (value!.isEmpty) {
                return 'Points Required';
              } else if (availablePoint < int.parse(pointController.text)) {
                return 'Insufficient Available Points';
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: "Enter points to redeem",
              hintStyle: PremiumTheme.textTheme.bodyMedium?.copyWith(
                color: PremiumTheme.textTertiary,
              ),
              filled: true,
              fillColor: Colors.white,
              prefixIcon: Icon(
                Icons.stars_rounded,
                color: PremiumTheme.primaryColor,
                size: 20,
              ),
              suffixText: 'PTS',
              suffixStyle: PremiumTheme.textTheme.bodyMedium?.copyWith(
                color: PremiumTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: PremiumTheme.primaryColor,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: PremiumTheme.errorColor,
                  width: 1,
                ),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
            onChanged: (value) {
              if (value.isNotEmpty) {
                setState(() {}); // Trigger rebuild to show conversion
              }
            },
          ),
          if (pointController.text.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: PremiumTheme.successColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: PremiumTheme.successColor.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: PremiumTheme.successColor,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'You will receive: ₹${pointController.text}',
                    style: PremiumTheme.textTheme.bodySmall?.copyWith(
                      color: PremiumTheme.successColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(delay: 600.ms);
  }

  IconData _getModeIcon(String mode) {
    switch (mode) {
      case 'UPI':
        return Icons.qr_code_rounded;
      case 'Account':
        return Icons.account_balance_rounded;
      case 'Cash':
        return Icons.money_rounded;
      default:
        return Icons.payment_rounded;
    }
  }

  Future<void> _submitRedeemRequest(UserProvider userProvider) async {
    if (formKey.currentState!.validate()) {
      check().then((internet) async {
        if (internet) {
          FocusManager.instance.primaryFocus?.unfocus();
          await userProvider.redemptionRequest(
            context,
            selectedValue,
            userToken,
            pointController.text.toString().trim(),
            "",
          );
        } else {
          showWarningToast("No network connection");
        }
      });
    }
  }
}