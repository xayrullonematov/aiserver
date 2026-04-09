import 'dart:async';
import 'package:ai_server_copilot/providers/auth_provider.dart';
import 'package:ai_server_copilot/providers/terminal_provider.dart';
import 'package:ai_server_copilot/services/api_service.dart';
import 'package:ai_server_copilot/services/ai_service.dart';
import 'package:ai_server_copilot/models/ai_response.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ai_provider.g.dart';

@Riverpod(keepAlive: true)
AIService aiService(AiServiceRef ref) {
  final api = ref.watch(apiServiceProvider);
  return AIService(api);
}

class ChatMessage {
  final String role;
  final String text;
  final bool isStreaming;
  final AIResponse? structuredResponse;

  ChatMessage({
    required this.role, 
    required this.text, 
    this.isStreaming = false,
    this.structuredResponse,
  });
}

@riverpod
class AIChat extends _$AIChat {
  AIResponse? _pendingResponse;
  AIResponse? get pendingResponse => _pendingResponse;

  @override
  List<ChatMessage> build(String serverId) {
    return [
      ChatMessage(
        role: 'assistant',
        text: 'Hello! I am your AI Server Copilot. I can help you manage your server and write code. What would you like to do?',
      ),
    ];
  }

  void clearPending() {
    _pendingResponse = null;
  }

  Future<void> approve(List<int> commands, List<int> edits) async {
    if (_pendingResponse == null) return;
    final currentProposal = _pendingResponse!;
    _pendingResponse = null;

    state = [...state, ChatMessage(role: 'assistant', text: '🚀 Executing approved changes...', isStreaming: true)];

    try {
      final api = ref.read(apiServiceProvider);
      await api.dio.post('/ai/approve', data: {
        'server_id': serverId,
        'ai_response_id': currentProposal.id,
        'approved_commands': commands,
        'approved_edits': edits,
      });

      state = [
        ...state.sublist(0, state.length - 1),
        ChatMessage(role: 'assistant', text: '✅ Changes applied successfully! Verification complete.'),
      ];
    } catch (e) {
      state = [
        ...state.sublist(0, state.length - 1),
        ChatMessage(role: 'assistant', text: '❌ Failed to apply changes: $e'),
      ];
    }
  }

  Future<void> sendMessage(String text, String provider, String apiKey) async {
    state = [...state, ChatMessage(role: 'user', text: text)];
    state = [...state, ChatMessage(role: 'assistant', text: 'Analyzing request and preparing proposal...', isStreaming: true)];

    try {
      final api = ref.read(apiServiceProvider);
      final response = await api.dio.post('/ai/chat', data: {
        'prompt': text,
        'server_id': int.tryParse(serverId),
        'provider': provider,
        'api_key': apiKey,
      });

      final aiResponse = AIResponse.fromJson(response.data);
      
      if (aiResponse.needsApproval) {
        _pendingResponse = aiResponse;
        state = [
          ...state.sublist(0, state.length - 1),
          ChatMessage(
            role: 'assistant', 
            text: aiResponse.summary,
            structuredResponse: aiResponse,
          ),
        ];
      } else {
        state = [
          ...state.sublist(0, state.length - 1),
          ChatMessage(role: 'assistant', text: aiResponse.summary),
        ];
      }
    } catch (e) {
      state = [
        ...state.sublist(0, state.length - 1),
        ChatMessage(role: 'assistant', text: 'Error: $e'),
      ];
    }
  }
}
