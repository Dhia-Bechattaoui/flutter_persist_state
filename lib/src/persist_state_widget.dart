import 'package:flutter/material.dart';
import 'package:flutter_persist_state/src/persist_state.dart';
import 'package:flutter_persist_state/src/storage_adapters.dart';

/// A widget that provides persistent state management to its children
class PersistStateWidget extends StatefulWidget {
  final Widget child;
  final Map<String, PersistState> states;
  final StorageAdapter? defaultStorage;

  const PersistStateWidget({
    super.key,
    required this.child,
    required this.states,
    this.defaultStorage,
  });

  @override
  State<PersistStateWidget> createState() => _PersistStateWidgetState();
}

class _PersistStateWidgetState extends State<PersistStateWidget> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initializeStates();
  }

  Future<void> _initializeStates() async {
    for (final state in widget.states.values) {
      await state.initialize();
    }
    if (mounted) {
      setState(() {
        _initialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return _PersistStateInheritedWidget(
      states: widget.states,
      defaultStorage: widget.defaultStorage,
      child: widget.child,
    );
  }

  @override
  void dispose() {
    for (final state in widget.states.values) {
      state.dispose();
    }
    super.dispose();
  }
}

/// Inherited widget that provides access to persistent states
class _PersistStateInheritedWidget extends InheritedWidget {
  final Map<String, PersistState> states;
  final StorageAdapter? defaultStorage;

  const _PersistStateInheritedWidget({
    required this.states,
    this.defaultStorage,
    required super.child,
  });

  @override
  bool updateShouldNotify(_PersistStateInheritedWidget oldWidget) {
    return states != oldWidget.states ||
        defaultStorage != oldWidget.defaultStorage;
  }

  static _PersistStateInheritedWidget? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_PersistStateInheritedWidget>();
  }
}

/// Extension to easily access persistent states from context
extension PersistStateContext on BuildContext {
  /// Get a persistent state by key
  PersistState<T>? getPersistState<T>(String key) {
    final inherited = _PersistStateInheritedWidget.of(this);
    if (inherited != null && inherited.states.containsKey(key)) {
      return inherited.states[key] as PersistState<T>?;
    }
    return null;
  }

  /// Get all available persistent states
  Map<String, PersistState>? getPersistStates() {
    final inherited = _PersistStateInheritedWidget.of(this);
    return inherited?.states;
  }

  /// Get the default storage adapter
  StorageAdapter? getDefaultStorage() {
    final inherited = _PersistStateInheritedWidget.of(this);
    return inherited?.defaultStorage;
  }
}

/// A simple widget that manages a single persistent state
class SinglePersistStateWidget<T> extends StatefulWidget {
  final String stateKey;
  final T defaultValue;
  final Widget Function(BuildContext context, T value, Function(T) setValue)
      builder;
  final StorageAdapter? storage;
  final bool autoPersist;
  final Duration? debounceTime;

  const SinglePersistStateWidget({
    super.key,
    required this.stateKey,
    required this.defaultValue,
    required this.builder,
    this.storage,
    this.autoPersist = true,
    this.debounceTime,
  });

  @override
  State<SinglePersistStateWidget<T>> createState() =>
      _SinglePersistStateWidgetState<T>();
}

class _SinglePersistStateWidgetState<T>
    extends State<SinglePersistStateWidget<T>> {
  late PersistState<T> _state;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _state = PersistState<T>(
      key: widget.stateKey,
      defaultValue: widget.defaultValue,
      storage: widget.storage,
      autoPersist: widget.autoPersist,
      debounceTime: widget.debounceTime,
    );
    _initializeState();
  }

  Future<void> _initializeState() async {
    await _state.initialize();
    if (mounted) {
      setState(() {
        _initialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<T>(
      stream: _state.stream,
      initialData: _state.value,
      builder: (context, snapshot) {
        final data = snapshot.data;
        if (data == null) return const SizedBox.shrink();
        return widget.builder(
          context,
          data,
          (value) => _state.set(value),
        );
      },
    );
  }

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }
}
