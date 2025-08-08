# Flutter Persist State

A lightweight state management solution for Flutter with automatic persistence to local storage.

## Features

- 🚀 **Lightweight**: Minimal overhead with simple API
- 💾 **Automatic Persistence**: State automatically saved to local storage
- 🔄 **Debounced Updates**: Configurable debounce to prevent excessive writes
- 🎯 **Type Safe**: Full type safety with generics
- 🔌 **Flexible Storage**: Multiple storage adapters (SharedPreferences, File-based)
- 🎨 **Widget Integration**: Easy integration with Flutter widgets
- 🧹 **Automatic Cleanup**: Proper resource disposal

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_persist_state: ^0.0.3
```

## Quick Start

### Basic Usage

```dart
import 'package:flutter_persist_state/flutter_persist_state.dart';

// Create a persistent state
final counterState = PersistState<int>(
  key: 'counter',
  defaultValue: 0,
);

// Initialize (load from storage)
await counterState.initialize();

// Update the state
await counterState.set(42);

// Get current value
print(counterState.value); // 42

// Listen to changes
counterState.stream.listen((value) {
  print('Counter changed to: $value');
});
```

### With Widgets

```dart
class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> with PersistStateMixin {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Counter: ${getPersistValue(key: 'counter', defaultValue: 0)}'),
        ElevatedButton(
          onPressed: () => updatePersistValue(
            key: 'counter',
            defaultValue: 0,
            updater: (value) => value + 1,
          ),
          child: Text('Increment'),
        ),
      ],
    );
  }
}
```

## API Reference

### PersistState<T>

The main class for managing persistent state.

#### Constructor

```dart
PersistState<T>({
  required String key,
  required T defaultValue,
  StorageAdapter? storage,
  bool autoPersist = true,
  Duration? debounceTime,
})
```

#### Methods

- `initialize()` - Load value from storage
- `set(T value, {bool? persist})` - Set new value
- `update(T Function(T) updater, {bool? persist})` - Update using function
- `persist()` - Manually persist current value
- `load()` - Reload from storage
- `delete()` - Delete persisted value
- `reset()` - Reset to default value
- `hasPersistedValue()` - Check if value is persisted
- `dispose()` - Clean up resources

#### Properties

- `value` - Current value
- `stream` - Stream of value changes

### PersistStateMixin

Mixin for easy integration with StatefulWidget.

#### Methods

- `getPersistState<T>()` - Get or create persistent state
- `getPersistValue<T>()` - Get current value
- `setPersistValue<T>()` - Set value
- `updatePersistValue<T>()` - Update value using function
- `deletePersistValue()` - Delete value
- `resetPersistValue()` - Reset to default
- `clearAllPersistValues()` - Clear all values

### Storage Adapters

#### SharedPreferencesAdapter

Default storage using SharedPreferences (good for small data).

```dart
final storage = await SharedPreferencesAdapter.create();
```

#### FileStorageAdapter

File-based storage for larger data.

```dart
final storage = await FileStorageAdapter.create('my_namespace');
```

## Examples

### Counter with Persistence

```dart
class CounterWidget extends StatefulWidget {
  @override
  State<CounterWidget> createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> with PersistStateMixin {
  @override
  Widget build(BuildContext context) {
    final count = getPersistValue(key: 'counter', defaultValue: 0);
    
    return Column(
      children: [
        Text('Count: $count'),
        Row(
          children: [
            ElevatedButton(
              onPressed: () => updatePersistValue(
                key: 'counter',
                defaultValue: 0,
                updater: (value) => value + 1,
              ),
              child: Text('+'),
            ),
            ElevatedButton(
              onPressed: () => updatePersistValue(
                key: 'counter',
                defaultValue: 0,
                updater: (value) => value - 1,
              ),
              child: Text('-'),
            ),
            ElevatedButton(
              onPressed: () => resetPersistValue('counter'),
              child: Text('Reset'),
            ),
          ],
        ),
      ],
    );
  }
}
```

### User Settings

```dart
class SettingsWidget extends StatefulWidget {
  @override
  State<SettingsWidget> createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> with PersistStateMixin {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SwitchListTile(
          title: Text('Dark Mode'),
          value: getPersistValue(key: 'dark_mode', defaultValue: false),
          onChanged: (value) => setPersistValue(
            key: 'dark_mode',
            value: value,
            defaultValue: false,
          ),
        ),
        TextField(
          decoration: InputDecoration(labelText: 'Username'),
          onChanged: (value) => setPersistValue(
            key: 'username',
            value: value,
            defaultValue: '',
          ),
        ),
      ],
    );
  }
}
```

### Todo List

```dart
class TodoWidget extends StatefulWidget {
  @override
  State<TodoWidget> createState() => _TodoWidgetState();
}

class _TodoWidgetState extends State<TodoWidget> with PersistStateMixin {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final todos = getPersistValue(
      key: 'todos',
      defaultValue: <String>[],
    );

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(labelText: 'Add todo'),
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    updatePersistValue(
                      key: 'todos',
                      defaultValue: <String>[],
                      updater: (current) => [...current, value],
                    );
                    _controller.clear();
                  }
                },
              ),
            ),
          ],
        ),
        ...todos.map((todo) => ListTile(
          title: Text(todo),
          trailing: IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => updatePersistValue(
              key: 'todos',
              defaultValue: <String>[],
              updater: (current) => current.where((t) => t != todo).toList(),
            ),
          ),
        )),
      ],
    );
  }
}
```

## Advanced Usage

### Custom Storage Adapter

```dart
class CustomStorageAdapter implements StorageAdapter {
  @override
  Future<void> save(String key, dynamic value) async {
    // Custom save logic
  }

  @override
  Future<dynamic> load(String key) async {
    // Custom load logic
  }

  @override
  Future<void> delete(String key) async {
    // Custom delete logic
  }

  @override
  Future<bool> containsKey(String key) async {
    // Custom contains logic
  }

  @override
  Future<void> clear() async {
    // Custom clear logic
  }
}

// Use custom storage
final state = PersistState<String>(
  key: 'my_key',
  defaultValue: '',
  storage: CustomStorageAdapter(),
);
```

### Disable Auto-Persistence

```dart
final state = PersistState<int>(
  key: 'counter',
  defaultValue: 0,
  autoPersist: false, // Disable automatic persistence
);

// Manually persist when needed
await state.set(42);
await state.persist();
```

### Custom Debounce Time

```dart
final state = PersistState<String>(
  key: 'search_query',
  defaultValue: '',
  debounceTime: Duration(milliseconds: 1000), // 1 second debounce
);
```

## Best Practices

1. **Use descriptive keys**: Use meaningful keys for your persistent states
2. **Handle errors**: Wrap persistence operations in try-catch blocks
3. **Dispose properly**: Always call `dispose()` when done with a PersistState
4. **Choose appropriate storage**: Use SharedPreferences for small data, FileStorage for large data
5. **Debounce wisely**: Set appropriate debounce times based on your use case

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
