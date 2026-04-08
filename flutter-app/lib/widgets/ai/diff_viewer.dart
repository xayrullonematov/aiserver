import 'package:flutter/material.dart';

class DiffViewer extends StatelessWidget {
  final String? oldContent;
  final String newContent;

  const DiffViewer({super.key, this.oldContent, required this.newContent});

  @override
  Widget build(BuildContext context) {
    if (oldContent == null) {
      return Container(
        padding: const EdgeInsets.all(8),
        color: Colors.green.withOpacity(0.1),
        child: Text(
          newContent,
          style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 12),
        ),
      );
    }

    // Very simple line-based diff for the MVP
    final oldLines = oldContent!.split('\n');
    final newLines = newContent.split('\n');
    
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark 
            ? Colors.white.withOpacity(0.05) 
            : Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Diff Preview:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 8),
          // For simplicity, just show them sequentially if they differ
          ..._buildDiffLines(),
        ],
      ),
    );
  }

  List<Widget> _buildDiffLines() {
    final List<Widget> widgets = [];
    final oldLines = oldContent!.split('\n');
    final newLines = newContent.split('\n');

    // This is a naive diff, but works for visualization
    int i = 0;
    while (i < oldLines.length || i < newLines.length) {
      if (i < oldLines.length && i < newLines.length) {
        if (oldLines[i] == newLines[i]) {
          widgets.add(_Line(text: oldLines[i], color: Colors.grey.withOpacity(0.5)));
        } else {
          widgets.add(_Line(text: '- ${oldLines[i]}', color: Colors.red.withOpacity(0.2)));
          widgets.add(_Line(text: '+ ${newLines[i]}', color: Colors.green.withOpacity(0.2)));
        }
      } else if (i < oldLines.length) {
        widgets.add(_Line(text: '- ${oldLines[i]}', color: Colors.red.withOpacity(0.2)));
      } else if (i < newLines.length) {
        widgets.add(_Line(text: '+ ${newLines[i]}', color: Colors.green.withOpacity(0.2)));
      }
      i++;
      if (i > 50) { // Safety break for very long files
        widgets.add(const Text('... truncated ...', style: TextStyle(fontSize: 10)));
        break;
      }
    }
    return widgets;
  }
}

class _Line extends StatelessWidget {
  final String text;
  final Color color;

  const _Line({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: color,
      child: Text(
        text,
        style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 11),
      ),
    );
  }
}
