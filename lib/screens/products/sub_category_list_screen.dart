import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/sub_category_model.dart';
import '../../providers/admin_sub_category_provider.dart';
import 'sub_category_dialog.dart';

class SubCategoryListScreen extends StatefulWidget {
  const SubCategoryListScreen({super.key});

  @override
  State<SubCategoryListScreen> createState() => _SubCategoryListScreenState();
}

class _SubCategoryListScreenState extends State<SubCategoryListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<AdminSubCategoryProvider>(context, listen: false);
    Future.microtask(() {
      provider.fetchSubCategories();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openDialog([SubCategoryModel? subCategory]) {
    showDialog(
      context: context,
      builder: (_) => SubCategoryFormDialog(subCategory: subCategory),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AdminSubCategoryProvider>(context);

    // Filter sub-categories based on search query
    final filteredSubCategories = provider.subCategories.where((subCat) {
      return subCat.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          subCat.slug.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          subCat.categoryName.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Title & Add Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sub-Categories Catalog',
                      style: GoogleFonts.lexend(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage, add, and organize sub-categories under main categories.',
                      style: GoogleFonts.lexend(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  onPressed: () => _openDialog(),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: Text(
                    'Add Sub-Category',
                    style: GoogleFonts.lexend(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Search Bar & Stats Row
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) => setState(() => _searchQuery = val),
                      style: GoogleFonts.lexend(fontSize: 13, color: const Color(0xFF0F172A)),
                      decoration: InputDecoration(
                        hintText: 'Search sub-categories by name, slug, or parent category...',
                        hintStyle: GoogleFonts.lexend(fontSize: 13, color: Colors.grey.shade400),
                        prefixIcon: Icon(Icons.search_rounded, color: Colors.grey.shade400, size: 20),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.account_tree_outlined, color: Colors.blue, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Total: ${provider.subCategories.length}',
                        style: GoogleFonts.lexend(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Content Body
            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredSubCategories.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.account_tree_outlined, size: 64, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isEmpty ? 'No sub-categories found.' : 'No matching sub-categories found.',
                            style: GoogleFonts.lexend(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _searchQuery.isEmpty ? 'Click "Add Sub-Category" to create your first sub-category.' : 'Try adjusting your search query.',
                            style: GoogleFonts.lexend(fontSize: 12, color: Colors.grey.shade400),
                          ),
                        ],
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: ListView.separated(
                          padding: EdgeInsets.zero,
                          itemCount: filteredSubCategories.length,
                          separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                          itemBuilder: (context, index) {
                            final subCat = filteredSubCategories[index];
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              child: Row(
                                children: [
                                  // Sub-Category Image / Avatar
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.grey.shade200),
                                      image: subCat.image.isNotEmpty
                                          ? DecorationImage(
                                              image: NetworkImage(subCat.image),
                                              fit: BoxFit.cover,
                                            )
                                          : null,
                                    ),
                                    child: subCat.image.isEmpty
                                        ? Icon(Icons.account_tree_rounded, color: Colors.grey.shade400, size: 22)
                                        : null,
                                  ),
                                  const SizedBox(width: 16),

                                  // Name, Category & Slug
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          subCat.name,
                                          style: GoogleFonts.lexend(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF0F172A),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 4,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.purple.shade50,
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                'Category: ${subCat.categoryName.isNotEmpty ? subCat.categoryName : 'N/A'}',
                                                style: GoogleFonts.lexend(
                                                  fontSize: 11,
                                                  color: Colors.purple.shade700,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.blue.shade50,
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                'slug: ${subCat.slug}',
                                                style: GoogleFonts.lexend(
                                                  fontSize: 11,
                                                  color: Colors.blue.shade700,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Actions: Edit & Delete
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF3B82F6)),
                                        tooltip: 'Edit Sub-Category',
                                        onPressed: () => _openDialog(subCat),
                                        style: IconButton.styleFrom(
                                          backgroundColor: Colors.blue.shade50,
                                          padding: const EdgeInsets.all(8),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.redAccent),
                                        tooltip: 'Delete Sub-Category',
                                        onPressed: () async {
                                          bool confirm = await showDialog(
                                                context: context,
                                                builder: (_) => AlertDialog(
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                  title: Text('Delete Sub-Category', style: GoogleFonts.lexend(fontWeight: FontWeight.bold)),
                                                  content: Text('Are you sure you want to delete "${subCat.name}"? This action cannot be undone.', style: GoogleFonts.lexend(fontSize: 13)),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () => Navigator.pop(context, false),
                                                      child: Text('Cancel', style: GoogleFonts.lexend(color: Colors.grey.shade600)),
                                                    ),
                                                    ElevatedButton(
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: Colors.redAccent,
                                                        foregroundColor: Colors.white,
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                      ),
                                                      onPressed: () => Navigator.pop(context, true),
                                                      child: Text('Delete', style: GoogleFonts.lexend(fontWeight: FontWeight.bold)),
                                                    ),
                                                  ],
                                                ),
                                              ) ??
                                              false;

                                          if (confirm) {
                                            provider.deleteSubCategory(subCat.id);
                                          }
                                        },
                                        style: IconButton.styleFrom(
                                          backgroundColor: Colors.red.shade50,
                                          padding: const EdgeInsets.all(8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
