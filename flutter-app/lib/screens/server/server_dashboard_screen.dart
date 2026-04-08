import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ai_server_copilot/providers/server_provider.dart';

class ServerDashboardScreen extends ConsumerWidget {
  final String serverId;

  const ServerDashboardScreen({super.key, required this.serverId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsync = ref.watch(serverMetricsProvider(serverId));

    return Scaffold(
      appBar: AppBar(title: const Text('Server Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildStatusCard(context),
          const SizedBox(height: 16),
          _buildQuickActions(context),
          const SizedBox(height: 24),
          _buildSection(context, 'Resource Usage'),
          metricsAsync.when(
            data: (metrics) => Column(
              children: [
                _buildMetricRow(
                  context,
                  'CPU Usage',
                  metrics['cpu'] ?? 0.0,
                  Colors.blue,
                ),
                const SizedBox(height: 16),
                _buildMetricRow(
                  context,
                  'RAM Usage',
                  metrics['ram'] ?? 0.0,
                  Colors.orange,
                ),
              ],
            ),
            loading: () => const Center(child: Padding(
              padding: EdgeInsets.all(24.0),
              child: CircularProgressIndicator(),
            )),
            error: (err, stack) => Text('Error loading metrics: $err'),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(BuildContext context, String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            Text('${value.toStringAsFixed(1)}%', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: value / 100,
          backgroundColor: color.withOpacity(0.1),
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildStatusCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.green,
                  radius: 6,
                ),
                const SizedBox(width: 8),
                Text('SSH Connected', style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 8),
            const Text('Real-time monitoring active'),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: [
        _ActionItem(
          icon: Icons.folder_open,
          label: 'Files',
          onTap: () => context.push('/server/$serverId/files'),
        ),
        _ActionItem(
          icon: Icons.terminal,
          label: 'Terminal',
          onTap: () => context.push('/server/$serverId/terminal'),
        ),
        _ActionItem(
          icon: Icons.smart_toy_outlined,
          label: 'AI Chat',
          onTap: () => context.push('/server/$serverId/ai-chat'),
        ),
      ],
    );
  }

  Widget _buildSection(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _ActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionItem({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: const Color(0xFF6161F2)),
            const SizedBox(height: 8),
            Text(label),
          ],
        ),
      ),
    );
  }
}
