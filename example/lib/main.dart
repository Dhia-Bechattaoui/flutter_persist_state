import 'package:flutter/material.dart';
import 'package:flutter_persist_state/flutter_persist_state.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Persist State Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with PersistStateMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Persist State Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Counter example
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Counter: ${getPersistValue(key: 'counter', defaultValue: 0)}',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () => updatePersistValue(
                            key: 'counter',
                            defaultValue: 0,
                            updater: (value) => value + 1,
                          ),
                          child: const Text('Increment'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => updatePersistValue(
                            key: 'counter',
                            defaultValue: 0,
                            updater: (value) => value - 1,
                          ),
                          child: const Text('Decrement'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => resetPersistValue('counter'),
                          child: const Text('Reset'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Text input example
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Saved Text:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      getPersistValue(
                          key: 'saved_text', defaultValue: 'No text saved'),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Enter text to save',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) => setPersistValue(
                        key: 'saved_text',
                        value: value,
                        defaultValue: '',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Theme toggle example
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dark Mode: ${getPersistValue(key: 'dark_mode', defaultValue: false) ? 'On' : 'Off'}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Switch(
                      value: getPersistValue(
                          key: 'dark_mode', defaultValue: false),
                      onChanged: (value) => setPersistValue(
                        key: 'dark_mode',
                        value: value,
                        defaultValue: false,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // List example
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Todo List:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    _TodoListWidget(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Clear all data button
            Center(
              child: ElevatedButton(
                onPressed: () => clearAllPersistValues(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Clear All Data'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodoListWidget extends StatefulWidget {
  @override
  State<_TodoListWidget> createState() => _TodoListWidgetState();
}

class _TodoListWidgetState extends State<_TodoListWidget>
    with PersistStateMixin {
  final TextEditingController _controller = TextEditingController();

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
                decoration: const InputDecoration(
                  labelText: 'Add todo',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    updatePersistValue(
                      key: 'todos',
                      defaultValue: <String>[],
                      updater: (currentTodos) => [...currentTodos, value],
                    );
                    _controller.clear();
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                if (_controller.text.isNotEmpty) {
                  updatePersistValue(
                    key: 'todos',
                    defaultValue: <String>[],
                    updater: (currentTodos) =>
                        [...currentTodos, _controller.text],
                  );
                  _controller.clear();
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (todos.isNotEmpty) ...[
          const SizedBox(height: 8),
          ...todos.asMap().entries.map((entry) {
            final index = entry.key;
            final todo = entry.value;
            return ListTile(
              title: Text(todo),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => updatePersistValue(
                  key: 'todos',
                  defaultValue: <String>[],
                  updater: (currentTodos) => currentTodos
                      .asMap()
                      .entries
                      .where((entry) => entry.key != index)
                      .map((entry) => entry.value)
                      .toList(),
                ),
              ),
            );
          }),
        ] else
          const Text('No todos yet'),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
