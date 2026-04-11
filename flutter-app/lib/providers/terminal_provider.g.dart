// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'terminal_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$wsServiceHash() => r'206c4c3ad1b04451e6556b6eaf9aa84a5368b924';

/// See also [wsService].
@ProviderFor(wsService)
final wsServiceProvider = Provider<WSService>.internal(
  wsService,
  name: r'wsServiceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$wsServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WsServiceRef = ProviderRef<WSService>;
String _$terminalNotifierHash() => r'a3553956130ec68bb7bd5f391bf6ca6125bd74e2';

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

abstract class _$TerminalNotifier
    extends BuildlessAutoDisposeNotifier<List<String>> {
  late final String serverId;

  List<String> build(
    String serverId,
  );
}

/// See also [TerminalNotifier].
@ProviderFor(TerminalNotifier)
const terminalNotifierProvider = TerminalNotifierFamily();

/// See also [TerminalNotifier].
class TerminalNotifierFamily extends Family<List<String>> {
  /// See also [TerminalNotifier].
  const TerminalNotifierFamily();

  /// See also [TerminalNotifier].
  TerminalNotifierProvider call(
    String serverId,
  ) {
    return TerminalNotifierProvider(
      serverId,
    );
  }

  @override
  TerminalNotifierProvider getProviderOverride(
    covariant TerminalNotifierProvider provider,
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
  String? get name => r'terminalNotifierProvider';
}

/// See also [TerminalNotifier].
class TerminalNotifierProvider
    extends AutoDisposeNotifierProviderImpl<TerminalNotifier, List<String>> {
  /// See also [TerminalNotifier].
  TerminalNotifierProvider(
    String serverId,
  ) : this._internal(
          () => TerminalNotifier()..serverId = serverId,
          from: terminalNotifierProvider,
          name: r'terminalNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$terminalNotifierHash,
          dependencies: TerminalNotifierFamily._dependencies,
          allTransitiveDependencies:
              TerminalNotifierFamily._allTransitiveDependencies,
          serverId: serverId,
        );

  TerminalNotifierProvider._internal(
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
  List<String> runNotifierBuild(
    covariant TerminalNotifier notifier,
  ) {
    return notifier.build(
      serverId,
    );
  }

  @override
  Override overrideWith(TerminalNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: TerminalNotifierProvider._internal(
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
  AutoDisposeNotifierProviderElement<TerminalNotifier, List<String>>
      createElement() {
    return _TerminalNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TerminalNotifierProvider && other.serverId == serverId;
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
mixin TerminalNotifierRef on AutoDisposeNotifierProviderRef<List<String>> {
  /// The parameter `serverId` of this provider.
  String get serverId;
}

class _TerminalNotifierProviderElement
    extends AutoDisposeNotifierProviderElement<TerminalNotifier, List<String>>
    with TerminalNotifierRef {
  _TerminalNotifierProviderElement(super.provider);

  @override
  String get serverId => (origin as TerminalNotifierProvider).serverId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
