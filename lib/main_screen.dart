// ignore_for_file: depend_on_referenced_packages
import 'package:colourmaster/provider/user_provider.dart';
import 'package:colourmaster/ui/redeem_request_screen.dart';
import 'package:colourmaster/utils/sharedPreferenceKey.dart';
import 'package:colourmaster/utils/utilsMethods.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ui/gift_screen.dart';
import 'ui/premium_home_screen.dart';
import 'ui/qr_screen_screen.dart';
import 'ui/redeem_screen.dart';
import 'ui/widget/side_bar.dart';
import 'package:colourmaster/utils/premium_theme.dart';
import 'package:colourmaster/ui/widget/premium_buttons.dart' as premium;
import 'package:flutter_animate/flutter_animate.dart';

class MainScreen extends StatefulWidget {
  final int? _selectedIndex;
  final String qrResult;
  const MainScreen(this._selectedIndex, this.qrResult, {super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const PremiumHomeScreen(),
    const GiftScreen(),
    const QRScreen(),
    const RedeemScreen(),
    const RedeemRequestScreen(),
  ];

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    if (widget._selectedIndex != null) {
      setState(() {
        _currentIndex = widget._selectedIndex!;
      });
      if (widget.qrResult.isNotEmpty) {
        qrRedeem(widget.qrResult);
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  qrRedeem(var qrID) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var userToken = sharedPreferences.getString(TOKEN)!;
    check().then((internet) async {
      if (internet) {
        // Internet Present Case
        FocusManager.instance.primaryFocus?.unfocus();
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        await userProvider.redeemQRCode(context, userToken, qrID);
      } else {
        // No-Internet Case
        showWarningToast("No network connection");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          if (_currentIndex == 0) {
            _scaffoldKey.currentState!.closeDrawer();
            final value = await showDialog<bool>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    content: const Text('Are you sure you want to exit?'),
                    actions: <Widget>[
                      ElevatedButton(
                        child: const Text('No'),
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                      ),
                      ElevatedButton(
                        child: const Text('Yes, exit'),
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                      ),
                    ],
                  );
                });
            return value == true;
          } else {
            setState(() {
              _currentIndex = 0;
              _scaffoldKey.currentState!.closeDrawer();
            });
          }
          return false;
        },
        child: ScreenUtilInit(
            designSize: const Size(390, 844),
            minTextAdapt: true,
            splitScreenMode: true,
            // Use builder only if you need to use library outside ScreenUtilInit context
            builder: (_, child) {
              return Scaffold(
                key: _scaffoldKey,
                extendBodyBehindAppBar: true,
                backgroundColor: PremiumTheme.backgroundColor,
                drawer: sideBar(context),
                floatingActionButton: MediaQuery.of(context).viewInsets.bottom != 0
                    ? null
                    : premium.FloatingActionButton(
                        onPressed: () {
                          setState(() {
                            _currentIndex = 2;
                          });
                        },
                        icon: Icons.qr_code_scanner_rounded,
                        tooltip: 'Scan QR Code',
                      ).animate().scale(delay: 500.ms),
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.centerDocked,
                body: SafeArea(
                  top: false,
                  child: Stack(
                    children: [
                      _screens[_currentIndex],
                      _currentIndex != 2
                          ? Positioned(
                              top: 60,
                              left: 24,
                              child: InkWell(
                                onTap: () {
                                  _scaffoldKey.currentState?.openDrawer();
                                },
                                child: Icon(
                                  Icons.menu_rounded,
                                  color: PremiumTheme.textPrimary,
                                  size: 24,
                                ),
                              ),
                            )
                          : const SizedBox(),
                    ],
                  ),
                ),
                bottomNavigationBar: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: BottomNavigationBar(
                    type: BottomNavigationBarType.fixed,
                    backgroundColor: Colors.transparent,
                    selectedItemColor: PremiumTheme.primaryColor,
                    unselectedItemColor: PremiumTheme.textTertiary,
                    elevation: 0,
                    unselectedLabelStyle: PremiumTheme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    selectedLabelStyle: PremiumTheme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: PremiumTheme.primaryColor,
                    ),
                    showUnselectedLabels: true,
                    currentIndex: _currentIndex,
                    onTap: (index) async {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    items: [
                      BottomNavigationBarItem(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            Icons.home_rounded,
                            size: 24,
                          ),
                        ),
                        label: 'Home',
                      ),
                      BottomNavigationBarItem(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            Icons.card_giftcard_rounded,
                            size: 24,
                          ),
                        ),
                        label: 'Gifts',
                      ),
                      BottomNavigationBarItem(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            Icons.qr_code_scanner_rounded,
                            color: Colors.transparent,
                            size: 24,
                          ),
                        ),
                        label: 'Scan',
                      ),
                      BottomNavigationBarItem(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            Icons.redeem_rounded,
                            size: 24,
                          ),
                        ),
                        label: 'Redeem',
                      ),
                      BottomNavigationBarItem(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            Icons.account_balance_wallet_rounded,
                            size: 24,
                          ),
                        ),
                        label: 'Cash',
                      ),
                    ],
                  ),
                ),
              );
            }));
  }
}