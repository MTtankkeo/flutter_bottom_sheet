import 'package:flutter/widgets.dart';
import 'package:flutter_bottom_sheet/flutter_bottom_sheet.dart';

/// A simple utility class to manage bottom sheets throughout the app.
///
/// Allows opening a bottom sheet with custom content, automatically applying
/// any globally set configuration for consistent styling and behavior.
///
/// Provides a method to close the currently open bottom sheet easily.
class BottomSheet {
  /// Optional global configuration that applies to all bottom sheets opened
  /// via this utility, overriding default animation and style settings.
  static BottomSheetConfig? config;

  /// Opens a bottom sheet by pushing a [BottomSheetRoute] onto the navigation stack.
  void open(BuildContext context, Widget body) {
    Navigator.push(context, BottomSheetRoute(body: body, config: config));
  }

  /// Closes the currently displayed bottom sheet by popping its route.
  /// This assumes that a bottom sheet route is currently active.
  static void close(BuildContext context) {
    Navigator.pop(context);
  }
}
