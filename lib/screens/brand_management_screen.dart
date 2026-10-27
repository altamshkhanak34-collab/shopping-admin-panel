import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/brand_model.dart';
import '../providers/admin_brand_provider.dart';
import '../widgets/zoom_image_big.dart';

class BrandManagementScreen extends StatefulWidget {
  const BrandManagementScreen({super.key});

  static const routeName = '/admin/brands';

  @override
  State<BrandManagementScreen> createState() => _BrandManagementScreenState();
}

class _BrandManagementScreenState extends State<BrandManagementScreen> {
  bool _isGridView = false; // Toggle between List and Grid view
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminBrandProvider>(context, listen: false).fetchBrands();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Add/Edit Dialog Form
  void _showBrandDialog({BrandModel? brand}) {
    final isEdit = brand != null;
    final nameController = TextEditingController(text: brand?.name ?? '');
    final slugController = TextEditingController(text: brand?.slug ?? '');
    final descController = TextEditingController(text: brand?.description ?? '');
    final logoController = TextEditingController(text: brand?.logo ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isEdit ? Icons.edit_rounded : Icons.add_circle_outline_rounded,
                color: Colors.blue.shade600,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              isEdit ? 'Edit Brand' : 'Add New Brand',
              style: GoogleFonts.lexend(fontWeight: FontWeight.bold, fontSize: 18, color: const Color(0xFF0F172A)),
            ),
          ],
        ),
        content: SizedBox(
          width: 450,
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDialogTextField(
                    controller: nameController,
                    label: 'Brand Name *',
                    icon: Icons.storefront_rounded,
                    onChanged: (val) {
                      if (!isEdit) {
                        slugController.text = val
                            .toLowerCase()
                            .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
                            .replaceAll(RegExp(r'\s+'), '-');
                      }
                    },
                    validator: (val) => val == null || val.trim().isEmpty ? 'Name is required' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildDialogTextField(
                    controller: slugController,
                    label: 'Slug *',
                    icon: Icons.link_rounded,
                    validator: (val) => val == null || val.trim().isEmpty ? 'Slug is required' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildDialogTextField(
                    controller: logoController,
                    label: 'Logo Image URL',
                    icon: Icons.image_outlined,
                  ),
                  const SizedBox(height: 16),
                  _buildDialogTextField(
                    controller: descController,
                    label: 'Description',
                    icon: Icons.description_outlined,
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.lexend(color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;

              final provider = Provider.of<AdminBrandProvider>(context, listen: false);
              final data = {
                'name': nameController.text.trim(),
                'slug': slugController.text.trim(),
                'logo': logoController.text.trim(),
                'description': descController.text.trim(),
              };

              bool success;
              if (isEdit) {
                success = await provider.updateBrand(brand.id, data);
              } else {
                success = await provider.addBrand(data);
              }

              if (!context.mounted) return;

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    success
                        ? (isEdit ? 'Brand updated successfully!' : 'Brand created successfully!')
                        : (provider.error ?? 'Failed to save brand.'),
                    style: GoogleFonts.lexend(color: Colors.white),
                  ),
                  backgroundColor: success ? Colors.green.shade600 : Colors.redAccent,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            child: Text('Save Brand', style: GoogleFonts.lexend(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    ValueChanged<String>? onChanged,
    FormFieldValidator<String>? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.lexend(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF334155)),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          onChanged: onChanged,
          validator: validator,
          style: GoogleFonts.lexend(fontSize: 13, color: const Color(0xFF0F172A)),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 18, color: Colors.grey.shade500),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.blue.shade600, width: 1.5)),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8FAFC),
      padding: const EdgeInsets.all(24.0),
      child: Consumer<AdminBrandProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded, size: 48, color: Colors.redAccent),
                  const SizedBox(height: 12),
                  Text(provider.error!, style: GoogleFonts.lexend(color: Colors.red.shade700, fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade600, foregroundColor: Colors.white),
                    onPressed: () => provider.fetchBrands(),
                    child: Text('Retry', style: GoogleFonts.lexend(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          }

          final filteredBrands = provider.brands.where((brand) {
            return brand.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                brand.slug.toLowerCase().contains(_searchQuery.toLowerCase());
          }).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Title & Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Brand Management',
                        style: GoogleFonts.lexend(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Manage, organize, and configure brand catalog.',
                        style: GoogleFonts.lexend(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      // View Switcher Button
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF0F172A),
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                        onPressed: () => setState(() => _isGridView = !_isGridView),
                        icon: Icon(_isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded, size: 18),
                        label: Text(
                          _isGridView ? 'List View' : 'Grid View',
                          style: GoogleFonts.lexend(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Inactive Archive Button
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.orange.shade800,
                          side: BorderSide(color: Colors.orange.shade300),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                        onPressed: () => showDialog(
                          context: context,
                          builder: (context) => const InactiveBrandsDialog(),
                        ),
                        icon: const Icon(Icons.archive_outlined, size: 18),
                        label: Text(
                          'Inactive Brands',
                          style: GoogleFonts.lexend(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Add Brand Button
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                        onPressed: () => _showBrandDialog(),
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: Text(
                          'Add Brand',
                          style: GoogleFonts.lexend(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Search & Total Count Row
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
                          hintText: 'Search brands by name or slug...',
                          hintStyle: GoogleFonts.lexend(fontSize: 13, color: Colors.grey.shade400),
                          prefixIcon: Icon(Icons.search_rounded, color: Colors.grey.shade400, size: 20),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded, size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                )
                              : null,
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
                        const Icon(Icons.storefront_rounded, color: Colors.blue, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Total Brands: ${provider.brands.length}',
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

              // Main Content Area
              Expanded(
                child: filteredBrands.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.store_mall_directory_outlined, size: 64, color: Colors.grey.shade300),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty ? 'No brands found' : 'No matching brands found',
                              style: GoogleFonts.lexend(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.grey.shade600),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _searchQuery.isEmpty ? 'Click "Add Brand" to create your first brand.' : 'Try adjusting your search query.',
                              style: GoogleFonts.lexend(fontSize: 12, color: Colors.grey.shade400),
                            ),
                          ],
                        ),
                      )
                    : _isGridView
                        ? _buildGridView(filteredBrands, provider, context)
                        : _buildListView(filteredBrands, provider, context),
              ),
            ],
          );
        },
      ),
    );
  }

  // List View Implementation
  Widget _buildListView(List<BrandModel> brands, AdminBrandProvider provider, BuildContext context) {
    return Container(
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
          itemCount: brands.length,
          padding: EdgeInsets.zero,
          separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
          itemBuilder: (context, index) {
            final brand = brands[index];
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  // Logo Thumbnail
                  brand.logo.isNotEmpty
                      ? ZoomableImageThumbnail(imageUrl: brand.logo, width: 48, height: 48)
                      : Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Icon(Icons.store_rounded, color: Colors.grey.shade400, size: 22),
                        ),
                  const SizedBox(width: 16),

                  // Name & Slug & Description
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          brand.name,
                          style: GoogleFonts.lexend(fontWeight: FontWeight.bold, fontSize: 14, color: const Color(0xFF0F172A)),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'slug: ${brand.slug}',
                                style: GoogleFonts.lexend(fontSize: 11, color: Colors.blue.shade700, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                        if (brand.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            brand.description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.lexend(color: Colors.grey.shade500, fontSize: 12),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Actions: Switch, Edit, Delete
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch.adaptive(
                        value: brand.isActive,
                        activeTrackColor: Colors.green.shade600,
                        onChanged: (val) async {
                          await provider.updateBrand(brand.id, {'isActive': val});
                        },
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF3B82F6)),
                        tooltip: 'Edit Brand',
                        onPressed: () => _showBrandDialog(brand: brand),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.blue.shade50,
                          padding: const EdgeInsets.all(8),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.redAccent),
                        tooltip: 'Delete Brand',
                        onPressed: () async {
                          bool confirm = await _showDeleteConfirmation(context);
                          if (confirm) {
                            await provider.deleteBrand(brand.id);
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
    );
  }

  // Grid View Implementation
  Widget _buildGridView(List<BrandModel> brands, AdminBrandProvider provider, BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 280,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.82,
      ),
      itemCount: brands.length,
      itemBuilder: (context, index) {
        final brand = brands[index];
        return Container(
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
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Switch.adaptive(
                      value: brand.isActive,
                      activeTrackColor: Colors.green.shade600,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      onChanged: (val) async {
                        await provider.updateBrand(brand.id, {'isActive': val});
                      },
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 16, color: Color(0xFF3B82F6)),
                          tooltip: 'Edit Brand',
                          onPressed: () => _showBrandDialog(brand: brand),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.blue.shade50,
                            padding: const EdgeInsets.all(6),
                          ),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, size: 16, color: Colors.redAccent),
                          tooltip: 'Delete Brand',
                          onPressed: () async {
                            bool confirm = await _showDeleteConfirmation(context);
                            if (confirm) {
                              await provider.deleteBrand(brand.id);
                            }
                          },
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.red.shade50,
                            padding: const EdgeInsets.all(6),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 10),
                brand.logo.isNotEmpty
                    ? ZoomableImageThumbnail(imageUrl: brand.logo, width: 64, height: 64)
                    : Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Icon(Icons.store_rounded, color: Colors.grey.shade400, size: 28),
                      ),
                const SizedBox(height: 12),
                Text(
                  brand.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.lexend(fontWeight: FontWeight.bold, fontSize: 15, color: const Color(0xFF0F172A)),
                ),
                const SizedBox(height: 2),
                Text(
                  '@${brand.slug}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.lexend(color: Colors.grey.shade500, fontSize: 11),
                ),
                const Spacer(),
                Text(
                  brand.description.isNotEmpty ? brand.description : 'No description provided',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lexend(color: Colors.grey.shade500, fontSize: 11),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text('Confirm Delete', style: GoogleFonts.lexend(fontWeight: FontWeight.bold)),
            content: Text('Are you sure you want to delete this brand? This action can be reversed if needed.', style: GoogleFonts.lexend(fontSize: 13)),
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
  }
}

