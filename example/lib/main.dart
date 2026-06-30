import 'package:any_dropdown/any_dropdown.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

/// Root widget with a Material 3 theme.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AnyDropdown Examples',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ExampleHomePage(),
    );
  }
}

/// Home page showcasing all dropdown variants.
class ExampleHomePage extends StatefulWidget {
  const ExampleHomePage({super.key});

  @override
  State<ExampleHomePage> createState() => _ExampleHomePageState();
}

class _ExampleHomePageState extends State<ExampleHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AnyDropdown Examples'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _SectionHeader(title: 'Basic Usage — Static Options'),
          SizedBox(height: 8),
          _BasicStaticExample(),
          SizedBox(height: 24),
          _SectionHeader(title: 'Async Options — Simulated Network Fetch'),
          SizedBox(height: 8),
          _AsyncExample(),
          SizedBox(height: 24),
          _SectionHeader(title: 'Custom Trigger & Menu'),
          SizedBox(height: 8),
          _CustomDelegatesExample(),
          SizedBox(height: 24),
          _SectionHeader(title: 'Multi-Select — Basic'),
          SizedBox(height: 8),
          _BasicMultiExample(),
          SizedBox(height: 24),
          _SectionHeader(title: 'Multi-Select — Custom Delegates'),
          SizedBox(height: 8),
          _CustomMultiExample(),
          SizedBox(height: 24),
          _SectionHeader(title: 'Null Safety — Nullable Value'),
          SizedBox(height: 8),
          _NullableValueExample(),
        ],
      ),
    );
  }
}

/// A bold section header label.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}

// =============================================================================
// 1. Basic static options
// =============================================================================
class _BasicStaticExample extends StatefulWidget {
  const _BasicStaticExample();

  @override
  State<_BasicStaticExample> createState() => _BasicStaticExampleState();
}

class _BasicStaticExampleState extends State<_BasicStaticExample> {
  String _selectedFruit = 'Apple';

  late final AnyDropdownOptionProvider<String> _optionProvider =
      AnyDropdownOptionProvider<String>(
        optionsFetcher: () => [
          'Apple',
          'Banana',
          'Cherry',
          'Durian',
          'Elderberry',
        ],
      );

  @override
  void initState() {
    super.initState();
    _optionProvider.refreshOptions();
  }

  @override
  void dispose() {
    _optionProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Pick a fruit:'),
        const SizedBox(height: 8),
        AnyDropdownSingle<String>(
          value: _selectedFruit,
          optionProvider: _optionProvider,
          menuDelegate: const AnyDropdownSingleMenuDelegate<String>(),
          triggerDelegate: const AnyDropdownSingleTriggerDelegate<String>(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _selectedFruit = value);
            }
          },
        ),
        const SizedBox(height: 8),
        Text('Selected: $_selectedFruit'),
      ],
    );
  }
}

// =============================================================================
// 2. Async options — simulates a network fetch
// =============================================================================
class _AsyncExample extends StatefulWidget {
  const _AsyncExample();

  @override
  State<_AsyncExample> createState() => _AsyncExampleState();
}

class _AsyncExampleState extends State<_AsyncExample> {
  String _selectedCity = '';

  late final AnyDropdownOptionProvider<String> _optionProvider =
      AnyDropdownOptionProvider<String>(optionsFetcher: _fetchCities);

  /// Simulates a network delay then returns a list of cities.
  Future<List<String>> _fetchCities() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    return [
      'New York',
      'London',
      'Tokyo',
      'Paris',
      'Sydney',
      'Berlin',
      'Mumbai',
    ];
  }

  @override
  void initState() {
    super.initState();
    _optionProvider.refreshOptions();
  }

  @override
  void dispose() {
    _optionProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Pick a city (async load):'),
        const SizedBox(height: 8),
        AnyDropdownSingle<String>(
          value: _selectedCity,
          optionProvider: _optionProvider,
          menuDelegate: const AnyDropdownSingleMenuDelegate<String>(),
          triggerDelegate: const AnyDropdownSingleTriggerDelegate<String>(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _selectedCity = value);
            }
          },
        ),
        const SizedBox(height: 8),
        Text('Selected: ${_selectedCity.isEmpty ? '(none)' : _selectedCity}'),
      ],
    );
  }
}

// =============================================================================
// 3. Custom trigger & menu delegates
// =============================================================================

