import 'package:flutter/material.dart';
import 'package:ai_server_copilot/models/ai_response.dart';
import 'package:ai_server_copilot/widgets/ai/diff_viewer.dart';

class ApprovalSheet extends StatefulWidget {
  final AIResponse response;
  final Function(List<int> approvedCommands, List<int> approvedEdits) onApprove;
  final VoidCallback onCancel;

  const ApprovalSheet({
    super.key,
    required this.response,
    required this.onApprove,
    required this.onCancel,
  });

  @override
  State<ApprovalSheet> createState() => _ApprovalSheetState();
}

class _ApprovalSheetState extends State<ApprovalSheet> {
  late Set<int> _approvedCommands;
  late Set<int> _approvedEdits;

  @override
  void initState() {
    super.initState();
    _approvedCommands = Set.from(Iterable<int>.generate(widget.response.proposedCommands.length));
    _approvedEdits = Set.from(Iterable<int>.generate(widget.response.fileEdits.length));
  }

  Color _getRiskColor(String level) {
    switch (level.toLowerCase()) {
      case 'critical': return Colors.red;
      case 'high': return Colors.deepOrange;
      case 'medium': return Colors.orange;
      default: return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Review Changes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getRiskColor(widget.response.riskLevel).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: _getRiskColor(widget.response.riskLevel)),
                ),
                child: Text(
                  widget.response.riskLevel.toUpperCase(),
                  style: TextStyle(color: _getRiskColor(widget.response.riskLevel), fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(widget.response.summary, style: const TextStyle(fontSize: 14)),
          const Divider(height: 32),
          
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                if (widget.response.proposedCommands.isNotEmpty) ...[
                  const Text('PROPOSED COMMANDS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 8),
                  ...widget.response.proposedCommands.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final cmd = entry.value;
                    return CheckboxListTile(
                      value: _approvedCommands.contains(idx),
                      onChanged: (v) => setState(() => v! ? _approvedCommands.add(idx) : _approvedCommands.remove(idx)),
                      title: Text(cmd.command, style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 13)),
                      subtitle: Text(cmd.description),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    );
                  }),
                  const SizedBox(height: 16),
                ],
                
                if (widget.response.fileEdits.isNotEmpty) ...[
                  const Text('FILE EDITS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 8),
                  ...widget.response.fileEdits.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final edit = entry.value;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CheckboxListTile(
                          value: _approvedEdits.contains(idx),
                          onChanged: (v) => setState(() => v! ? _approvedEdits.add(idx) : _approvedEdits.remove(idx)),
                          title: Text(edit.path, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          subtitle: edit.description != null ? Text(edit.description!) : null,
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        if (_approvedEdits.contains(idx))
                          Padding(
                            padding: const EdgeInsets.only(left: 32, bottom: 16),
                            child: DiffViewer(oldContent: edit.oldContent, newContent: edit.newContent),
                          ),
                      ],
                    );
                  }),
                ],
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onCancel,
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6161F2),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => widget.onApprove(
                    _approvedCommands.toList(),
                    _approvedEdits.toList(),
                  ),
                  child: const Text('Approve'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
