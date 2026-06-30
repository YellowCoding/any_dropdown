/// A customizable dropdown widget library for Flutter.
///
/// Supports single-select, multi-select, async option loading, and fully
/// customizable trigger and menu delegates.
///
/// ## Quick start
/// ```dart
/// AnyDropdownSingle<String>(
///   value: _selectedFruit,
///   optionProvider: AnyDropdownOptionProvider<String>(
///     optionsFetcher: () => ['Apple', 'Banana', 'Cherry'],
///   )..refreshOptions(),
///   menuDelegate: const AnyDropdownSingleMenuDelegate<String>(),
///   triggerDelegate: const AnyDropdownSingleTriggerDelegate<String>(),
///   onChanged: (value) => setState(() => _selectedFruit = value!),
/// );
/// ```
library;

export 'src/any_dropdown.dart';
export 'src/any_dropdown_item_view.dart';
export 'src/any_dropdown_menu_delegate.dart';
export 'src/any_dropdown_option_provider.dart';
export 'src/any_dropdown_trigger_delegate.dart';
