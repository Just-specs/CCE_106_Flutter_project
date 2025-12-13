import 'package:flutter/material.dart';
import 'package:fresh_petals/models/my_products.dart';
import 'package:fresh_petals/models/product.dart';

class EditProduct extends StatefulWidget {
  final Product product;
  
  const EditProduct({super.key, required this.product});

  @override
  State<EditProduct> createState() => _EditProductState();
}

class _EditProductState extends State<EditProduct> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  late TextEditingController _imageController;
  
  late String _selectedCategory;
  
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _priceController = TextEditingController(text: widget.product.price.toString());
    _descriptionController = TextEditingController(text: widget.product.description);
    _imageController = TextEditingController(text: widget.product.image);
    _selectedCategory = widget.product.category;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  void _updateProduct() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        // Update in all lists
        _updateProductInList(MyProducts.allProducts);
        _updateProductInList(MyProducts.birthdayList);
        _updateProductInList(MyProducts.anniversaryList);
        _updateProductInList(MyProducts.debutList);
        _updateProductInList(MyProducts.giftList);
        _updateProductInList(MyProducts.MothersdayList);
        
        // If category changed, handle migration
        if (_selectedCategory != widget.product.category) {
          _removeFromOldCategory(widget.product.category);
          _addToNewCategory(_selectedCategory);
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(' updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    }
  }

  void _updateProductInList(List<Product> list) {
    final index = list.indexWhere((p) => p.id == widget.product.id);
    if (index != -1) {
      list[index] = Product(
        id: widget.product.id,
        name: _nameController.text,
        category: _selectedCategory,
        image: _imageController.text,
        description: _descriptionController.text,
        price: double.parse(_priceController.text),
        quantity: widget.product.quantity,
      );
    }
  }

  void _removeFromOldCategory(String oldCategory) {
    switch (oldCategory) {
      case 'Birthday':
        MyProducts.birthdayList.removeWhere((p) => p.id == widget.product.id);
        break;
      case 'Anniversary':
        MyProducts.anniversaryList.removeWhere((p) => p.id == widget.product.id);
        break;
      case 'Debut':
        MyProducts.debutList.removeWhere((p) => p.id == widget.product.id);
        break;
      case 'Gift':
        MyProducts.giftList.removeWhere((p) => p.id == widget.product.id);
        break;
      case 'Mothersday':
        MyProducts.MothersdayList.removeWhere((p) => p.id == widget.product.id);
        break;
    }
  }

  void _addToNewCategory(String newCategory) {
    final updatedProduct = Product(
      id: widget.product.id,
      name: _nameController.text,
      category: newCategory,
      image: _imageController.text,
      description: _descriptionController.text,
      price: double.parse(_priceController.text),
      quantity: widget.product.quantity,
    );

    switch (newCategory) {
      case 'Birthday':
        MyProducts.birthdayList.add(updatedProduct);
        break;
      case 'Anniversary':
        MyProducts.anniversaryList.add(updatedProduct);
        break;
      case 'Debut':
        MyProducts.debutList.add(updatedProduct);
        break;
      case 'Gift':
        MyProducts.giftList.add(updatedProduct);
        break;
      case 'Mothersday':
        MyProducts.MothersdayList.add(updatedProduct);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Product',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image Preview
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    widget.product.image,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        color: Colors.grey[300],
                        child: Icon(
                          Icons.image_not_supported,
                          size: 80,
                          color: Colors.grey[600],
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              const Text(
                'Edit Product Information',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Product Name
              TextFormField(
                controller: _nameController,
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
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              // Price
              TextFormField(
                controller: _priceController,
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
              
              // Update Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _updateProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Update Product',
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
    );
  }
}
