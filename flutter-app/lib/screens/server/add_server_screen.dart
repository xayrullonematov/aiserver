import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ai_server_copilot/providers/server_provider.dart';

class AddServerScreen extends ConsumerStatefulWidget {
  const AddServerScreen({super.key});

  @override
  ConsumerState<AddServerScreen> createState() => _AddServerScreenState();
}

class _AddServerScreenState extends ConsumerState<AddServerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _hostController = TextEditingController();
  final _portController = TextEditingController(text: '22');
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _projectPathController = TextEditingController(text: '/var/www');
  String _authType = 'password';

  @override
  void dispose() {
    _displayNameController.dispose();
    _hostController.dispose();
    _portController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _projectPathController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    try {
      await ref.read(serversProvider.notifier).addServer(
            displayName: _displayNameController.text,
            host: _hostController.text,
            port: int.parse(_portController.text),
            username: _usernameController.text,
            authType: _authType,
            passwordOrKey: _passwordController.text,
            projectPath: _projectPathController.text,
          );
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add server: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final serversState = ref.watch(serversProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Add Server')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            TextFormField(
              controller: _displayNameController,
              decoration: const InputDecoration(labelText: 'Display Name', border: OutlineInputBorder()),
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _hostController,
              decoration: const InputDecoration(labelText: 'Host (IP or Domain)', border: OutlineInputBorder()),
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _portController,
              decoration: const InputDecoration(labelText: 'Port', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username', border: OutlineInputBorder()),
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _authType,
              decoration: const InputDecoration(labelText: 'Auth Type', border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'password', child: Text('Password')),
                DropdownMenuItem(value: 'key', child: Text('Private Key')),
              ],
              onChanged: (v) => setState(() => _authType = v!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: _authType == 'password' ? 'Password' : 'Private Key Content',
                border: const OutlineInputBorder(),
              ),
              obscureText: _authType == 'password',
              maxLines: _authType == 'password' ? 1 : 5,
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _projectPathController,
              decoration: const InputDecoration(labelText: 'Project Path', border: OutlineInputBorder()),
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: serversState.isLoading ? null : _submit,
                child: serversState.isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Connect & Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
