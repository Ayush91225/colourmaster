import 'package:flutter/material.dart';
import '../../utils/premium_theme.dart';

/// Shared sliver app bar used across all screens.
/// - [title]: screen name
/// - [onMenuTap]: if provided, shows hamburger (main tabs). If null, shows back arrow (pushed screens).
/// - [actions]: optional trailing widgets
SliverAppBar appHeader({
  required BuildContext context,
  required String title,
  VoidCallback? onMenuTap,
  List<Widget>? actions,
}) {
  final sw = MediaQuery.of(context).size.width;
  final s = (sw / 390).clamp(0.8, 1.3);

  final Widget leading = onMenuTap != null
      ? Padding(
          padding: EdgeInsets.only(left: 8 * s),
          child: GestureDetector(
            onTap: onMenuTap,
            child: Container(
              width: 38 * s,
              height: 38 * s,
              margin: EdgeInsets.symmetric(vertical: 11 * s),
              decoration: BoxDecoration(
                color: AppTheme.black3,
                borderRadius: BorderRadius.circular(9 * s),
                border: Border.all(color: AppTheme.black5),
              ),
              child: Icon(Icons.menu_rounded,
                  size: 18 * s, color: AppTheme.white),
            ),
          ),
        )
      : IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_rounded,
              size: 18 * s, color: AppTheme.white),
        );

  return SliverAppBar(
    pinned: true,
    backgroundColor: AppTheme.black,
    elevation: 0,
    toolbarHeight: 60 * s,
    leading: leading,
    title: Text(
      title,
      style: TextStyle(
        fontSize: 17 * s,
        fontWeight: FontWeight.w700,
        color: AppTheme.white,
      ),
    ),
    centerTitle: false,
    actions: actions,
    bottom: PreferredSize(
      preferredSize: const Size.fromHeight(1),
      child: Container(
          height: 1, color: AppTheme.black5.withOpacity(0.5)),
    ),
  );
}
