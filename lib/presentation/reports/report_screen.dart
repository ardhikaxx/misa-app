import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/currency_formatter.dart';
import '../../providers/report_provider.dart';
import '../../services/report_service.dart';
import '../../core/constants/app_text_styles.dart';

class ReportScreen extends ConsumerStatefulWidget {
  const ReportScreen({super.key});

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  String _selectedPeriod = 'monthly';

  FutureProvider<ReportData> _getReportForPeriod() {
    switch (_selectedPeriod) {
      case 'daily':
        return dailyReportProvider;
      case 'weekly':
        return weeklyReportProvider;
      case 'monthly':
        return monthlyReportProvider;
      case 'yearly':
        return yearlyReportProvider;
      default:
        return monthlyReportProvider;
    }
  }

  @override
  Widget build(BuildContext context) {
    final reportAsync = ref.watch(_getReportForPeriod());
    final chartData = ref.watch(yearlyMonthlyRevenueProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.reports),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dailyReportProvider);
          ref.invalidate(weeklyReportProvider);
          ref.invalidate(monthlyReportProvider);
          ref.invalidate(yearlyReportProvider);
          ref.invalidate(yearlyMonthlyRevenueProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'daily', label: Text('Harian')),
                ButtonSegment(value: 'weekly', label: Text('Mingguan')),
                ButtonSegment(value: 'monthly', label: Text('Bulanan')),
                ButtonSegment(value: 'yearly', label: Text('Tahunan')),
              ],
              selected: {_selectedPeriod},
              onSelectionChanged: (Set<String> selected) {
                setState(() {
                  _selectedPeriod = selected.first;
                });
              },
            ),
            const SizedBox(height: 20),

            reportAsync.when(
              loading: () => const Center(
                  child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(),
              )),
              error: (e, st) => Center(child: Text('Error: $e')),
              data: (report) => Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _ReportCard(
                          title: AppStrings.totalRevenue,
                          value: CurrencyFormatter.format(report.totalRevenue),
                          icon: Icons.account_balance_wallet,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ReportCard(
                          title: AppStrings.totalTransactionsReport,
                          value: '${report.totalTransactions}',
                          icon: Icons.receipt,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _ReportCard(
                    title: AppStrings.averageTransaction,
                    value: CurrencyFormatter.format(report.averageTransaction),
                    icon: Icons.trending_up,
                    color: AppColors.accent,
                    isFullWidth: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Grafik Pendapatan Tahunan',
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: chartData.when(
                  loading: () => const SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (e, st) => SizedBox(
                    height: 200,
                    child: Center(child: Text('Error: $e')),
                  ),
                  data: (data) {
                    final maxY = data.isEmpty
                        ? 100.0
                        : data
                                .map((e) => e.revenue.toDouble())
                                .reduce((a, b) => a > b ? a : b) *
                            1.2;
                    final interval = maxY / 4;

                    return SizedBox(
                      height: 250,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: maxY,
                          barTouchData: BarTouchData(
                            touchTooltipData: BarTouchTooltipData(
                              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                return BarTooltipItem(
                                  CurrencyFormatter.format(rod.toY.toInt()),
                                  const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                );
                              },
                            ),
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  final months = [
                                    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
                                    'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'
                                  ];
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      months[value.toInt()],
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                  );
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 60,
                                getTitlesWidget: (value, meta) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: Text(
                                      CurrencyFormatter.formatShort(value.toInt()),
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                  );
                                },
                              ),
                            ),
                            topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                          ),
                          borderData: FlBorderData(show: false),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: interval,
                          ),
                          barGroups: data.asMap().entries.map((entry) {
                            return BarChartGroupData(
                              x: entry.key,
                              barRods: [
                                BarChartRodData(
                                  toY: entry.value.revenue.toDouble(),
                                  color: AppColors.primary,
                                  width: 20,
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(4)),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isFullWidth;

  const _ReportCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.bodySmall),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
