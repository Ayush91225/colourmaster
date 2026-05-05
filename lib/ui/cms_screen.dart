// ignore_for_file: depend_on_referenced_packages
import 'package:colourmaster/ui/widget/loader.dart';
import 'package:colourmaster/ui/widget/side_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';

import '../provider/user_provider.dart';
import '../utils/style/color_constants.dart';

class CMSScreen extends StatefulWidget {
  const CMSScreen({super.key});
  @override
  State<StatefulWidget> createState() => _CMSScreenState();
}

class _CMSScreenState extends State<CMSScreen> {
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: ColorConstants.bodyBackgroundColor,
        drawer: sideBar(context),
        body: Consumer<UserProvider>(
            builder: (context, UserProvider userProvider, child) {
          return LoadingOverlay(
            isLoading: userProvider.isLoading,
            color: ColorConstants.loadingBackgroundColor
                .withValues(alpha: 0.7), // 50% opacity
            progressIndicator: loadingIndicator(),
            child: SafeArea(
                child: Stack(
              children: [
                Column(children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        child: Container(
                            padding: const EdgeInsets.only(
                                left: 20, top: 10, right: 20, bottom: 10),
                            color: Colors.transparent,
                            child: Image.asset(
                                height: 30,
                                width: 30,
                                'assets/images/menu.png')),
                        onTap: () {
                          debugPrint("click");
                          Scaffold.of(context).openDrawer();
                        },
                      ),
                      Align(
                          alignment: Alignment.center,
                          child: SvgPicture.asset(
                              height: 18, width: 20, 'assets/svg/logo.svg')),
                    ],
                  ),
                  Expanded(
                      child: SingleChildScrollView(
                          controller: scrollController,
                          scrollDirection: Axis.vertical,
                          child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 10.0, right: 10.0, top: 0, bottom: 0),
                              child: Column(children: [])))),
                ]),
              ],
            )),
          );
        }));
  }
}
