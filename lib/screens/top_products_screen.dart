import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/admin_stats_provider.dart';

class TopProductsScreen extends StatefulWidget {
  const TopProductsScreen({Key? key}) : super(key: key);

  @override
  State<TopProductsScreen> createState() => _TopProductsScreenState();
}

class _TopProductsScreenState extends State<TopProductsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminStatsProvider>().fetchAllTopProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'All Top Selling Products',
          style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Consumer<AdminStatsProvider>(
        builder: (context, provider, child) {
          if (provider.isAllTopProductsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.allTopProducts.isEmpty) {
            return Center(
              child: Text(
                'No products sold yet',
                style: GoogleFonts.lexend(fontSize: 14, color: Colors.grey),
              ),
            );
          }

          // Max sold count nikal rahe hain progress bar scaling ke liye
          final int maxSold = provider.allTopProducts.isNotEmpty
              ? (provider.allTopProducts[0]['totalSold'] ?? 1)
              : 1;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: provider.allTopProducts.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final product = provider.allTopProducts[index];
              final int currentSold = product['totalSold'] ?? 0;
              double progress = maxSold > 0 ? (currentSold / maxSold).clamp(0.0, 1.0) : 0.0;

              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade100),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.01),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Rank Badge
                        Container(
                          width: 28,
                          alignment: Alignment.center,
                          child: Text(
                            '#${index + 1}',
                            style: GoogleFonts.lexend(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade500),
                          ),
                        ),
                        const SizedBox(width: 4),
                        // Thumbnail with light background
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              product['thumbnail'] ?? '',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(
                                Icons.image_not_supported,
                                size: 20,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Title & Sold Count
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product['title'] ?? 'Unknown Product',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.lexend(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '$currentSold sold',
                                style: GoogleFonts.lexend(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.grey.shade500),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Price on the Right
                        // Unit Price & Total Revenue on the Right
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '₹${product['price']?.toStringAsFixed(0) ?? '0'}',
                              style: GoogleFonts.lexend(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Rev: ₹${product['totalRevenue']?.toStringAsFixed(0) ?? '0'}',
                              style: GoogleFonts.lexend(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Progress Bar Line at bottom of card item
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey.shade100,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.grey.shade800),
                        minHeight: 3,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}