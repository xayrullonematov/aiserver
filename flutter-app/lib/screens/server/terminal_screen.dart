import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_server_copilot/providers/terminal_provider.dart';

class TerminalScreen extends ConsumerStatefulWidget {
  final String serverId;

  const TerminalScreen({super.key, required this.serverId});

  @override
  ConsumerState<TerminalScreen> createState() => _TerminalScreenState();
}

class _TerminalScreenState extends ConsumerState<TerminalScreen> {
  final _commandController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(terminalNotifierProvider(widget.serverId).notifier).connect());
  }

  @override
  void dispose() {
    _commandController.dispose();
    _scrollController.dispose();
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

  @override
  Widget build(BuildContext context) {
    final output = ref.watch(terminalNotifierProvider(widget.serverId));
    
    // Auto-scroll on new output
    ref.listen(terminalNotifierProvider(widget.serverId), (prev, next) {
      if (prev?.length != next.length) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Terminal'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: output.length,
              itemBuilder: (context, index) {
                return Text(
                  output[index],
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    fontFamily: 'JetBrainsMono',
                    fontSize: 13,
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: const BoxDecoration(
              color: Color(0xFF1A1A1A),
              border: Border(top: BorderSide(color: Colors.white12)),
            ),
            child: Row(
              children: [
                const Text(
                  '\$ ',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: TextField(
                    controller: _commandController,
                    style: const TextStyle(color: Colors.white, fontFamily: 'JetBrainsMono', fontSize: 14),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      hintText: 'Enter command...',
                      hintStyle: TextStyle(color: Colors.white30),
                    ),
                    onSubmitted: (v) {
                      if (v.trim().isNotEmpty) {
                        ref.read(terminalNotifierProvider(widget.serverId).notifier).sendCommand(v);
                        _commandController.clear();
                      }
                    },
                  ),
                ),
                IconButton(
                  onPressed: () {
                    final v = _commandController.text;
                    if (v.trim().isNotEmpty) {
                      ref.read(terminalNotifierProvider(widget.serverId).notifier).sendCommand(v);
                      _commandController.clear();
                    }
                  },
                  icon: const Icon(Icons.send, color: Colors.white, size: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