class InactiveBrandsDialog extends StatelessWidget {
  const InactiveBrandsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 500),
        padding: const EdgeInsets.all(24),
        child: Consumer<AdminBrandProvider>(
          builder: (context, provider, child) {
            final inactiveBrands = provider.brands.where((brand) => !brand.isActive).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.archive_outlined, color: Colors.orange.shade800, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Inactive Brands (${inactiveBrands.length})',
                          style: GoogleFonts.lexend(fontWeight: FontWeight.bold, fontSize: 18, color: const Color(0xFF0F172A)),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(height: 24, color: Color(0xFFE2E8F0)),

                // Content List
                Expanded(
                  child: inactiveBrands.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle_outline_rounded, size: 56, color: Colors.green.shade400),
                              const SizedBox(height: 12),
                              Text(
                                'No inactive brands found!',
                                style: GoogleFonts.lexend(fontSize: 16, color: Colors.grey.shade700, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'All your brands are currently active.',
                                style: GoogleFonts.lexend(fontSize: 12, color: Colors.grey.shade400),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          itemCount: inactiveBrands.length,
                          separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                          itemBuilder: (context, index) {
                            final brand = inactiveBrands[index];
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              child: Row(
                                children: [
                                  // Brand Logo
                                  brand.logo.isNotEmpty
                                      ? ZoomableImageThumbnail(imageUrl: brand.logo, width: 44, height: 44)
                                      : Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade100,
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(color: Colors.grey.shade200),
                                          ),
                                          child: Icon(Icons.store_rounded, color: Colors.grey.shade400, size: 20),
                                        ),
                                  const SizedBox(width: 14),
                                  // Brand Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          brand.name,
                                          style: GoogleFonts.lexend(fontWeight: FontWeight.bold, fontSize: 14, color: const Color(0xFF0F172A)),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'slug: ${brand.slug}',
                                          style: GoogleFonts.lexend(color: Colors.grey.shade500, fontSize: 11),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Activate Button
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green.shade600,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      elevation: 0,
                                    ),
                                    icon: const Icon(Icons.check_circle_outline_rounded, size: 16),
                                    label: Text(
                                      'Activate',
                                      style: GoogleFonts.lexend(fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                    onPressed: () async {
                                      bool success = await provider.updateBrand(brand.id, {'isActive': true});
                                      if (success && context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('${brand.name} activated successfully!', style: GoogleFonts.lexend(color: Colors.white)),
                                            backgroundColor: Colors.green.shade600,
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
