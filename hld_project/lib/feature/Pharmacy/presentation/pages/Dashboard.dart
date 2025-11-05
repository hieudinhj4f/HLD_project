// presentation/pages/dashboard.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hld_project/feature/Pharmacy/presentation/providers/dashboard_provider.dart';
import 'package:hld_project/feature/Pharmacy/domain/entity/pharmacy.dart';
import 'package:hld_project/feature/Pharmacy/domain/entity/kpi_stats.dart';

// ==================== MÀU SẮC ====================
const Color adminPrimaryGreen = Color(0xFF90D2B0);
const Color adminCardBackground = Colors.white;
const Color adminChipGreen = Color(0xFFC8E6C9);
const Color adminChipRed = Color(0xFFFFCDD2);
const Color adminTextGreen = Color(0xFF2E7D32);
const Color adminTextRed = Color(0xFFC62828);
const Color adminChipNeutral = Color(0xFFE0E0E0);
const Color adminTextNeutral = Color(0xFF616161);

// ==================== ADMIN HOME PAGE ====================
class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().fetchInitialData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, provider, child) {
        final isLoading = provider.isLoading;
        final stats = provider.stats;
        final chartData = provider.chartData;
        final pharmacy = provider.pharmacy;

        return Scaffold(
          backgroundColor: Colors.grey[50],
          body: SafeArea(
            bottom: false,
            child: RefreshIndicator(
              onRefresh: provider.refreshDataForSelectedPharmacy,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    const Text(
                      'HLD',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: adminPrimaryGreen,
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // PHARMACY SELECTOR
                    const _PharmacySelector(),
                    const SizedBox(height: 24),

                    // KPI GRID
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.25,
                      children: [
                        _KpiCard(
                          title: 'Total Products',
                          value: isLoading ? '...' : stats.totalProducts.toString(),
                          backgroundColor: isLoading ? adminCardBackground : adminPrimaryGreen,
                          textColor: isLoading ? Colors.black : Colors.white,
                        ),
                        _KpiCard(
                          title: 'Items Sold',
                          value: isLoading ? '...' : stats.itemsSold.toString(),
                          backgroundColor: adminCardBackground,
                          textColor: Colors.black,
                        ),
                        _KpiCard(
                          title: 'Today\'s Revenue',
                          value: isLoading ? '...' : formatRevenue(stats.todayRevenue),
                          backgroundColor: adminCardBackground,
                          textColor: Colors.black,
                          changeIndicator: _ChangeChip(value: isLoading ? 0 : stats.todayRevenuePercent),
                        ),
                        _KpiCard(
                          title: 'Total Revenue',
                          value: isLoading ? '...' : formatRevenue(stats.totalRevenue),
                          backgroundColor: adminCardBackground,
                          textColor: Colors.black,
                          changeIndicator: _ChangeChip(value: isLoading ? 0 : stats.totalRevenuePercent),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // VENDOR ACTIVITY
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Vendor Activity', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), // <-- Đã dịch
                        _WeekDropdown(),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // CHART
                    Container(
                      height: 200,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2)),
                        ],
                      ),
                      child: _VendorChart(data: isLoading ? List.filled(7, 0.0) : chartData),
                    ),
                    const SizedBox(height: 24),

                    // PHARMACY CARD
                    if (isLoading || pharmacy == null)
                      const _PharmacyInfoCard.loading()
                    else
                      _PharmacyInfoCard.data(pharmacy: pharmacy),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ==================== PHARMACY SELECTOR ====================
class _PharmacySelector extends StatelessWidget {
  const _PharmacySelector();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DashboardProvider>();
    final allPharmacies = provider.allAdminPharmacies;
    final selectedId = provider.selectedPharmacyId;
    final isListLoading = provider.isListLoading;

    if (isListLoading) {
      return Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          children: [
            SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            SizedBox(width: 16),
            Text("Loading pharmacy list...", style: TextStyle(color: Colors.grey)), // <-- Đã dịch
          ],
        ),
      );
    }

    if (allPharmacies.isEmpty) {
      return Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 16),
            Text("No pharmacies assigned yet.", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 3))],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: selectedId,
          hint: const Text("Select a pharmacy", style: TextStyle(color: Colors.grey)),
          icon: const Icon(Icons.keyboard_arrow_down, color: adminPrimaryGreen),
          items: allPharmacies.map((pharmacy) {
            return DropdownMenuItem<String>(
              value: pharmacy.id,
              child: Text(
                pharmacy.name,
                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: (newId) {
            if (newId != null && newId != selectedId) {
              context.read<DashboardProvider>().selectPharmacy(newId);
            }
          },
        ),
      ),
    );
  }
}

