import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_appbar/flutter_appbar.dart';
import 'package:flutter_scroll_bottom_sheet/flutter_bottom_sheet.dart';

/// Wraps and renders the bottom sheet content as part of the custom
/// bottom sheet system. Used internally by [BottomSheetRoute].
class BottomSheetWidget extends StatefulWidget {
  const BottomSheetWidget({
    super.key,
    required this.config,
    required this.route,
    required this.child,
  });

  /// Configuration for animation, layout, and appearance.
  final BottomSheetConfig config;

  /// The route associated with this bottom sheet.
  final BottomSheetRoute route;

  /// The content to display inside the bottom sheet.
  final Widget child;

  @override
  State<BottomSheetWidget> createState() => BottomSheetWidgetState();
}

class BottomSheetWidgetState extends State<BottomSheetWidget>
    with TickerProviderStateMixin {
  /// Controls the animation progress of the bottom sheet.
  AnimationController? _animation;

  /// The curve applied to the animation value for easing effects.
  Curve? _curve;

  /// The range of movement for the bottom sheet animation.
  /// Typically updated based on drag or snap boundaries.
  final Tween<double> _tween = Tween(begin: 0, end: 0);

  /// Returns the current animation value after applying the curve transformation.
  /// If no animation is active, returns the initial tween value.
  double get animValue =>
      _curve?.transform(_animation?.value ?? 0.0) ?? _tween.begin!;

  /// Absolute vertical expansion ratio of the bottom sheet
  /// based on the current animation value.
  ///
  /// Ranges from 0.0 to [maxFraction].
  double get absFraction => _tween.transform(animValue);

  /// Relative expansion ratio normalized to the range 0.0 to 1.0,
  /// based on the proportion of [absFraction] to [maxFraction].
  double get relFraction => maxFraction == 0 ? 0 : absFraction / maxFraction;

  /// Maximum vertical expansion ratio of the bottom sheet,
  /// relative to the screen height (0.0 to 1.0).
  /// e.g. 0.3 means up to 30% of the screen height.
  double maxFraction = 0.0;

  /// The physical pixel height available for bottom sheet
  /// expansion, regardless of the content’s intrinsic size.
  double viewportHeight = 0.0;

  void animateTo(double value, {Duration? duration, Curve? curve}) {
    _tween.begin = absFraction;
    _tween.end = value;
    _curve = curve ?? widget.config.curve;
    _animation?.dispose();
    _animation = AnimationController(
      vsync: this,
      duration: duration ?? widget.config.duration,
    );
    _animation!.addListener(() => setState(() {}));
    _animation!.forward();
  }

  void moveTo(double value) {
    setState(() {
      _tween.begin = value;
      _tween.end = value;
      _animation?.dispose();
      _animation = null;
    });
  }

  double _handleNestedScroll(
    double available,
    ScrollPosition position,
  ) {
    if (position.pixels != 0) return 0.0;

    // Convert the available scroll pixels into a relative delta
    // based on the current viewport height.
    final double delta = available / viewportHeight;

    final double prevAbsFraction = absFraction;
    final double newAbsFraction =
        (prevAbsFraction - delta).clamp(0.0, maxFraction);

    // Calculate how much was actually consumed (in fraction and pixels).
    final double consumedFraction = prevAbsFraction - newAbsFraction;
    final double consumedPixels = consumedFraction * viewportHeight;

    moveTo(newAbsFraction);

    // If fully closed, request route pop (dismiss).
    if (newAbsFraction == 0) {
      widget.route.navigator?.maybePop();
    }

    return consumedPixels;
  }

  bool _handleScrollEnd(ScrollEndNotification notification) {
    final double initFraction = widget.config.initialFraction!;

    // Determine candidate snap points based on whether
    // initial position is between max and 0.
    final List<double> snapPoints = maxFraction > initFraction
        ? [maxFraction, initFraction, 0.0] // Expanded, initial, collapsed
        : [maxFraction, 0.0]; // Expanded, collapsed

    // Pick the closest snap point to the current position.
    final double snapFraction = findNearestSnap(absFraction, snapPoints);

    // Dismiss if snapped to collapsed, otherwise animate to target.
    snapFraction == 0.0
        ? widget.route.navigator?.maybePop()
        : animateTo(snapFraction);

    return false;
  }

  /// Returns the snap point closest to the given [value].
  /// Assumes [snapPoints] are ordered from highest to lowest.
  double findNearestSnap(double value, List<double> snapPoints) {
    for (int i = 0; i < snapPoints.length - 1; i++) {
      final double upper = snapPoints[i];
      final double lower = snapPoints[i + 1];
      final double mid = (upper + lower) / 2;

      if (value >= mid) {
        return upper;
      }
    }

    return snapPoints.last;
  }

  @override
  void initState() {
    super.initState();

    // Animate fade-in to initial fraction after first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      animateTo(
        min(maxFraction, widget.config.initialFraction!),
        duration: widget.config.fadeInDuration,
        curve: widget.config.fadeInCurve,
      );
    });

    // Animate fade-out to closed state on pop request.
    widget.route.onPopRequest = () {
      animateTo(
        0.0,
        duration: widget.config.fadeOutDuration,
        curve: widget.config.fadeOutCurve,
      );
    };
  }

  @override
  void dispose() {
    _animation?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The builder for the inner content of the bottom sheet.
    final BottomSheetBuilder builder = widget.config.builder ?? _defaultBuilder;

    // The builder for the bottom sheet itself, including its styling and shape.
    final BottomSheetBuilder sheetBuilder =
        widget.config.sheetBuilder ?? _defaultSheetBuilder;

    // Retrieves the current theme from the context.
    final ThemeData theme = Theme.of(context);

    // The modal barrier color, falling back to theme or semi-transparent black.
    final Color barrierColor = widget.config.barrierColor ??
        theme.bottomSheetTheme.modalBarrierColor ??
        Color.fromRGBO(0, 0, 0, 1).withAlpha(150);

    // The fade alpha based on the relative animation fraction.
    final int barrierAlpha = ((barrierColor.a * 255) * relFraction).toInt();

    return Stack(
      children: [
        // Semi-transparent background that fades in/out with bottom sheet expansion.
        IgnorePointer(
          ignoring: true,
          child: Container(color: barrierColor.withAlpha(barrierAlpha)),
        ),

        // Bottom sheet positioned and translated vertically based on animation state.
        Positioned.fill(
          child: SafeArea(
            bottom: false,
            child: FractionalTranslation(
              translation: Offset(0, 1 - absFraction),
              child: NestedScrollConnection(
                onPostScroll: _handleNestedScroll,
                onPreScroll: _handleNestedScroll,
                child: NotificationListener<ScrollEndNotification>(
                  onNotification: _handleScrollEnd,

                  // To allow minimum size to be maintained.
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: sheetBuilder(
                      context,
                      RenderBottomSheet(
                        state: this,
                        child: PrimaryScrollController(
                          controller: NestedScrollController(),
                          child: builder(context, widget.child),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Provides the default shape for bottom sheets, used when no custom
  /// shape is specified.
  ///
  /// Ensures consistent rounded top corners across sheets.
  static ShapeBorder get _defaultShape {
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
    );
  }

  /// Builds the bottom sheet with [Material] styling, applying the theme's
  /// background color and shape. Used as the default bottom sheet wrapper.
  static Widget _defaultSheetBuilder(BuildContext context, Widget child) {
    final ThemeData theme = Theme.of(context);
    final Color? backgroundColor = theme.bottomSheetTheme.backgroundColor;
    final ShapeBorder shape = theme.bottomSheetTheme.shape ?? _defaultShape;

    return Material(
      color: backgroundColor,
      shape: shape,
      child: child,
    );
  }

  /// Wraps content in a SafeArea to prevent it from overlapping system UI
  /// elements. Used as the default builder for general content wrapping.
  static Widget _defaultBuilder(BuildContext context, Widget child) {
    return SafeArea(child: child);
  }
}

/// A widget that creates a render object for the bottom sheet,
/// linking it to the bottom sheet's state for
/// layout and animation control.
class RenderBottomSheet extends SingleChildRenderObjectWidget {
  const RenderBottomSheet({
    super.key,
    required this.state,
    required super.child,
  });

  /// The state object managing animation and layout data.
  final BottomSheetWidgetState state;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _BottomSheetRenderBox(state: state);
  }
}

/// RenderBox responsible for sizing and painting the bottom sheet content.
class _BottomSheetRenderBox extends RenderBox
    with RenderObjectWithChildMixin<RenderBox> {
  _BottomSheetRenderBox({required this.state});

  final BottomSheetWidgetState state;

  @override
  RenderBox get child => super.child!;

  @override
  void performLayout() {
    child.layout(constraints, parentUsesSize: true);

    // Define the maximum expansion ratio for the bottom sheet.
    state.maxFraction = child.size.height / constraints.maxHeight;
    state.viewportHeight = constraints.maxHeight;

    // Set size to fill the parent's constraints.
    size = Size(
      constraints.maxWidth,
      constraints.maxHeight,
    );
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    // Delegate all hit testing to the child.
    return child.hitTest(result, position: position);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    context.paintChild(child, offset);
  }
}
