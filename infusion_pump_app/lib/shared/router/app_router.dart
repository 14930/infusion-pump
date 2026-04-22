import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/dashboard/dashboard_screen.dart';
import '../../features/alarms/alarms_screen.dart';
import '../../features/control/control_screen.dart';
import '../../features/dose_calculator/dose_calculator_screen.dart';
import '../../features/history/history_screen.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/blood_cell_background.dart';

/// App router using go_router with a ShellRoute for persistent bottom nav.
final appRouter = GoRouter(
  initialLocation: '/dashboard',
  routes: [
    ShellRoute(
      builder: (context, state, child) => _ScaffoldWithNavBar(child: child),
      routes: [
        GoRoute(
          path: '/dashboard',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const DashboardScreen(),
            transitionsBuilder: _fadeTransition,
          ),
        ),
        GoRoute(
          path: '/alarms',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const AlarmsScreen(),
            transitionsBuilder: _fadeTransition,
          ),
        ),
        GoRoute(
          path: '/control',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const ControlScreen(),
            transitionsBuilder: _fadeTransition,
          ),
        ),
        GoRoute(
          path: '/dose-calculator',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const DoseCalculatorScreen(),
            transitionsBuilder: _fadeTransition,
          ),
        ),
        GoRoute(
          path: '/history',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const HistoryScreen(),
            transitionsBuilder: _fadeTransition,
          ),
        ),
      ],
    ),
  ],
);

Widget _fadeTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return FadeTransition(opacity: animation, child: child);
}

class _ScaffoldWithNavBar extends StatelessWidget {
  final Widget child;

  const _ScaffoldWithNavBar({required this.child});

  static const _navItems = [
    (icon: Icons.dashboard_rounded, label: 'Dashboard', path: '/dashboard'),
    (icon: Icons.warning_amber_rounded, label: 'Alarms', path: '/alarms'),
    (icon: Icons.tune_rounded, label: 'Control', path: '/control'),
    (
      icon: Icons.calculate_rounded,
      label: 'Dose Calc',
      path: '/dose-calculator'
    ),
    (icon: Icons.history_rounded, label: 'History', path: '/history'),
  ];

  @override
  Widget build(BuildContext context) {
    final currentLocation = GoRouterState.of(context).uri.toString();
    final currentIndex = _navItems.indexWhere(
      (item) => currentLocation.startsWith(item.path),
    );

    return BloodCellBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: child,
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: AppTheme.background,
            border: Border(
              top: BorderSide(color: Color(0x441E88E5), width: 0.5),
            ),
          ),
          child: BottomNavigationBar(
            currentIndex: currentIndex >= 0 ? currentIndex : 0,
            onTap: (index) {
              final path = _navItems[index].path;
              if (currentLocation != path) {
                context.go(path);
              }
            },
            items: _navItems
                .map(
                  (item) => BottomNavigationBarItem(
                    icon: Icon(item.icon),
                    label: item.label,
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}
