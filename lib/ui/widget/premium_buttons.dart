import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../utils/premium_theme.dart';

class PremiumButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double height;
  final EdgeInsetsGeometry? padding;
  
  const PremiumButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 56,
    this.padding,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onPressed != null && !isLoading;
    final Color bgColor = backgroundColor ?? PremiumTheme.primaryColor;
    final Color fgColor = textColor ?? PremiumTheme.textOnPrimary;
    
    Widget button = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: isOutlined ? null : LinearGradient(
          colors: isEnabled 
            ? [bgColor, bgColor.withOpacity(0.8)]
            : [Colors.grey.shade300, Colors.grey.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        color: isOutlined ? Colors.transparent : null,
        borderRadius: PremiumTheme.buttonRadius,
        border: isOutlined ? Border.all(
          color: isEnabled ? bgColor : Colors.grey.shade300,
          width: 2,
        ) : null,
        boxShadow: !isOutlined && isEnabled ? [
          BoxShadow(
            color: bgColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? onPressed : null,
          borderRadius: PremiumTheme.buttonRadius,
          child: Padding(
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading) ...[
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isOutlined ? bgColor : fgColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ] else if (icon != null) ...[
                  Icon(
                    icon,
                    color: isOutlined ? bgColor : fgColor,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                ],
                Text(
                  text,
                  style: PremiumTheme.textTheme.titleMedium?.copyWith(
                    color: isOutlined ? bgColor : fgColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    
    return button.animate(target: isEnabled ? 1 : 0)
      .scale(begin: const Offset(1, 1), end: const Offset(0.98, 0.98))
      .fadeIn(duration: 200.ms);
  }
}

class FloatingActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double size;
  
  const FloatingActionButton({
    Key? key,
    required this.onPressed,
    required this.icon,
    this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
    this.size = 60,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            backgroundColor ?? PremiumTheme.primaryColor,
            (backgroundColor ?? PremiumTheme.primaryColor).withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size / 2),
        boxShadow: [
          BoxShadow(
            color: (backgroundColor ?? PremiumTheme.primaryColor).withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(size / 2),
          child: Icon(
            icon,
            color: foregroundColor ?? Colors.white,
            size: size * 0.4,
          ),
        ),
      ),
    ).animate()
      .scale(delay: 300.ms, duration: 400.ms)
      .then()
      .shimmer(duration: 1000.ms, color: Colors.white.withOpacity(0.3));
  }
}

class IconButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;
  final bool showShadow;
  
  const IconButton({
    Key? key,
    required this.onPressed,
    required this.icon,
    this.tooltip,
    this.backgroundColor,
    this.iconColor,
    this.size = 48,
    this.showShadow = true,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: showShadow ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Icon(
            icon,
            color: iconColor ?? PremiumTheme.textSecondary,
            size: size * 0.5,
          ),
        ),
      ),
    ).animate().fadeIn(duration: 200.ms);
  }
}

class ChipButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isSelected;
  final IconData? icon;
  final Color? selectedColor;
  
  const ChipButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isSelected = false,
    this.icon,
    this.selectedColor,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final Color bgColor = selectedColor ?? PremiumTheme.primaryColor;
    
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? bgColor : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isSelected ? bgColor : PremiumTheme.textTertiary,
          width: 1,
        ),
        boxShadow: isSelected ? [
          BoxShadow(
            color: bgColor.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: 16,
                    color: isSelected ? Colors.white : PremiumTheme.textSecondary,
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  text,
                  style: PremiumTheme.textTheme.bodyMedium?.copyWith(
                    color: isSelected ? Colors.white : PremiumTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 200.ms);
  }
}