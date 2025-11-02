// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$chatSessionsHash() => r'd1d645fdbd619001cadeb5bacacd1cbf83f2c750';

/// See also [ChatSessions].
@ProviderFor(ChatSessions)
final chatSessionsProvider =
    AutoDisposeAsyncNotifierProvider<ChatSessions, List<ChatSession>>.internal(
      ChatSessions.new,
      name: r'chatSessionsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$chatSessionsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ChatSessions = AutoDisposeAsyncNotifier<List<ChatSession>>;
String _$currentSessionHash() => r'b28396f905fb12e908ee2cbee0e2f5a9af1ca18a';

/// See also [CurrentSession].
@ProviderFor(CurrentSession)
final currentSessionProvider =
    AutoDisposeNotifierProvider<CurrentSession, ChatSession?>.internal(
      CurrentSession.new,
      name: r'currentSessionProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$currentSessionHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CurrentSession = AutoDisposeNotifier<ChatSession?>;
String _$chatMessagesHash() => r'7a0af1497f3f30357fbc79c08df77c08febeeb8f';

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

abstract class _$ChatMessages
    extends BuildlessAutoDisposeAsyncNotifier<List<Message>> {
  late final String sessionId;

  FutureOr<List<Message>> build(String sessionId);
}

/// See also [ChatMessages].
@ProviderFor(ChatMessages)
const chatMessagesProvider = ChatMessagesFamily();

/// See also [ChatMessages].
class ChatMessagesFamily extends Family<AsyncValue<List<Message>>> {
  /// See also [ChatMessages].
  const ChatMessagesFamily();

  /// See also [ChatMessages].
  ChatMessagesProvider call(String sessionId) {
    return ChatMessagesProvider(sessionId);
  }

  @override
  ChatMessagesProvider getProviderOverride(
    covariant ChatMessagesProvider provider,
  ) {
    return call(provider.sessionId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'chatMessagesProvider';
}

/// See also [ChatMessages].
class ChatMessagesProvider
    extends AutoDisposeAsyncNotifierProviderImpl<ChatMessages, List<Message>> {
  /// See also [ChatMessages].
  ChatMessagesProvider(String sessionId)
    : this._internal(
        () => ChatMessages()..sessionId = sessionId,
        from: chatMessagesProvider,
        name: r'chatMessagesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$chatMessagesHash,
        dependencies: ChatMessagesFamily._dependencies,
        allTransitiveDependencies:
            ChatMessagesFamily._allTransitiveDependencies,
        sessionId: sessionId,
      );

  ChatMessagesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.sessionId,
  }) : super.internal();

  final String sessionId;

  @override
  FutureOr<List<Message>> runNotifierBuild(covariant ChatMessages notifier) {
    return notifier.build(sessionId);
  }

  @override
  Override overrideWith(ChatMessages Function() create) {
    return ProviderOverride(
      origin: this,
      override: ChatMessagesProvider._internal(
        () => create()..sessionId = sessionId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        sessionId: sessionId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<ChatMessages, List<Message>>
  createElement() {
    return _ChatMessagesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChatMessagesProvider && other.sessionId == sessionId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, sessionId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ChatMessagesRef on AutoDisposeAsyncNotifierProviderRef<List<Message>> {
  /// The parameter `sessionId` of this provider.
  String get sessionId;
}

class _ChatMessagesProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<ChatMessages, List<Message>>
    with ChatMessagesRef {
  _ChatMessagesProviderElement(super.provider);

  @override
  String get sessionId => (origin as ChatMessagesProvider).sessionId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
