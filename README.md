A customizable dropdown widget for Flutter that supports any data type, single-select
and multi-select modes, asynchronous option loading, and fully customizable trigger
and menu delegates.

## Features

- **Single-select** — `AnyDropdownSingle<T>` for picking one value.
- **Multi-select** — `AnyDropdownMulti<T>` for picking a `Set<T>` of values.
- **Any data type** — works with `String`, `int`, enums, or custom classes.
- **Nullable support** — nullable type parameters allow unselected states.
- **Async options** — fetch options from a network or database with built-in loading
  and error tracking.
- **Fully customizable** — swap trigger and menu delegates to match your design system.
- **Keyboard accessible** — Enter and Space activate the dropdown; arrow keys navigate
  items.
- **Focus and hover** — widget-state-driven styling for focused and hovered items.

## Usage

### Basic single-select

```dart
String _selected = 'Apple';

late final _provider = AnyDropdownOptionProvider<String>(
  optionsFetcher: () => ['Apple', 'Banana', 'Cherry'],
)..refreshOptions();

AnyDropdownSingle<String>(
  value: _selected,
  optionProvider: _provider,
  menuDelegate: const AnyDropdownSingleMenuDelegate<String>(),
  triggerDelegate: const AnyDropdownSingleTriggerDelegate<String>(),
  onChanged: (value) => setState(() => _selected = value!),
);
```

### Multi-select

```dart
Set<String> _selected = {'Flutter'};

late final _provider = AnyDropdownOptionProvider<String>(
  optionsFetcher: () => ['Flutter', 'Dart', 'React', 'Vue'],
)..refreshOptions();

AnyDropdownMulti<String>(
  value: _selected,
  optionProvider: _provider,
  menuDelegate: const AnyDropdownMultiMenuDelegate<String>(),
  triggerDelegate: const AnyDropdownMultiTriggerDelegate<String>(),
  onChanged: (value) => setState(() => _selected = value),
);
```

### Async options

```dart
late final _provider = AnyDropdownOptionProvider<String>(
  optionsFetcher: () async {
    await Future.delayed(const Duration(seconds: 1));
    return ['New York', 'London', 'Tokyo'];
  },
)..refreshOptions();
```

### Custom trigger and menu

Implement `AnyDropdownTriggerDelegate<T>` and `AnyDropdownMenuDelegate<T, O>`
(or extend the default delegates) to build your own trigger and menu widgets.
See the [example app](https://github.com/YaolongChen/any_dropdown/tree/main/example)
for a chip-style trigger and a Material-styled menu with ink ripple and checkboxes.

## Additional information

- [Example app](https://github.com/YaolongChen/any_dropdown/tree/main/example) —
  run the example to see all 6 usage scenarios.
- [GitHub repository](https://github.com/YaolongChen/any_dropdown) —
  report issues or contribute.
- [pub.dev package](https://pub.dev/packages/any_dropdown) —
  latest version and API reference.