/// A chip-style trigger with an optional icon and animated dropdown arrow.
class ChipTriggerDelegate<T> extends AnyDropdownSingleTriggerDelegate<T> {
  const ChipTriggerDelegate({this.icon});

  /// Optional icon shown before the value text.
  final IconData? icon;

  @override
  Widget buildTrigger(
    BuildContext context,
    T value,
    Set<WidgetState> states,
    MenuController menuController, {
    required VoidCallback toggleMenu,
    required AnyDropdownSetValueCallback<T> setValueCallback,
  }) {
    final isOpen = menuController.isOpen;
    return GestureDetector(
      onTap: toggleMenu,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: isOpen ? Colors.deepPurple.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isOpen ? Colors.deepPurple : Colors.grey.shade400,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: Colors.deepPurple),
              const SizedBox(width: 6),
            ],
            Text(
              value.toString(),
              style: TextStyle(
                color: Colors.deepPurple.shade800,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 6),
            AnimatedRotation(
              turns: isOpen ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child: Icon(Icons.arrow_drop_down, color: Colors.deepPurple),
            ),
          ],
        ),
      ),
    );
  }
}

/// A Material-styled menu with ink ripple, checkmark on selected item,
/// and a shadow decoration.
class MaterialMenuDelegate<T> extends AnyDropdownSingleMenuDelegate<T> {
  const MaterialMenuDelegate();

  @override
  Widget buildMenu(
    BuildContext context,
    MenuController menuController,
    T value,
    AnyDropdownOptionState<T> optionState, {
    required AnyDropdownSetValueCallback<T> setValueCallback,
  }) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      itemCount: optionState.options.length,
      itemExtent: 44,
      itemBuilder: (context, index) {
        final option = optionState.options[index];
        final selected = value == option;
        return Material(
          type: .transparency,
          child: InkWell(
            onTap: () {
              if (!selected) {
                setValueCallback(option);
                menuController.close();
              }
            },
            child: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              color: selected ? Colors.deepPurple.shade50 : null,
              child: Row(
                children: [
                  if (selected)
                    const Icon(Icons.check, size: 18, color: Colors.deepPurple),
                  const SizedBox(width: 8),
                  Text(
                    option.toString(),
                    style: TextStyle(
                      fontWeight: selected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget buildMenuDecoration(BuildContext context, Widget menu) {
    return RepaintBoundary(
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: menu,
      ),
    );
  }
}

class _CustomDelegatesExample extends StatefulWidget {
  const _CustomDelegatesExample();

  @override
  State<_CustomDelegatesExample> createState() =>
      _CustomDelegatesExampleState();
}

class _CustomDelegatesExampleState extends State<_CustomDelegatesExample> {
  String _selectedSize = 'Medium';

  late final AnyDropdownOptionProvider<String> _optionProvider =
      AnyDropdownOptionProvider<String>(
        optionsFetcher: () => ['Small', 'Medium', 'Large', 'Extra Large'],
      );

  @override
  void initState() {
    super.initState();
    _optionProvider.refreshOptions();
  }

  @override
  void dispose() {
    _optionProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Pick a size (custom delegates):'),
        const SizedBox(height: 8),
        AnyDropdownSingle<String>(
          value: _selectedSize,
          optionProvider: _optionProvider,
          menuDelegate: const MaterialMenuDelegate<String>(),
          triggerDelegate: const ChipTriggerDelegate<String>(
            icon: Icons.straighten,
          ),
          onChanged: (value) {
            if (value != null) {
              setState(() => _selectedSize = value);
            }
          },
        ),
        const SizedBox(height: 8),
        Text('Selected: $_selectedSize'),
      ],
    );
  }
}

// =============================================================================
// 4. Basic multi-select — default delegates
// =============================================================================
class _BasicMultiExample extends StatefulWidget {
  const _BasicMultiExample();

  @override
  State<_BasicMultiExample> createState() => _BasicMultiExampleState();
}

class _BasicMultiExampleState extends State<_BasicMultiExample> {
  Set<String> _selectedTags = {'Flutter'};

  late final AnyDropdownOptionProvider<String> _optionProvider =
      AnyDropdownOptionProvider<String>(
        optionsFetcher: () => [
          'Flutter',
          'Dart',
          'React',
          'Vue',
          'Angular',
          'Svelte',
        ],
      );

  @override
  void initState() {
    super.initState();
    _optionProvider.refreshOptions();
  }

  @override
  void dispose() {
    _optionProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Pick your favorite frameworks:'),
        const SizedBox(height: 8),
        AnyDropdownMulti<String>(
          value: _selectedTags,
          optionProvider: _optionProvider,
          menuDelegate: const AnyDropdownMultiMenuDelegate<String>(),
          triggerDelegate: const AnyDropdownMultiTriggerDelegate<String>(),
          onChanged: (value) {
            setState(() => _selectedTags = value);
          },
        ),
        const SizedBox(height: 8),
        Text(
          'Selected: ${_selectedTags.isEmpty ? '(none)' : _selectedTags.join(', ')}',
        ),
      ],
    );
  }
}

// =============================================================================
// 5. Multi-select — custom chip trigger & checkbox menu
// =============================================================================

/// A multi-select trigger that renders selected items as [Chip] widgets
/// inside a horizontally scrollable row.
class ChipMultiTriggerDelegate<T> extends AnyDropdownMultiTriggerDelegate<T> {
  const ChipMultiTriggerDelegate({this.width = 260});

  /// Fixed width of the trigger; overflow scrolls horizontally.
  final double width;

  @override
  Widget buildTrigger(
    BuildContext context,
    Set<T> value,
    Set<WidgetState> states,
    MenuController menuController, {
    required VoidCallback toggleMenu,
    required AnyDropdownSetValueCallback<Set<T>> setValueCallback,
  }) {
    final isOpen = menuController.isOpen;
    return GestureDetector(
      onTap: toggleMenu,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: width,
        height: 40,
        padding: const EdgeInsets.only(left: 6, right: 2),
        decoration: BoxDecoration(
          color: isOpen ? Colors.deepPurple.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isOpen ? Colors.deepPurple : Colors.grey.shade400,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: value.isEmpty
                    ? Text(
                        'Select items...',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 14,
                        ),
                      )
                    : Row(
                        children: value
                            .map(
                              (item) => Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: Chip(
                                  label: Text(
                                    item.toString(),
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  deleteIcon: const Icon(Icons.close, size: 16),
                                  onDeleted: () {
                                    final nextValue = Set.of(value)
                                      ..remove(item);
                                    setValueCallback(nextValue);
                                  },
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: VisualDensity.compact,
                                  padding: EdgeInsets.zero,
                                  labelPadding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
              ),
            ),
            Icon(
              isOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
              color: Colors.deepPurple,
            ),
          ],
        ),
      ),
    );
  }
}

/// A multi-select menu with checkboxes, a Select All button, and a Clear
/// button.
///
/// The menu is constrained to a minimum width ([_kMinMenuWidth]) so the
/// action buttons fit comfortably.
class CheckboxMultiMenuDelegate<T> extends AnyDropdownMultiMenuDelegate<T> {
  const CheckboxMultiMenuDelegate();

