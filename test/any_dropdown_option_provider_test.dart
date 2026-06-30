import 'package:any_dropdown/any_dropdown.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Async fetcher', () {
    test('Refresh success', () async {
      final provider = AnyDropdownOptionProvider<int>(
        optionsFetcher: () async {
          await Future.delayed(Duration(seconds: 1));
          return List.generate(10, (index) => index);
        },
      );
      expect(provider.state.loading, false);
      expect(provider.state.options, []);
      expect(provider.state.error, null);
      await provider.refreshOptions();
      expect(provider.state.loading, false);
      expect(provider.state.options, List.generate(10, (index) => index));
      expect(provider.state.error, null);
    });

    test('Refresh error', () async {
      final provider = AnyDropdownOptionProvider<int>(
        optionsFetcher: () async {
          await Future.delayed(Duration(seconds: 1));
          throw Exception();
        },
      );
      expect(provider.state.loading, false);
      expect(provider.state.options, []);
      expect(provider.state.error, null);
      await provider.refreshOptions();
      expect(provider.state.loading, false);
      expect(provider.state.options, []);
      expect(provider.state.error, isA<Exception>());
    });
  });

  group('Sync fetcher', () {
    test('Refresh success', () async {
      final provider = AnyDropdownOptionProvider<int>(
        optionsFetcher: () {
          return List.generate(10, (index) => index);
        },
      );
      expect(provider.state.loading, false);
      expect(provider.state.options, []);
      expect(provider.state.error, null);
      provider.refreshOptions();
      expect(provider.state.loading, false);
      expect(provider.state.options, List.generate(10, (index) => index));
      expect(provider.state.error, null);
    });

    test('Refresh error', () async {
      final provider = AnyDropdownOptionProvider<int>(
        optionsFetcher: () {
          throw Exception();
        },
      );
      expect(provider.state.loading, false);
      expect(provider.state.options, []);
      expect(provider.state.error, null);
      provider.refreshOptions();
      expect(provider.state.loading, false);
      expect(provider.state.options, []);
      expect(provider.state.error, isA<Exception>());
    });
  });
}
