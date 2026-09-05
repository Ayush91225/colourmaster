import 'package:flutter/material.dart';
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

  const PremiumButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 48,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;
    final bg = backgroundColor ?? AppTheme.orange;
    final fg = textColor ?? AppTheme.white;

    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: isOutlined
            ? Colors.transparent
            : (enabled ? bg : AppTheme.black3),
        borderRadius: AppTheme.buttonRadius,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: AppTheme.buttonRadius,
          child: Container(
            alignment: Alignment.center,
            decoration: isOutlined
                ? BoxDecoration(
                    borderRadius: AppTheme.buttonRadius,
                    border: Border.all(
                      color: enabled ? bg : const Color(0xFFD1D5DB),
                      width: 1.5,
                    ),
                  )
                : null,
            child: isLoading
                ? SizedBox(
                    width: 18, height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(
                          isOutlined ? bg : fg),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, size: 16,
                            color: isOutlined
                                ? (enabled ? bg : const Color(0xFFD1D5DB))
                                : fg),
                        const SizedBox(width: 7),
                      ],
                      Text(text,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isOutlined
                                ? (enabled ? bg : const Color(0xFFD1D5DB))
                                : (enabled ? fg : AppTheme.textMuted),
                          )),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

// ── FAB ────────────────────────────────────────────────────────────────────────
class FloatingActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double size;

  const FloatingActionButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
    this.size = 52,
  });

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? AppTheme.accent;
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size, height: size,
        decoration: BoxDecoration(
          color: bg, shape: BoxShape.circle,
          boxShadow: [BoxShadow(
            color: bg.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Icon(icon, color: foregroundColor ?? Colors.white, size: size * 0.42),
      ),
    );
  }
}

// ── Icon button ────────────────────────────────────────────────────────────────
class IconButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;
  final bool showShadow;

  const IconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.tooltip,
    this.backgroundColor,
    this.iconColor,
    this.size = 40,
    this.showShadow = false,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onPressed,
    child: Container(
      width: size, height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: showShadow ? const [AppTheme.cardShadow] : null,
      ),
      child: Icon(icon,
          color: iconColor ?? AppTheme.textSecondary, size: size * 0.45),
    ),
  );
}

// ── Chip button ────────────────────────────────────────────────────────────────
class ChipButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isSelected;
  final IconData? icon;
  final Color? selectedColor;

  const ChipButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isSelected = false,
    this.icon,
    this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = selectedColor ?? AppTheme.navy;
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? color : AppTheme.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 13,
                  color: isSelected ? Colors.white : AppTheme.textSecondary),
              const SizedBox(width: 5),
            ],
            Text(text,
                style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : AppTheme.textSecondary,
                )),
          ],
        ),
      ),
    );
  }
}
