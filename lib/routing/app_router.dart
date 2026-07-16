import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'route_paths.dart';
import '../providers/auth_provider.dart';
import '../presentation/splash/splash_screen.dart';
import '../presentation/auth/login_screen.dart';
import '../presentation/auth/register_screen.dart';
import '../presentation/onboarding/business_setup_screen.dart';
import '../presentation/dashboard/dashboard_screen.dart';
import '../presentation/services/service_form_screen.dart';
import '../presentation/customers/customer_detail_screen.dart';
import '../presentation/customers/customer_form_screen.dart';
import '../presentation/transactions/transaction_form_screen.dart';
import '../presentation/transactions/transaction_detail_screen.dart';
import '../presentation/invoices/invoice_preview_screen.dart';
import '../presentation/settings/business_profile_screen.dart';
import '../presentation/settings/invoice_settings_screen.dart';
import '../presentation/reports/report_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: RoutePaths.splash,
    routes: [
      GoRoute(path: RoutePaths.splash, builder: (_, _) => const SplashScreen()),
      GoRoute(path: RoutePaths.login, builder: (_, _) => const LoginScreen()),
      GoRoute(path: RoutePaths.register, builder: (_, _) => const RegisterScreen()),
      GoRoute(path: RoutePaths.onboarding, builder: (_, _) => const BusinessSetupScreen()),
      GoRoute(path: RoutePaths.dashboard, builder: (_, _) => const DashboardScreen()),
      GoRoute(path: RoutePaths.serviceForm, builder: (_, _) => const ServiceFormScreen()),
      GoRoute(path: RoutePaths.businessProfile, builder: (_, _) => const BusinessProfileScreen()),
      GoRoute(path: RoutePaths.invoiceSettings, builder: (_, _) => const InvoiceSettingsScreen()),
      GoRoute(path: RoutePaths.reports, builder: (_, _) => const ReportScreen()),
      GoRoute(path: RoutePaths.customerForm, builder: (_, _) => const CustomerFormScreen()),
      GoRoute(
        path: RoutePaths.customerDetail,
        builder: (_, state) => CustomerDetailScreen(customerId: state.pathParameters['id']!),
      ),
      GoRoute(path: RoutePaths.transactionForm, builder: (_, _) => const TransactionFormScreen()),
      GoRoute(
        path: RoutePaths.transactionDetail,
        builder: (_, state) => TransactionDetailScreen(transactionId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: RoutePaths.invoicePreview,
        builder: (_, state) => InvoicePreviewScreen(transactionId: state.pathParameters['id']!),
      ),
    ],
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final location = state.matchedLocation;

      if (location == RoutePaths.splash) return null;

      if (!isLoggedIn) {
        if (location == RoutePaths.login || location == RoutePaths.register) return null;
        return RoutePaths.login;
      }

      if (isLoggedIn && (location == RoutePaths.login || location == RoutePaths.register)) {
        return RoutePaths.dashboard;
      }

      return null;
    },
  );
});
