import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ai_server_copilot/screens/onboarding/onboarding_screen.dart';
import 'package:ai_server_copilot/screens/auth/login_screen.dart';
import 'package:ai_server_copilot/screens/auth/register_screen.dart';
import 'package:ai_server_copilot/screens/home/home_screen.dart';
import 'package:ai_server_copilot/screens/server/add_server_screen.dart';
import 'package:ai_server_copilot/screens/server/server_dashboard_screen.dart';
import 'package:ai_server_copilot/screens/server/file_explorer_screen.dart';
import 'package:ai_server_copilot/screens/server/terminal_screen.dart';
import 'package:ai_server_copilot/screens/server/ai_chat_screen.dart';

import 'package:ai_server_copilot/screens/server/file_editor_screen.dart';

part 'router.g.dart';

@riverpod
GoRouter router(RouterRef ref) {
  return GoRouter(
    initialLocation: '/onboarding',
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'add-server',
            builder: (context, state) => const AddServerScreen(),
          ),
          GoRoute(
            path: 'server/:id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return ServerDashboardScreen(serverId: id);
            },
            routes: [
              GoRoute(
                path: 'files',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return FileExplorerScreen(serverId: id);
                },
                routes: [
                  GoRoute(
                    path: 'edit',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      final path = state.uri.queryParameters['path']!;
                      return FileEditorScreen(serverId: id, path: path);
                    },
                  ),
                ],
              ),
              GoRoute(
                path: 'terminal',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return TerminalScreen(serverId: id);
                },
              ),
              GoRoute(
                path: 'ai-chat',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return AIChatScreen(serverId: id);
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
