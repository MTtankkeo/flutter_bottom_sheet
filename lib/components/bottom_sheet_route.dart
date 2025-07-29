import 'package:flutter/widgets.dart';
import 'package:flutter_bottom_sheet/flutter_bottom_sheet.dart';

/// A custom [PopupRoute] that presents a bottom sheet with
/// configurable animation, layout, and interaction behaviors.
///
/// ### Example
/// ```dart
/// Navigator.push(
///   context,
///   BottomSheetRoute(...)
/// );
/// ```
class BottomSheetRoute extends PopupRoute {
  BottomSheetRoute({
    required this.body,
    BottomSheetConfig? config,
  }) {
    _config = defaultConfig.coptyWith(config);
  }

  /// The main content widget of the bottom sheet.
  final Widget body;

  /// Internal config object resolved by merging with [defaultConfig].
  late BottomSheetConfig _config;

  /// Called when a pop (dismiss) is requested.
  VoidCallback? onPopRequest;

  @override
  Color? get barrierColor => Color.fromRGBO(0, 0, 0, 0);

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => null;

  @override
  Duration get transitionDuration => _config.duration!;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return BottomSheetWidget(config: _config, route: this, child: body);
  }

  @override
  bool didPop(result) {
    assert(onPopRequest != null);
    onPopRequest?.call();
    return super.didPop(result);
  }

  /// Default config applied when no user config is provided.
  static BottomSheetConfig get defaultConfig {
    return BottomSheetConfig(
      initialFraction: 0.5,
      duration: Duration(milliseconds: 300),
      curve: Cubic(.4, 0, .4, 1),
    );
  }
}
