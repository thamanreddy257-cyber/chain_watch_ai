import 'package:go_router/go_router.dart';
import '../../features/landing/landing_page.dart';
import '../../features/dashboard/dashboard_page.dart';
import '../../features/wallet_investigation/wallet_investigation_page.dart';
import '../../features/network_graph/network_graph_page.dart';
import '../../features/alerts/alerts_page.dart';
import '../../features/ai_assistant/ai_assistant_page.dart';
import '../../features/reports/report_page.dart';
import '../../shared/widgets/app_shell.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => const NoTransitionPage(child: LandingPage()),
    ),
    ShellRoute(
      builder: (context, state, child) {
        return AppShell(
          currentPath: state.uri.path,
          onNavigate: (path) => context.go(path),
          child: child,
        );
      },
      routes: [
        GoRoute(
          path: '/dashboard',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: DashboardPage()),
        ),
        GoRoute(
          path: '/wallet',
          pageBuilder: (context, state) {
            final address = state.uri.queryParameters['address'];
            return NoTransitionPage(
                child: WalletInvestigationPage(initialAddress: address));
          },
        ),
        GoRoute(
          path: '/network',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: NetworkGraphPage()),
        ),
        GoRoute(
          path: '/alerts',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: AlertsPage()),
        ),
        GoRoute(
          path: '/assistant',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: AiAssistantPage()),
        ),
        GoRoute(
          path: '/reports',
          pageBuilder: (context, state) {
            final address = state.uri.queryParameters['address'];
            return NoTransitionPage(
                child: ReportPage(initialAddress: address));
          },
        ),
      ],
    ),
  ],
);
