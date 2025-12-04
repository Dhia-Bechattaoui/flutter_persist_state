import 'dart:async';

import 'package:flutter/material.dart';

import 'persist_state.dart';
import 'storage_adapters.dart';

/// A widget that provides persistent state management to its children
class PersistStateWidget extends StatefulWidget {
  const PersistStateWidget({
    required this.child,
    required this.states,
    super.key,
    this.defaultStorage,
  });

  final Widget child;
  final Map<String, PersistState<dynamic>> states;
  final StorageAdapter? defaultStorage;

  @override
  State<PersistStateWidget> createState() => _PersistStateWidgetState();
}

class _PersistStateWidgetState extends State<PersistStateWidget> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    unawaited(_initializeStates());
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
  Widget build(final BuildContext context) {
    if (!_initialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
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
  const _PersistStateInheritedWidget({
    required this.states,
    required super.child,
    this.defaultStorage,
  });

  final Map<String, PersistState<dynamic>> states;
  final StorageAdapter? defaultStorage;

  @override
  bool updateShouldNotify(final _PersistStateInheritedWidget oldWidget) =>
      states != oldWidget.states || defaultStorage != oldWidget.defaultStorage;

  static _PersistStateInheritedWidget? of(final BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<_PersistStateInheritedWidget>();
}

/// Extension to easily access persistent states from context
extension PersistStateContext on BuildContext {
  /// Get a persistent state by key
  PersistState<T>? getPersistState<T>(final String key) {
    final inherited = _PersistStateInheritedWidget.of(this);
    if (inherited != null && inherited.states.containsKey(key)) {
      return inherited.states[key] as PersistState<T>?;
    }
    return null;
  }

  /// Get all available persistent states
  Map<String, PersistState<dynamic>>? getPersistStates() {
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
  const SinglePersistStateWidget({
    required this.stateKey,
    required this.defaultValue,
    required this.builder,
    super.key,
    this.storage,
    this.autoPersist = true,
    this.debounceTime,
  });

  final String stateKey;
  final T defaultValue;
  final Widget Function(
    BuildContext context,
    T value,
    void Function(T) setValue,
  )
  builder;
  final StorageAdapter? storage;
  final bool autoPersist;
  final Duration? debounceTime;

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
    unawaited(_initializeState());
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
  Widget build(final BuildContext context) {
    if (!_initialized) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<T>(
      stream: _state.stream,
      initialData: _state.value,
      builder: (final context, final snapshot) {
        final data = snapshot.data;
        if (data == null) {
          return const SizedBox.shrink();
        }
        return widget.builder(
          context,
          data,
          (final value) => unawaited(_state.set(value)),
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
