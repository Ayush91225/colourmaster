import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../utils/premium_theme.dart';

class PremiumShimmer {
  static Widget card({
    double? width,
    double? height,
    BorderRadius? borderRadius,
  }) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFF0F0F0),
      highlightColor: const Color(0xFFFFFFFF),
      child: Container(
        width: width ?? double.infinity,
        height: height ?? 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ?? PremiumTheme.cardRadius,
        ),
      ),
    );
  }
  
  static Widget text({
    double? width,
    double height = 16,
    BorderRadius? borderRadius,
  }) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFF0F0F0),
      highlightColor: const Color(0xFFFFFFFF),
      child: Container(
        width: width ?? 120,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
      ),
    );
  }
  
  static Widget circle({double size = 60}) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFF0F0F0),
      highlightColor: const Color(0xFFFFFFFF),
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
  
  static Widget listTile() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFF0F0F0),
      highlightColor: const Color(0xFFFFFFFF),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 200,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  static Widget dashboardCard() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFF0F0F0),
      highlightColor: const Color(0xFFFFFFFF),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: PremiumTheme.cardRadius,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 100,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 80,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  static Widget profileHeader() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFF0F0F0),
      highlightColor: const Color(0xFFFFFFFF),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 18,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 150,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 120,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}