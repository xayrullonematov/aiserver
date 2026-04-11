import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart'; // ✅ Fixed: missing import
import 'package:ai_server_copilot/providers/file_explorer_provider.dart';

class FileExplorerScreen extends ConsumerWidget {
  final String serverId;

  const FileExplorerScreen({super.key, required this.serverId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rootPath = ref.watch(explorerRootPathProvider(serverId));
    final currentPath = ref.watch(currentPathProvider(serverId));
    final filesAsync = ref.watch(
      fileExplorerNotifierProvider(serverId, currentPath),
    );

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('File Explorer', style: TextStyle(fontSize: 16)),
            Text(
              currentPath,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed:
              currentPath == rootPath
                  ? () => Navigator.pop(context)
                  : () =>
                      ref.read(currentPathProvider(serverId).notifier).goUp(),
        ),
        actions: [
          IconButton(
            onPressed:
                () =>
                    ref
                        .read(
                          fileExplorerNotifierProvider(
                            serverId,
                            currentPath,
                          ).notifier,
                        )
                        .refresh(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: filesAsync.when(
        data:
            (files) => ListView.builder(
              itemCount: files.length,
              itemBuilder: (context, index) {
                final file = files[index];
                final bool isDir = file['is_dir'] == true;

                return ListTile(
                  leading: Icon(
                    isDir ? Icons.folder : Icons.insert_drive_file,
                    color: isDir ? Colors.blue : null,
                  ),
                  title: Text(file['name']),
                  subtitle: isDir ? null : Text(_formatSize(file['size'])),
                  trailing: const Icon(Icons.more_vert),
                  onTap: () {
                    if (isDir) {
                      final nextPath =
                          currentPath == '/'
                              ? '/${file['name']}'
                              : '$currentPath/${file['name']}';
                      ref
                          .read(currentPathProvider(serverId).notifier)
                          .navigateTo(nextPath);
                    } else {
                      final filePath =
                          currentPath == '/'
                              ? '/${file['name']}'
                              : '$currentPath/${file['name']}';
                      final route =
                          Uri(
                            path: '/server/$serverId/files/edit',
                            queryParameters: {'path': filePath},
                          ).toString();
                      context.push(route);
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

  String _formatSize(dynamic size) {
    if (size is! num) return '';
    if (size < 1024) return '${size.toInt()} B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    if (size < 1024 * 1024 * 1024) {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
