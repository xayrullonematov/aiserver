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
String _$serverMetricsHash() => r'49f5ca9a56304534d27ec59cf186f5beeee272c3';

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

String _$serversHash() => r'98e3e3204b9738dc1c614c0f3382a15f84e23d24';

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
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
