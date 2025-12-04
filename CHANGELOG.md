# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2024-12-04

### Added
- Comprehensive example app demonstrating all package features
- Tab-based navigation in example app for better organization
- Detailed test instructions and descriptions for each feature
- Interactive demos for all PersistStateMixin methods
- Interactive demos for all PersistState API methods
- Storage adapters comparison demo
- Configuration options demo (autoPersist, debounceTime)
- Documentation for FileStorageAdapter methods
- Library-level documentation

### Changed
- Improved example app UI with top navigation tabs instead of side navigation
- Enhanced example app with clear descriptions and test expectations for each feature
- Replaced `print` statements with `debugPrint` for better Flutter integration
- Improved file I/O operations using `compute()` for better performance
- Changed `dynamic` type annotations to `Object?` for better type safety
- Enhanced code quality to achieve 160/160 pana score

### Fixed
- Fixed all linter warnings and info issues (183 → 0 issues)
- Fixed formatting issues across all files
- Fixed parameter ordering in constructors
- Fixed discarded futures warnings
- Fixed type annotation issues
- Fixed file I/O async operations to use isolates properly

## [0.0.3] - 2024-01-01

### Added
- Added WASM compatibility with SharedPreferences-based file storage fallback
- Improved platform support with conditional imports for maximum compatibility

### Fixed
- Fixed WASM compatibility issues by removing dart:io dependencies from default path
- Ensured all platforms have reliable SharedPreferences fallback

## [0.0.2] - 2024-01-01

### Added
- Added web platform support with localStorage-based storage adapter
- Added conditional imports for platform-specific storage implementations
- Added modern web APIs support using package:web

### Fixed
- Fixed type parameter shadowing issues in PersistStateMixin
- Fixed function signature issues in example code
- Removed unnecessary library name declaration
- Added proper ignore comments for print statements
- Fixed const constructor warnings in tests
- Fixed unnecessary type check warnings
- Fixed dart:html deprecation warnings by using modern web APIs

## [0.0.1] - 2024-01-01

### Added
- Initial release of Flutter Persist State
- `PersistState<T>` class for managing persistent state
- `PersistStateMixin` for easy widget integration
- `PersistStateWidget` for providing state to widget tree
- `SinglePersistStateWidget` for single state management
- `SharedPreferencesAdapter` for small data storage
- `FileStorageAdapter` for large data storage
- Automatic persistence with configurable debouncing
- Type-safe API with generics
- Stream-based state changes
- Comprehensive unit tests
- Complete documentation and examples

### Features
- Lightweight state management with minimal overhead
- Automatic persistence to local storage
- Configurable debounce to prevent excessive writes
- Multiple storage adapters for different use cases
- Easy integration with Flutter widgets
- Proper resource disposal and cleanup

[Unreleased]: https://github.com/Dhia-Bechattaoui/flutter_persist_state/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/Dhia-Bechattaoui/flutter_persist_state/compare/v0.0.3...v0.1.0
[0.0.3]: https://github.com/Dhia-Bechattaoui/flutter_persist_state/compare/v0.0.2...v0.0.3
[0.0.2]: https://github.com/Dhia-Bechattaoui/flutter_persist_state/compare/v0.0.1...v0.0.2
[0.0.1]: https://github.com/Dhia-Bechattaoui/flutter_persist_state/releases/tag/v0.0.1
