import 'package:flutter/material.dart';

class NavBarVisibility extends InheritedWidget {
  final bool isVisible;
  final Function(bool) updateVisibility;

  const NavBarVisibility({
    super.key,
    required this.isVisible,
    required this.updateVisibility,
    required super.child,
  });

  static NavBarVisibility of(BuildContext context) {
    final NavBarVisibility? result =
        context.dependOnInheritedWidgetOfExactType<NavBarVisibility>();
    assert(result != null, 'No NavBarVisibility found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(NavBarVisibility oldWidget) {
    return isVisible != oldWidget.isVisible;
  }
}
