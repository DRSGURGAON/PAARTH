import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../game/data/accessory_catalog.dart';
import '../../game/data/hero_customization_catalog.dart';
import '../../game/data/shop_catalog.dart';
import '../../game/models/accessory_option.dart';
import '../../game/models/customization_option.dart';
import '../../game/models/hero_profile.dart';
import '../../game/models/shop_item.dart';

/// Renders a [HeroProfile] as an original cartoon kid, painted in
/// vector with [HeroAvatarPainter]: scalloped hair fringe, a real face
/// (eyes, smile, blush), arms with sleeves, backpack with straps, and
/// shoes with toes — every customization choice (skin tone, hair,
/// outfit, shoes, backpack, accessory) visibly reflected.
class HeroAvatarPreview extends StatelessWidget {
  const HeroAvatarPreview({required this.profile, this.size = 220, super.key});

  final HeroProfile profile;
  final double size;

  /// Resolves a chosen option id to its color, checking the free
  /// starter [options] first and then [ShopCatalog] — a hero profile
  /// can reference a purchased shop item id that never appears in the
  /// free catalog, so both have to be searched to render correctly.
  Color _colorFor(List<CustomizationOption> options, ShopCategory shopCategory,
      String id) {
    for (final option in options) {
      if (option.id == id) return option.color;
    }
    for (final item in ShopCatalog.itemsFor(shopCategory)) {
      if (item.id == id) return item.color;
    }
    return options.first.color;
  }

  AccessoryOption _accessoryFor(String id) {
    for (final option in AccessoryCatalog.options) {
      if (option.id == id) return option;
    }
    return AccessoryCatalog.options.first;
  }

  /// Skin tones are never sold in the Shop, so this only ever needs to
  /// search the free catalog.
  Color _skinToneColorFor(String id) {
    for (final option in HeroCustomizationCatalog.skinToneOptions) {
      if (option.id == id) return option.color;
    }
    return HeroCustomizationCatalog.skinToneOptions.first.color;
  }

  @override
  Widget build(BuildContext context) {
    final accessory = _accessoryFor(profile.accessoryId);

    return SizedBox(
      width: size,
      height: size * 1.15,
      child: Stack(
        children: [
          CustomPaint(
            key: const ValueKey('hero_painter'),
            size: Size(size, size * 1.15),
            painter: HeroAvatarPainter(
              skinColor: _skinToneColorFor(profile.skinToneId),
              hairColor: _colorFor(HeroCustomizationCatalog.hairOptions,
                  ShopCategory.hair, profile.hairOptionId),
              outfitColor: _colorFor(HeroCustomizationCatalog.outfitOptions,
                  ShopCategory.outfit, profile.outfitOptionId),
              shoesColor: _colorFor(HeroCustomizationCatalog.shoesOptions,
                  ShopCategory.shoes, profile.shoesOptionId),
              backpackColor: _colorFor(HeroCustomizationCatalog.backpackOptions,
                  ShopCategory.backpack, profile.backpackOptionId),
            ),
          ),
          // Accessory — an emoji badge worn near the head.
          if (accessory.emoji != null)
            Positioned(
              top: size * 0.06,
              right: size * 0.10,
              child: Text(
                accessory.emoji!,
                semanticsLabel: accessory.label,
                style: TextStyle(fontSize: size * 0.18),
              ),
            ),
        ],
      ),
    );
  }
}

/// The vector cartoon kid. Public (rather than private) so tests can
/// assert the painted colors really are the profile's resolved colors.
class HeroAvatarPainter extends CustomPainter {
  const HeroAvatarPainter({
    required this.skinColor,
    required this.hairColor,
    required this.outfitColor,
    required this.shoesColor,
    required this.backpackColor,
  });

  final Color skinColor;
  final Color hairColor;
  final Color outfitColor;
  final Color shoesColor;
  final Color backpackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;

    Paint fill(Color color) => Paint()..color = color;
    Paint stroke(Color color, double width) => Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;

