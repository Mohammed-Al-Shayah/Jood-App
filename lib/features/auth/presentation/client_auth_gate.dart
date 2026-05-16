import 'package:flutter/material.dart';

import '../../../core/di/service_locator.dart';
import '../../../features/main_shell/presentation/pages/main_shell_screen.dart';
import '../../../features/users/domain/usecases/sync_auth_user_usecase.dart';
import '../domain/entities/auth_user_entity.dart';
import '../domain/usecases/watch_auth_state_changes_usecase.dart';
import 'auth_placeholder_screen.dart';
import 'login/page/login.page.dart';

class ClientAuthGate extends StatelessWidget {
  const ClientAuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthUserEntity?>(
      stream: getIt<WatchAuthStateChangesUseCase>()(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const AuthPlaceholderScreen();
        }

        final authUser = snapshot.data;
        if (authUser == null) {
          return const LoginPage();
        }

        return _ClientAuthSyncGate(authUser: authUser);
      },
    );
  }
}

class _ClientAuthSyncGate extends StatefulWidget {
  const _ClientAuthSyncGate({required this.authUser});

  final AuthUserEntity authUser;

  @override
  State<_ClientAuthSyncGate> createState() => _ClientAuthSyncGateState();
}

class _ClientAuthSyncGateState extends State<_ClientAuthSyncGate> {
  Future<void>? _syncFuture;

  @override
  void initState() {
    super.initState();
    _syncFuture = _syncAuthUser(widget.authUser);
  }

  @override
  void didUpdateWidget(covariant _ClientAuthSyncGate oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.authUser.uid != widget.authUser.uid) {
      _syncFuture = _syncAuthUser(widget.authUser);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _syncFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const AuthPlaceholderScreen();
        }
        return const MainShellScreen();
      },
    );
  }

  Future<void> _syncAuthUser(AuthUserEntity authUser) async {
    try {
      await getIt<SyncAuthUserUseCase>()(authUser);
    } catch (error, stackTrace) {
      debugPrint('Client auth sync failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }
}
