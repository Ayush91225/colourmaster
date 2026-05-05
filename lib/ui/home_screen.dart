// ignore_for_file: depend_on_referenced_packages
import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:colourmaster/main_screen.dart';
import 'package:colourmaster/ui/product_qr_redeem_history_screen.dart';
import 'package:colourmaster/ui/profile_screen.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../provider/user_provider.dart';
import '../utils/sharedPreferenceKey.dart';
import '../utils/style/color_constants.dart';
import '../utils/style/text_view_style.dart';
import '../utils/utilsMethods.dart';
import 'cash_redeem_history_screen.dart';
import 'component/textView.dart';
import 'component/wrapPrimaryButton.dart';
import 'product_redeem_points_screen.dart';
import 'widget/loader.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  SharedPreferences? sharedPreferences;
  var userToken = "";
  var userPhoto = "";
  var onLoad = true;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();

    initializePreference().whenComplete(() {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      check().then((internet) async {
        if (internet) {
          // Internet Present Case
          FocusManager.instance.primaryFocus?.unfocus();
          await userProvider.fetchDashboard(context, userToken);
        } else {
          // No-Internet Case
          showWarningToast("No network connection");
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> initializePreference() async {
    sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      userToken = sharedPreferences!.getString(TOKEN)!;
      userPhoto = sharedPreferences!.getString(USERPHOTO) ?? "";
      debugPrint("userToken:${userToken}");
      debugPrint("userPhoto:${userPhoto}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
        builder: (context, UserProvider userProvider, child) {
      return LoadingOverlay(
          isLoading: userProvider.isLoading,
          color: ColorConstants.loadingBackgroundColor
              .withValues(alpha: 0.7), // 50% opacity
          progressIndicator: loadingIndicator(),
          child: Stack(children: [
            Container(
              height: 270.h,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: <Color>[
                    Color(0xFF3BF284),
                    Color(0xFF0077CD),
                  ],
                ),
              ),
            ),
            Image.asset(height: 300.h, 'assets/images/home_top_bg.png'),
            Container(
              alignment: Alignment.topCenter,
              padding:
                  const EdgeInsets.only(left: 20.0, right: 20.0, top: 10).r,
              child: Image.asset(
                  height: 100.w, width: 100.w, 'assets/images/logo.png'),
            ),
            SingleChildScrollView(
              child: Container(
                  padding:
                      const EdgeInsets.only(left: 20.0, right: 20.0, top: 100)
                          .r,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10).w,
                        ),
                        child: Row(
                          children: [
                            Stack(
                              children: [
                                Container(
                                    margin: const EdgeInsets.only(
                                            bottom: 5, right: 20)
                                        .r,
                                    height: 80.w,
                                    width: 80.w,
                                    decoration: BoxDecoration(
                                        color:
                                            ColorConstants.primaryButtonColor,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(50).w)),
                                    child: Padding(
                                      padding: EdgeInsets.all(
                                              userPhoto == "null" ? 0 : 0)
                                          .r,
                                      child: userPhoto == ""
                                          ? Image.asset(
                                              height: 80.w,
                                              width: 80.w,
                                              'assets/images/user.png')
                                          : ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(50).w,
                                              child: Image.network(
                                                userPhoto,
                                                fit: BoxFit.cover,
                                              )),
                                    )),
                                Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                        height: 40.w,
                                        width: 40.w,
                                        padding:
                                            const EdgeInsets.only(right: 10).r,
                                        child: GestureDetector(
                                            onTap: () async {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const ProfileScreen()),
                                              );
                                            },
                                            child: SvgPicture.asset(
                                                'assets/svg/edit_profile_icon.svg'))))
                              ],
                            ),
                            SizedBox(
                              width: 10.w,
                            ),
                            Flexible(
                                child: Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 10.h,
                                    ),
                                    userProvider.dashboardData != null
                                        ? Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  TextView(
                                                      data: 'Lifetime Balance',
                                                      textColor: ColorConstants
                                                          .whiteColor,
                                                      fontSize:
                                                          textLabelFontSize_12
                                                              .sp,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                  TextView(
                                                    data:
                                                        '${userProvider.dashboardData!.data!.lifeTimBalance.toString()} PTS',
                                                    textColor: ColorConstants
                                                        .whiteColor,
                                                    fontSize:
                                                        textLabelFontSize_16.sp,
                                                    fontWeight: FontWeight.w700,
                                                    fontFamily: 'Poppins',
                                                  )
                                                ],
                                              )
                                            ],
                                          )
                                        : const SizedBox(),
                                    Column(
                                      children: [
                                        SizedBox(
                                          height: 10.h,
                                        ),
                                        userProvider.dashboardData != null
                                            ? Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      TextView(
                                                          data:
                                                              'Available Balance',
                                                          textColor:
                                                              ColorConstants
                                                                  .whiteColor,
                                                          fontSize:
                                                              textLabelFontSize_12
                                                                  .sp,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                      TextView(
                                                        data:
                                                            '${userProvider.dashboardData!.data!.user!.balance.toString()} PTS',
                                                        textColor:
                                                            ColorConstants
                                                                .whiteColor,
                                                        fontSize:
                                                            textLabelFontSize_16
                                                                .sp,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        fontFamily: 'Poppins',
                                                      )
                                                    ],
                                                  )
                                                ],
                                              )
                                            : const SizedBox(),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  width: 10.w,
                                ),
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: 5.h,
                                      ),
                                      userProvider.dashboardData != null
                                          ? Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Flexible(
                                                    child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    TextView(
                                                        data:
                                                            'Gift Lifetime Balance',
                                                        textColor:
                                                            ColorConstants
                                                                .whiteColor,
                                                        fontSize:
                                                            textLabelFontSize_12
                                                                .sp,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                    TextView(
                                                      data:
                                                          '${userProvider.dashboardData!.data!.giftLifetimeBalance.toString()} PTS',
                                                      textColor: ColorConstants
                                                          .whiteColor,
                                                      fontSize:
                                                          textLabelFontSize_16
                                                              .sp,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontFamily: 'Poppins',
                                                    )
                                                  ],
                                                ))
                                              ],
                                            )
                                          : const SizedBox(),
                                      Column(
                                        children: [
                                          SizedBox(
                                            height: 5.h,
                                          ),
                                          userProvider.dashboardData != null
                                              ? Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Flexible(
                                                        child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        TextView(
                                                            data:
                                                                'Gift Available Balance',
                                                            textColor:
                                                                ColorConstants
                                                                    .whiteColor,
                                                            fontSize:
                                                                textLabelFontSize_12
                                                                    .sp,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                        TextView(
                                                          data:
                                                              '${userProvider.dashboardData!.data!.giftBalance.toString()} PTS',
                                                          textColor:
                                                              ColorConstants
                                                                  .whiteColor,
                                                          fontSize:
                                                              textLabelFontSize_16
                                                                  .sp,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          fontFamily: 'Poppins',
                                                        )
                                                      ],
                                                    ))
                                                  ],
                                                )
                                              : const SizedBox(),
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ))
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20.h,
                      ),
                      Visibility(
                          maintainSize: true,
                          maintainAnimation: true,
                          maintainState: true,
                          visible: userProvider.dashboardData != null
                              ? userProvider.dashboardData!.data!
                                          .lastTransaction !=
                                      null
                                  ? true
                                  : false
                              : false,
                          child: Container(
                            margin: const EdgeInsets.only(top: 10).r,
                            padding:
                                const EdgeInsets.fromLTRB(10, 10, 10, 10).r,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10).w,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey,
                                  blurRadius: 5.0,
                                ),
                              ],
                              color: ColorConstants.whiteColor,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                    child: TextView(
                                  data: userProvider.dashboardData != null
                                      ? userProvider.dashboardData!.data!
                                                  .lastTransaction !=
                                              null
                                          ? 'Last Redeem ${userProvider.dashboardData!.data!.lastTransaction!.points.toString()}PTS,  '
                                              '${lastTransactionDateOnHome(userProvider.dashboardData!.data!.lastTransaction!.createdAt)}'
                                          : ""
                                      : "",
                                  textColor: ColorConstants.blackColor,
                                  fontSize: textLabelFontSize_10.sp,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Poppins',
                                )),
                                SizedBox(
                                  width: 10.w,
                                ),
                                WrapPrimaryButton(
                                    onPressed: () {
                                      if (!context.mounted) return;
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const MainScreen(4, "")),
                                      );
                                    },
                                    text: "Redeem")
                              ],
                            ),
                          )),
                      SizedBox(
                        height: 20.h,
                      ),
                      userProvider.dashboardData != null
                          ? userProvider.dashboardData!.data!.sliders!.length >
                                  0
                              ? CarouselSlider.builder(
                                  itemCount: userProvider
                                      .dashboardData!.data!.sliders!.length,
                                  itemBuilder: (BuildContext context,
                                          int itemIndex, int pageViewIndex) =>
                                      Container(
                                    width: MediaQuery.of(context).size.width,
                                    margin:
                                        const EdgeInsets.only(right: 0, left: 0)
                                            .r,
                                    child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(10).w,
                                        child: Image.network(
                                          fit: BoxFit.fill,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          userProvider.dashboardData!.data!
                                              .sliders![itemIndex].image!,
                                          height: 300.h,
                                        )),
                                  ),
                                  options: CarouselOptions(
                                    onPageChanged: (index, reason) {
                                      setState(() {
                                        currentIndex = index;
                                      });
                                    },
                                    viewportFraction: 1.0,
                                    height: userProvider.dashboardData!.data!
                                                .sliders!.length >
                                            0
                                        ? 300.0.h
                                        : 0,
                                    autoPlay: true,
                                    aspectRatio: 16 / 9,
                                    enableInfiniteScroll: false,
                                  ),
                                )
                              : const SizedBox()
                          : const SizedBox(),
                      userProvider.dashboardData != null
                          ? userProvider.dashboardData!.data!.sliders!.length >
                                  0
                              ? Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 10, 0, 10).r,
                                  child: Align(
                                      alignment: Alignment.bottomCenter,
                                      child: DotsIndicator(
                                        dotsCount: userProvider.dashboardData!
                                            .data!.sliders!.length,
                                        position: currentIndex.toDouble(),
                                        decorator: DotsDecorator(
                                          spacing: const EdgeInsets.only(
                                                  left: 10, right: 10)
                                              .r,
                                          color: ColorConstants.blackColor,
                                          activeColor:
                                              ColorConstants.primaryColor,
                                        ),
                                      )),
                                )
                              : const SizedBox()
                          : const SizedBox(),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          /*  WrapPrimaryButton(
                              fontSize: 12,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const MainScreen(3, "")),
                                );
                              },
                              text: "Gift redeem"),*/
                          WrapPrimaryButton(
                              fontSize: 12,
                              onPressed: () {
                                if (!context.mounted) return;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const ProductQRRedeemHistoryScreen()),
                                );
                              },
                              text: "Product redeem"),
                          WrapPrimaryButton(
                              fontSize: 12,
                              onPressed: () {
                                if (!context.mounted) return;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const CashRedeemHistoryScreen()),
                                );
                              },
                              text: "Cash History"),
                          WrapPrimaryButton(
                              fontSize: 12,
                              onPressed: () {
                                if (!context.mounted) return;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const ProductRedeemPointScreen()),
                                );
                              },
                              text: "Product coupon"),
                        ],
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                    ],
                  )),
            ),
          ]));
    });
  }
}
