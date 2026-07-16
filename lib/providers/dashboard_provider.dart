import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction_model.dart';
import 'auth_provider.dart';
import 'transaction_provider.dart';

final dashboardProvider = FutureProvider<DashboardData>((ref) async {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) {
    return const DashboardData();
  }

  final transactionService = ref.watch(transactionServiceProvider);
  final now = DateTime.now();

  final todayStart = DateTime(now.year, now.month, now.day);
  final todayEnd = todayStart.add(const Duration(days: 1));
  final monthStart = DateTime(now.year, now.month, 1);
  final monthEnd = DateTime(now.year, now.month + 1, 1);

  final todayTransactions = await transactionService
      .getTransactionsByDateRangeSync(uid, todayStart, todayEnd);
  final monthlyTransactions = await transactionService
      .getTransactionsByDateRangeSync(uid, monthStart, monthEnd);

  // Ambil semua transaksi untuk hitung total piutang
  final allUnpaidTransactions =
      await transactionService.getUnpaidTransactions(uid);

  int todayIncome = 0;
  for (final t in todayTransactions) {
    if (t.paymentStatus == 'paid') {
      todayIncome = todayIncome + t.totalAmount;
    } else if (t.paymentStatus == 'partial') {
      todayIncome = todayIncome + t.amountPaid;
    }
  }

  int monthlyIncome = 0;
  for (final t in monthlyTransactions) {
    if (t.paymentStatus == 'paid') {
      monthlyIncome = monthlyIncome + t.totalAmount;
    } else if (t.paymentStatus == 'partial') {
      monthlyIncome = monthlyIncome + t.amountPaid;
    }
  }

  int pendingJobs = 0;
  for (final t in monthlyTransactions) {
    if (t.jobStatus == 'waiting' || t.jobStatus == 'in_progress') {
      pendingJobs++;
    }
  }

  // Hitung total piutang: unpaid = totalAmount, partial = (totalAmount - amountPaid)
  int totalReceivables = 0;
  int receivablesCount = 0;
  for (final t in allUnpaidTransactions) {
    if (t.paymentStatus == 'unpaid') {
      totalReceivables += t.totalAmount;
      receivablesCount++;
    } else if (t.paymentStatus == 'partial') {
      totalReceivables += (t.totalAmount - t.amountPaid);
      receivablesCount++;
    }
  }

  return DashboardData(
    todayIncome: todayIncome,
    monthlyIncome: monthlyIncome,
    pendingJobs: pendingJobs,
    recentTransactions: todayTransactions.take(5).toList(),
    totalReceivables: totalReceivables,
    receivablesCount: receivablesCount,
  );
});

class DashboardData {
  final int todayIncome;
  final int monthlyIncome;
  final int pendingJobs;
  final List<TransactionModel> recentTransactions;
  final int totalReceivables;
  final int receivablesCount;

  const DashboardData({
    this.todayIncome = 0,
    this.monthlyIncome = 0,
    this.pendingJobs = 0,
    this.recentTransactions = const [],
    this.totalReceivables = 0,
    this.receivablesCount = 0,
  });
}
