import 'package:flutter/widgets.dart';

import '../any_dropdown.dart';

/// Signature for callbacks that update the dropdown value from the menu.
typedef AnyDropdownSetValueCallback<T> = void Function(T value);

/// A dropdown widget that supports any data type.
///
/// Wires together a [RawMenuAnchor] with focus, hover, and keyboard-activation
/// handling. Subclasses only need to provide trigger and menu content.
///
/// Type parameters:
/// - [T] — the value type exposed by the widget.
/// - [O] — the raw option type stored in [AnyDropdownOptionProvider].
abstract class AnyDropdown<T, O> extends StatefulWidget {
  const AnyDropdown({
    super.key,
    required this.optionProvider,
    required this.menuDelegate,
    required this.triggerDelegate,
  });

  /// The source of available options and their loading/error state.
  final AnyDropdownOptionProvider<O> optionProvider;

  /// Controls how the menu is built, positioned, and animated.
  final AnyDropdownMenuDelegate<T, O> menuDelegate;

  /// Controls how the trigger button is built.
  final AnyDropdownTriggerDelegate<T> triggerDelegate;

  @override
  State<AnyDropdown<T, O>> createState();
}

/// Shared state for all dropdown variants.
///
/// Manages widget-state tracking, focus, the [MenuController], and the
/// open/close [AnimationController]. Subclasses implement [buildStatesTrigger]
/// and [buildPopupMenu].
abstract class _AnyDropdownState<T extends AnyDropdown> extends State<T>
    with SingleTickerProviderStateMixin {
  late WidgetStatesController _statesController;
  late FocusNode _focusNode;
  late MenuController _menuController;
  late AnimationController _animationController;

  /// Keyboard action map. Enter and Space both activate the dropdown.
  late final Map<Type, Action<Intent>> _actionMap = <Type, Action<Intent>>{
    ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: activateOnIntent),
    ButtonActivateIntent: CallbackAction<ButtonActivateIntent>(
      onInvoke: activateOnIntent,
    ),
  };

  @override
  void initState() {
    super.initState();
    _statesController = WidgetStatesController();
    _focusNode = FocusNode();
    _menuController = MenuController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animationController.addStatusListener((_) => update());
  }

  @override
  void dispose() {
    _statesController.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  /// Toggles the menu in response to keyboard activation (Enter / Space).
  @protected
  void activateOnIntent(Intent? intent) {
    if (_animationController.isForwardOrCompleted) {
      _menuController.close();
    } else {
      _menuController.open();
    }
  }

  /// Requests a rebuild. Safe to call from animation and state listeners.
  @protected
  void update() {
    if (context.mounted) {
      setState(() {});
    }
  }

  /// Called by [RawMenuAnchor] when the menu should close.
  ///
  /// Runs the reverse animation, then calls [hideOverlay] to remove the
  /// overlay from the tree.
  @protected
  void onMenuCloseRequested(VoidCallback hideOverlay) {
    if (!_animationController.isForwardOrCompleted) {
      return;
    }
    _animationController.reverse().whenComplete(hideOverlay);
  }

  /// Called by [RawMenuAnchor] when the menu should open.
  ///
  /// Shows the overlay first, then runs the forward animation.
  @protected
  void onMenuOpenRequested(Offset? position, VoidCallback showOverlay) {
    showOverlay();
    if (_animationController.isForwardOrCompleted) {
      return;
    }
    _animationController.forward();
  }

  /// Builds the trigger widget, typically wrapped with a [ValueListenableBuilder]
  /// on the states controller.
  Widget buildStatesTrigger(BuildContext context);

  /// Builds the popup menu content.
  Widget buildPopupMenu(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return RawMenuAnchor(
      controller: _menuController,
      childFocusNode: _focusNode,
      onOpenRequested: onMenuOpenRequested,
      onCloseRequested: onMenuCloseRequested,
      child: Actions(
        actions: _actionMap,
        child: Focus(
          focusNode: _focusNode,
          onFocusChange: (focus) {
            _statesController.update(WidgetState.focused, focus);
          },
          child: MouseRegion(
            onEnter: (_) => _statesController.update(WidgetState.hovered, true),
            onExit: (_) => _statesController.update(WidgetState.hovered, false),
            child: buildStatesTrigger(context),
          ),
        ),
      ),
      overlayBuilder: (context, overlayInfo) {
        Widget menu = buildPopupMenu(context);

        menu = widget.menuDelegate.buildMenuTransition(
          context,
          _animationController,
          menu,
        );

        menu = widget.menuDelegate.buildMenuDecoration(context, menu);

        final (
          :left,
          :right,
          :top,
          :bottom,
          :popupDirection,
          :constraints,
        ) = widget.menuDelegate.calculatePositionAndConstraints(
          context,
          overlayInfo,
        );
        return Positioned(
          left: left,
          right: right,
          top: top,
          bottom: bottom,
          child: Align(
            alignment: switch (popupDirection) {
              .top => .topCenter,
              .bottom => .bottomCenter,
              .start => .centerStart,
              .end => .centerEnd,
            },
            child: FocusScope(
              parentNode: _focusNode,
              child: TapRegion(
                groupId: overlayInfo.tapRegionGroupId,
                onTapOutside: (event) {
                  _menuController.close();
                },
                child: ConstrainedBox(constraints: constraints, child: menu),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// A single-select dropdown that returns one value of type [T].
///
/// ```dart
/// AnyDropdownSingle<String>(
///   value: _selected,
///   optionProvider: _provider,
///   menuDelegate: const AnyDropdownSingleMenuDelegate<String>(),
///   triggerDelegate: const AnyDropdownSingleTriggerDelegate<String>(),
///   onChanged: (v) => setState(() => _selected = v!),
/// );
/// ```
class AnyDropdownSingle<T> extends AnyDropdown<T, T> {
  const AnyDropdownSingle({
    super.key,
    required this.value,
    required super.optionProvider,
    required AnyDropdownSingleMenuDelegate<T> super.menuDelegate,
    required AnyDropdownSingleTriggerDelegate<T> super.triggerDelegate,
    this.onChanged,
  });

  /// The currently selected value.
  final T value;

  /// Called when the user selects a new value.
  ///
  /// The value may be `null` if [T] is nullable and the selection is cleared.
  final ValueChanged<T?>? onChanged;

  @override
  State<AnyDropdownSingle<T>> createState() => _AnyDropdownSingleState<T>();
}

/// State for [AnyDropdownSingle].
///
/// Maintains a local copy of the value for immediate UI updates and syncs
/// back to [AnyDropdownSingle.value] in [didUpdateWidget].
class _AnyDropdownSingleState<T>
    extends _AnyDropdownState<AnyDropdownSingle<T>> {
  late T _value;

  @override
  void initState() {
    super.initState();
    _value = widget.value;
    widget.optionProvider.addListener(update);
  }

  @override
  void didUpdateWidget(covariant AnyDropdownSingle<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _value = widget.value;
    }
    if (oldWidget.optionProvider != widget.optionProvider) {
      oldWidget.optionProvider.removeListener(update);
      widget.optionProvider.addListener(update);
    }
  }

  @override
  void dispose() {
    widget.optionProvider.removeListener(update);
    super.dispose();
  }

  void setValue(T nextValue) {
    setState(() {
      _value = nextValue;
      widget.onChanged?.call(nextValue);
    });
  }

  @override
  Widget buildStatesTrigger(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _statesController,
      builder: (context, states, child) {
        return widget.triggerDelegate.buildTrigger(
          context,
          _value,
          states,
          _menuController,
          toggleMenu: () {
            if (_animationController.isForwardOrCompleted) {
              _menuController.close();
            } else {
              _menuController.open();
            }
          },
          setValueCallback: setValue,
        );
      },
    );
  }

  @override
  Widget buildPopupMenu(BuildContext context) {
    return widget.menuDelegate.buildMenu(
      context,
      _menuController,
      _value,
      widget.optionProvider.state,
      setValueCallback: setValue,
    );
  }
}

/// A multi-select dropdown that returns a [Set] of values of type [T].
///
/// ```dart
/// AnyDropdownMulti<String>(
///   value: _selectedTags,
///   optionProvider: _provider,
///   menuDelegate: const AnyDropdownMultiMenuDelegate<String>(),
///   triggerDelegate: const AnyDropdownMultiTriggerDelegate<String>(),
///   onChanged: (v) => setState(() => _selectedTags = v),
/// );
/// ```
class AnyDropdownMulti<T> extends AnyDropdown<Set<T>, T> {
  const AnyDropdownMulti({
    super.key,
    required this.value,
    required super.optionProvider,
    required AnyDropdownMultiMenuDelegate<T> super.menuDelegate,
    required AnyDropdownMultiTriggerDelegate<T> super.triggerDelegate,
    this.onChanged,
  });

  /// The currently selected values.
  final Set<T> value;

  /// Called when the user selects or deselects values.
  final ValueChanged<Set<T>>? onChanged;

  @override
  State<AnyDropdownMulti<T>> createState() => _AnyDropdownMultiState<T>();
}

/// State for [AnyDropdownMulti].
///
/// Mirrors [_AnyDropdownSingleState] but operates on [Set]`<T>` instead of `T`.
class _AnyDropdownMultiState<T> extends _AnyDropdownState<AnyDropdownMulti<T>> {
  late Set<T> _value;

  @override
  void initState() {
    super.initState();
    _value = widget.value;
    widget.optionProvider.addListener(update);
  }

  @override
  void didUpdateWidget(covariant AnyDropdownMulti<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _value = widget.value;
    }
    if (oldWidget.optionProvider != widget.optionProvider) {
      oldWidget.optionProvider.removeListener(update);
      widget.optionProvider.addListener(update);
    }
  }

  @override
  void dispose() {
    widget.optionProvider.removeListener(update);
    super.dispose();
  }

  void setValue(Set<T> nextValue) {
    setState(() {
      _value = nextValue;
      widget.onChanged?.call(nextValue);
    });
  }

  @override
  Widget buildStatesTrigger(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _statesController,
      builder: (context, states, child) {
        return widget.triggerDelegate.buildTrigger(
          context,
          _value,
          states,
          _menuController,
          toggleMenu: () {
            if (_animationController.isForwardOrCompleted) {
              _menuController.close();
            } else {
              _menuController.open();
            }
          },
          setValueCallback: setValue,
        );
      },
    );
  }

  @override
  Widget buildPopupMenu(BuildContext context) {
    return widget.menuDelegate.buildMenu(
      context,
      _menuController,
      _value,
      widget.optionProvider.state,
      setValueCallback: setValue,
    );
  }
}
