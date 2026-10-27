import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart'; // 👈 fl_chart package zaroori hai
import '../providers/admin_stats_provider.dart';

class ProfitLossCard extends StatefulWidget {
  const ProfitLossCard({Key? key}) : super(key: key);

  @override
  State<ProfitLossCard> createState() => _ProfitLossCardState();
}

class _ProfitLossCardState extends State<ProfitLossCard> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminStatsProvider>(
      builder: (context, provider, child) {
        if (provider.isProfitLoading) {
          return Container(
            height: 220,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        final isProfit = provider.isProfitVal;
        final netProfit = provider.netProfitVal;
        final totalRevenue = provider.totalRevenueVal;
        final totalCost = provider.totalCostVal;

        // Agar revenue 0 hai toh default values taaki chart crash na ho
        final double safeRevenue = totalRevenue <= 0 ? 1.0 : totalRevenue;
        final double costPercentage = ((totalCost / safeRevenue) * 100).clamp(0, 100);
        final double profitPercentage = ((netProfit / safeRevenue) * 100).clamp(0, 100);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Financial Overview',
                      style: GoogleFonts.lexend(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: (isProfit ? Colors.green : Colors.red).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isProfit ? 'PROFIT' : 'LOSS',
                        style: GoogleFonts.lexend(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isProfit ? Colors.green.shade700 : Colors.red.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Donut Chart & Legend Row
                Row(
                  children: [
                    // Donut Chart View
                    SizedBox(
                      height: 140,
                      width: 140,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          PieChart(
                            PieChartData(
                              pieTouchData: PieTouchData(
                                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                                  setState(() {
                                    if (!event.isInterestedForInteractions ||
                                        pieTouchResponse == null ||
                                        pieTouchResponse.touchedSection == null) {
                                      touchedIndex = -1;
                                      return;
                                    }
                                    touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                                  });
                                },
                              ),
                              borderData: FlBorderData(show: false),
                              sectionsSpace: 3,
                              centerSpaceRadius: 50,
                              sections: [
                                // 1. Total Cost Slice (Orange)
                                PieChartSectionData(
                                  color: Colors.orange.shade800,
                                  value: totalCost > 0 ? totalCost : 0.1,
                                  title: '${costPercentage.toStringAsFixed(0)}%',
                                  radius: touchedIndex == 0 ? 25 : 20,
                                  titleStyle: GoogleFonts.lexend(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                // 2. Net Profit / Loss Slice (Green or Red)
                                PieChartSectionData(
                                  color: isProfit ? Colors.green.shade600 : Colors.red.shade600,
                                  value: netProfit > 0 ? netProfit : 0.1,
                                  title: '${profitPercentage.toStringAsFixed(0)}%',
                                  radius: touchedIndex == 1 ? 25 : 20,
                                  titleStyle: GoogleFonts.lexend(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Revenue',
                                style: GoogleFonts.lexend(fontSize: 10, color: Colors.grey),
                              ),
                              Text(
                                '₹${totalRevenue.toStringAsFixed(0)}',
                                style: GoogleFonts.lexend(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 30),

                    // Legends & Breakdown Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLegendItem(
                            color: Colors.blue.shade700,
                            title: 'Total Revenue',
                            value: '₹${totalRevenue.toStringAsFixed(0)}',
                          ),
                          const SizedBox(height: 10),
                          _buildLegendItem(
                            color: Colors.orange.shade800,
                            title: 'Total Cost',
                            value: '₹${totalCost.toStringAsFixed(0)}',
                          ),
                          const SizedBox(height: 10),
                          _buildLegendItem(
                            color: isProfit ? Colors.green.shade600 : Colors.red.shade600,
                            title: isProfit ? 'Net Profit' : 'Net Loss',
                            value: '₹${netProfit.abs().toStringAsFixed(0)}',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.lexend(fontSize: 12, color: Colors.grey.shade600),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.lexend(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}