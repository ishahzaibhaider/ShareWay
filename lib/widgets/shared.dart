import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

// ── Back Button ────────────────────────────────────────────────────────────
class SwBackButton extends StatelessWidget {
  final Color? background;
  final Color? iconColor;
  const SwBackButton({super.key, this.background, this.iconColor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: 42,
        height: 42,
        decoration: AppTheme.card3D.copyWith(
          color: background ?? AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 16,
          color: iconColor ?? AppTheme.textMain,
        ),
      ),
    );
  }
}

// ── 3D Icon Container ──────────────────────────────────────────────────────
class Sw3DIcon extends StatelessWidget {
  final IconData icon;
  final Color baseColor;
  final double size;
  const Sw3DIcon({super.key, required this.icon, required this.baseColor, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size * 1.8,
      height: size * 1.8,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            baseColor.withOpacity(0.8),
            baseColor,
          ],
        ),
        borderRadius: BorderRadius.circular(size / 1.5),
        boxShadow: [
          BoxShadow(
            color: baseColor.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.2),
            blurRadius: 1,
            offset: const Offset(-2, -2),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: size),
    );
  }
}

// ── 3D Glass Card ──────────────────────────────────────────────────────────
class Sw3DCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  const Sw3DCard({super.key, required this.child, this.padding, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(16),
        decoration: AppTheme.card3D,
        child: child,
      ),
    );
  }
}

// ── Tag / Chip ─────────────────────────────────────────────────────────────
class SwTag extends StatelessWidget {
  final String label;
  final Color? bg;
  final Color? fg;
  const SwTag(this.label, {super.key, this.bg, this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg ?? AppTheme.sand,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: (bg ?? AppTheme.sand).withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        label,
        style: GoogleFonts.outfit(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: fg ?? AppTheme.brandGreen,
        ),
      ),
    );
  }
}

// ── Star Rating Row ────────────────────────────────────────────────────────
class SwStarRating extends StatelessWidget {
  final double rating;
  final int? totalRatings;
  const SwStarRating(this.rating, {super.key, this.totalRatings});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star_rounded, size: 14, color: AppTheme.accent),
        const SizedBox(width: 3),
        Text(
          rating.toStringAsFixed(1),
          style: GoogleFonts.outfit(
            fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textMain,
          ),
        ),
        if (totalRatings != null) ...[
          const SizedBox(width: 3),
          Text(
            '($totalRatings)',
            style: GoogleFonts.outfit(fontSize: 11, color: AppTheme.textSub),
          ),
        ],
      ],
    );
  }
}

// ── Section Header ─────────────────────────────────────────────────────────
class SwSectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  const SwSectionHeader(this.title, {super.key, this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: AppTheme.titleL),
        const Spacer(),
        if (action != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              action!,
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppTheme.brandGreen,
              ),
            ),
          ),
      ],
    );
  }
}

// ── Info Stat Box ──────────────────────────────────────────────────────────
class SwStatBox extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const SwStatBox({super.key, required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AppTheme.sandDecoration,
      child: Column(
        children: [
          Icon(icon, color: AppTheme.brandEspresso, size: 22),
          const SizedBox(height: 6),
          Text(value, style: AppTheme.titleM),
          const SizedBox(height: 2),
          Text(label, style: AppTheme.caption),
        ],
      ),
    );
  }
}

// ── Form Field Wrapper ─────────────────────────────────────────────────────
class SwFormField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? suffix;
  final String? initialValue;

  const SwFormField({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.suffix,
    this.initialValue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 12, fontWeight: FontWeight.w700,
            color: AppTheme.textMain, letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          initialValue: initialValue,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 18, color: AppTheme.textSub),
            suffixIcon: suffix,
          ),
        ),
      ],
    );
  }
}
