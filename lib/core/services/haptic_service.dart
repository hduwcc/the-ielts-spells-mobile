import 'package:flutter/services.dart';

class HapticService {
  static Future<void> light() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (_) {}
  }

  static Future<void> medium() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (_) {}
  }

  static Future<void> heavy() async {
    try {
      await HapticFeedback.heavyImpact();
    } catch (_) {}
  }

  static Future<void> selection() async {
    try {
      await HapticFeedback.selectionClick();
    } catch (_) {}
  }

  static Future<void> error() async {
    try {
      await HapticFeedback.vibrate();
    } catch (_) {}
  }

  static Future<void> comboHit(int combo) async {
    if (combo >= 10) {
      await heavy();
    } else if (combo >= 5) {
      await medium();
    } else {
      await light();
    }
  }
}