    // ── Backpack (behind everything, peeking past the torso) ──
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(cx, h * 0.585), width: w * 0.56, height: h * 0.24),
        Radius.circular(w * 0.09),
      ),
      fill(backpackColor),
    );

    // ── Legs and shoes ──
    final legPaint = stroke(skinColor, w * 0.085);
    canvas.drawLine(
        Offset(cx - w * 0.09, h * 0.72), Offset(cx - w * 0.09, h * 0.885),
        legPaint);
    canvas.drawLine(
        Offset(cx + w * 0.09, h * 0.72), Offset(cx + w * 0.09, h * 0.885),
        legPaint);
    for (final side in const [-1, 1]) {
      final x = cx + side * w * 0.09;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
              x - w * 0.065 + side * w * 0.02, h * 0.885, w * 0.15, h * 0.055),
          Radius.circular(w * 0.03),
        ),
        fill(shoesColor),
      );
    }

    // ── Arms (skin) with short sleeves, hands as round caps ──
    final armPaint = stroke(skinColor, w * 0.07);
    final sleevePaint = stroke(outfitColor, w * 0.095);
    for (final side in const [-1, 1]) {
      final shoulder = Offset(cx + side * w * 0.185, h * 0.50);
      final hand = Offset(cx + side * w * 0.285, h * 0.665);
      canvas.drawLine(shoulder, hand, armPaint);
      canvas.drawLine(
          shoulder, Offset.lerp(shoulder, hand, 0.38)!, sleevePaint);
      canvas.drawCircle(hand, w * 0.048, fill(skinColor));
    }

    // ── Torso ──
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(cx, h * 0.60), width: w * 0.44, height: h * 0.30),
        Radius.circular(w * 0.10),
      ),
      fill(outfitColor),
    );

    // ── Backpack straps over the outfit ──
    final strapPaint = stroke(backpackColor, w * 0.035);
    for (final side in const [-1, 1]) {
      canvas.drawLine(Offset(cx + side * w * 0.13, h * 0.475),
          Offset(cx + side * w * 0.055, h * 0.62), strapPaint);
    }

    // ── Ears, head ──
    final headCenter = Offset(cx, h * 0.285);
    final headRadius = w * 0.20;
    for (final side in const [-1, 1]) {
      canvas.drawCircle(
          Offset(cx + side * headRadius, h * 0.295), w * 0.045,
          fill(skinColor));
    }
    canvas.drawCircle(headCenter, headRadius, fill(skinColor));

    // ── Hair: top cap plus a scalloped fringe and side tufts ──
    final hairPaint = fill(hairColor);
    final cap = Path()
      ..addArc(
          Rect.fromCircle(center: headCenter, radius: headRadius * 1.08),
          pi, pi)
      ..close();
    canvas.drawPath(cap, hairPaint);
    for (final dx in const [-0.105, 0.0, 0.105]) {
      canvas.drawCircle(
          Offset(cx + w * dx, h * 0.215), w * 0.055, hairPaint);
    }
    for (final side in const [-1, 1]) {
      canvas.drawCircle(
          Offset(cx + side * headRadius * 0.96, h * 0.26), w * 0.05,
          hairPaint);
    }

    // ── Face: eyes with sparkle, smile, blush ──
    for (final side in const [-1, 1]) {
      final eyeCenter = Offset(cx + side * w * 0.078, h * 0.295);
      canvas.drawOval(
        Rect.fromCenter(
            center: eyeCenter, width: w * 0.075, height: w * 0.09),
        fill(Colors.white),
      );
      canvas.drawCircle(
          eyeCenter.translate(0, w * 0.012), w * 0.022,
          fill(AppColors.inkNavy));
      canvas.drawCircle(
          eyeCenter.translate(w * 0.008, w * 0.002), w * 0.007,
          fill(Colors.white));
    }
    canvas.drawArc(
      Rect.fromCenter(
          center: Offset(cx, h * 0.325), width: w * 0.13, height: w * 0.09),
      pi * 0.15,
      pi * 0.7,
      false,
      stroke(AppColors.inkNavy, w * 0.014),
    );
    for (final side in const [-1, 1]) {
      canvas.drawCircle(
          Offset(cx + side * w * 0.135, h * 0.335), w * 0.028,
          fill(AppColors.coral.withValues(alpha: 0.35)));
    }
  }

  @override
  bool shouldRepaint(HeroAvatarPainter oldDelegate) =>
      oldDelegate.skinColor != skinColor ||
      oldDelegate.hairColor != hairColor ||
      oldDelegate.outfitColor != outfitColor ||
      oldDelegate.shoesColor != shoesColor ||
      oldDelegate.backpackColor != backpackColor;
}
