import 'package:flutter/widgets.dart';

/// Adjusts the chrome rendered by descendant [PageHeader]s.
///
/// A [PageHeader] normally auto-wires a logout button into its trailing slot
/// whenever an `AuthService` is registered. That is the right affordance for a
/// full page, but not when the same header is embedded in a constrained host
/// such as a dialog, where a stray logout button is both confusing and a
/// footgun. Wrap the subtree in a [PageHeaderScope] with `showLogout: false`
/// to suppress it without threading flags through every intermediate widget.
class PageHeaderScope extends InheritedWidget {
  const PageHeaderScope({
    super.key,
    this.showLogout = true,
    required super.child,
  });

  /// Whether descendant [PageHeader]s may render a logout button.
  final bool showLogout;

  static PageHeaderScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<PageHeaderScope>();

  @override
  bool updateShouldNotify(PageHeaderScope oldWidget) =>
      oldWidget.showLogout != showLogout;
}
