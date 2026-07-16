import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/report_service.dart';
import 'auth_provider.dart';

final reportServiceProvider = Provider<ReportService>((ref) => ReportService());

final dailyReportProvider = FutureProvider<ReportData>((ref) async {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return const ReportData(totalRevenue: 0, totalTransactions: 0, averageTransaction: 0, transactions: []);
  return ref.watch(reportServiceProvider).getDailyReport(uid);
});

final weeklyReportProvider = FutureProvider<ReportData>((ref) async {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return const ReportData(totalRevenue: 0, totalTransactions: 0, averageTransaction: 0, transactions: []);
  return ref.watch(reportServiceProvider).getWeeklyReport(uid);
});

final monthlyReportProvider = FutureProvider<ReportData>((ref) async {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return const ReportData(totalRevenue: 0, totalTransactions: 0, averageTransaction: 0, transactions: []);
  return ref.watch(reportServiceProvider).getMonthlyReport(uid);
});

final yearlyReportProvider = FutureProvider<ReportData>((ref) async {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return const ReportData(totalRevenue: 0, totalTransactions: 0, averageTransaction: 0, transactions: []);
  return ref.watch(reportServiceProvider).getYearlyReport(uid);
});

final yearlyMonthlyRevenueProvider = FutureProvider<List<MonthlyRevenue>>((ref) async {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return [];
  return ref.watch(reportServiceProvider).getYearlyMonthlyRevenue(uid);
});

final selectedReportTypeProvider = StateProvider<String>((ref) => 'monthly');
