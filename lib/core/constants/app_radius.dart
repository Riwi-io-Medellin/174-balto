import 'package:flutter/material.dart';

/// Centralized corner-radius scale. Every named constant mirrors a value
/// that was already in use across the app (audited via grep) — using these
/// instead of a raw `BorderRadius.circular(N)` literal changes nothing
/// visually, it just gives every screen a single source of truth to reuse.
class AppRadius {
  AppRadius._();

  static const double r2 = 2;
  static const double r4 = 4;
  static const double r6 = 6;
  static const double r8 = 8;
  static const double r10 = 10;
  static const double r12 = 12;
  static const double r14 = 14;
  static const double r16 = 16;
  static const double r18 = 18;
  static const double r20 = 20;
  static const double r22 = 22;
  static const double r24 = 24;
  static const double r40 = 40;

  /// Fully rounded / pill shape.
  static const double pill = 999;

  static const BorderRadius radius2 = BorderRadius.all(Radius.circular(r2));
  static const BorderRadius radius4 = BorderRadius.all(Radius.circular(r4));
  static const BorderRadius radius6 = BorderRadius.all(Radius.circular(r6));
  static const BorderRadius radius8 = BorderRadius.all(Radius.circular(r8));
  static const BorderRadius radius10 = BorderRadius.all(Radius.circular(r10));
  static const BorderRadius radius12 = BorderRadius.all(Radius.circular(r12));
  static const BorderRadius radius14 = BorderRadius.all(Radius.circular(r14));
  static const BorderRadius radius16 = BorderRadius.all(Radius.circular(r16));
  static const BorderRadius radius18 = BorderRadius.all(Radius.circular(r18));
  static const BorderRadius radius20 = BorderRadius.all(Radius.circular(r20));
  static const BorderRadius radius22 = BorderRadius.all(Radius.circular(r22));
  static const BorderRadius radius24 = BorderRadius.all(Radius.circular(r24));
  static const BorderRadius radius40 = BorderRadius.all(Radius.circular(r40));
  static const BorderRadius radiusPill = BorderRadius.all(
    Radius.circular(pill),
  );
}
