
import 'package:flutter/material.dart';
import 'package:new_flutter_project/providers/admin_product_provider.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/product_model.dart';
import '../providers/admin_offer_provider.dart';

class AdminOffersScreen extends StatefulWidget {
  const AdminOffersScreen({super.key});

  @override
  State<AdminOffersScreen> createState() => _AdminOffersScreenState();
}

class _AdminOffersScreenState extends State<AdminOffersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'All'; // 'All', 'Active', 'Featured'

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      _loadOffers();
      Provider.of<AdminProductProvider>(context, listen: false).fetchProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadOffers() async {
    await Provider.of<AdminOfferProvider>(context, listen: false).fetchAdminOffers();
  }

  // Modern Entry Animation Helper
  Widget _buildAnimatedSection(Widget child, {int delayMs = 0}) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + delayMs),
      curve: Curves.easeOutCubic,
      builder: (context, value, childWidget) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: childWidget,
          ),
        );
      },
      child: child,
    );
  }

  void _showCreateOfferBottomSheet(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final imageController = TextEditingController();
    final discountController = TextEditingController();
    final codeController = TextEditingController();

    bool isFeatured = false;
    List<ProductModel> selectedProducts = [];

    DateTime selectedStartDate = DateTime.now().subtract(const Duration(minutes: 10));
    DateTime selectedEndDate = DateTime.now().add(const Duration(days: 30));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final productProvider = Provider.of<AdminProductProvider>(context);
            final List<ProductModel> allProducts = productProvider.products;

            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFF111827),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
                top: 24,
                left: 20,
                right: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Create Exclusive Offer',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Inputs
                    _buildTextField(titleController, 'Offer Title *', Icons.local_offer_outlined),
                    const SizedBox(height: 12),
                    _buildTextField(descController, 'Description', Icons.description_outlined, maxLines: 2),
                    const SizedBox(height: 12),
                    _buildTextField(imageController, 'Banner Image URL *', Icons.image_outlined),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            discountController,
                            'Discount % *',
                            Icons.percent_outlined,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(codeController, 'Offer Code (e.g. FESTIVE50)', Icons.qr_code_outlined),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Search & Select Products
                    Text(
                      'Applicable Products',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade300,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Autocomplete<ProductModel>(
                      displayStringForOption: (option) => option.title ?? '',
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text.isEmpty) {
                          return allProducts.take(5);
                        }
                        return allProducts.where((product) {
                          final name = (product.title ?? '').toLowerCase();
                          return name.contains(textEditingValue.text.toLowerCase());
                        });
                      },
                      onSelected: (ProductModel selection) {
                        if (selection.id.isEmpty) return;
                        final bool alreadyExists = selectedProducts.any((p) => p.id == selection.id);
                        if (!alreadyExists) {
                          setModalState(() {
                            selectedProducts.add(selection);
                          });
                        }
                      },
                      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                        return TextField(
                          controller: controller,
                          focusNode: focusNode,
                          style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Search product by name...',
                            hintStyle: GoogleFonts.plusJakartaSans(color: Colors.grey.shade500, fontSize: 13),
                            prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20),
                            filled: true,
                            fillColor: const Color(0xFF1F2937),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: Colors.grey.shade800),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: Color(0xFFF59E0B)),
                            ),
                          ),
                        );
                      },
                      optionsViewBuilder: (context, onSelected, options) {
                        return Align(
                          alignment: Alignment.topLeft,
                          child: Material(
                            elevation: 8,
                            color: const Color(0xFF1F2937),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              width: MediaQuery.of(context).size.width - 40,
                              height: 200,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade800),
                              ),
                              child: ListView.separated(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                itemCount: options.length,
                                separatorBuilder: (_, __) => Divider(color: Colors.grey.shade800, height: 1),
                                itemBuilder: (BuildContext context, int index) {
                                  final option = options.elementAt(index);
                                  return ListTile(
                                    title: Text(
                                      option.title ?? '',
                                      style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 13),
                                    ),
                                    subtitle: option.price != null
                                        ? Text(
                                      '₹${option.price}',
                                      style: GoogleFonts.plusJakartaSans(
                                        color: const Color(0xFFF59E0B),
                                        fontSize: 11,
                                      ),
                                    )
                                        : null,
                                    onTap: () => onSelected(option),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),

                    // Display Selected Products Chips
                    if (selectedProducts.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1F2937),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade800),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: selectedProducts.map((product) {
                                final String prodId = product.id;
                                return Chip(
                                  label: Text(
                                    product.title ?? 'Product',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: Colors.black87,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  backgroundColor: const Color(0xFFF59E0B),
                                  deleteIcon: const Icon(Icons.cancel, size: 16, color: Colors.black54),
                                  onDeleted: () {
                                    setModalState(() {
                                      selectedProducts.removeWhere((p) => p.id == prodId);
                                    });
                                  },
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${selectedProducts.length} product(s) linked to this offer',
                              style: GoogleFonts.plusJakartaSans(
                                color: const Color(0xFFF59E0B),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 12),

                    // Expiry Date Picker
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1F2937),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.calendar_today_outlined, color: Color(0xFFF59E0B)),
                        title: Text(
                          'Offer Expiry Date',
                          style: GoogleFonts.plusJakartaSans(fontSize: 14, color: Colors.white),
                        ),
                        subtitle: Text(
                          '${selectedEndDate.day}/${selectedEndDate.month}/${selectedEndDate.year}',
                          style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey.shade400),
                        ),
                        trailing: TextButton(
                          onPressed: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: selectedEndDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: const ColorScheme.dark(
                                      primary: Color(0xFFF59E0B),
                                      onPrimary: Colors.black,
                                      surface: Color(0xFF1F2937),
                                      onSurface: Colors.white,
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (picked != null) {
                              setModalState(() {
                                selectedEndDate = DateTime(
                                  picked.year,
                                  picked.month,
                                  picked.day,
                                  23,
                                  59,
                                  59,
                                );
                              });
                            }
                          },
                          child: Text(
                            'Select Date',
                            style: GoogleFonts.plusJakartaSans(
                              color: const Color(0xFFF59E0B),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Featured Toggle Switch
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1F2937),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: SwitchListTile(
                        title: Text(
                          'Featured on Home Slider',
                          style: GoogleFonts.plusJakartaSans(fontSize: 14, color: Colors.white),
                        ),
                        activeColor: const Color(0xFFF59E0B),
                        value: isFeatured,
                        onChanged: (val) => setModalState(() => isFeatured = val),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Action Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF59E0B),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        onPressed: () async {
                          if (titleController.text.isEmpty ||
                              imageController.text.isEmpty ||
                              discountController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please fill required fields')),
                            );
                            return;
                          }

                          final List<String> productIds = selectedProducts
                              .map((p) => p.id.trim())
                              .where((id) => id.isNotEmpty)
                              .toList();

                          final offerPayload = {
                            "title": titleController.text.trim(),
                            "description": descController.text.trim(),
                            "bannerImage": imageController.text.trim(),
                            "discountPercentage": double.parse(discountController.text.trim()),
                            "offerCode": codeController.text.trim(),
                            "products": productIds,
                            "isFeatured": isFeatured,
                            "isActive": true,
                            "startDate": selectedStartDate.toUtc().toIso8601String(),
                            "endDate": selectedEndDate.toUtc().toIso8601String(),
                          };

                          final success = await Provider.of<AdminOfferProvider>(context, listen: false)
                              .createOffer(offerPayload);

                          if (success && context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Offer created successfully!')),
                            );
                          }
                        },
                        child: Text(
                          'Publish Offer',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  static Widget _buildTextField(
      TextEditingController controller,
      String label,
      IconData icon, {
        TextInputType keyboardType = TextInputType.text,
        int maxLines = 1,
      }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.plusJakartaSans(color: Colors.grey.shade400, fontSize: 13),
        prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 20),
        filled: true,
        fillColor: const Color(0xFF1F2937),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade800),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFF59E0B)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: Text(
          'Offers & Discounts',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
        ),
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Refresh Offers',
            onPressed: _loadOffers,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'admin_offers_fab',
        backgroundColor: const Color(0xFFF59E0B),
        onPressed: () => _showCreateOfferBottomSheet(context),
        icon: const Icon(Icons.add, color: Colors.black),
        label: Text(
          'New Offer',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
      body: Consumer<AdminOfferProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.offers.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFF59E0B)));
          }

          final allOffers = provider.offers;
          final totalOffers = allOffers.length;
          final activeOffers = allOffers.where((o) => (o['isActive'] ?? true) == true).length;
          final featuredOffers = allOffers.where((o) => (o['isFeatured'] ?? false) == true).length;

          // Filter & Search
          final filteredOffers = allOffers.where((offer) {
            final title = (offer['title'] ?? '').toString().toLowerCase();
            final code = (offer['offerCode'] ?? '').toString().toLowerCase();
            final query = _searchQuery.toLowerCase();

            bool matchesSearch = title.contains(query) || code.contains(query);
            bool matchesFilter = true;
            if (_selectedFilter == 'Active') {
              matchesFilter = (offer['isActive'] ?? true) == true;
            } else if (_selectedFilter == 'Featured') {
              matchesFilter = (offer['isFeatured'] ?? false) == true;
            }
            return matchesSearch && matchesFilter;
          }).toList();

          return RefreshIndicator(
            onRefresh: _loadOffers,
            color: const Color(0xFFF59E0B),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Stats Overview Cards
                  _buildAnimatedSection(
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            title: 'Total Offers',
                            count: '$totalOffers',
                            icon: Icons.local_offer_outlined,
                            color: const Color(0xFFF59E0B),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            title: 'Active Offers',
                            count: '$activeOffers',
                            icon: Icons.check_circle_outline,
                            color: const Color(0xFF10B981),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            title: 'Featured',
                            count: '$featuredOffers',
                            icon: Icons.star_outline,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ],
                    ),
                    delayMs: 0,
                  ),

                  const SizedBox(height: 20),

                  // 2. Search & Filter Bar
                  _buildAnimatedSection(
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.05)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _searchController,
                            onChanged: (val) => setState(() => _searchQuery = val),
                            style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 14),
                            decoration: InputDecoration(
                              hintText: 'Search by title or offer code...',
                              hintStyle: GoogleFonts.plusJakartaSans(color: Colors.grey.shade500, fontSize: 13),
                              prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? IconButton(
                                icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                                  : null,
                              filled: true,
                              fillColor: const Color(0xFF111827),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Colors.grey.shade800),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Colors.grey.shade800),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: Color(0xFFF59E0B), width: 1.5),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Text(
                                'Filter:',
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                              const SizedBox(width: 10),
                              _buildFilterChip('All', totalOffers),
                              const SizedBox(width: 8),
                              _buildFilterChip('Active', activeOffers),
                              const SizedBox(width: 8),
                              _buildFilterChip('Featured', featuredOffers),
                            ],
                          ),
                        ],
                      ),
                    ),
                    delayMs: 100,
                  ),

                  const SizedBox(height: 20),

                  // 3. Offers List Section
                  _buildAnimatedSection(
                    filteredOffers.isEmpty
                        ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.05)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.local_offer_outlined, size: 48, color: Colors.grey.shade600),
                          const SizedBox(height: 12),
                          Text(
                            _searchQuery.isEmpty ? 'No offers configured yet.' : 'No offers match your search.',
                            style: GoogleFonts.plusJakartaSans(color: Colors.grey.shade400, fontSize: 14),
                          ),
                        ],
                      ),
                    )
                        : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredOffers.length,
                      itemBuilder: (context, index) {
                        final offer = filteredOffers[index];
                        final String id = offer['_id'] ?? '';
                        final bool isActive = offer['isActive'] ?? true;
                        final bool isFeatured = offer['isFeatured'] ?? false;
                        final List products = offer['applicableProducts'] ?? [];
                        final String offerCode = offer['offerCode'] ?? '';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withOpacity(0.05)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (offer['bannerImage'] != null && offer['bannerImage'].toString().isNotEmpty)
                                      HoverableImagePreview(
                                        imageUrl: offer['bannerImage'] ?? '',
                                      ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  offer['title'] ?? 'Untitled Offer',
                                                  style: GoogleFonts.plusJakartaSans(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                    color: Colors.white,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              if (isFeatured)
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: Colors.blue.withOpacity(0.2),
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: Text(
                                                    'FEATURED',
                                                    style: GoogleFonts.plusJakartaSans(
                                                      fontSize: 9,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.blueAccent,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            offer['description'] ?? '',
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 12,
                                              color: Colors.grey.shade400,
                                            ),
                                          ),
                                          if (offerCode.isNotEmpty) ...[
                                            const SizedBox(height: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFF59E0B).withOpacity(0.15),
                                                borderRadius: BorderRadius.circular(6),
                                                border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.3)),
                                              ),
                                              child: Text(
                                                'CODE: $offerCode',
                                                style: GoogleFonts.plusJakartaSans(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: const Color(0xFFF59E0B),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF10B981).withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '${offer['discountPercentage']}% OFF',
                                        style: GoogleFonts.plusJakartaSans(
                                          color: const Color(0xFF34D399),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (products.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  Text(
                                    'Targeted Products: ${products.length} items linked',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      color: const Color(0xFFF59E0B),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 12),
                                Divider(color: Colors.white.withOpacity(0.08)),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'Status',
                                          style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey.shade400),
                                        ),
                                        Switch(
                                          value: isActive,
                                          activeColor: const Color(0xFF10B981),
                                          onChanged: (val) {
                                            provider.updateOffer(id, {'isActive': val});
                                          },
                                        ),
                                      ],
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444)),
                                      onPressed: () async {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            backgroundColor: const Color(0xFF1E293B),
                                            title: Text('Delete Offer', style: GoogleFonts.plusJakartaSans(color: Colors.white)),
                                            content: Text('Are you sure you want to remove this offer?', style: GoogleFonts.plusJakartaSans(color: Colors.grey.shade300)),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(ctx, false),
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () => Navigator.pop(ctx, true),
                                                child: const Text('Delete', style: TextStyle(color: Color(0xFFEF4444))),
                                              ),
                                            ],
                                          ),
                                        );

                                        if (confirm == true) {
                                          provider.deleteOffer(id);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    delayMs: 200,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Stat Card Widget
  Widget _buildStatCard({
    required String title,
    required String count,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              Icon(Icons.trending_up, color: color, size: 16),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(color: Colors.grey.shade400, fontSize: 11, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 2),
          Text(
            count,
            style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }

  // Filter Chip Widget
  Widget _buildFilterChip(String label, int count) {
    bool isSelected = _selectedFilter == label;
    return InkWell(
      onTap: () => setState(() => _selectedFilter = label),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF59E0B) : const Color(0xFF111827),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFFF59E0B) : Colors.grey.shade800,
          ),
        ),
        child: Text(
          '$label ($count)',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.black : Colors.grey.shade300,
          ),
        ),
      ),
    );
  }
}

class HoverableImagePreview extends StatefulWidget {
  final String imageUrl;

  const HoverableImagePreview({super.key, required this.imageUrl});

  @override
  State<HoverableImagePreview> createState() => _HoverableImagePreviewState();
}

class _HoverableImagePreviewState extends State<HoverableImagePreview> {
  OverlayEntry? _overlayEntry;

  void _showImagePreview(BuildContext context) {
    if (_overlayEntry != null) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: IgnorePointer(
          child: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
              Center(
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    constraints: const BoxConstraints(
                      maxWidth: 350,
                      maxHeight: 350,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black45,
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        widget.imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Container(
                          width: 200,
                          height: 200,
                          color: Colors.grey.shade900,
                          child: const Icon(
                            Icons.image_not_supported,
                            size: 50,
                            color: Colors.white54,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideImagePreview() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _hideImagePreview();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => _showImagePreview(context),
      onExit: (_) => _hideImagePreview(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          widget.imageUrl,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            width: 60,
            height: 60,
            color: Colors.grey.shade800,
            child: const Icon(Icons.image_not_supported, color: Colors.white54),
          ),
        ),
      ),
    );
  }
}





