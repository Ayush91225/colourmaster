import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../utils/premium_theme.dart';

class PremiumShimmer {
  static Widget card({double? width, double? height, BorderRadius? borderRadius}) {
    return Shimmer.fromColors(
      baseColor: AppTheme.black3,
      highlightColor: AppTheme.black4,
      child: Container(
        width: width ?? double.infinity,
        height: height ?? 120,
        decoration: BoxDecoration(
          color: AppTheme.black3,
          borderRadius: borderRadius ?? AppTheme.cardRadius,
        ),
      ),
    );
  }

  static Widget text({double? width, double height = 14}) {
    return Shimmer.fromColors(
      baseColor: AppTheme.black3,
      highlightColor: AppTheme.black4,
      child: Container(
        width: width ?? 120, height: height,
        decoration: BoxDecoration(
          color: AppTheme.black3,
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }

  static Widget circle({double size = 48}) {
    return Shimmer.fromColors(
      baseColor: AppTheme.black3,
      highlightColor: AppTheme.black4,
      child: Container(
        width: size, height: size,
        decoration: const BoxDecoration(color: AppTheme.black3, shape: BoxShape.circle),
      ),
    );
  }

  static Widget dashboardCard() {
    return Shimmer.fromColors(
      baseColor: AppTheme.black3,
      highlightColor: AppTheme.black4,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.black3,
          borderRadius: AppTheme.cardRadius,
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: 32, height: 32,
              decoration: BoxDecoration(color: AppTheme.black4,
                  borderRadius: BorderRadius.circular(8))),
          const SizedBox(height: 12),
          Container(width: 80, height: 20,
              decoration: BoxDecoration(color: AppTheme.black4,
                  borderRadius: BorderRadius.circular(4))),
          const SizedBox(height: 6),
          Container(width: 60, height: 12,
              decoration: BoxDecoration(color: AppTheme.black4,
                  borderRadius: BorderRadius.circular(4))),
        ]),
      ),
    );
  }

  static Widget profileHeader() {
    return Shimmer.fromColors(
      baseColor: AppTheme.black3,
      highlightColor: AppTheme.black4,
      child: Row(children: [
        Container(width: 48, height: 48,
            decoration: const BoxDecoration(color: AppTheme.black3, shape: BoxShape.circle)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: double.infinity, height: 16,
              decoration: BoxDecoration(color: AppTheme.black3,
                  borderRadius: BorderRadius.circular(6))),
          const SizedBox(height: 8),
          Container(width: 120, height: 12,
              decoration: BoxDecoration(color: AppTheme.black3,
                  borderRadius: BorderRadius.circular(6))),
        ])),
      ]),
    );
  }

  static Widget listTile() {
    return Shimmer.fromColors(
      baseColor: AppTheme.black3,
      highlightColor: AppTheme.black4,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(children: [
          Container(width: 44, height: 44,
              decoration: BoxDecoration(color: AppTheme.black3,
                  borderRadius: BorderRadius.circular(10))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(width: double.infinity, height: 14,
                decoration: BoxDecoration(color: AppTheme.black3,
                    borderRadius: BorderRadius.circular(4))),
            const SizedBox(height: 6),
            Container(width: 160, height: 12,
                decoration: BoxDecoration(color: AppTheme.black3,
                    borderRadius: BorderRadius.circular(4))),
          ])),
        ]),
      ),
    );
  }
}
