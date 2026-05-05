// ignore_for_file: depend_on_referenced_packages
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../models/Transaction.dart';
import '../provider/user_provider.dart';
import '../utils/sharedPreferenceKey.dart';
import '../utils/premium_theme.dart';
import '../utils/utilsMethods.dart';
import 'widget/premium_cards.dart';
import 'widget/premium_shimmer.dart';

class ProductQRRedeemHistoryScreen extends StatefulWidget {
  const ProductQRRedeemHistoryScreen({super.key});
  @override
  State<StatefulWidget> createState() => _ProductQRRedeemHistoryScreenState();
}

class _ProductQRRedeemHistoryScreenState extends State<ProductQRRedeemHistoryScreen> {
  SharedPreferences? sharedPreferences;
  var userToken = "";
  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();
  DateTime lastPickedStartDate = DateTime.now().subtract(const Duration(days: 1));
  DateTime lastPickedEndDate = DateTime.now().subtract(const Duration(days: 1));
  String startDate = "";
  String endDate = "";

  @override
  void initState() {
    super.initState();
    initializePreference().whenComplete(() {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      check().then((internet) async {
        if (internet) {
          userProvider.transactionDataArr = [];
          await userProvider.fetchProductTransactionList(context, userToken, "", "");
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
                          delegate: SliverChildListDelegate([
                            PremiumShimmer.card(height: 120),
                            const SizedBox(height: 20),
                            ...List.generate(5, (index) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: PremiumShimmer.card(height: 100),
                            )),
                          ]),
                        ),
                      ),
                    ],
                  )
                : CustomScrollView(
                    slivers: [
                      _buildAppBar(),
                      SliverPadding(
                        padding: const EdgeInsets.all(24),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            _buildDateFilters(userProvider),
                            const SizedBox(height: 24),
                            _buildTransactionsList(userProvider),
                          ]),
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
          'QR Redeem History',
          style: PremiumTheme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: PremiumTheme.textPrimary,
          ),
        ).animate().fadeIn(delay: 200.ms),
      ),
    );
  }

  Widget _buildDateFilters(UserProvider userProvider) {
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter by Date',
            style: PremiumTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDateField(
                  'Start Date',
                  startDateController,
                  () => _selectStartDate(userProvider),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDateField(
                  'End Date',
                  endDateController,
                  () => _selectEndDate(userProvider),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildDateField(String label, TextEditingController controller, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: PremiumTheme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: PremiumTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: true,
          onTap: onTap,
          style: PremiumTheme.textTheme.bodyMedium,
          decoration: InputDecoration(
            hintText: 'Select date',
            hintStyle: PremiumTheme.textTheme.bodyMedium?.copyWith(
              color: PremiumTheme.textTertiary,
            ),
            filled: true,
            fillColor: Colors.white,
            suffixIcon: Icon(
              Icons.calendar_today_rounded,
              color: PremiumTheme.primaryColor,
              size: 18,
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
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionsList(UserProvider userProvider) {
    if (userProvider.transactionDataArr.isEmpty) {
      return PremiumCard(
        child: Column(
          children: [
            Icon(
              Icons.qr_code_scanner_rounded,
              size: 64,
              color: PremiumTheme.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              'No QR Transactions Found',
              style: PremiumTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your QR redeem history will appear here',
              style: PremiumTheme.textTheme.bodyMedium?.copyWith(
                color: PremiumTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ).animate().fadeIn(delay: 400.ms);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Transaction History',
          style: PremiumTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        ...userProvider.transactionDataArr.asMap().entries.map((entry) {
          int index = entry.key;
          TransactionData transaction = entry.value;
          return _buildTransactionCard(transaction, index);
        }).toList(),
      ],
    );
  }

  Widget _buildTransactionCard(TransactionData transaction, int index) {
    Color statusColor = _getStatusColor(transaction);
    String statusText = _getStatusText(transaction);
    IconData statusIcon = _getStatusIcon(transaction);

    return PremiumCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              statusIcon,
              color: statusColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.productName ?? 'QR Redeem',
                  style: PremiumTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  transaction.transactionId ?? '',
                  style: PremiumTheme.textTheme.bodyMedium?.copyWith(
                    color: PremiumTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${lastTransactionDate(transaction.createdAt)} • ${getFormattedTime(transaction.createdAt)}",
                  style: PremiumTheme.textTheme.bodySmall?.copyWith(
                    color: PremiumTheme.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                transaction.type == "credit"
                    ? "+${transaction.points.toString()}"
                    : "-${transaction.points.toString()}",
                style: PremiumTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: transaction.type == "credit"
                      ? PremiumTheme.successColor
                      : PremiumTheme.errorColor,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  statusText,
                  style: PremiumTheme.textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 400 + (index * 100)));
  }

  Color _getStatusColor(TransactionData transaction) {
    if (transaction.transactionType == "qr") return PremiumTheme.successColor;
    
    switch (transaction.status) {
      case "approved":
      case "completed":
        return PremiumTheme.successColor;
      case "rejected":
        return PremiumTheme.errorColor;
      case "pending":
      default:
        return PremiumTheme.warningColor;
    }
  }

  String _getStatusText(TransactionData transaction) {
    if (transaction.transactionType == "qr") return "Success";
    
    switch (transaction.status) {
      case "approved":
        return "Approved";
      case "rejected":
        return "Rejected";
      case "completed":
        return "Completed";
      case "pending":
      default:
        return "Pending";
    }
  }

  IconData _getStatusIcon(TransactionData transaction) {
    if (transaction.transactionType == "qr") return Icons.qr_code_rounded;
    
    switch (transaction.status) {
      case "approved":
      case "completed":
        return Icons.check_circle_rounded;
      case "rejected":
        return Icons.cancel_rounded;
      case "pending":
      default:
        return Icons.schedule_rounded;
    }
  }

  Future<void> _selectStartDate(UserProvider userProvider) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: lastPickedStartDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now().subtract(const Duration(days: 1)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: PremiumTheme.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: PremiumTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      lastPickedStartDate = pickedDate;
      String formattedDate = DateFormat('dd/MM/yyyy').format(pickedDate);
      startDate = DateFormat('yyyy-MM-dd').format(pickedDate);
      startDateController.text = formattedDate;
      _fetchTransactions(userProvider);
    } else {
      setState(() {
        startDate = "";
        startDateController.clear();
        _fetchTransactions(userProvider);
      });
    }
  }

  Future<void> _selectEndDate(UserProvider userProvider) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: lastPickedEndDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now().subtract(const Duration(days: 1)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: PremiumTheme.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: PremiumTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      lastPickedEndDate = pickedDate;
      String formattedDate = DateFormat('dd/MM/yyyy').format(pickedDate);
      endDate = DateFormat('yyyy-MM-dd').format(pickedDate);
      endDateController.text = formattedDate;
      _fetchTransactions(userProvider);
    } else {
      setState(() {
        endDate = "";
        endDateController.clear();
        _fetchTransactions(userProvider);
      });
    }
  }

  void _fetchTransactions(UserProvider userProvider) {
    check().then((internet) async {
      if (internet) {
        userProvider.transactionDataArr = [];
        await userProvider.fetchProductTransactionList(context, userToken, startDate, endDate);
      } else {
        showWarningToast("No network connection");
      }
    });
  }
}