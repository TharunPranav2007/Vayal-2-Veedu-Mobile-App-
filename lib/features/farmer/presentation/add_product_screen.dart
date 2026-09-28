import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  String _selectedCategory = 'Fresh Vegetables';
  String _selectedUnit = 'kg';

  final List<String> _categories = [
    'Fresh Vegetables',
    'Fresh Greens',
    'Organic Fruits',
    'Grains & Pulses',
    'Dairy & Eggs',
  ];

  final List<String> _units = ['kg', 'bunch', 'liter', 'pack', 'piece'];

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Produce listed successfully!'),
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
                  labelText: 'Produce Name (e.g. Country Tomatoes)',
                  prefixIcon: Icon(Icons.eco_outlined),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Please enter produce name' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category_outlined),
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
                        prefixIcon: Icon(Icons.currency_rupee),
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
                  prefixIcon: Icon(Icons.inventory_outlined),
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
                onPressed: () {},
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('Capture / Upload Produce Photos'),
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
