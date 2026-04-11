// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'server_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$serverServiceHash() => r'25c00128986c818382e86a6643751d7c51ab324c';

/// See also [serverService].
@ProviderFor(serverService)
final serverServiceProvider = Provider<ServerService>.internal(
  serverService,
  name: r'serverServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$serverServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ServerServiceRef = ProviderRef<ServerService>;
String _$serverMetricsHash() => r'654ece1b8f6eb9272a8f7f61941c45f98c8deb4f';

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

/// See also [serverMetrics].
@ProviderFor(serverMetrics)
const serverMetricsProvider = ServerMetricsFamily();

/// See also [serverMetrics].
class ServerMetricsFamily extends Family<AsyncValue<Map<String, double>>> {
  /// See also [serverMetrics].
  const ServerMetricsFamily();

  /// See also [serverMetrics].
  ServerMetricsProvider call(
    String serverId,
  ) {
    return ServerMetricsProvider(
      serverId,
    );
  }

  @override
  ServerMetricsProvider getProviderOverride(
    covariant ServerMetricsProvider provider,
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
  String? get name => r'serverMetricsProvider';
}

/// See also [serverMetrics].
class ServerMetricsProvider
    extends AutoDisposeStreamProvider<Map<String, double>> {
  /// See also [serverMetrics].
  ServerMetricsProvider(
    String serverId,
  ) : this._internal(
          (ref) => serverMetrics(
            ref as ServerMetricsRef,
            serverId,
          ),
          from: serverMetricsProvider,
          name: r'serverMetricsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$serverMetricsHash,
          dependencies: ServerMetricsFamily._dependencies,
          allTransitiveDependencies:
              ServerMetricsFamily._allTransitiveDependencies,
          serverId: serverId,
        );

  ServerMetricsProvider._internal(
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
  Override overrideWith(
    Stream<Map<String, double>> Function(ServerMetricsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ServerMetricsProvider._internal(
        (ref) => create(ref as ServerMetricsRef),
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
  AutoDisposeStreamProviderElement<Map<String, double>> createElement() {
    return _ServerMetricsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ServerMetricsProvider && other.serverId == serverId;
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
mixin ServerMetricsRef on AutoDisposeStreamProviderRef<Map<String, double>> {
  /// The parameter `serverId` of this provider.
  String get serverId;
}

class _ServerMetricsProviderElement
    extends AutoDisposeStreamProviderElement<Map<String, double>>
    with ServerMetricsRef {
  _ServerMetricsProviderElement(super.provider);

  @override
  String get serverId => (origin as ServerMetricsProvider).serverId;
}

String _$serversHash() => r'157b4aa531142568217585f12a2d401b1f32118f';

/// See also [Servers].
@ProviderFor(Servers)
final serversProvider =
    AutoDisposeAsyncNotifierProvider<Servers, List<ServerProfile>>.internal(
  Servers.new,
  name: r'serversProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$serversHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Servers = AutoDisposeAsyncNotifier<List<ServerProfile>>;
String _$serverConnectionStatusHash() =>
    r'd85d247f0e54dca4e0df427da5e50d05f84296f3';

abstract class _$ServerConnectionStatus
    extends BuildlessAutoDisposeAsyncNotifier<ServerConnectionResult> {
  late final String serverId;

  FutureOr<ServerConnectionResult> build(
    String serverId,
  );
}

/// See also [ServerConnectionStatus].
@ProviderFor(ServerConnectionStatus)
const serverConnectionStatusProvider = ServerConnectionStatusFamily();

/// See also [ServerConnectionStatus].
class ServerConnectionStatusFamily
    extends Family<AsyncValue<ServerConnectionResult>> {
  /// See also [ServerConnectionStatus].
  const ServerConnectionStatusFamily();

  /// See also [ServerConnectionStatus].
  ServerConnectionStatusProvider call(
    String serverId,
  ) {
    return ServerConnectionStatusProvider(
      serverId,
    );
  }

  @override
  ServerConnectionStatusProvider getProviderOverride(
    covariant ServerConnectionStatusProvider provider,
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
  String? get name => r'serverConnectionStatusProvider';
}

/// See also [ServerConnectionStatus].
class ServerConnectionStatusProvider
    extends AutoDisposeAsyncNotifierProviderImpl<ServerConnectionStatus,
        ServerConnectionResult> {
  /// See also [ServerConnectionStatus].
  ServerConnectionStatusProvider(
    String serverId,
  ) : this._internal(
          () => ServerConnectionStatus()..serverId = serverId,
          from: serverConnectionStatusProvider,
          name: r'serverConnectionStatusProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$serverConnectionStatusHash,
          dependencies: ServerConnectionStatusFamily._dependencies,
          allTransitiveDependencies:
              ServerConnectionStatusFamily._allTransitiveDependencies,
          serverId: serverId,
        );

  ServerConnectionStatusProvider._internal(
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
  FutureOr<ServerConnectionResult> runNotifierBuild(
    covariant ServerConnectionStatus notifier,
  ) {
    return notifier.build(
      serverId,
    );
  }

  @override
  Override overrideWith(ServerConnectionStatus Function() create) {
    return ProviderOverride(
      origin: this,
      override: ServerConnectionStatusProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<ServerConnectionStatus,
      ServerConnectionResult> createElement() {
    return _ServerConnectionStatusProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ServerConnectionStatusProvider &&
        other.serverId == serverId;
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
mixin ServerConnectionStatusRef
    on AutoDisposeAsyncNotifierProviderRef<ServerConnectionResult> {
  /// The parameter `serverId` of this provider.
  String get serverId;
}

class _ServerConnectionStatusProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<ServerConnectionStatus,
        ServerConnectionResult> with ServerConnectionStatusRef {
  _ServerConnectionStatusProviderElement(super.provider);

  @override
  String get serverId => (origin as ServerConnectionStatusProvider).serverId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
