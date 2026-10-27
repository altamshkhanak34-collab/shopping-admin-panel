import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/admin_stats_provider.dart';

class CategoryProductsScreen extends StatefulWidget {
  final String categoryName;
  final String categorySlug;

  const CategoryProductsScreen({
    Key? key,
    required this.categoryName,
    required this.categorySlug,
  }) : super(key: key);

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminStatsProvider>(context, listen: false)
          .fetchCategoryProducts(widget.categorySlug);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          '${widget.categoryName} - Sold Products',
          style: GoogleFonts.lexend(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: const BackButton(color: Colors.black87),
      ),
      body: Consumer<AdminStatsProvider>(
        builder: (context, provider, child) {
          if (provider.isCategoryProductsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.categoryProducts.isEmpty) {
            return Center(
              child: Text(
                'No products sold in this category yet',
                style: GoogleFonts.lexend(color: Colors.grey),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: provider.categoryProducts.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final product = provider.categoryProducts[index];

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          product['thumbnail'] ?? '',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.image_not_supported, color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product['title'] ?? 'Unknown Product',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Sold: ${product['totalSold'] ?? 0} units',
                            style: GoogleFonts.lexend(fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '₹${product['totalRevenue']?.toStringAsFixed(0) ?? '0'}',
                          style: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        Text(
                          'Price: ₹${product['price']?.toStringAsFixed(0) ?? '0'}',
                          style: GoogleFonts.lexend(fontSize: 11, color: Colors.grey),
                        ),
                      ],
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