  static const double _kMinMenuWidth = 200.0;

  @override
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
    final result = super.calculatePositionAndConstraints(context, overlayInfo);
    final widerConstraints = BoxConstraints(
      minWidth: result.constraints.minWidth < _kMinMenuWidth
          ? _kMinMenuWidth
          : result.constraints.minWidth,
      maxWidth: result.constraints.maxWidth < _kMinMenuWidth
          ? _kMinMenuWidth
          : result.constraints.maxWidth,
      minHeight: result.constraints.minHeight,
      maxHeight: result.constraints.maxHeight,
    );
    return (
      left: result.left,
      top: result.top,
      right: result.right,
      bottom: result.bottom,
      popupDirection: result.popupDirection,
      constraints: widerConstraints,
    );
  }

  @override
  Widget buildMenu(
    BuildContext context,
    MenuController menuController,
    Set<T> value,
    AnyDropdownOptionState<T> optionState, {
    required AnyDropdownSetValueCallback<Set<T>> setValueCallback,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          fit: FlexFit.loose,
          child: ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemCount: optionState.options.length,
            itemExtent: 44,
            itemBuilder: (context, index) {
              final option = optionState.options[index];
              final selected = value.contains(option);
              return Material(
                type: MaterialType.transparency,
                child: InkWell(
                  onTap: () {
                    final nextValue = selected
                        ? (Set.of(value)..remove(option))
                        : {...value, option};
                    setValueCallback(nextValue);
                  },
                  child: Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 22,
                          height: 22,
                          child: Checkbox(
                            value: selected,
                            onChanged: (_) {
                              final nextValue = selected
                                  ? (Set.of(value)..remove(option))
                                  : {...value, option};
                              setValueCallback(nextValue);
                            },
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(option.toString()),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () {
                  final all = optionState.options.toSet();
                  setValueCallback(all);
                },
                child: const Text('Select All'),
              ),
              TextButton(
                onPressed: () {
                  setValueCallback(const {});
                  menuController.close();
                },
                child: const Text('Clear'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget buildMenuDecoration(BuildContext context, Widget menu) {
    return RepaintBoundary(
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: menu,
      ),
    );
  }
}

class _CustomMultiExample extends StatefulWidget {
  const _CustomMultiExample();

  @override
  State<_CustomMultiExample> createState() => _CustomMultiExampleState();
}

class _CustomMultiExampleState extends State<_CustomMultiExample> {
  Set<String> _selectedSkills = {'Dart'};

  late final AnyDropdownOptionProvider<String> _optionProvider =
      AnyDropdownOptionProvider<String>(
        optionsFetcher: () => [
          'Dart',
          'Flutter',
          'Swift',
          'Kotlin',
          'Rust',
          'Python',
          'TypeScript',
        ],
      );

  @override
  void initState() {
    super.initState();
    _optionProvider.refreshOptions();
  }

  @override
  void dispose() {
    _optionProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Pick your skills (custom delegates):'),
        const SizedBox(height: 8),
        AnyDropdownMulti<String>(
          value: _selectedSkills,
          optionProvider: _optionProvider,
          menuDelegate: const CheckboxMultiMenuDelegate<String>(),
          triggerDelegate: const ChipMultiTriggerDelegate<String>(),
          onChanged: (value) {
            setState(() => _selectedSkills = value);
          },
        ),
        const SizedBox(height: 8),
        Text(
          'Selected: ${_selectedSkills.isEmpty ? '(none)' : _selectedSkills.join(', ')}',
        ),
      ],
    );
  }
}

// =============================================================================
// 6. Nullable value — shows optional (nullable) selection
// =============================================================================
class _NullableValueExample extends StatefulWidget {
  const _NullableValueExample();

  @override
  State<_NullableValueExample> createState() => _NullableValueExampleState();
}

class _NullableValueExampleState extends State<_NullableValueExample> {
  String? _selectedColor;

  late final AnyDropdownOptionProvider<String> _optionProvider =
      AnyDropdownOptionProvider<String>(
        optionsFetcher: () => ['Red', 'Green', 'Blue', 'Yellow', 'Purple'],
      );

  @override
  void initState() {
    super.initState();
    _optionProvider.refreshOptions();
  }

  @override
  void dispose() {
    _optionProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Pick a color (nullable — initially unselected):'),
        const SizedBox(height: 8),
        AnyDropdownSingle<String?>(
          value: _selectedColor,
          optionProvider: AnyDropdownOptionProvider<String?>(
            optionsFetcher: () => ['Red', 'Green', 'Blue', 'Yellow', 'Purple'],
          )..refreshOptions(),
          menuDelegate: const AnyDropdownSingleMenuDelegate<String?>(),
          triggerDelegate: const _NullableTriggerDelegate(),
          onChanged: (value) {
            setState(() => _selectedColor = value);
          },
        ),
        const SizedBox(height: 8),
        Text('Selected: ${_selectedColor ?? '(none)'}'),
      ],
    );
  }
}

/// A trigger that shows a placeholder when the value is `null`.
class _NullableTriggerDelegate
    extends AnyDropdownSingleTriggerDelegate<String?> {
  const _NullableTriggerDelegate();

  @override
  Widget buildTrigger(
    BuildContext context,
    String? value,
    Set<WidgetState> states,
    MenuController menuController, {
    required VoidCallback toggleMenu,
    required AnyDropdownSetValueCallback<String?> setValueCallback,
  }) {
    return GestureDetector(
      onTap: toggleMenu,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          border: Border.all(
            color: const Color(0xFF000000),
            strokeAlign: BorderSide.strokeAlignOutside,
          ),
          borderRadius: BorderRadius.circular(4.0),
        ),
        height: 40.0,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: .centerStart,
        child: Text(
          value ?? 'Select a color...',
          style: TextStyle(
            color: value == null ? Colors.grey.shade500 : Colors.black,
          ),
        ),
      ),
    );
  }
}
