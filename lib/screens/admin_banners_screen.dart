import 'package:flutter/material.dart';
import 'package:new_flutter_project/providers/admin_category_provider.dart';
import 'package:new_flutter_project/providers/admin_product_provider.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/admin_banner_provider.dart';
import '../providers/admin_offer_provider.dart';

class AdminBannersScreen extends StatefulWidget {
  const AdminBannersScreen({super.key});

  @override
  State<AdminBannersScreen> createState() => _AdminBannersScreenState();
}

class _AdminBannersScreenState extends State<AdminBannersScreen> {

  @override
  void initState() {
    super.initState();

    // Dono API calls ko frame render hone ke baad execute karein
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminBannerProvider>(context, listen: false).fetchAllBanners();
      Provider.of<AdminOfferProvider>(context, listen: false).fetchAdminOffers();
    });
  }

  // Add / Edit Dialog Box
  void _showBannerDialog({Map<String, dynamic>? banner}) {
    final isEdit = banner != null;
    final titleController = TextEditingController(text: isEdit ? banner['title'] : '');
    final imageUrlController = TextEditingController(text: isEdit ? banner['imageUrl'] : '');
    final targetIdController = TextEditingController(text: isEdit ? banner['targetId'] ?? '' : '');
    final priorityController = TextEditingController(text: isEdit ? (banner['priority'] ?? 0).toString() : '0');

    final List<String> targetTypes = [
      'NONE',
      'PRODUCT', 'CATEGORY', 'SUBCATEGORY', 'FLASH_SALE','OFFER', 'EXTERNAL'
    ];

    String rawType = isEdit ? (banner['targetType'] ?? 'NONE') : 'NONE';
    String selectedTargetType = targetTypes.contains(rawType) ? rawType : 'NONE';
    String? selectedTargetId = isEdit ? banner['targetId'] : null;
    bool isActive = isEdit ? (banner['isActive'] ?? true) : true;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            // Access Providers for items list
            final productProvider = Provider.of<AdminProductProvider>(context, listen: false);
            final categoryProvider = Provider.of<AdminCategoryProvider>(context, listen: false);

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(isEdit ? 'Edit Banner' : 'Create Banner', style: GoogleFonts.lexend(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      style: GoogleFonts.lexend(fontSize: 14),
                      decoration: const InputDecoration(labelText: 'Title *'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: imageUrlController,
                      style: GoogleFonts.lexend(fontSize: 14),
                      decoration: const InputDecoration(labelText: 'Image URL *'),
                    ),
                    const SizedBox(height: 10),

                    // 1. Target Type Selector
                    DropdownButtonFormField<String>(
                      value: selectedTargetType,
                      decoration: const InputDecoration(labelText: 'Target Type'),
                      items: targetTypes
                          .toSet()
                          .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() {
                            selectedTargetType = val;
                            selectedTargetId = null; // reset selection on type change
                            targetIdController.clear();
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 10),

                    // 2. Dynamic Target Selection based on Type
                    if (selectedTargetType == 'PRODUCT') ...[
                      DropdownButtonFormField<String>(
                        // 🟢 Fix 1: Safe Value Check - Agar product list me selectedTargetId na mile toh app crash nahi hoga
                        value: productProvider.products.any((p) => p.id == selectedTargetId)
                            ? selectedTargetId
                            : null,
                        decoration: const InputDecoration(labelText: 'Select Product *'),
                        // 🟢 Fix 2: .toSet() / Unique check - Duplicate item IDs filter karne ke liye
                        items: productProvider.products
                            .map((item) => item.id)
                            .toSet()
                            .map((id) {
                          final item = productProvider.products.firstWhere((p) => p.id == id);
                          return DropdownMenuItem<String>(
                            value: item.id,
                            child: Text(item.title, overflow: TextOverflow.ellipsis),
                          );
                        })
                            .toList(),
                        onChanged: (val) => setDialogState(() => selectedTargetId = val),
                      ),
                    ] else if (selectedTargetType == 'CATEGORY') ...[
                      DropdownButtonFormField<String>(
                        // 🟢 Fix 1: Safe Value Check for Category
                        value: categoryProvider.categories.any((c) => c.id == selectedTargetId)
                            ? selectedTargetId
                            : null,
                        decoration: const InputDecoration(labelText: 'Select Category *'),
                        // 🟢 Fix 2: Unique Categories handle karein
                        items: categoryProvider.categories
                            .map((item) => item.id)
                            .toSet()
                            .map((id) {
                          final item = categoryProvider.categories.firstWhere((c) => c.id == id);
                          return DropdownMenuItem<String>(
                            value: item.id,
                            child: Text(item.name, overflow: TextOverflow.ellipsis),
                          );
                        })
                            .toList(),
                        onChanged: (val) => setDialogState(() => selectedTargetId = val),
                      ),
                    ] else if (selectedTargetType == 'OFFER') ...[
                      Consumer<AdminOfferProvider>(
                        builder: (context, offerProvider, _) {
                          final offers = offerProvider.offers;

                          // Safe Selected Value handling
                          final isIdValid = offers.any((o) => (o['_id'] ?? o['id']) == selectedTargetId);

                          return DropdownButtonFormField<String>(
                            value: isIdValid ? selectedTargetId : null,
                            decoration: const InputDecoration(labelText: 'Select Offer *'),
                            items: offers.map((item) {
                              final String id = item['_id'] ?? item['id'] ?? '';
                              final String title = item['title'] ?? 'Untitled Offer';
                              final String code = item['offerCode'] ?? '';
                              final String displayTitle = code.isNotEmpty ? '$title ($code)' : title;

                              return DropdownMenuItem<String>(
                                value: id,
                                child: Text(
                                  displayTitle,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.lexend(fontSize: 14),
                                ),
                              );
                            }).toList(),
                            onChanged: (val) => setDialogState(() => selectedTargetId = val),
                          );
                        },
                      ),
                    ] else if (selectedTargetType == 'EXTERNAL') ...[
                      TextField(
                        controller: targetIdController,
                        style: GoogleFonts.lexend(fontSize: 14),
                        decoration: const InputDecoration(labelText: 'External URL (https://...) *'),
                      ),
                    ],

                    const SizedBox(height: 10),
                    TextField(
                      controller: priorityController,
                      keyboardType: TextInputType.number,
                      style: GoogleFonts.lexend(fontSize: 14),
                      decoration: const InputDecoration(labelText: 'Priority (Order)'),
                    ),
                    const SizedBox(height: 10),
                    SwitchListTile(
                      title: Text('Is Active', style: GoogleFonts.lexend(fontSize: 14)),
                      value: isActive,
                      activeColor: const Color(0xFF111827),
                      onChanged: (val) => setDialogState(() => isActive = val),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text('Cancel', style: GoogleFonts.lexend(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF111827),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () async {
                    if (titleController.text.trim().isEmpty || imageUrlController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Title and Image URL are required')),
                      );
                      return;
                    }

                    // Final Target ID value determine karein
                    String finalTargetId = '';
                    if (selectedTargetType == 'EXTERNAL') {
                      finalTargetId = targetIdController.text.trim();
                    } else if (selectedTargetType != 'NONE') {
                      finalTargetId = selectedTargetId ?? '';
                    }

                    if (selectedTargetType != 'NONE' && finalTargetId.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please select/enter Target for $selectedTargetType')),
                      );
                      return;
                    }

                    final data = {
                      'title': titleController.text.trim(),
                      'imageUrl': imageUrlController.text.trim(),
                      'targetType': selectedTargetType,
                      'targetId': finalTargetId,
                      'priority': int.tryParse(priorityController.text) ?? 0,
                      'isActive': isActive,
                    };

                    final provider = Provider.of<AdminBannerProvider>(context, listen: false);
                    final String bannerId = banner != null ? (banner['_id'] ?? banner['id'] ?? '') : '';

                    final success = isEdit
                        ? await provider.updateBanner(bannerId, data)
                        : await provider.createBanner(data);

                    if (success && mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(isEdit ? 'Banner updated' : 'Banner created')),
                      );
                    }
                  },
                  child: Text(isEdit ? 'Update' : 'Create', style: GoogleFonts.lexend(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text('Banner Management', style: GoogleFonts.lexend(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'admin_banners_fab', // 👈unique tag add karna zaroori hai
        backgroundColor: const Color(0xFF111827),
        tooltip: 'Create Banner', // 🟢 Hover par 'Create Banner' text dikhayega
        onPressed: () => _showBannerDialog(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Consumer<AdminBannerProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Text(provider.error!, style: GoogleFonts.lexend(color: Colors.red)),
            );
          }

          if (provider.banners.isEmpty) {
            return Center(
              child: Text('No banners found', style: GoogleFonts.lexend(color: Colors.grey)),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchAllBanners(),
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: provider.banners.length,
              itemBuilder: (context, index) {
                final banner = provider.banners[index];
                final String bannerId = banner['_id'] ?? banner['id'] ?? '';
                final bool isActive = banner['isActive'] ?? false;

                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 🟢 Banner Image Preview (Fixed Full-Width & Non-Cropped View)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: double.infinity,
                            color: Colors.grey.shade100, // Image background spacing ke liye
                            child: AspectRatio(
                              aspectRatio: 16 / 9, // Banner ka standard aspect ratio
                              child: Image.network(
                                banner['imageUrl'] ?? '',
                                fit: BoxFit.contain, // 👈 Poori image bina cut huye dikhane ke liye
                                errorBuilder: (context, error, stackTrace) => Container(
                                  color: Colors.grey.shade200,
                                  child: const Icon(Icons.broken_image, color: Colors.grey),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Title & Status
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                banner['title'] ?? '',
                                style: GoogleFonts.lexend(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ),
                            Switch(
                              value: isActive,
                              activeColor: Colors.green,
                              onChanged: (val) {
                                provider.toggleBannerStatus(bannerId, val);
                              },
                            ),
                          ],
                        ),

                        // Details (Priority & Target)
                        Text(
                          'Priority: ${banner['priority'] ?? 0} | Target: ${banner['targetType'] ?? 'NONE'}',
                          style: GoogleFonts.lexend(fontSize: 12, color: Colors.grey.shade600),
                        ),

                        const Divider(),

                        // Actions (Edit / Delete)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                              onPressed: () => _showBannerDialog(banner: banner),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: Text('Delete Banner', style: GoogleFonts.lexend(fontWeight: FontWeight.bold)),
                                    content: Text('Are you sure you want to delete this banner?', style: GoogleFonts.lexend()),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                      TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  provider.deleteBanner(bannerId);
                                }
                              },
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}