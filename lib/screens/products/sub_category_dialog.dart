import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/sub_category_model.dart';
import '../../providers/admin_category_provider.dart';
import '../../providers/admin_sub_category_provider.dart';

class SubCategoryFormDialog extends StatefulWidget {
  final SubCategoryModel? subCategory;

  const SubCategoryFormDialog({super.key, this.subCategory});

  @override
  State<SubCategoryFormDialog> createState() => _SubCategoryFormDialogState();
}

class _SubCategoryFormDialogState extends State<SubCategoryFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _imageController;
  String? _selectedCategoryId;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.subCategory?.name ?? '');
    _imageController = TextEditingController(text: widget.subCategory?.image ?? '');
    _selectedCategoryId = widget.subCategory?.categoryId;

    // Load parent categories for dropdown
    Future.microtask(() {
      Provider.of<AdminCategoryProvider>(context, listen: false).fetchCategories();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a parent category'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSaving = true);
    final provider = Provider.of<AdminSubCategoryProvider>(context, listen: false);

    bool success = false;
    if (widget.subCategory == null) {
      success = await provider.createSubCategory(
        name: _nameController.text.trim(),
        categoryId: _selectedCategoryId!,
        image: _imageController.text.trim(),
      );
    } else {
      success = await provider.updateSubCategory(
        widget.subCategory!.id,
        name: _nameController.text.trim(),
        categoryId: _selectedCategoryId!,
        image: _imageController.text.trim(),
      );
    }

    setState(() => _isSaving = false);

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.subCategory == null ? 'Sub-category added!' : 'Sub-category updated!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Operation failed.'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<AdminCategoryProvider>(context);
    final isEdit = widget.subCategory != null;

    return AlertDialog(
      title: Text(
        isEdit ? 'Edit Sub-Category' : 'Add Sub-Category',
        style: GoogleFonts.lexend(fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Category Dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategoryId,
                decoration: const InputDecoration(
                  labelText: 'Select Parent Category *',
                  border: OutlineInputBorder(),
                ),
                items: categoryProvider.categories.map((cat) {
                  return DropdownMenuItem<String>(
                    value: cat.id,
                    child: Text(cat.name),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedCategoryId = val),
                validator: (val) => val == null ? 'Category is required' : null,
              ),
              const SizedBox(height: 16),

              // Name Input
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Sub-Category Name *',
                  hintText: 'e.g. T-Shirts, Laptops',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),

              // Image URL Input
              TextFormField(
                controller: _imageController,
                decoration: const InputDecoration(
                  labelText: 'Image URL',
                  hintText: 'https://example.com/image.png',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.link),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _submit,
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E2022)),
          child: _isSaving
              ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
          )
              : Text(isEdit ? 'Update' : 'Create', style: const TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}