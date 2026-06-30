import 'package:flutter/widgets.dart';

/// A single selectable item in the dropdown menu.
///
/// Renders [value] with styling driven by widget states:
/// - Selected: larger font (16px), black.
/// - Focused: light gray background.
/// - Default: smaller font (14px), gray, transparent background.
///
/// Calls [onTap] on tap, Enter, or Space.
class AnyDropdownItemView<T> extends StatefulWidget {
  const AnyDropdownItemView({
    super.key,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  /// The value this item represents.
  final T value;

  /// Whether this item is the currently selected value.
  final bool selected;

  /// Called when the user taps or activates this item.
  final VoidCallback? onTap;

  @override
  State<AnyDropdownItemView> createState() => _AnyDropdownItemViewState();
}

class _AnyDropdownItemViewState<T> extends State<AnyDropdownItemView<T>> {
  final _statesController = WidgetStatesController();

  /// Keyboard action map. Enter and Space both activate the item.
  late final Map<Type, Action<Intent>> _actionMap = <Type, Action<Intent>>{
    ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: activateOnIntent),
    ButtonActivateIntent: CallbackAction<ButtonActivateIntent>(
      onInvoke: activateOnIntent,
    ),
  };

  /// Resolves the background color from widget states.
  final _bgColor = WidgetStateColor.resolveWith((states) {
    if (states.contains(WidgetState.focused)) {
      return Color(0xFFDDDDDD);
    }
    return Color(0x00000000);
  });

  /// Resolves the text style from widget states.
  final _textStyle = WidgetStateTextStyle.resolveWith((states) {
    if (states.contains(WidgetState.selected)) {
      return TextStyle(fontSize: 16.0, height: 1.2, color: Color(0xFF000000));
    }
    return TextStyle(fontSize: 14.0, height: 1.2, color: Color(0xFF666666));
  });

  @override
  void initState() {
    super.initState();
    _statesController.addListener(_update);
    _statesController.update(WidgetState.selected, widget.selected);
  }

  @override
  void didUpdateWidget(covariant AnyDropdownItemView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected != oldWidget.selected) {
      _statesController.update(WidgetState.selected, widget.selected);
    }
  }

  @override
  void dispose() {
    _statesController.dispose();
    super.dispose();
  }

  void _update() {
    if (context.mounted) {
      setState(() {});
    }
  }

  void activateOnIntent(Intent? intent) {
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final states = _statesController.value;
    final bgColor = _bgColor.resolve(states);
    final textStyle = _textStyle.resolve(states);

    return Actions(
      actions: _actionMap,
      child: Focus(
        autofocus: widget.selected,
        skipTraversal: widget.onTap == null,
        onFocusChange: (v) {
          _statesController.update(WidgetState.focused, v);
        },
        child: Builder(
          builder: (context) {
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: widget.onTap != null
                  ? () {
                      widget.onTap!.call();
                      Focus.of(context).requestFocus();
                    }
                  : null,
              child: Container(
                height: 40.0,
                padding: .symmetric(horizontal: 12),
                alignment: .centerStart,
                color: bgColor,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(widget.value.toString(), style: textStyle),
                    ),
                    if (widget.selected)
                      CustomPaint(
                        size: .square(20.0),
                        painter: _AnyDropdownItemCheckPaint(
                          color: Color(0xFF000000),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Paints a checkmark for selected multi-select items.
///
/// The checkmark is drawn as a two-segment polyline and scales
/// proportionally to [size].
class _AnyDropdownItemCheckPaint extends CustomPainter {
  const _AnyDropdownItemCheckPaint({super.repaint, required this.color});

  /// The stroke color.
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    // Reference coordinates are designed for a 20×20 canvas.
    final scaleX = size.width / 20.0;
    final scaleY = size.height / 20.0;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(3.0 * scaleX, 10.0 * scaleY)
      ..lineTo(8.0 * scaleX, 16.0 * scaleY)
      ..lineTo(17.0 * scaleX, 3.0 * scaleY);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _AnyDropdownItemCheckPaint oldDelegate) {
    return oldDelegate.color != color;
  }
}
