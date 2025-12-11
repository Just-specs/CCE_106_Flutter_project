import 'package:flutter/material.dart';
import 'package:fresh_petals/models/my_products.dart';
import 'package:fresh_petals/models/product.dart';
import 'package:fresh_petals/services/supabase_service.dart';

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
  
  String _selectedCategory = 'Birthday';
  bool _isLoading = false;
  
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

  Future<void> _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        print('DEBUG: Attempting to create product in Supabase');
        print('DEBUG: Name = ${_nameController.text}');
        print('DEBUG: Category = $_selectedCategory');
        print('DEBUG: Price = ${_priceController.text}');
        
        // Save to Supabase
        await _supabaseService.createProduct(
          name: _nameController.text,
          category: _selectedCategory,
          image: _imageController.text,
          description: _descriptionController.text,
          price: double.parse(_priceController.text),
        );

        print('DEBUG: Product created successfully in Supabase');

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
        print('ERROR: Failed to create product: $e');
        
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
                    value: _selectedCategory,
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
                      labelText: 'Price (₱)',
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
                  
                  // Image Path
                  TextFormField(
                    controller: _imageController,
                    enabled: !_isLoading,
                    decoration: InputDecoration(
                      labelText: 'Image Path',
                      prefixIcon: const Icon(Icons.image),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      helperText: 'e.g., lib/images/birthday/FlowerName.png',
                      helperMaxLines: 2,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter image path';
                      }
                      return null;
                    },
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