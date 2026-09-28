import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../app/providers/products_provider.dart';
import '../../products/domain/product_model.dart';

class AddProductScreen extends ConsumerStatefulWidget {
  const AddProductScreen({super.key});

  @override
  ConsumerState<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends ConsumerState<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  String _selectedCategory = 'Vegetables';
  String _selectedUnit = 'kg';

  final List<String> _categories = [
    'Vegetables',
    'Greens',
    'Fruits',
    'Grains',
  ];

  final List<String> _units = ['kg', 'bunch', 'liter', 'pack', 'dozen'];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  void _submitProduct() {
    if (_formKey.currentState!.validate()) {
      final newProduct = Product(
        id: 'p-${DateTime.now().millisecondsSinceEpoch}',
        farmerId: 'f1',
        farmerName: 'Green Field Organic Farm',
        categoryId: 'cat-${_selectedCategory.toLowerCase()}',
        categoryName: _selectedCategory,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? 'Fresh farm produce directly from grower'
            : _descriptionController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        unit: _selectedUnit,
        stock: double.parse(_stockController.text.trim()),
        averageRating: 5.0,
        totalReviews: 1,
      );

      ref.read(productsProvider.notifier).addProduct(newProduct);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${newProduct.name}" published to direct marketplace!'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Produce Listing'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Produce Name (e.g. Organic Bell Peppers)',
                  prefixIcon: Icon(Icons.eco_outlined, color: AppColors.primaryGreen),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Please enter produce name' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category_outlined, color: AppColors.primaryGreen),
                ),
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCategory = val);
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _priceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Price (₹)',
                        prefixIcon: Icon(Icons.currency_rupee, color: AppColors.primaryGreen),
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Enter price';
                        final p = double.tryParse(val);
                        if (p == null || p <= 0) return 'Price must be > 0';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField<String>(
                      value: _selectedUnit,
                      decoration: const InputDecoration(labelText: 'Unit'),
                      items: _units
                          .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedUnit = val);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _stockController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Available Inventory Stock',
                  prefixIcon: Icon(Icons.inventory_outlined, color: AppColors.primaryGreen),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Enter available stock';
                  final s = double.tryParse(val);
                  if (s == null || s < 0) return 'Stock must be >= 0';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description & Harvest Details',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Farm photo captured successfully!')),
                  );
                },
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('Capture / Upload Produce Photo'),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submitProduct,
                child: const Text('Publish Produce to Marketplace'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
