// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$aiServiceHash() => r'c7362c7a7b1da9d216f52d07deebbb112896d88a';

/// See also [aiService].
@ProviderFor(aiService)
final aiServiceProvider = Provider<AIService>.internal(
  aiService,
  name: r'aiServiceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$aiServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AiServiceRef = ProviderRef<AIService>;
String _$aIChatHash() => r'3e9a18421235efe51da672f8f1d8d772e6bbbdf5';

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

abstract class _$AIChat
    extends BuildlessAutoDisposeNotifier<List<ChatMessage>> {
  late final String serverId;

  List<ChatMessage> build(
    String serverId,
  );
}

/// See also [AIChat].
@ProviderFor(AIChat)
const aIChatProvider = AIChatFamily();

/// See also [AIChat].
class AIChatFamily extends Family<List<ChatMessage>> {
  /// See also [AIChat].
  const AIChatFamily();

  /// See also [AIChat].
  AIChatProvider call(
    String serverId,
  ) {
    return AIChatProvider(
      serverId,
    );
  }

  @override
  AIChatProvider getProviderOverride(
    covariant AIChatProvider provider,
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
  String? get name => r'aIChatProvider';
}

/// See also [AIChat].
class AIChatProvider
    extends AutoDisposeNotifierProviderImpl<AIChat, List<ChatMessage>> {
  /// See also [AIChat].
  AIChatProvider(
    String serverId,
  ) : this._internal(
          () => AIChat()..serverId = serverId,
          from: aIChatProvider,
          name: r'aIChatProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$aIChatHash,
          dependencies: AIChatFamily._dependencies,
          allTransitiveDependencies: AIChatFamily._allTransitiveDependencies,
          serverId: serverId,
        );

  AIChatProvider._internal(
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
  List<ChatMessage> runNotifierBuild(
    covariant AIChat notifier,
  ) {
    return notifier.build(
      serverId,
    );
  }

  @override
  Override overrideWith(AIChat Function() create) {
    return ProviderOverride(
      origin: this,
      override: AIChatProvider._internal(
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
  AutoDisposeNotifierProviderElement<AIChat, List<ChatMessage>>
      createElement() {
    return _AIChatProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AIChatProvider && other.serverId == serverId;
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
mixin AIChatRef on AutoDisposeNotifierProviderRef<List<ChatMessage>> {
  /// The parameter `serverId` of this provider.
  String get serverId;
}

class _AIChatProviderElement
    extends AutoDisposeNotifierProviderElement<AIChat, List<ChatMessage>>
    with AIChatRef {
  _AIChatProviderElement(super.provider);

  @override
  String get serverId => (origin as AIChatProvider).serverId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
