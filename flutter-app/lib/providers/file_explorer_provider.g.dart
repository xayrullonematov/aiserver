// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_explorer_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sshServiceHash() => r'611be0e5cbe16c14b4e14d837e1b7ed64f41c401';

/// See also [sshService].
@ProviderFor(sshService)
final sshServiceProvider = Provider<SSHService>.internal(
  sshService,
  name: r'sshServiceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$sshServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SshServiceRef = ProviderRef<SSHService>;
String _$fileExplorerNotifierHash() =>
    r'0abbf903a8d8f355b386faaeb9c1205211cde4f7';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$FileExplorerNotifier
    extends BuildlessAutoDisposeAsyncNotifier<List<dynamic>> {
  late final String serverId;
  late final String path;

  FutureOr<List<dynamic>> build(
    String serverId,
    String path,
  );
}

/// See also [FileExplorerNotifier].
@ProviderFor(FileExplorerNotifier)
const fileExplorerNotifierProvider = FileExplorerNotifierFamily();

/// See also [FileExplorerNotifier].
class FileExplorerNotifierFamily extends Family<AsyncValue<List<dynamic>>> {
  /// See also [FileExplorerNotifier].
  const FileExplorerNotifierFamily();

  /// See also [FileExplorerNotifier].
  FileExplorerNotifierProvider call(
    String serverId,
    String path,
  ) {
    return FileExplorerNotifierProvider(
      serverId,
      path,
    );
  }

  @override
  FileExplorerNotifierProvider getProviderOverride(
    covariant FileExplorerNotifierProvider provider,
  ) {
    return call(
      provider.serverId,
      provider.path,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'fileExplorerNotifierProvider';
}

/// See also [FileExplorerNotifier].
class FileExplorerNotifierProvider extends AutoDisposeAsyncNotifierProviderImpl<
    FileExplorerNotifier, List<dynamic>> {
  /// See also [FileExplorerNotifier].
  FileExplorerNotifierProvider(
    String serverId,
    String path,
  ) : this._internal(
          () => FileExplorerNotifier()
            ..serverId = serverId
            ..path = path,
          from: fileExplorerNotifierProvider,
          name: r'fileExplorerNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$fileExplorerNotifierHash,
          dependencies: FileExplorerNotifierFamily._dependencies,
          allTransitiveDependencies:
              FileExplorerNotifierFamily._allTransitiveDependencies,
          serverId: serverId,
          path: path,
        );

  FileExplorerNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.serverId,
    required this.path,
  }) : super.internal();

  final String serverId;
  final String path;

  @override
  FutureOr<List<dynamic>> runNotifierBuild(
    covariant FileExplorerNotifier notifier,
  ) {
    return notifier.build(
      serverId,
      path,
    );
  }

  @override
  Override overrideWith(FileExplorerNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: FileExplorerNotifierProvider._internal(
        () => create()
          ..serverId = serverId
          ..path = path,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        serverId: serverId,
        path: path,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<FileExplorerNotifier, List<dynamic>>
      createElement() {
    return _FileExplorerNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FileExplorerNotifierProvider &&
        other.serverId == serverId &&
        other.path == path;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, serverId.hashCode);
    hash = _SystemHash.combine(hash, path.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FileExplorerNotifierRef
    on AutoDisposeAsyncNotifierProviderRef<List<dynamic>> {
  /// The parameter `serverId` of this provider.
  String get serverId;

  /// The parameter `path` of this provider.
  String get path;
}

class _FileExplorerNotifierProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<FileExplorerNotifier,
        List<dynamic>> with FileExplorerNotifierRef {
  _FileExplorerNotifierProviderElement(super.provider);

  @override
  String get serverId => (origin as FileExplorerNotifierProvider).serverId;
  @override
  String get path => (origin as FileExplorerNotifierProvider).path;
}

String _$currentPathHash() => r'aa6887a77f3c21c4d6759f8438c37e63ccf4f9e9';

abstract class _$CurrentPath extends BuildlessAutoDisposeNotifier<String> {
  late final String serverId;

  String build(
    String serverId,
  );
}

/// See also [CurrentPath].
@ProviderFor(CurrentPath)
const currentPathProvider = CurrentPathFamily();

/// See also [CurrentPath].
class CurrentPathFamily extends Family<String> {
  /// See also [CurrentPath].
  const CurrentPathFamily();

  /// See also [CurrentPath].
  CurrentPathProvider call(
    String serverId,
  ) {
    return CurrentPathProvider(
      serverId,
    );
  }

  @override
  CurrentPathProvider getProviderOverride(
    covariant CurrentPathProvider provider,
  ) {
    return call(
      provider.serverId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'currentPathProvider';
}

/// See also [CurrentPath].
class CurrentPathProvider
    extends AutoDisposeNotifierProviderImpl<CurrentPath, String> {
  /// See also [CurrentPath].
  CurrentPathProvider(
    String serverId,
  ) : this._internal(
          () => CurrentPath()..serverId = serverId,
          from: currentPathProvider,
          name: r'currentPathProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$currentPathHash,
          dependencies: CurrentPathFamily._dependencies,
          allTransitiveDependencies:
              CurrentPathFamily._allTransitiveDependencies,
          serverId: serverId,
        );

  CurrentPathProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.serverId,
  }) : super.internal();

  final String serverId;

  @override
  String runNotifierBuild(
    covariant CurrentPath notifier,
  ) {
    return notifier.build(
      serverId,
    );
  }

  @override
  Override overrideWith(CurrentPath Function() create) {
    return ProviderOverride(
      origin: this,
      override: CurrentPathProvider._internal(
        () => create()..serverId = serverId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        serverId: serverId,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<CurrentPath, String> createElement() {
    return _CurrentPathProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CurrentPathProvider && other.serverId == serverId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, serverId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CurrentPathRef on AutoDisposeNotifierProviderRef<String> {
  /// The parameter `serverId` of this provider.
  String get serverId;
}

class _CurrentPathProviderElement
    extends AutoDisposeNotifierProviderElement<CurrentPath, String>
    with CurrentPathRef {
  _CurrentPathProviderElement(super.provider);

  @override
  String get serverId => (origin as CurrentPathProvider).serverId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
