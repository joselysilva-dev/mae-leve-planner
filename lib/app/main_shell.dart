import 'package:flutter/material.dart';

import '../core/widgets/planner_bottom_bar.dart';
import '../features/home/presentation/pages/home_page.dart';
import '../features/profile/presentation/pages/profile_page.dart';
import '../features/routine/presentation/pages/routine_page.dart';
import '../features/self_care/presentation/pages/self_care_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  final _navigator = GlobalKey<NavigatorState>();
  final _selected = ValueNotifier<int>(0);
  bool _innerCanHandlePop = false;
  void _select(int index) {
    bool blocked = false;
    _navigator.currentState?.popUntil((route) {
      blocked = route.popDisposition == RoutePopDisposition.doNotPop;
      return route.isFirst || blocked;
    });
    if (!blocked) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      setState(() => _selected.value = index);
    }
  }

  @override
  void dispose() {
    _selected.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: _selected.value == 0 && !_innerCanHandlePop,
    onPopInvokedWithResult: (didPop, result) {
      if (didPop) return;
      if (_innerCanHandlePop) {
        _navigator.currentState?.maybePop();
      } else if (_selected.value != 0) {
        _select(0);
      }
    },
    child: Scaffold(
      body: NotificationListener<NavigationNotification>(
        onNotification: (notification) {
          if (_innerCanHandlePop != notification.canHandlePop) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() => _innerCanHandlePop = notification.canHandlePop);
              }
            });
          }
          return true;
        },
        child: Navigator(
          key: _navigator,
          onGenerateRoute: (_) => MaterialPageRoute<void>(
            builder: (context) => ValueListenableBuilder<int>(
              valueListenable: _selected,
              builder: (context, index, _) => IndexedStack(
                index: index,
                children: [
                  HomePage(active: index == 0, onSelectTab: _select),
                  RoutinePage(embedded: true, active: index == 1),
                  SelfCarePage(embedded: true, active: index == 2),
                  const ProfilePage(embedded: true),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: PlannerBottomBar(
        index: _selected.value,
        onSelected: _select,
      ),
    ),
  );
}
