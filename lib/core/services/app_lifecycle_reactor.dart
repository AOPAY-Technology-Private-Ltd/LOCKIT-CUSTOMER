import 'package:flutter/material.dart';

import '../../features/auth/data/datasource/auth_remote_datasource.dart';


class AppLifecycleReactor extends StatefulWidget {
  final Widget child;
  const AppLifecycleReactor({super.key, required this.child});

  @override
  State<AppLifecycleReactor> createState() => _AppLifecycleReactorState();
}

class _AppLifecycleReactorState extends State<AppLifecycleReactor> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      print("🔄 App resumed: Syncing installed apps and checking pending actions...");
      _syncOnResume();
    }
  }

  Future<void> _syncOnResume() async {
    try {
      await AppMasterService.sendInstalledApps();
      await PendingActionService.checkPendingDeviceActions();
    } catch (e) {
      print("❌ Error syncing on resume: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}