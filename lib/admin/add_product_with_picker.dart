import 'package:flutter/material.dart';
import 'package:fresh_petals/models/my_products.dart';
import 'package:fresh_petals/models/product.dart';
import 'package:fresh_petals/services/supabase_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

class AddProduct extends StatefulWidget {
  final String category;
  
  const AddProduct({super.key, required this.category});

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageController = TextEditingController();
  final _supabaseService = SupabaseService.instance;
  final ImagePicker _picker = ImagePicker();
  
  String _selectedCategory = 'Birthday';
  bool _isLoading = false;
  XFile? _selectedImage; // Changed from File to XFile for web support
  
  @override
  void initState() {
    super.initState();
    if (widget.category != 'All Products') {
      _selectedCategory = widget.category;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = image;
          _imageController.text = image.path;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image selected: ${image.name}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Save to Supabase
        await _supabaseService.createProduct(
          name: _nameController.text,
          category: _selectedCategory,
          image: _imageController.text,
          description: _descriptionController.text,
          price: double.parse(_priceController.text),
        );
        // Also add to local memory for immediate display
        int newId = MyProducts.allProducts.isEmpty 
            ? 1 
            : MyProducts.allProducts.map((p) => p.id).reduce((a, b) => a > b ? a : b) + 1;

        final newProduct = Product(
          id: newId,
          name: _nameController.text,
          category: _selectedCategory,
          image: _imageController.text,
          description: _descriptionController.text,
          price: double.parse(_priceController.text),
          quantity: 1,
        );

        setState(() {
          // Add to all products
          MyProducts.allProducts.add(newProduct);
          
          // Add to category-specific list
          switch (_selectedCategory) {
            case 'Birthday':
              MyProducts.birthdayList.add(newProduct);
              break;
            case 'Anniversary':
              MyProducts.anniversaryList.add(newProduct);
              break;
            case 'Debut':
              MyProducts.debutList.add(newProduct);
              break;
            case 'Gift':
              MyProducts.giftList.add(newProduct);
              break;
            case 'Mothersday':
              MyProducts.MothersdayList.add(newProduct);
              break;
          }
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${_nameController.text} added successfully!'),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.pop(context, true); // Return true to indicate success
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to add product: ${e.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Widget _buildImagePreview() {
    if (_selectedImage == null) return const SizedBox.shrink();

    return Container(
      height: 200,
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: kIsWeb
            ? Image.network(
                _selectedImage!.path,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // For web, try to load from bytes
                  return FutureBuilder<List<int>>(
                    future: _selectedImage!.readAsBytes(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Image.memory(
                          snapshot.data! as dynamic,
                          fit: BoxFit.cover,
                        );
                      }
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  );
                },
              )
            : Image.file(
                File(_selectedImage!.path),
                fit: BoxFit.cover,
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add New Product',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Product Information',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Product Name
                  TextFormField(
                    controller: _nameController,
                    enabled: !_isLoading,
                    decoration: InputDecoration(
                      labelText: 'Product Name',
                      prefixIcon: const Icon(Icons.local_florist),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter product name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Category Dropdown
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
                    decoration: InputDecoration(
                      labelText: 'Category',
                      prefixIcon: const Icon(Icons.category),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Birthday', child: Text('Birthday')),
                      DropdownMenuItem(value: 'Anniversary', child: Text('Anniversary')),
                      DropdownMenuItem(value: 'Debut', child: Text('Debut')),
                      DropdownMenuItem(value: 'Gift', child: Text('Gift')),
                      DropdownMenuItem(value: 'Mothersday', child: Text("Mother's Day")),
                    ],
                    onChanged: _isLoading ? null : (value) {
                      setState(() {
                        _selectedCategory = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Price
                  TextFormField(
                    controller: _priceController,
                    enabled: !_isLoading,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Price (?)',
                      prefixIcon: const Icon(Icons.attach_money),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter price';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Image Picker Section
                  const Text(
                    'Product Image',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Image Preview (Web & Mobile Compatible)
                  _buildImagePreview(),
                  
                  // Image Path Field with Browse Button
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _imageController,
                          enabled: !_isLoading,
                          decoration: InputDecoration(
                            labelText: 'Image Path',
                            prefixIcon: const Icon(Icons.image),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            helperText: 'Click Browse to select image',
                            helperMaxLines: 2,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select an image';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : _pickImage,
                        icon: const Icon(Icons.folder_open, color: Colors.white),
                        label: const Text(
                          'Browse',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Description
                  TextFormField(
                    controller: _descriptionController,
                    enabled: !_isLoading,
                    maxLines: 5,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      prefixIcon: const Icon(Icons.description),
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveProduct,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Save Product',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}