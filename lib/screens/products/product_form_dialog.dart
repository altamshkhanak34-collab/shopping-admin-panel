import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/product_model.dart';
import '../../providers/admin_brand_provider.dart';
import '../../providers/admin_category_provider.dart';
import '../../providers/admin_product_provider.dart';
import '../../providers/admin_sub_category_provider.dart';

class ColorItem {
  TextEditingController nameController;
  TextEditingController hexController;
  List<TextEditingController> imageControllers;

  ColorItem({
    String name = '',
    String hex = '#000000',
    List<String>? images,
  })  : nameController = TextEditingController(text: name),
        hexController = TextEditingController(text: hex),
        imageControllers = (images != null && images.isNotEmpty)
            ? images.map((img) => TextEditingController(text: img)).toList()
            : [TextEditingController()]; // Default 1 image field

  void addImageField() {
    imageControllers.add(TextEditingController());
  }

  void removeImageField(int index) {
    if (imageControllers.length > 1) {
      imageControllers[index].dispose();
      imageControllers.removeAt(index);
    }
  }

  void dispose() {
    nameController.dispose();
    hexController.dispose();
    for (var controller in imageControllers) {
      controller.dispose();
    }
  }
}

class ProductFormScreen extends StatefulWidget {
  final ProductModel? product;

  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Text Controllers matching MongoDB Schema
  late TextEditingController _titleController;
  late TextEditingController _slugController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  late TextEditingController _originalPriceController;
  late TextEditingController _costPriceController;
  late TextEditingController _discountPercentageController;
  late TextEditingController _stockController;
  late TextEditingController _categorySlugController;
  late TextEditingController _subCategorySlugController;
  late TextEditingController _brandIdController;
  late TextEditingController _thumbnailController;
  late TextEditingController _imagesController; // Comma separated URLs
  late TextEditingController _sizesController;  // Comma separated e.g. S, M, L, XL
  late TextEditingController _flashSalePriceController;

  // Dynamic Color Variants with Image
  List<ColorItem> _colorItems = [];

  // Boolean Flags
  bool _isActive = true;
  bool _isFeatured = false;
  bool _isBestSeller = false;
  bool _isNewArrival = false;
  bool _isFlashSale = false;
  bool _isSaving = false;
  String? _selectedCategorySlug;
  String? _selectedSubCategorySlug;
  String? _selectedBrandId;

