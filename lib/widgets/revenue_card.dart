import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/admin_stats_provider.dart';

class RevenueTrendsCard extends StatefulWidget {
  const RevenueTrendsCard({Key? key}) : super(key: key);

  @override
  State<RevenueTrendsCard> createState() => _RevenueTrendsCardState();
}

class _RevenueTrendsCardState extends State<RevenueTrendsCard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminStatsProvider>(context, listen: false).fetchRevenueTrends();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Consumer<AdminStatsProvider>(
        builder: (context, provider, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row with Title & Dropdown Toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    provider.isRevenueMonthly
                        ? 'Revenue Trends (${DateTime.now().year})'
                        : 'Revenue Trends',
                    style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  Container(
                    height: 32,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.01),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: DropdownButton<String>(
                      value: provider.isRevenueMonthly ? 'This Year' : 'Last 7 Days',
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Colors.grey),
                      elevation: 1,
                      style: GoogleFonts.lexend(fontSize: 12, color: Colors.black, fontWeight: FontWeight.w500),
                      underline: const SizedBox(),
                      onChanged: (String? newValue) {
                        bool isMonthly = newValue == 'This Year';
                        provider.toggleRevenueChartType(isMonthly);
                      },
                      items: <String>['Last 7 Days', 'This Year']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Chart Area / Loading State
              if (provider.isRevenueLoading)
                const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (provider.revenueTrends.isEmpty)
                const SizedBox(
                  height: 200,
                  child: Center(
                    child: Text('No revenue data available', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ),
                )
              else
                SizedBox(
                  height: 200,
                  // Entry Scale & Fade Animation Builder (Keyed with isRevenueMonthly)
                  child: TweenAnimationBuilder<double>(
                    key: ValueKey('${provider.isRevenueMonthly}_${provider.revenueTrends.length}'),
                    tween: Tween<double>(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.easeOutCubic,
                    builder: (context, animValue, child) {
                      return Transform.scale(
                        scale: animValue,
                        child: Opacity(
                          opacity: animValue,
                          child: child,
                        ),
                      );
                    },
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade100, strokeWidth: 1),
                        ),
                        // Interactive Tooltip (Date/Month & Amount)
                        lineTouchData: LineTouchData(
                          handleBuiltInTouches: true,
                          touchTooltipData: LineTouchTooltipData(
                            getTooltipColor: (LineBarSpot touchedSpot) => Colors.black.withOpacity(0.85),
                            tooltipRoundedRadius: 8,
                            tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            getTooltipItems: (List<LineBarSpot> touchedSpots) {
                              return touchedSpots.map((LineBarSpot touchedSpot) {
                                final index = touchedSpot.x.toInt();
                                if (index >= 0 && index < provider.revenueTrends.length) {
                                  final item = provider.revenueTrends[index];
                                  final label = provider.isRevenueMonthly
                                      ? (item['month']?.toString() ?? '')
                                      : (item['_id']?.toString() ?? '');
                                  final revenue = touchedSpot.y.toInt();
                                  return LineTooltipItem(
                                    '$label\n₹$revenue',
                                    GoogleFonts.lexend(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                }
                                return null;
                              }).whereType<LineTooltipItem>().toList();
                            },
                          ),
                        ),
                        titlesData: FlTitlesData(
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 1, // Duplicate dates prevent karne ke liye
                              getTitlesWidget: (value, meta) {
                                int index = value.toInt();
                                if (index >= 0 && index < provider.revenueTrends.length) {
                                  final item = provider.revenueTrends[index];
                                  String labelText = '';
                                  if (provider.isRevenueMonthly) {
                                    labelText = item['month']?.toString() ?? '';
                                  } else {
                                    String dateStr = item['_id']?.toString() ?? '';
                                    labelText = dateStr.length >= 10 ? dateStr.substring(8, 10) : dateStr;
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      labelText,
                                      style: GoogleFonts.lexend(fontSize: 10, color: Colors.grey),
                                    ),
                                  );
                                }
                                return const Text('');
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: provider.revenueTrends.asMap().entries.map((entry) {
                              int i = entry.key;
                              var item = entry.value;
                              double revenue = (item['totalRevenue'] ?? 0).toDouble();
                              return FlSpot(i.toDouble(), revenue);
                            }).toList(),
                            isCurved: true,
                            color: Colors.teal.shade600,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true,
                              color: Colors.teal.shade50.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}