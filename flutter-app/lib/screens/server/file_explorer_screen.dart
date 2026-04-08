import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_server_copilot/providers/file_explorer_provider.dart';

class FileExplorerScreen extends ConsumerWidget {
  final String serverId;

  const FileExplorerScreen({super.key, required this.serverId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPath = ref.watch(currentPathProvider(serverId));
    final filesAsync = ref.watch(fileExplorerNotifierProvider(serverId, currentPath));

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('File Explorer', style: TextStyle(fontSize: 16)),
            Text(currentPath, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: currentPath == '.' 
            ? () => Navigator.pop(context)
            : () => ref.read(currentPathProvider(serverId).notifier).goUp(),
        ),
        actions: [
          IconButton(
            onPressed: () => ref.read(fileExplorerNotifierProvider(serverId, currentPath).notifier).refresh(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: filesAsync.when(
        data: (files) => ListView.builder(
          itemCount: files.length,
          itemBuilder: (context, index) {
            final file = files[index];
            final bool isDir = file['type'] == 'directory';
            
            return ListTile(
              leading: Icon(isDir ? Icons.folder : Icons.insert_drive_file,
                  color: isDir ? Colors.blue : null),
              title: Text(file['name']),
              subtitle: isDir ? null : Text(file['size_human'] ?? ''),
              trailing: const Icon(Icons.more_vert),
              onTap: () {
                if (isDir) {
                  final nextPath = currentPath == '.' ? file['name'] : '$currentPath/${file['name']}';
                  ref.read(currentPathProvider(serverId).notifier).navigateTo(nextPath);
                } else {
                  final filePath = currentPath == '.' ? file['name'] : '$currentPath/${file['name']}';
                  context.push('/server/$serverId/files/edit?path=$filePath');
                }
              },
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
