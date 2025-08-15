import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_persist_state/flutter_persist_state.dart';

// Mock storage adapter for testing
class MockStorageAdapter implements StorageAdapter {
  final Map<String, dynamic> _storage = {};

  @override
  Future<void> save(String key, dynamic value) async {
    _storage[key] = value;
  }

  @override
  Future<dynamic> load(String key) async {
    return _storage[key];
  }

  @override
  Future<void> delete(String key) async {
    _storage.remove(key);
  }

  @override
  Future<bool> containsKey(String key) async {
    return _storage.containsKey(key);
  }

  @override
  Future<void> clear() async {
    _storage.clear();
  }
}

void main() {
  group('PersistState', () {
    late MockStorageAdapter mockStorage;

    setUp(() {
      mockStorage = MockStorageAdapter();
    });

    test('should initialize with default value', () {
      final state = PersistState<int>(
        key: 'test',
        defaultValue: 42,
        storage: mockStorage,
      );

      expect(state.value, equals(42));
    });

    test('should load value from storage on initialize', () async {
      await mockStorage.save('test', 100);

      final state = PersistState<int>(
        key: 'test',
        defaultValue: 42,
        storage: mockStorage,
      );

      await state.initialize();
      expect(state.value, equals(100));
    });

    test('should use default value when storage is empty', () async {
      final state = PersistState<int>(
        key: 'test',
        defaultValue: 42,
        storage: mockStorage,
      );

      await state.initialize();
      expect(state.value, equals(42));
    });

    test('should set new value', () async {
      final state = PersistState<int>(
        key: 'test',
        defaultValue: 42,
        storage: mockStorage,
      );

      await state.set(100);
      expect(state.value, equals(100));
    });

    test('should update value using function', () async {
      final state = PersistState<int>(
        key: 'test',
        defaultValue: 42,
        storage: mockStorage,
      );

      await state.update((value) => value + 10);
      expect(state.value, equals(52));
    });

    test('should persist value automatically', () async {
      final state = PersistState<int>(
        key: 'test',
        defaultValue: 42,
        storage: mockStorage,
        autoPersist: true,
      );

      await state.set(100);

      // Wait for debounce
      await Future.delayed(const Duration(milliseconds: 600));

      final storedValue = await mockStorage.load('test');
      expect(storedValue, equals(100));
    });

    test('should not persist when autoPersist is false', () async {
      final state = PersistState<int>(
        key: 'test',
        defaultValue: 42,
        storage: mockStorage,
        autoPersist: false,
      );

      await state.set(100);

      // Wait for debounce
      await Future.delayed(const Duration(milliseconds: 600));

      final storedValue = await mockStorage.load('test');
      expect(storedValue, isNull);
    });

    test('should manually persist value', () async {
      final state = PersistState<int>(
        key: 'test',
        defaultValue: 42,
        storage: mockStorage,
        autoPersist: false,
      );

      await state.set(100);
      await state.persist();

      final storedValue = await mockStorage.load('test');
      expect(storedValue, equals(100));
    });

    test('should delete persisted value', () async {
      await mockStorage.save('test', 100);

      final state = PersistState<int>(
        key: 'test',
        defaultValue: 42,
        storage: mockStorage,
      );

      await state.delete();
      expect(state.value, equals(42));

      final storedValue = await mockStorage.load('test');
      expect(storedValue, isNull);
    });

    test('should reset to default value', () async {
      final state = PersistState<int>(
        key: 'test',
        defaultValue: 42,
        storage: mockStorage,
      );

      await state.set(100);
      await state.reset();

      expect(state.value, equals(42));
    });

    test('should check if value is persisted', () async {
      final state = PersistState<int>(
        key: 'test',
        defaultValue: 42,
        storage: mockStorage,
      );

      expect(await state.hasPersistedValue(), isFalse);

      await state.set(100);
      await state.persist();

      expect(await state.hasPersistedValue(), isTrue);
    });

    test('should emit values through stream', () async {
      final state = PersistState<int>(
        key: 'test',
        defaultValue: 42,
        storage: mockStorage,
      );

      final values = <int>[];
      state.stream.listen(values.add);

      await state.set(100);
      await state.set(200);
      await state.set(300);

      expect(values, equals([100, 200, 300]));
    });

    test('should not emit when value is the same', () async {
      final state = PersistState<int>(
        key: 'test',
        defaultValue: 42,
        storage: mockStorage,
      );

      final values = <int>[];
      state.stream.listen(values.add);

      await state.set(100);
      await state.set(100); // Same value
      await state.set(200);

      expect(values, equals([100, 200]));
    });

    test('should handle string values', () async {
      final state = PersistState<String>(
        key: 'test',
        defaultValue: 'default',
        storage: mockStorage,
      );

      await state.set('hello world');
      expect(state.value, equals('hello world'));
    });

    test('should handle list values', () async {
      final state = PersistState<List<String>>(
        key: 'test',
        defaultValue: [],
        storage: mockStorage,
      );

      await state.set(['item1', 'item2']);
      expect(state.value, equals(['item1', 'item2']));
    });

    test('should handle map values', () async {
      final state = PersistState<Map<String, dynamic>>(
        key: 'test',
        defaultValue: {},
        storage: mockStorage,
      );

      await state.set({'key': 'value', 'number': 42});
      expect(state.value, equals({'key': 'value', 'number': 42}));
    });

    test('should dispose resources', () async {
      final state = PersistState<int>(
        key: 'test',
        defaultValue: 42,
        storage: mockStorage,
      );

      final values = <int>[];
      state.stream.listen(values.add);

      state.dispose();

      // Should not throw when trying to use disposed state
      expect(() => state.value, returnsNormally);
    });

    test('should handle type mismatch gracefully', () async {
      // Store a string value when expecting an int
      await mockStorage.save('test', 'not_an_int');

      final state = PersistState<int>(
        key: 'test',
        defaultValue: 42,
        storage: mockStorage,
      );

      await state.initialize();

      // Should use default value when type mismatch occurs
      expect(state.value, equals(42));
    });
  });

  group('PersistStateExtension', () {
    test('should create PersistState from value', () {
      final state = 42.asPersistState(key: 'test');

      expect(state.value, equals(42));
      expect(state, isA<PersistState<int>>());
    });
  });
}
