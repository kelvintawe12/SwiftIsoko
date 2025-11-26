import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/models/product.dart';
import '../../data/providers/providers.dart';
import '../../data/providers/state_notifiers.dart';
import '../../data/utils/validators.dart';

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
  
  String? _selectedCategory;
  ProductCondition? _selectedCondition;
  String _selectedCurrency = 'RWF';
  final List<File> _selectedImages = [];
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage();
      
      if (images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(
            images.map((xFile) => File(xFile.path)),
          );
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking images: $e')),
        );
      }
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
      );
      
      if (image != null) {
        setState(() {
          _selectedImages.add(File(image.path));
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error taking photo: $e')),
        );
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedImages.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least 3 images'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a category'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedCondition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a condition'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final currentUser = ref.read(currentUserProvider);
    final userId = ref.read(currentUserIdProvider);
    
    currentUser.when(
      data: (user) async {
        if (user == null || userId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please sign in to create a product'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        final productCreationNotifier = ref.read(productCreationNotifierProvider.notifier);
        
        final result = await productCreationNotifier.createProduct(
          name: _nameController.text.trim(),
          images: _selectedImages,
          category: _selectedCategory!,
          description: _descriptionController.text.trim(),
          condition: _selectedCondition!,
          price: double.parse(_priceController.text.trim()),
          currency: _selectedCurrency,
          ownerId: userId,
          ownerName: user.name,
        );

        result.fold(
          (failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${failure.message}'),
                backgroundColor: Colors.red,
              ),
            );
          },
          (product) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Product created successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            // Reset form
            productCreationNotifier.reset();
            // Navigate back
            Navigator.of(context).pop();
            // Refresh products list
            ref.invalidate(productsStreamProvider);
          },
        );
      },
      loading: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Loading user information...'),
            backgroundColor: Colors.orange,
          ),
        );
      },
      error: (error, stack) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $error'),
            backgroundColor: Colors.red,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(productCategoriesProvider);
    final productCreationState = ref.watch(productCreationNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sell Product'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Product Name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Product Name',
                    hintText: 'Enter product name',
                    prefixIcon: Icon(Icons.shopping_bag_outlined),
                  ),
                  validator: Validators.validateProductName,
                  enabled: !productCreationState.isLoading,
                ),
                const SizedBox(height: 16),

                // Description
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Describe your product',
                    prefixIcon: Icon(Icons.description_outlined),
                  ),
                  maxLines: 4,
                  validator: Validators.validateDescription,
                  enabled: !productCreationState.isLoading,
                ),
                const SizedBox(height: 16),

                // Category
                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  items: categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: productCreationState.isLoading
                      ? null
                      : (value) {
                          setState(() {
                            _selectedCategory = value;
                          });
                        },
                  validator: Validators.validateCategory,
                ),
                const SizedBox(height: 16),

                // Condition
                DropdownButtonFormField<ProductCondition>(
                  initialValue: _selectedCondition,
                  decoration: const InputDecoration(
                    labelText: 'Condition',
                    prefixIcon: Icon(Icons.verified_outlined),
                  ),
                  items: ProductCondition.values.map((condition) {
                    return DropdownMenuItem(
                      value: condition,
                      child: Text(_formatCondition(condition)),
                    );
                  }).toList(),
                  onChanged: productCreationState.isLoading
                      ? null
                      : (value) {
                          setState(() {
                            _selectedCondition = value;
                          });
                        },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a condition';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Price and Currency Row
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(
                          labelText: 'Price',
                          hintText: '0.00',
                          prefixIcon: Icon(Icons.attach_money),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: Validators.validatePrice,
                        enabled: !productCreationState.isLoading,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedCurrency,
                        decoration: const InputDecoration(
                          labelText: 'Currency',
                        ),
                        items: const [
                          DropdownMenuItem(value: 'RWF', child: Text('RWF')),
                          DropdownMenuItem(value: 'USD', child: Text('USD')),
                          DropdownMenuItem(value: 'EUR', child: Text('EUR')),
                        ],
                        onChanged: productCreationState.isLoading
                            ? null
                            : (value) {
                                setState(() {
                                  _selectedCurrency = value!;
                                });
                              },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Images Section
                Text(
                  'Product Images (At least 3 required)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_selectedImages.length}/3+ images selected',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _selectedImages.length >= 3
                            ? Colors.green
                            : Colors.orange,
                      ),
                ),
                const SizedBox(height: 12),

                // Image Selection Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: productCreationState.isLoading
                            ? null
                            : _pickImages,
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Choose from Gallery'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: productCreationState.isLoading
                            ? null
                            : _pickImageFromCamera,
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Take Photo'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Selected Images Grid
                if (_selectedImages.isNotEmpty)
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _selectedImages.length,
                      itemBuilder: (context, index) {
                        return Container(
                          width: 150,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  _selectedImages[index],
                                  width: 150,
                                  height: 200,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: CircleAvatar(
                                  backgroundColor: Colors.red,
                                  radius: 16,
                                  child: IconButton(
                                    icon: const Icon(Icons.close, size: 16),
                                    color: Colors.white,
                                    onPressed: productCreationState.isLoading
                                        ? null
                                        : () => _removeImage(index),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 32),

                // Submit Button
                productCreationState.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Create Product',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatCondition(ProductCondition condition) {
    switch (condition) {
      case ProductCondition.newItem:
        return 'New';
      case ProductCondition.likeNew:
        return 'Like New';
      case ProductCondition.used:
        return 'Used';
      case ProductCondition.damaged:
        return 'Damaged';
    }
  }
}

