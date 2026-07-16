/// Spacing constants used across the app. Never hardcode raw padding/
/// margin numbers in a screen or widget — use one of these instead.
///
/// Added on Day 6, not Day 1 — didn't want to guess spacing values
/// before any real screen existed. Waited until the Home dashboard
/// cards were actually being built, then picked values based on what
/// those cards genuinely needed.
class AppSpacing {
  AppSpacing._();

  static const double xs =
      4; // gap between a label and its value (e.g. stat tiles)
  static const double sm = 8; // gap between sibling cards in a row
  static const double md = 16; // standard screen-edge padding
  static const double lg = 24; // padding inside a card
  static const double xl =
      32; // section-level breathing room (onboarding, empty states)
  static const double cardRadius =
      20; // rounded corners, used on every bordered card app-wide
}