// ==================== KPI CARD ====================
class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final Color backgroundColor;
  final Color textColor;
  final Widget? changeIndicator;

  const _KpiCard({
    required this.title,
    required this.value,
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black,
    this.changeIndicator,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(color: textColor.withOpacity(0.8), fontSize: 14)),
              Icon(Icons.more_horiz, color: textColor.withOpacity(0.8), size: 20),
            ],
          ),
          const Spacer(),
          Text(value, style: TextStyle(color: textColor, fontSize: 32, fontWeight: FontWeight.bold)),
          if (changeIndicator != null) ...[
            const SizedBox(height: 8),
            changeIndicator!,
          ],
        ],
      ),
    );
  }
}

// ==================== FORMAT REVENUE ====================
String formatRevenue(double value) {
  if (value == 0) return '0';
  if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
  return '${(value / 1000).toStringAsFixed(0)}K';
}

// ==================== CHANGE CHIP ====================
class _ChangeChip extends StatelessWidget {
  final double value;
  const _ChangeChip({required this.value});

  @override
  Widget build(BuildContext context) {
    final (chipColor, textColor, prefix) = value > 0
        ? (adminChipGreen, adminTextGreen, '+')
        : value < 0
        ? (adminChipRed, adminTextRed, '')
        : (adminChipNeutral, adminTextNeutral, '');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: chipColor, borderRadius: BorderRadius.circular(20)),
      child: Text(
        '$prefix${value.toStringAsFixed(1)}%',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}

// ==================== WEEK DROPDOWN ====================
class _WeekDropdown extends StatelessWidget {
  const _WeekDropdown();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: const Row(children: [
        Text('This Week', style: TextStyle(color: Colors.grey)), // <-- Đã dịch
        SizedBox(width: 8),
        Icon(Icons.keyboard_arrow_down, color: Colors.grey, size: 20),
      ]),
    );
  }
}

// ==================== VENDOR CHART ====================
class _VendorChart extends StatelessWidget {
  final List<double> data;
  const _VendorChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final maxY = (data.reduce((a, b) => a > b ? a : b) * 1.2).clamp(100.0, double.infinity);

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles:false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const style = TextStyle(color: Colors.grey, fontSize: 14);
                const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']; // <-- Đã dịch
                return SideTitleWidget(meta: meta, child: Text(days[value.toInt()], style: style));
              },
              reservedSize: 38,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: maxY / 3,
              getTitlesWidget: (value, meta) => SideTitleWidget(
                meta: meta,
                child: Text(formatRevenue(value), style: const TextStyle(fontSize: 12)),
              ),
            ),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY / 3,
          getDrawingHorizontalLine: (_) => FlLine(color: Colors.grey[200]!, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        barGroups: data.asMap().entries.map((e) {
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: e.value,
                color: adminPrimaryGreen,
                width: 20,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ==================== PHARMACY CARD ====================
class _PharmacyInfoCard extends StatelessWidget {
  final Pharmacy? pharmacy;
  final bool isLoading;

  const _PharmacyInfoCard.data({required this.pharmacy}) : isLoading = false;
  const _PharmacyInfoCard.loading() : pharmacy = null, isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 3))],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: isLoading
                ? Container(width: 80, height: 80, color: Colors.grey[200])
                : pharmacy!.imageUrl != null
                ? Image.network(pharmacy!.imageUrl!, width: 80, height: 80, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _placeholder())
                : _placeholder(),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                isLoading
                    ? _shimmer(150, 20)
                    : Text(pharmacy!.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(children: [
                  const Text('Status:', style: TextStyle(color: Colors.grey, fontSize: 14)), // <-- Đã dịch
                  const SizedBox(width: 8),
                  isLoading ? _shimmer(100, 20) : _stateChip(pharmacy!.state),
                ]),
                const SizedBox(height: 4),
                Row(children: [
                  const Text('Staff:', style: TextStyle(color: Colors.grey, fontSize: 14)), // <-- Đã dịch
                  const SizedBox(width: 8),
                  isLoading
                      ? _shimmer(50, 16)
                      : Text('${pharmacy!.staffCount} people', style: const TextStyle(fontWeight: FontWeight.w500)), // <-- Đã dịch
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() => Container(width: 80, height: 80, color: Colors.grey[300], child: const Icon(Icons.local_pharmacy, color: Colors.grey));

  Widget _shimmer(double w, double h) => Container(width: w, height: h, color: Colors.grey[200]);

  Widget _stateChip(String state) {
    final (bg, fg) = state == 'Current Working'
        ? (adminChipGreen, adminTextGreen)
        : (Colors.orange[100]!, Colors.orange[800]!);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(state, style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }
}