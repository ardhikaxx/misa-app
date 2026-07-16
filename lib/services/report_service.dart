import '../models/transaction_model.dart';
import 'transaction_service.dart';

class ReportService {
  final TransactionService _transactionService = TransactionService();

  Future<ReportData> getDailyReport(String uid) async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));

    final transactions = await _transactionService.getTransactionsByDateRangeSync(uid, start, end);
    return _calculateReport(transactions);
  }

  Future<ReportData> getWeeklyReport(String uid) async {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: now.weekday - 1));
    final startOfDay = DateTime(start.year, start.month, start.day);
    final end = startOfDay.add(const Duration(days: 7));

    final transactions = await _transactionService.getTransactionsByDateRangeSync(uid, startOfDay, end);
    return _calculateReport(transactions);
  }

  Future<ReportData> getMonthlyReport(String uid) async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 1);

    final transactions = await _transactionService.getTransactionsByDateRangeSync(uid, start, end);
    return _calculateReport(transactions);
  }

  Future<ReportData> getYearlyReport(String uid) async {
    final now = DateTime.now();
    final start = DateTime(now.year, 1, 1);
    final end = DateTime(now.year + 1, 1, 1);

    final transactions = await _transactionService.getTransactionsByDateRangeSync(uid, start, end);
    return _calculateReport(transactions);
  }

  Future<List<MonthlyRevenue>> getYearlyMonthlyRevenue(String uid) async {
    final now = DateTime.now();
    final start = DateTime(now.year, 1, 1);
    final end = DateTime(now.year + 1, 1, 1);

    final transactions = await _transactionService.getTransactionsByDateRangeSync(uid, start, end);

    final monthlyMap = <int, int>{};
    for (int i = 1; i <= 12; i++) {
      monthlyMap[i] = 0;
    }

    for (final t in transactions) {
      if (t.paymentStatus == 'paid' || t.paymentStatus == 'partial') {
        final revenue = t.paymentStatus == 'paid' ? t.totalAmount : t.amountPaid;
        monthlyMap[t.transactionDate.month] =
            (monthlyMap[t.transactionDate.month] ?? 0) + revenue;
      }
    }

    return monthlyMap.entries
        .map((e) => MonthlyRevenue(month: e.key, revenue: e.value))
        .toList();
  }

  ReportData _calculateReport(List<TransactionModel> transactions) {
    int totalRevenue = 0;
    int totalTransactions = 0;

    for (final t in transactions) {
      if (t.paymentStatus == 'paid') {
        totalRevenue += t.totalAmount;
        totalTransactions++;
      } else if (t.paymentStatus == 'partial') {
        totalRevenue += t.amountPaid;
        totalTransactions++;
      }
    }

    final average = totalTransactions > 0 ? totalRevenue ~/ totalTransactions : 0;

    return ReportData(
      totalRevenue: totalRevenue,
      totalTransactions: totalTransactions,
      averageTransaction: average,
      transactions: transactions,
    );
  }
}

class ReportData {
  final int totalRevenue;
  final int totalTransactions;
  final int averageTransaction;
  final List<TransactionModel> transactions;

  const ReportData({
    required this.totalRevenue,
    required this.totalTransactions,
    required this.averageTransaction,
    required this.transactions,
  });
}

class MonthlyRevenue {
  final int month;
  final int revenue;

  const MonthlyRevenue({required this.month, required this.revenue});
}
