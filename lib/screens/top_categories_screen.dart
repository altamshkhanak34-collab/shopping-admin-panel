import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/admin_stats_provider.dart';
import 'category_products_screen.dart';

class TopCategoriesScreen extends StatefulWidget {
  const TopCategoriesScreen({Key? key}) : super(key: key);

  @override
  State<TopCategoriesScreen> createState() => _TopCategoriesScreenState();
}

class _TopCategoriesScreenState extends State<TopCategoriesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminStatsProvider>(context, listen: false).fetchAllTopCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text('Top Categories', style: GoogleFonts.lexend(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: const BackButton(color: Colors.black87),
      ),
      body: Consumer<AdminStatsProvider>(
        builder: (context, provider, child) {
          if (provider.isAllCategoriesLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.allTopCategories.isEmpty) {
            return Center(
              child: Text('No categories data available', style: GoogleFonts.lexend(color: Colors.grey)),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: provider.allTopCategories.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final category = provider.allTopCategories[index];
              final String imageUrl = category['image'] ?? '';
              final String categorySlug = category['slug'] ?? category['_id'] ?? '';

              // Progress bar ke liye max sold count nikal rahe hain
              final int maxSold = provider.allTopCategories.isNotEmpty
                  ? (provider.allTopCategories[0]['totalSold'] ?? 1)
                  : 1;
              final int currentSold = category['totalSold'] ?? 0;
              double progress = maxSold > 0 ? (currentSold / maxSold).clamp(0.0, 1.0) : 0.0;

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          color: Colors.teal.shade50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: imageUrl.isNotEmpty
                              ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Icon(Icons.category_outlined, color: Colors.teal.shade700),
                          )
                              : Icon(Icons.category_outlined, color: Colors.teal.shade700),
                        ),
                      ),
                      title: Text(
                        category['name']?.toString().toUpperCase() ?? 'UNKNOWN',
                        style: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        '$currentSold items sold',
                        style: GoogleFonts.lexend(fontSize: 12, color: Colors.grey.shade600),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '₹${category['totalRevenue']?.toStringAsFixed(0) ?? '0'}',
                                style: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                              ),
                              Text('Revenue', style: GoogleFonts.lexend(fontSize: 10, color: Colors.grey)),
                            ],
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.chevron_right, color: Colors.grey),
                        ],
                      ),
                      onTap: () {
                        // Navigate to sold products of this category
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CategoryProductsScreen(
                              categoryName: category['name'] ?? 'Category',
                              categorySlug: categorySlug,
                            ),
                          ),
                        );
                      },
                    ),
                    // Progress Indicator at the bottom of each card
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.grey.shade100,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.grey.shade800),
                          minHeight: 3,
                        ),
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