  @override
  void initState() {
    super.initState();
    final p = widget.product;

    _titleController = TextEditingController(text: p?.title ?? '');
    _slugController = TextEditingController(text: p?.slug ?? '');
    _descController = TextEditingController(text: p?.description ?? '');
    _priceController = TextEditingController(text: p?.price.toString() ?? '');
    _originalPriceController = TextEditingController(text: p?.originalPrice?.toString() ?? '');
    _costPriceController = TextEditingController(text: p?.costPrice?.toString() ?? '');
    _discountPercentageController = TextEditingController(text: p?.discountPercentage?.toString() ?? '');
    _stockController = TextEditingController(text: p?.stock.toString() ?? '');
    _categorySlugController = TextEditingController(text: p?.categorySlug ?? '');
    _subCategorySlugController = TextEditingController(text: p?.subCategorySlug ?? '');
    _brandIdController = TextEditingController(text: p?.brandId ?? '');
    _thumbnailController = TextEditingController(text: p?.thumbnail ?? '');
    _flashSalePriceController = TextEditingController(text: p?.flashSalePrice?.toString() ?? '');

    // Categories, Sub-Categories aur Brands fetch karne ke liye
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminCategoryProvider>(context, listen: false).fetchCategories();
      Provider.of<AdminSubCategoryProvider>(context, listen: false).fetchSubCategories();
      Provider.of<AdminBrandProvider>(context, listen: false).fetchBrands();
    });

    _selectedCategorySlug = p?.categorySlug;
    _selectedSubCategorySlug = p?.subCategorySlug;
    _selectedBrandId = p?.brandId;

    // Arrays to string representation
    _imagesController = TextEditingController(text: p?.images?.join(', ') ?? '');
    _sizesController = TextEditingController(text: p?.sizes?.join(', ') ?? '');

    // Initialize Color Variants with all images list
    if (p != null && p.colors != null && p.colors!.isNotEmpty) {
      _colorItems = p.colors!.map((c) {
        return ColorItem(
          name: c.name ?? '',
          hex: c.hexCode ?? '#000000',
          images: c.images,
        );
      }).toList();
    } else {
      _colorItems = [ColorItem()];
    }

    if (p != null) {
      _isActive = p.isActive ?? true;
      _isFeatured = p.isFeatured ?? false;
      _isBestSeller = p.isBestSeller ?? false;
      _isNewArrival = p.isNewArrival ?? false;
      _isFlashSale = p.isFlashSale ?? false;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _slugController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _originalPriceController.dispose();
    _costPriceController.dispose();
    _discountPercentageController.dispose();
    _stockController.dispose();
    _categorySlugController.dispose();
    _subCategorySlugController.dispose();
    _brandIdController.dispose();
    _thumbnailController.dispose();
    _imagesController.dispose();
    _sizesController.dispose();
    _flashSalePriceController.dispose();

    for (var item in _colorItems) {
      item.dispose();
    }
    super.dispose();
  }

  // Auto-generate slug from title
  void _generateSlug(String title) {
    if (widget.product == null || _slugController.text.isEmpty) {
      final slug = title
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
          .replaceAll(RegExp(r'\s+'), '-');
      _slugController.text = slug;
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final provider = Provider.of<AdminProductProvider>(context, listen: false);

    List<String> imagesList = _imagesController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    List<String> sizesList = _sizesController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    // Map Color Variants to MongoDB Schema
    List<Map<String, dynamic>> colorsPayload = _colorItems
        .where((item) => item.nameController.text.trim().isNotEmpty)
        .map((item) {
      List<String> colorImages = item.imageControllers
          .map((c) => c.text.trim())
          .where((url) => url.isNotEmpty)
          .toList();

      return {
        'name': item.nameController.text.trim(),
        'hexCode': item.hexController.text.trim().isEmpty
            ? '#000000'
            : item.hexController.text.trim(),
        'images': colorImages.isNotEmpty
            ? colorImages
            : [_thumbnailController.text.trim()],
      };
    }).toList();

    final data = {
      'title': _titleController.text.trim(),
      'slug': _slugController.text.trim(),
      'description': _descController.text.trim(),
      'price': double.tryParse(_priceController.text) ?? 0.0,
      'originalPrice': double.tryParse(_originalPriceController.text) ?? 0.0,
      'costPrice': double.tryParse(_costPriceController.text) ?? 0.0,
      'discountPercentage': double.tryParse(_discountPercentageController.text) ?? 0.0,
      'stock': int.tryParse(_stockController.text) ?? 0,
      'categorySlug': _categorySlugController.text.trim(),
      'subCategorySlug': _subCategorySlugController.text.trim(),
      'brandId': _brandIdController.text.trim().isEmpty ? null : _brandIdController.text.trim(),
      'thumbnail': _thumbnailController.text.trim(),
      'images': imagesList.isNotEmpty ? imagesList : [_thumbnailController.text.trim()],
      'sizes': sizesList,
      'colors': colorsPayload,
      'isActive': _isActive,
      'isFeatured': _isFeatured,
      'isBestSeller': _isBestSeller,
      'isNewArrival': _isNewArrival,
      'isFlashSale': _isFlashSale,
      'flashSalePrice': double.tryParse(_flashSalePriceController.text),
    };

    bool success = false;
    if (widget.product == null) {
      success = await provider.addProduct(data);
    } else {
      success = await provider.updateProduct(widget.product!.id, data);
    }

    setState(() => _isSaving = false);

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.product == null ? 'Product created successfully!' : 'Product updated successfully!',
              style: GoogleFonts.lexend(),
            ),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save product.', style: GoogleFonts.lexend()),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade200, height: 1),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEdit ? 'Edit Product' : 'Add New Product',
          style: GoogleFonts.lexend(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20, top: 8, bottom: 8),
            child: ElevatedButton.icon(
              onPressed: _isSaving ? null : _submitForm,
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.save_rounded, color: Colors.white, size: 18),
              label: Text(
                isEdit ? 'Save Changes' : 'Publish Product',
                style: GoogleFonts.lexend(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E2022),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // LEFT COLUMN: All Data Fields (Flex 3)
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    // Card 1: General Details
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: _cardDecoration(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Text('Basic Information', style: _sectionHeaderStyle()),
                            ],
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _titleController,
                            onChanged: _generateSlug,
                            style: GoogleFonts.lexend(fontSize: 14),
                            decoration: _inputDecoration(
                              labelText: 'Title *',
                              hintText: 'e.g. Shree Ji Casual Raglan Sleeves Top',
                              prefixIcon: Icons.title,
                            ),
                            validator: (val) => val == null || val.trim().isEmpty ? 'Title is required' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _slugController,
                            style: GoogleFonts.lexend(fontSize: 14),
                            decoration: _inputDecoration(
                              labelText: 'Slug *',
                              hintText: 'shree-ji-casual-raglan-sleeves-top',
                              prefixIcon: Icons.link,
                            ),
                            validator: (val) => val == null || val.trim().isEmpty ? 'Slug is required' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _descController,
                            maxLines: 4,
                            style: GoogleFonts.lexend(fontSize: 14),
                            decoration: _inputDecoration(
                              labelText: 'Description',
                              hintText: 'Enter detailed description...',
                              prefixIcon: Icons.description_outlined,
                            ).copyWith(
                              alignLabelWithHint: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Card 2: Pricing & Stock
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: _cardDecoration(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(Icons.currency_rupee, color: Colors.green.shade700, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Text('Pricing & Inventory', style: _sectionHeaderStyle()),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _priceController,
                                  keyboardType: TextInputType.number,
                                  style: GoogleFonts.lexend(fontSize: 14),
                                  decoration: _inputDecoration(
                                    labelText: 'Selling Price (₹) *',
                                    hintText: '0.00',
                                  ),
                                  validator: (val) => val == null || val.trim().isEmpty ? 'Price is required' : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _originalPriceController,
                                  keyboardType: TextInputType.number,
                                  style: GoogleFonts.lexend(fontSize: 14),
                                  decoration: _inputDecoration(
                                    labelText: 'Original Price (₹)',
                                    hintText: '0.00',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _costPriceController,
                                  keyboardType: TextInputType.number,
                                  style: GoogleFonts.lexend(fontSize: 14),
                                  decoration: _inputDecoration(
                                    labelText: 'Cost Price (₹) *',
                                    hintText: 'Purchase cost',
                                  ),
                                  validator: (val) => val == null || val.trim().isEmpty ? 'Cost price is required' : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _discountPercentageController,
                                  keyboardType: TextInputType.number,
                                  style: GoogleFonts.lexend(fontSize: 14),
                                  decoration: _inputDecoration(
                                    labelText: 'Discount %',
                                    hintText: '0%',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _stockController,
                            keyboardType: TextInputType.number,
                            style: GoogleFonts.lexend(fontSize: 14),
                            decoration: _inputDecoration(
                              labelText: 'Stock Quantity *',
                              hintText: 'e.g. 100',
                              prefixIcon: Icons.inventory_2_outlined,
                            ),
                            validator: (val) => val == null || val.trim().isEmpty ? 'Stock is required' : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Card 3: Categories & Dynamic Color Variants
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: _cardDecoration(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.purple.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(Icons.category_outlined, color: Colors.purple.shade700, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Text('Category, Brand & Variants', style: _sectionHeaderStyle()),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Consumer2<AdminCategoryProvider, AdminSubCategoryProvider>(
                            builder: (context, catProvider, subCatProvider, child) {
                              bool categoryExists = catProvider.categories.any((cat) => cat.slug == _selectedCategorySlug);
                              String? safeCategoryValue = categoryExists ? _selectedCategorySlug : null;

                              bool subCategoryExists = subCatProvider.subCategories.any((subCat) => subCat.slug == _selectedSubCategorySlug);
                              String? safeSubCategoryValue = subCategoryExists ? _selectedSubCategorySlug : null;

                              return Row(
                                children: [
                                  // Category Dropdown
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      value: safeCategoryValue,
                                      style: GoogleFonts.lexend(fontSize: 14, color: Colors.black87),
                                      decoration: _inputDecoration(
                                        labelText: 'Select Category *',
                                      ),
                                      hint: Text('Choose category', style: GoogleFonts.lexend(color: Colors.grey.shade400, fontSize: 14)),
                                      items: catProvider.categories.map((cat) {
                                        return DropdownMenuItem<String>(
                                          value: cat.slug,
                                          child: Text(cat.name, style: GoogleFonts.lexend(fontSize: 14)),
                                        );
                                      }).toList(),
                                      onChanged: (val) {
                                        setState(() {
                                          _selectedCategorySlug = val;
                                          _categorySlugController.text = val ?? '';
                                        });
                                      },
                                      validator: (val) => val == null || val.isEmpty ? 'Category is required' : null,
                                    ),
                                  ),
                                  const SizedBox(width: 16),

                                  // Sub-Category Dropdown
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      value: safeSubCategoryValue,
                                      style: GoogleFonts.lexend(fontSize: 14, color: Colors.black87),
                                      decoration: _inputDecoration(
                                        labelText: 'Select Sub-Category',
                                      ),
                                      hint: Text('Choose sub-category', style: GoogleFonts.lexend(color: Colors.grey.shade400, fontSize: 14)),
                                      items: subCatProvider.subCategories.map((subCat) {
                                        return DropdownMenuItem<String>(
                                          value: subCat.slug,
                                          child: Text(subCat.name, style: GoogleFonts.lexend(fontSize: 14)),
                                        );
                                      }).toList(),
                                      onChanged: (val) {
                                        setState(() {
                                          _selectedSubCategorySlug = val;
                                          _subCategorySlugController.text = val ?? '';
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Consumer<AdminBrandProvider>(
                                  builder: (context, brandProvider, child) {
                                    final brandIds = brandProvider.brands.map((b) => b.id).toList();
                                    final safeBrandValue = (brandIds.contains(_selectedBrandId)) ? _selectedBrandId : null;

                                    return DropdownButtonFormField<String>(
                                      value: safeBrandValue,
                                      style: GoogleFonts.lexend(fontSize: 14, color: Colors.black87),
                                      decoration: _inputDecoration(
                                        labelText: 'Select Brand',
                                        prefixIcon: Icons.branding_watermark_outlined,
                                      ),
                                      hint: Text('Choose brand', style: GoogleFonts.lexend(color: Colors.grey.shade400, fontSize: 14)),
                                      items: brandProvider.brands.map((brand) {
                                        return DropdownMenuItem<String>(
                                          value: brand.id,
                                          child: Text(brand.name, style: GoogleFonts.lexend(fontSize: 14)),
                                        );
                                      }).toList(),
                                      onChanged: (val) {
                                        setState(() {
                                          _selectedBrandId = val;
                                          _brandIdController.text = val ?? '';
                                        });
                                      },
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _sizesController,
                                  style: GoogleFonts.lexend(fontSize: 14),
                                  decoration: _inputDecoration(
                                    labelText: 'Sizes (Comma Separated)',
                                    hintText: 'S, M, L, XL',
                                    prefixIcon: Icons.straighten,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          const Divider(height: 1, color: Color(0xFFE5E7EB)),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Color Variants & Images', style: GoogleFonts.lexend(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.grey.shade900)),
                              OutlinedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _colorItems.add(ColorItem());
                                  });
                                },
                                icon: const Icon(Icons.add, size: 16),
                                label: Text('Add Color Variant', style: GoogleFonts.lexend(fontSize: 13, fontWeight: FontWeight.w600)),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF1E2022),
                                  side: const BorderSide(color: Color(0xFF1E2022)),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Dynamic Color Variants with Multiple Images Support
                          ..._colorItems.asMap().entries.map((entry) {
                            int colorIndex = entry.key;
                            ColorItem item = entry.value;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 16.0),
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Top Row: Color Name & Delete Color Button
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller: item.nameController,
                                          style: GoogleFonts.lexend(fontSize: 13,),

                                          decoration: _inputDecoration(
                                            labelText: 'Color Name *',
                                            hintText: 'e.g. Red',

                                          ).copyWith(
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: TextFormField(
                                          controller: item.hexController,
                                          style: GoogleFonts.lexend(fontSize: 13),
                                          decoration: _inputDecoration(
                                            labelText: 'Hex Code',
                                            hintText: '#FF0000',
                                          ).copyWith(
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                          ),
                                        ),
                                      ),
                                      if (_colorItems.length > 1) ...[
                                        const SizedBox(width: 8),
                                        IconButton(
                                          icon: const Icon(Icons.delete_forever_outlined, color: Colors.red),
                                          tooltip: 'Remove Variant',
                                          onPressed: () {
                                            setState(() {
                                              item.dispose();
                                              _colorItems.removeAt(colorIndex);
                                            });
                                          },
                                        ),
                                      ]
                                    ],
                                  ),
                                  const SizedBox(height: 14),

                                  // Sub-Header for Images
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Color Images', style: GoogleFonts.lexend(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            item.addImageField();
                                          });
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.add_photo_alternate_outlined, size: 16, color: Colors.blue),
                                              const SizedBox(width: 6),
                                              Text('Add Image URL', style: GoogleFonts.lexend(color: Colors.blue.shade700, fontSize: 12, fontWeight: FontWeight.w600)),
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 8),

                                  // List of Image TextFields for this specific Color
                                  ...item.imageControllers.asMap().entries.map((imgEntry) {
                                    int imgIndex = imgEntry.key;
                                    TextEditingController imgController = imgEntry.value;

                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 8.0),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: TextFormField(
                                              controller: imgController,
                                              style: GoogleFonts.lexend(fontSize: 13),
                                              decoration: _inputDecoration(
                                                labelText: 'Image URL #${imgIndex + 1}',
                                                hintText: 'https://example.com/image.jpg',
                                                prefixIcon: Icons.link,
                                              ).copyWith(
                                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                              ),
                                            ),
                                          ),
                                          if (item.imageControllers.length > 1) ...[
                                            const SizedBox(width: 8),
                                            IconButton(
                                              icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent, size: 20),
                                              onPressed: () {
                                                setState(() {
                                                  item.removeImageField(imgIndex);
                                                });
                                              },
                                            ),
                                          ]
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 24),

              // RIGHT COLUMN: Image Preview & Visibility Flags (Flex 2)
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    // Card 4: Thumbnail & Image Preview
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: _cardDecoration(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(Icons.image_outlined, color: Colors.orange.shade700, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Text('Product Thumbnail', style: _sectionHeaderStyle()),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Image Box
                          Container(
                            width: double.infinity,
                            height: 240,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: ValueListenableBuilder<TextEditingValue>(
                              valueListenable: _thumbnailController,
                              builder: (context, value, child) {
                                final url = value.text.trim();
                                if (url.isEmpty) {
                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.image_search_rounded, size: 48, color: Colors.grey.shade400),
                                      const SizedBox(height: 10),
                                      Text('Enter URL to preview image', style: GoogleFonts.lexend(color: Colors.grey.shade600, fontSize: 13)),
                                    ],
                                  );
                                }
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    url,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) => Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.broken_image_outlined, color: Colors.red, size: 40),
                                          const SizedBox(height: 8),
                                          Text('Invalid Image URL', style: GoogleFonts.lexend(color: Colors.red.shade700, fontSize: 13)),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _thumbnailController,
                            onChanged: (_) => setState(() {}),
                            style: GoogleFonts.lexend(fontSize: 14),
                            decoration: _inputDecoration(
                              labelText: 'Thumbnail URL *',
                              prefixIcon: Icons.link,
                              hintText: 'https://example.com/thumbnail.jpg',
                            ),
                            validator: (val) => val == null || val.trim().isEmpty ? 'Thumbnail is required' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _imagesController,
                            style: GoogleFonts.lexend(fontSize: 14),
                            decoration: _inputDecoration(
                              labelText: 'Additional Image URLs (Comma separated)',
                              prefixIcon: Icons.collections_outlined,
                              hintText: 'url1, url2, url3',
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Card 5: Store Flags & Badges
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: _cardDecoration(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.teal.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(Icons.verified_outlined, color: Colors.teal.shade700, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Text('Product Visibility & Badges', style: _sectionHeaderStyle()),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SwitchListTile(
                            title: Text('Is Active', style: GoogleFonts.lexend(fontWeight: FontWeight.w500, fontSize: 14)),
                            value: _isActive,
                            activeColor: const Color(0xFF1E2022),
                            onChanged: (val) => setState(() => _isActive = val),
                            contentPadding: EdgeInsets.zero,
                          ),
                          const Divider(height: 1, color: Color(0xFFF3F4F6)),
                          SwitchListTile(
                            title: Text('Is Featured', style: GoogleFonts.lexend(fontWeight: FontWeight.w500, fontSize: 14)),
                            value: _isFeatured,
                            activeColor: const Color(0xFF1E2022),
                            onChanged: (val) => setState(() => _isFeatured = val),
                            contentPadding: EdgeInsets.zero,
                          ),
                          const Divider(height: 1, color: Color(0xFFF3F4F6)),
                          SwitchListTile(
                            title: Text('Is Best Seller', style: GoogleFonts.lexend(fontWeight: FontWeight.w500, fontSize: 14)),
                            value: _isBestSeller,
                            activeColor: const Color(0xFF1E2022),
                            onChanged: (val) => setState(() => _isBestSeller = val),
                            contentPadding: EdgeInsets.zero,
                          ),
                          const Divider(height: 1, color: Color(0xFFF3F4F6)),
                          SwitchListTile(
                            title: Text('Is New Arrival', style: GoogleFonts.lexend(fontWeight: FontWeight.w500, fontSize: 14)),
                            value: _isNewArrival,
                            activeColor: const Color(0xFF1E2022),
                            onChanged: (val) => setState(() => _isNewArrival = val),
                            contentPadding: EdgeInsets.zero,
                          ),
                          const Divider(height: 1, color: Color(0xFFF3F4F6)),
                          SwitchListTile(
                            title: Text('Is Flash Sale', style: GoogleFonts.lexend(fontWeight: FontWeight.w500, fontSize: 14)),
                            value: _isFlashSale,
                            activeColor: const Color(0xFF1E2022),
                            onChanged: (val) => setState(() => _isFlashSale = val),
                            contentPadding: EdgeInsets.zero,
                          ),
                          if (_isFlashSale) ...[
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _flashSalePriceController,
                              keyboardType: TextInputType.number,
                              style: GoogleFonts.lexend(fontSize: 14),
                              decoration: _inputDecoration(
                                labelText: 'Flash Sale Price (₹)',
                                hintText: '0.00',
                                prefixIcon: Icons.local_offer_outlined,
                              ),
                            ),
                          ]
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
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
    );
  }

  TextStyle _sectionHeaderStyle() {
    return GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade900);
  }

  InputDecoration _inputDecoration({
    required String labelText,
    String? hintText,
    IconData? prefixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: GoogleFonts.lexend(color: Colors.grey.shade600, fontSize: 13),
      hintText: hintText,
      hintStyle: GoogleFonts.lexend(color: Colors.grey.shade400, fontSize: 14),
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 20, color: Colors.grey.shade500) : null,
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF1E2022), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.red.shade300, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.red.shade600, width: 1.5),
      ),
    );
  }
}
