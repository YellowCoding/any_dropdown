import 'package:flutter/widgets.dart';

import 'any_dropdown.dart';

/// Builds the trigger widget that opens and closes the dropdown menu.
///
/// Override [buildTrigger] to customize the trigger's appearance. The method
/// receives the current [WidgetState]s and callbacks for toggling the menu
/// and updating the selected value.
abstract class AnyDropdownTriggerDelegate<T> {
  const AnyDropdownTriggerDelegate();

  /// Builds the widget the user interacts with to open and close the dropdown.
  ///
  /// [value] is the currently selected value (or values, for multi-select).
  /// [states] exposes the current [WidgetState]s such as focused and hovered.
  /// [menuController] provides access to [MenuController.isOpen] so the
  /// trigger can adapt its appearance when the menu is open.
  ///
  /// Call [toggleMenu] to open or close the menu. Call [setValueCallback] to
  /// update the selection programmatically from within the trigger.
  Widget buildTrigger(
    BuildContext context,
    T value,
    Set<WidgetState> states,
    MenuController menuController, {
    required VoidCallback toggleMenu,
    required AnyDropdownSetValueCallback<T> setValueCallback,
  });
}

/// Default single-select trigger.
///
/// A white bordered container (40px height, 4px rounded corners) with the
/// string representation of the value left-aligned.
class AnyDropdownSingleTriggerDelegate<T>
    extends AnyDropdownTriggerDelegate<T> {
  const AnyDropdownSingleTriggerDelegate();

  @override
  Widget buildTrigger(
    BuildContext context,
    T value,
    Set<WidgetState> states,
    MenuController menuController, {
    required VoidCallback toggleMenu,
    required AnyDropdownSetValueCallback<T> setValueCallback,
  }) {
    return GestureDetector(
      onTap: toggleMenu,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFFFFFFFF),
          border: .all(
            color: Color(0xFF000000),
            strokeAlign: BorderSide.strokeAlignOutside,
          ),
          borderRadius: .circular(4.0),
        ),
        height: 40.0,
        padding: .symmetric(horizontal: 12),
        alignment: .centerStart,
        child: Text(value.toString()),
      ),
    );
  }
}

/// Default multi-select trigger.
///
/// Same visual style as [AnyDropdownSingleTriggerDelegate]. Joins multiple
/// selected values with a comma via [Iterable.join].
class AnyDropdownMultiTriggerDelegate<T>
    extends AnyDropdownTriggerDelegate<Set<T>> {
  const AnyDropdownMultiTriggerDelegate();

  @override
  Widget buildTrigger(
    BuildContext context,
    Set<T> value,
    Set<WidgetState> states,
    MenuController menuController, {
    required VoidCallback toggleMenu,
    required AnyDropdownSetValueCallback<Set<T>> setValueCallback,
  }) {
    return GestureDetector(
      onTap: toggleMenu,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFFFFFFFF),
          border: .all(
            color: Color(0xFF000000),
            strokeAlign: BorderSide.strokeAlignOutside,
          ),
          borderRadius: .circular(4.0),
        ),
        height: 40.0,
        padding: .symmetric(horizontal: 12),
        alignment: .centerStart,
        child: Text(value.join(',')),
      ),
    );
  }
}
