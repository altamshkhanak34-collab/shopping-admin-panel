import 'package:flutter/material.dart';
import 'package:new_flutter_project/screens/products/product_form_dialog.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/admin_product_provider.dart';
import '../../models/product_model.dart';
import '../../widgets/zoom_image_big.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _showOnlyOutOfStock = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<AdminProductProvider>(context, listen: false).fetchAdminProducts());
  }

  // Open Add/Edit Product Dialog
  void _openProductForm([ProductModel? product]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductFormScreen(product: product),
      ),
    );
  }

  // Confirm Delete Dialog
  void _confirmDeleteProduct(ProductModel product, AdminProductProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 24),
            ),
            const SizedBox(width: 12),
            Text('Delete Product', style: GoogleFonts.lexend(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            'Are you sure you want to delete "${product.title}"? This action cannot be undone.',
            style: GoogleFonts.lexend(color: Colors.grey.shade700, fontSize: 14),
          ),
        ),
        actionsPadding: const EdgeInsets.all(16),
        actions: [
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.lexend(color: Colors.grey.shade700, fontWeight: FontWeight.w500)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await provider.deleteProduct(product.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success ? 'Product deleted successfully!' : 'Failed to delete product',
                      style: GoogleFonts.lexend(),
                    ),
                    backgroundColor: success ? Colors.green.shade700 : Colors.red.shade700,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                );
              }
            },
            child: Text('Delete', style: GoogleFonts.lexend(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProductProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF1E2022)),
          );
        }

        if (provider.error != null) {
          return Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red),
                  const SizedBox(width: 12),
                  Text(
                    'Error loading products: ${provider.error}',
                    style: GoogleFonts.lexend(color: Colors.red.shade800, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          );
        }

        // Search & Filter Logic
        List<ProductModel> filteredList = provider.products.where((p) {
          final query = _searchController.text.toLowerCase();
          final matchesSearch = p.title.toLowerCase().contains(query) ||
              p.categorySlug.toLowerCase().contains(query);

          if (_showOnlyOutOfStock) {
            return matchesSearch && p.isOutOfStock;
          }
          return matchesSearch;
        }).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Action Bar Container (Search & Filter Controls)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Search Input
                  SizedBox(
                    width: 360,
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) => setState(() {}),
                      style: GoogleFonts.lexend(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Search product or category...',
                        hintStyle: GoogleFonts.lexend(color: Colors.grey.shade400, fontSize: 14),
                        prefixIcon: Icon(Icons.search, size: 20, color: Colors.grey.shade500),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFF1E2022), width: 1.5),
                        ),
                      ),
                    ),
                  ),

                  Row(
                    children: [
                      // Out of Stock Filter Toggle
                      FilterChip(
                        label: Text(
                          'Out of Stock Only (${provider.outOfStockProducts.length})',
                          style: GoogleFonts.lexend(
                            color: _showOnlyOutOfStock ? Colors.white : Colors.red.shade700,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        selected: _showOnlyOutOfStock,
                        selectedColor: Colors.red.shade600,
                        backgroundColor: Colors.red.shade50,
                        checkmarkColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: _showOnlyOutOfStock ? Colors.red.shade600 : Colors.red.shade200,
                          ),
                        ),
                        onSelected: (selected) {
                          setState(() => _showOnlyOutOfStock = selected);
                        },
                      ),
                      const SizedBox(width: 16),

                      // Add Product Button Connected
                      ElevatedButton.icon(
                        onPressed: () => _openProductForm(),
                        icon: const Icon(Icons.add, color: Colors.white, size: 20),
                        label: Text(
                          'Add Product',
                          style: GoogleFonts.lexend(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E2022),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Products Web Table Container
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SingleChildScrollView(
                    child: DataTable(
                      headingRowColor: MaterialStateProperty.all(Colors.grey.shade50),
                      headingTextStyle: GoogleFonts.lexend(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                        fontSize: 13,
                      ),
                      dataRowMinHeight: 64,
                      dataRowMaxHeight: 72,
                      dividerThickness: 1,
                      columns: const [
                        DataColumn(label: Text('Product')),
                        DataColumn(label: Text('Category')),
                        DataColumn(label: Text('Price')),
                        DataColumn(label: Text('Cost Price', overflow: TextOverflow.ellipsis)),
                        DataColumn(label: Text('Stock')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: filteredList.map((product) {
                        return DataRow(
                          cells: [
                            // Product Name & Image
                            DataCell(
                              SizedBox(
                                width: 380,
                                child: Row(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.grey.shade200),
                                      ),
                                      child: ZoomableImageThumbnail(
                                        imageUrl: product.thumbnail,
                                        width: 48,
                                        height: 48,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Text(
                                        product.title,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.lexend(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 13,
                                          color: Colors.grey.shade900,
                                        ),
                                        maxLines: 2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                product.categorySlug.isEmpty ? 'N/A' : product.categorySlug,
                                style: GoogleFonts.lexend(color: Colors.grey.shade700, fontSize: 13),
                              ),
                            ),
                            DataCell(
                              Text(
                                '₹${product.price.toStringAsFixed(2)}',
                                style: GoogleFonts.lexend(fontWeight: FontWeight.w600, color: Colors.grey.shade900, fontSize: 13),
                              ),
                            ),
                            DataCell(
                              Text(
                                '₹${product.costPrice.toStringAsFixed(2)}',
                                style: GoogleFonts.lexend(color: Colors.grey.shade700, fontSize: 13),
                              ),
                            ),
                            // Stock Count
                            DataCell(
                              Text(
                                '${product.stock} pcs',
                                style: GoogleFonts.lexend(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: product.isOutOfStock ? Colors.red.shade700 : Colors.grey.shade900,
                                ),
                              ),
                            ),
                            // Stock Badge
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: product.isOutOfStock
                                      ? Colors.red.shade50
                                      : Colors.green?.shade50 ?? Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: product.isOutOfStock
                                        ? Colors.red.shade200
                                        : Colors.green.shade200,
                                  ),
                                ),
                                child: Text(
                                  product.isOutOfStock ? 'Out of Stock' : 'In Stock',
                                  style: GoogleFonts.lexend(
                                    color: product.isOutOfStock ? Colors.red.shade800 : Colors.green.shade800,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            // Actions Button
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Quick Stock Update Dialog
                                  Tooltip(
                                    message: 'Update Stock',
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(8),
                                      onTap: () => _showUpdateStockDialog(context, product, provider),
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade50,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(Icons.edit_note, color: Colors.blue, size: 18),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Edit Full Details
                                  Tooltip(
                                    message: 'Edit Product',
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(8),
                                      onTap: () => _openProductForm(product),
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.shade50,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(Icons.edit, color: Colors.orange, size: 18),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Delete Product
                                  Tooltip(
                                    message: 'Delete Product',
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(8),
                                      onTap: () => _confirmDeleteProduct(product, provider),
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.red.shade50,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Quick Stock Update Modal Dialog
  void _showUpdateStockDialog(
      BuildContext context, ProductModel product, AdminProductProvider provider) {
    final controller = TextEditingController(text: product.stock.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Update Stock: ${product.title}', style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Enter new stock quantity:', style: GoogleFonts.lexend(fontSize: 13, color: Colors.grey.shade700)),
            const SizedBox(height: 10),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: GoogleFonts.lexend(fontSize: 14),
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF1E2022), width: 1.5),
                ),
                hintText: 'e.g. 50',
                hintStyle: GoogleFonts.lexend(color: Colors.grey.shade400),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.all(16),
        actions: [
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.lexend(color: Colors.grey.shade700, fontWeight: FontWeight.w500)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E2022),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            onPressed: () async {
              final newStock = int.tryParse(controller.text);
              if (newStock != null && newStock >= 0) {
                final success = await provider.updateStock(
                  productId: product.id,
                  newStock: newStock,
                  type: 'set',
                );

                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success ? 'Stock updated successfully!' : 'Failed to update stock',
                        style: GoogleFonts.lexend(),
                      ),
                      backgroundColor: success ? Colors.green.shade700 : Colors.red.shade700,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  );
                }
              }
            },
            child: Text('Save Stock', style: GoogleFonts.lexend(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
