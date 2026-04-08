import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_server_copilot/providers/ai_provider.dart';
import 'package:ai_server_copilot/models/ai_response.dart';
import 'package:ai_server_copilot/widgets/ai/approval_sheet.dart';

class AIChatScreen extends ConsumerStatefulWidget {
  final String serverId;

  const AIChatScreen({super.key, required this.serverId});

  @override
  ConsumerState<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends ConsumerState<AIChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  
  String _selectedProvider = 'openai';
  final _apiKeyController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _send() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    
    final apiKey = _apiKeyController.text.trim();
    if (apiKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an API Key in settings')),
      );
      return;
    }

    ref.read(aIChatProvider(widget.serverId).notifier).sendMessage(  // ✅ Fixed
      text,
      _selectedProvider,
      apiKey,
    );
    _messageController.clear();
  }

  void _showApprovalSheet(BuildContext context, AIResponse response) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => ApprovalSheet(
        response: response,
        onApprove: (commands, edits) {
          Navigator.pop(context);
          ref.read(aIChatProvider(widget.serverId).notifier).approve(commands, edits);  // ✅ Fixed
        },
        onCancel: () => Navigator.pop(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(aIChatProvider(widget.serverId));  // ✅ Fixed

    ref.listen(aIChatProvider(widget.serverId), (prev, next) {  // ✅ Fixed
      _scrollToBottom();
      
      final notifier = ref.read(aIChatProvider(widget.serverId).notifier);  // ✅ Fixed
      if (next.isNotEmpty && next.last.structuredResponse != null && notifier.pendingResponse != null) {
        final response = next.last.structuredResponse!;
        notifier.clearPending();
        _showApprovalSheet(context, response);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Chat'),
        actions: [
          IconButton(
            onPressed: () => _showSettings(context),  // ✅ Removed missing syncContext()
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isUser = msg.role == 'user';
                return _ChatBubble(text: msg.text, isUser: isUser);
              },
            ),
          ),
          _buildInput(),
        ],
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      padding: EdgeInsets.fromLTRB(12, 12, 12, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Ask anything about your project...',
                border: InputBorder.none,
              ),
              onSubmitted: (v) => _send(),
            ),
          ),
          IconButton(
            onPressed: _send,
            icon: const Icon(Icons.send, color: Color(0xFF6161F2)),
          ),
        ],
      ),
    );
  }

  void _showSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('AI Settings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedProvider,
              decoration: const InputDecoration(labelText: 'AI Provider'),
              items: const [
                DropdownMenuItem(value: 'openai', child: Text('OpenAI (GPT-4)')),
                DropdownMenuItem(value: 'anthropic', child: Text('Anthropic (Claude)')),
                DropdownMenuItem(value: 'gemini', child: Text('Google (Gemini)')),
                DropdownMenuItem(value: 'grok', child: Text('xAI (Grok)')),
              ],
              onChanged: (v) => setState(() => _selectedProvider = v!),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _apiKeyController,
              decoration: const InputDecoration(
                labelText: 'API Key',
                helperText: 'Keys are only stored in memory during the session.',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;

  const _ChatBubble({required this.text, required this.isUser});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser
              ? const Color(0xFF6161F2)
              : Theme.of(context).brightness == Brightness.dark
                  ? Colors.white10
                  : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        child: Text(
          text,
          style: TextStyle(color: isUser ? Colors.white : null),
        ),
      ),
    );
  }
}
