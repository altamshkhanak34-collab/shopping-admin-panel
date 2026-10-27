import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/Category_model.dart';
import '../../providers/admin_category_provider.dart';

class CategoryFormDialog extends StatefulWidget {
  final CategoryModel? category;

  const CategoryFormDialog({super.key, this.category});

  @override
  State<CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends State<CategoryFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _imageController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _imageController = TextEditingController(text: widget.category?.image ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final provider = Provider.of<AdminCategoryProvider>(context, listen: false);

    bool success = false;
    if (widget.category == null) {
      success = await provider.createCategory(
        _nameController.text.trim(),
        _imageController.text.trim(),
      );
    } else {
      success = await provider.updateCategory(
        widget.category!.id,
        name: _nameController.text.trim(),
        image: _imageController.text.trim(),
      );
    }

    setState(() => _isSaving = false);

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.category == null ? 'Category added!' : 'Category updated!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save category.'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.category != null;

    return AlertDialog(
      title: Text(
        isEdit ? 'Edit Category' : 'Add New Category',
        style: GoogleFonts.lexend(fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Category Name *',
                  hintText: 'e.g. Fashion, Electronics',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),
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