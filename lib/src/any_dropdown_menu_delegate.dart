import 'package:flutter/widgets.dart';

import '../any_dropdown.dart';

/// The direction the dropdown menu opens relative to the trigger.
enum AnyDropdownPopupMenuDirection {
  /// Menu opens above the trigger.
  top,

  /// Menu opens below the trigger.
  bottom,

  /// Menu opens toward the start side (left in LTR, right in RTL).
  start,

  /// Menu opens toward the end side (right in LTR, left in RTL).
  end,
}

/// Controls how the dropdown menu is built, positioned, and animated.
///
/// Override individual methods to customize:
/// - [calculatePositionAndConstraints] — menu placement.
/// - [buildMenu] — menu content.
/// - [buildMenuDecoration] — background, border, shadow.
/// - [buildMenuTransition] — open/close animation.
abstract class AnyDropdownMenuDelegate<T, O> {
  const AnyDropdownMenuDelegate();

  /// Calculates the menu position and size constraints.
  ///
  /// Places the menu above the trigger when there is more space there,
  /// otherwise below. The menu width matches the trigger width.
  /// Returns a record with edge offsets, [popupDirection], and
  /// [BoxConstraints].
  ({
    double? left,
    double? top,
    double? right,
    double? bottom,
    AnyDropdownPopupMenuDirection popupDirection,
    BoxConstraints constraints,
  })
  calculatePositionAndConstraints(
    BuildContext context,
    RawMenuOverlayInfo overlayInfo,
  ) {
    const verticalMargin = 6.0;
    final viewPadding = MediaQuery.viewPaddingOf(context);
    double? left, top, bottom, right;
    left = overlayInfo.anchorRect.left;
    final topSpace =
        overlayInfo.anchorRect.top - 2 * verticalMargin - viewPadding.top;
    final bottomSpace =
        overlayInfo.overlaySize.height -
        overlayInfo.anchorRect.bottom -
        2 * verticalMargin -
        viewPadding.bottom;
    double maxHeight = .0;
    AnyDropdownPopupMenuDirection popupDirection = .top;
    if (topSpace > bottomSpace) {
      bottom =
          overlayInfo.overlaySize.height -
          overlayInfo.anchorRect.top +
          verticalMargin;
      maxHeight = topSpace;
      popupDirection = .top;
    } else {
      top = overlayInfo.anchorRect.bottom + verticalMargin;
      maxHeight = bottomSpace;
      popupDirection = .bottom;
    }
    final constraints = BoxConstraints(
      minWidth: overlayInfo.anchorRect.width,
      maxWidth: overlayInfo.anchorRect.width,
      minHeight: .0,
      maxHeight: maxHeight,
    );
    return (
      left: left,
      top: top,
      bottom: bottom,
      right: right,
      popupDirection: popupDirection,
      constraints: constraints,
    );
  }

  /// Builds the menu content.
  ///
  /// Use [menuController] to close the menu after selection and
  /// [setValueCallback] to update the current value.
  Widget buildMenu(
    BuildContext context,
    MenuController menuController,
    T value,
    AnyDropdownOptionState<O> optionState, {
    required AnyDropdownSetValueCallback<T> setValueCallback,
  });

  /// Wraps the menu with decorative styling.
  ///
  /// Default: white background, black border, 4px rounded corners, wrapped
  /// in a [RepaintBoundary].
  Widget buildMenuDecoration(BuildContext context, Widget menu) {
    return RepaintBoundary(
      child: Container(
        clipBehavior: .hardEdge,
        decoration: BoxDecoration(
          color: Color(0xFFFFFFFF),
          border: .all(
            color: Color(0xff000000),
            strokeAlign: BorderSide.strokeAlignOutside,
          ),
          borderRadius: .circular(4.0),
        ),
        child: menu,
      ),
    );
  }

  /// Builds the open/close animation for the menu.
  ///
  /// Combines a [SizeTransition] (first half) with a [FadeTransition]
  /// (second half) for a smooth reveal.
  Widget buildMenuTransition(
    BuildContext context,
    Animation<double> animation,
    Widget child,
  ) {
    final Animation<double> sizeAnimation = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      reverseCurve: const Interval(0.0, 1.0, curve: Curves.easeIn),
    );

    final Animation<double> slideAnimation = Tween<double>(begin: .0, end: 1.0)
        .animate(
          CurvedAnimation(
            parent: animation,
            curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
            reverseCurve: const Interval(0.0, 1.0, curve: Curves.easeIn),
          ),
        );

    return FadeTransition(
      opacity: slideAnimation,
      child: SizeTransition(
        sizeFactor: sizeAnimation,
        fixedCrossAxisSizeFactor: 1.0,
        child: child,
      ),
    );
  }
}

/// Default single-select menu.
///
/// Renders a [ListView] of [AnyDropdownItemView] items. Tapping an
/// unselected item selects it and closes the menu; tapping the already-selected
/// item is a no-op.
class AnyDropdownSingleMenuDelegate<T> extends AnyDropdownMenuDelegate<T, T> {
  const AnyDropdownSingleMenuDelegate();

  @override
  Widget buildMenu(
    BuildContext context,
    MenuController menuController,
    T value,
    AnyDropdownOptionState<T> optionState, {
    required AnyDropdownSetValueCallback<T> setValueCallback,
  }) {
    return ListView.builder(
      padding: .zero,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        final option = optionState.options[index];
        final selected = value == option;
        return AnyDropdownItemView(
          value: option,
          selected: selected,
          onTap: () {
            if (!selected) {
              setValueCallback(option);
              menuController.close();
            }
          },
        );
      },
      itemCount: optionState.options.length,
      itemExtent: 40.0,
    );
  }
}

/// Default multi-select menu.
///
/// Renders a [ListView] of toggleable [AnyDropdownItemView] items.
/// Tapping an item adds or removes it from the selection without closing
/// the menu.
class AnyDropdownMultiMenuDelegate<T>
    extends AnyDropdownMenuDelegate<Set<T>, T> {
  const AnyDropdownMultiMenuDelegate();

  @override
  Widget buildMenu(
    BuildContext context,
    MenuController menuController,
    Set<T> value,
    AnyDropdownOptionState<T> optionState, {
    required AnyDropdownSetValueCallback<Set<T>> setValueCallback,
  }) {
    return ListView.builder(
      padding: .zero,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        final option = optionState.options[index];
        final selected = value.contains(option);
        return AnyDropdownItemView(
          value: option,
          selected: selected,
          onTap: () {
            final nextValue = selected
                ? (Set.of(value)..remove(option))
                : {...value, option};
            setValueCallback(nextValue);
          },
        );
      },
      itemCount: optionState.options.length,
      itemExtent: 40.0,
    );
  }
}
