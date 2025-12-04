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
      home: const FeatureDemoPage(),
    );
  }
}

class FeatureDemoPage extends StatefulWidget {
  const FeatureDemoPage({super.key});

  @override
  State<FeatureDemoPage> createState() => _FeatureDemoPageState();
}

class _FeatureDemoPageState extends State<FeatureDemoPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Persist State - All Features'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.widgets), text: 'Mixin Features'),
            Tab(icon: Icon(Icons.code), text: 'PersistState API'),
            Tab(icon: Icon(Icons.storage), text: 'Storage Adapters'),
            Tab(icon: Icon(Icons.tune), text: 'Configuration'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          MixinFeaturesDemo(),
          PersistStateApiDemo(),
          StorageAdaptersDemo(),
          ConfigurationDemo(),
        ],
      ),
    );
  }
}

// ============================================================================
// 1. PERSISTSTATEMIXIN FEATURES DEMO
// ============================================================================
class MixinFeaturesDemo extends StatefulWidget {
  const MixinFeaturesDemo({super.key});

  @override
  State<MixinFeaturesDemo> createState() => _MixinFeaturesDemoState();
}

class _MixinFeaturesDemoState extends State<MixinFeaturesDemo>
    with PersistStateMixin {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PersistStateMixin Features',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'All values are automatically saved to storage. Restart the app to verify persistence. Use "Clear All Values" to delete everything.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.blue[900],
                        ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Test all methods available when using PersistStateMixin in your StatefulWidget',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 24),

          // getPersistValue & setPersistValue
          _buildCard(
            title: 'getPersistValue & setPersistValue',
            description:
                'Get current value and set new value directly. Value persists automatically.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Counter: ${getPersistValue(key: 'mixin_counter', defaultValue: 0)}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Test: Click buttons, close and reopen app - value should persist!',
                  style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () => setPersistValue(
                        key: 'mixin_counter',
                        value: getPersistValue(
                                key: 'mixin_counter', defaultValue: 0) +
                            1,
                        defaultValue: 0,
                      ),
                      child: const Text('Increment'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => setPersistValue(
                        key: 'mixin_counter',
                        value: getPersistValue(
                                key: 'mixin_counter', defaultValue: 0) -
                            1,
                        defaultValue: 0,
                      ),
                      child: const Text('Decrement'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // updatePersistValue
          _buildCard(
            title: 'updatePersistValue',
            description:
                'Update value using a function. Useful for complex updates based on current value.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Value: ${getPersistValue(key: 'mixin_updater', defaultValue: 0)}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Test: Click multiple times - each click adds 10 to current value',
                  style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => updatePersistValue(
                    key: 'mixin_updater',
                    defaultValue: 0,
                    updater: (value) => value + 10,
                  ),
                  child: const Text('Add 10'),
                ),
              ],
            ),
          ),

          // getPersistState with stream
          _buildCard(
            title: 'getPersistState (Stream)',
            description:
                'Access the underlying PersistState to listen to value changes via stream.',
            child: _StreamListenerWidget(stateKey: 'mixin_stream'),
          ),

          // deletePersistValue
          _buildCard(
            title: 'deletePersistValue',
            description:
                'Delete a persisted value from storage. Value resets to default after deletion.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Text: ${getPersistValue(key: 'mixin_delete', defaultValue: 'Not deleted')}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Test: Set a value, then delete it. Value should return to default.',
                  style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () => setPersistValue(
                        key: 'mixin_delete',
                        value: 'This will be deleted',
                        defaultValue: 'Not deleted',
                      ),
                      child: const Text('Set Value'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => deletePersistValue('mixin_delete'),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // resetPersistValue
          _buildCard(
            title: 'resetPersistValue',
            description:
                'Reset value to its default. Value is also persisted after reset.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Value: ${getPersistValue(key: 'mixin_reset', defaultValue: 0)}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Test: Add some value, then reset. Should go back to 0.',
                  style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () => updatePersistValue(
                        key: 'mixin_reset',
                        defaultValue: 0,
                        updater: (value) => value + 5,
                      ),
                      child: const Text('Add 5'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => resetPersistValue('mixin_reset'),
                      child: const Text('Reset to 0'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // clearAllPersistValues
          _buildCard(
            title: 'clearAllPersistValues',
            description:
                'Delete ALL persisted values managed by this mixin. Use with caution!',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Warning: This will delete all values in this tab!',
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => clearAllPersistValues(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Clear All Values'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required Widget child,
    String? description,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (description != null) ...[
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[700],
                    ),
              ),
            ],
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _StreamListenerWidget extends StatefulWidget {
  final String stateKey;

  const _StreamListenerWidget({required this.stateKey});

  @override
  State<_StreamListenerWidget> createState() => _StreamListenerWidgetState();
}

class _StreamListenerWidgetState extends State<_StreamListenerWidget>
    with PersistStateMixin {
  String _streamValue = 'Listening...';

  @override
  void initState() {
    super.initState();
    // Listen to stream
    getPersistState<String>(
      key: widget.stateKey,
      defaultValue: 'Initial',
    ).stream.listen((value) {
      if (mounted) {
        setState(() {
          _streamValue = 'Stream: $value';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_streamValue),
        const SizedBox(height: 8),
        const Text(
          'Test: Click button - stream should update immediately showing new timestamp',
          style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () => setPersistValue(
            key: widget.stateKey,
            value: DateTime.now().toString(),
            defaultValue: 'Initial',
          ),
          child: const Text('Update (watch stream)'),
        ),
      ],
    );
  }
}

// ============================================================================
// 2. PERSISTSTATE API DEMO
// ============================================================================
class PersistStateApiDemo extends StatefulWidget {
  const PersistStateApiDemo({super.key});

  @override
  State<PersistStateApiDemo> createState() => _PersistStateApiDemoState();
}

class _PersistStateApiDemoState extends State<PersistStateApiDemo> {
  late PersistState<int> _counterState;
  late PersistState<String> _textState;
  String _streamOutput = '';
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _counterState = PersistState<int>(
      key: 'api_counter',
      defaultValue: 0,
    );
    _textState = PersistState<String>(
      key: 'api_text',
      defaultValue: 'Hello',
    );

    // Listen to stream
    _counterState.stream.listen((value) {
      if (mounted) {
        setState(() {
          _streamOutput = 'Stream updated: $value';
        });
      }
    });

    _initialize();
  }

  Future<void> _initialize() async {
    await _counterState.initialize();
    await _textState.initialize();
    if (mounted) {
      setState(() {
        _initialized = true;
      });
    }
  }

  @override
  void dispose() {
    _counterState.dispose();
    _textState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PersistState API Features',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          // value property
          _buildCard(
            title: 'value property',
            child: Text(
              'Current value: ${_counterState.value}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),

          // set method
          _buildCard(
            title: 'set() method',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Value: ${_counterState.value}'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () => _counterState.set(42),
                      child: const Text('Set to 42'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => _counterState.set(100),
                      child: const Text('Set to 100'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // update method
          _buildCard(
            title: 'update() method',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Value: ${_counterState.value}'),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => _counterState.update((value) => value * 2),
                  child: const Text('Double value'),
                ),
              ],
            ),
          ),

          // stream property
          _buildCard(
            title: 'stream property',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_streamOutput.isEmpty ? 'No updates yet' : _streamOutput),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => _counterState.set(_counterState.value + 1),
                  child: const Text('Increment (watch stream)'),
                ),
              ],
            ),
          ),

          // persist method
          _buildCard(
            title: 'persist() - Manual persistence',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Text: ${_textState.value}'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () => _textState.set(
                          'Updated at ${DateTime.now().toString().substring(11, 19)}',
                          persist: false),
                      child: const Text('Set (no auto-persist)'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => _textState.persist(),
                      child: const Text('Persist Now'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // load method
          _buildCard(
            title: 'load() - Reload from storage',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Value: ${_counterState.value}'),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () async {
                    await _counterState.load();
                    if (mounted) setState(() {});
                  },
                  child: const Text('Reload from Storage'),
                ),
              ],
            ),
          ),

          // delete method
          _buildCard(
            title: 'delete() method',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Value: ${_textState.value}'),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () async {
                    await _textState.delete();
                    if (mounted) setState(() {});
                  },
                  child: const Text('Delete from Storage'),
                ),
              ],
            ),
          ),

          // reset method
          _buildCard(
            title: 'reset() method',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Value: ${_counterState.value}'),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () async {
                    await _counterState.reset();
                    if (mounted) setState(() {});
                  },
                  child: const Text('Reset to Default (0)'),
                ),
              ],
            ),
          ),

          // hasPersistedValue method
          _buildCard(
            title: 'hasPersistedValue() method',
            child: FutureBuilder<bool>(
              future: _counterState.hasPersistedValue(),
              builder: (context, snapshot) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Has persisted value: ${snapshot.data ?? 'Loading...'}',
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {});
                      },
                      child: const Text('Refresh'),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 3. STORAGE ADAPTERS DEMO
