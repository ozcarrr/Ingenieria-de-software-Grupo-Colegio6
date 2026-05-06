import 'package:flutter/material.dart';

import 'kairos_palette.dart';

// Aliases kept for backward compatibility with existing widgets.
class AppColors {
  AppColors._();

  static const Color primary        = KairosPalette.primary;
  static const Color primaryLight   = KairosPalette.muted;
  static const Color background     = KairosPalette.background;
  static const Color surface        = KairosPalette.card;
  static const Color textPrimary    = KairosPalette.foreground;
  static const Color textSecondary  = KairosPalette.secondary;
  static const Color textTertiary   = Color(0xFF94A3B8);
  static const Color divider        = KairosPalette.border;
  static const Color chipBorder     = KairosPalette.border;
  static const Color tipAmber       = Color(0xFFFFF8E1);
}
