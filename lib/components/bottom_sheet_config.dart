import 'package:flutter/widgets.dart';

/// Signature for a function that builds a bottom sheet container
/// using the given [context] and embedded [child] widget.
///
/// Can be used to apply consistent styling, such as background color,
/// shape, padding, or other layout-related customizations.
typedef BottomSheetBuilder = Widget Function(
  BuildContext context,
  Widget child,
);

/// Configuration options for customizing the appearance and behavior
/// of a bottom sheet, including animation and layout properties.
class BottomSheetConfig {
  const BottomSheetConfig({
    this.duration,
    this.curve,
    this.fadeInDuration,
    this.fadeInCurve,
    this.fadeOutDuration,
    this.fadeOutCurve,
    this.initialFraction,
    this.barrierColor,
    this.sheetBuilder,
    this.builder,
  });

  /// The shared duration for various bottom sheet animations,
  /// such as snapping, resizing, or dismissing transitions.
  final Duration? duration;

  /// The common animation curve applied throughout bottom sheet
  /// animations, including snapping and transition effects.
  final Curve? curve;

  /// The duration of the fade-in effect when the bottom sheet
  /// first appears.
  final Duration? fadeInDuration;

  /// The animation curve used during the initial fade-in.
  final Curve? fadeInCurve;

  /// The duration of the fade-out effect when the bottom sheet
  /// is dismissed.
  final Duration? fadeOutDuration;

  /// The animation curve used during the fade-out transition.
  final Curve? fadeOutCurve;

  /// The initial visible fraction of the bottom sheet when shown.
  final double? initialFraction;

  /// The color of the modal barrier behind the bottom sheet.
  /// If null, defaults to transparent or system default.
  final Color? barrierColor;

  /// A builder that builds the card-style container inside the bottom
  /// sheet, applying consistent styling, shape, and background.
  final BottomSheetBuilder? sheetBuilder;

  /// A builder that builds the inner content of the bottom sheet.
  final BottomSheetBuilder? builder;

  /// Returns a new config where any null values are replaced
  /// by the corresponding values from [other].
  BottomSheetConfig coptyWith(BottomSheetConfig? other) {
    if (other == null) return this;
    return BottomSheetConfig(
      duration: other.duration ?? duration,
      curve: other.curve ?? curve,
      fadeInDuration: other.fadeInDuration ?? fadeInDuration,
      fadeInCurve: other.fadeInCurve ?? fadeInCurve,
      fadeOutDuration: other.fadeOutDuration ?? fadeOutDuration,
      fadeOutCurve: other.fadeOutCurve ?? fadeOutCurve,
      initialFraction: other.initialFraction ?? initialFraction,
      barrierColor: other.barrierColor ?? barrierColor,
      sheetBuilder: other.sheetBuilder ?? sheetBuilder,
      builder: other.builder ?? builder,
    );
  }
}