// ============================================================================
class StorageAdaptersDemo extends StatefulWidget {
  const StorageAdaptersDemo({super.key});

  @override
  State<StorageAdaptersDemo> createState() => _StorageAdaptersDemoState();
}

class _StorageAdaptersDemoState extends State<StorageAdaptersDemo> {
  late PersistState<String> _sharedPrefsState;
  late PersistState<String> _fileStorageState;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    // SharedPreferences adapter
    final sharedPrefsStorage = await SharedPreferencesAdapter.create();
    _sharedPrefsState = PersistState<String>(
      key: 'shared_prefs_demo',
      defaultValue: 'Default (SharedPreferences)',
      storage: sharedPrefsStorage,
    );

    // FileStorage adapter
    final fileStorage = await FileStorageAdapter.create('demo_namespace');
    _fileStorageState = PersistState<String>(
      key: 'file_storage_demo',
      defaultValue: 'Default (FileStorage)',
      storage: fileStorage,
    );

    await _sharedPrefsState.initialize();
    await _fileStorageState.initialize();

    if (mounted) {
      setState(() {
        _initialized = true;
      });
    }
  }

  @override
  void dispose() {
    _sharedPrefsState.dispose();
    _fileStorageState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Storage Adapters',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          _buildCard(
            title: 'SharedPreferencesAdapter',
            description: 'Good for small data (strings, numbers, booleans)',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Value: ${_sharedPrefsState.value}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Enter value',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (value) {
                    _sharedPrefsState.set(value);
                    setState(() {});
                  },
                ),
              ],
            ),
          ),
          _buildCard(
            title: 'FileStorageAdapter',
            description: 'Good for larger data (complex objects, lists)',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Value: ${_fileStorageState.value}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Enter value',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (value) {
                    _fileStorageState.set(value);
                    setState(() {});
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required Widget child,
    String? description,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (description != null) ...[
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 4. CONFIGURATION DEMO
// ============================================================================
class ConfigurationDemo extends StatefulWidget {
  const ConfigurationDemo({super.key});

  @override
  State<ConfigurationDemo> createState() => _ConfigurationDemoState();
}

class _ConfigurationDemoState extends State<ConfigurationDemo> {
  late PersistState<int> _autoPersistState;
  late PersistState<int> _manualPersistState;
  late PersistState<int> _debouncedState;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    // Auto-persist enabled (default)
    _autoPersistState = PersistState<int>(
      key: 'auto_persist',
      defaultValue: 0,
      autoPersist: true,
    );

    // Auto-persist disabled
    _manualPersistState = PersistState<int>(
      key: 'manual_persist',
      defaultValue: 0,
      autoPersist: false,
    );

    // Custom debounce time (2 seconds)
    _debouncedState = PersistState<int>(
      key: 'debounced',
      defaultValue: 0,
      debounceTime: const Duration(seconds: 2),
    );

    await _autoPersistState.initialize();
    await _manualPersistState.initialize();
    await _debouncedState.initialize();

    if (mounted) {
      setState(() {
        _initialized = true;
      });
    }
  }

  @override
  void dispose() {
    _autoPersistState.dispose();
    _manualPersistState.dispose();
    _debouncedState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Configuration Options',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          _buildCard(
            title: 'autoPersist: true (default)',
            description: 'Changes are automatically persisted after debounce',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Value: ${_autoPersistState.value}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    _autoPersistState.set(_autoPersistState.value + 1);
                    setState(() {});
                  },
                  child: const Text('Increment (auto-persists)'),
                ),
              ],
            ),
          ),
          _buildCard(
            title: 'autoPersist: false',
            description:
                'Changes are NOT automatically persisted. Use persist() manually.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Value: ${_manualPersistState.value}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _manualPersistState.set(_manualPersistState.value + 1);
                        setState(() {});
                      },
                      child: const Text('Increment (no persist)'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        _manualPersistState.persist();
                      },
                      child: const Text('Persist Now'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _buildCard(
            title: 'debounceTime: 2 seconds',
            description:
                'Changes are debounced for 2 seconds before persisting',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Value: ${_debouncedState.value}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    _debouncedState.set(_debouncedState.value + 1);
                    setState(() {});
                  },
                  child: const Text('Increment (2s debounce)'),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Try clicking rapidly - only the last change persists after 2s',
                  style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required Widget child,
    String? description,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (description != null) ...[
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
