import 'package:flutter/material.dart';

class AddressBookScreen extends StatefulWidget {
  const AddressBookScreen({super.key});

  @override
  State<AddressBookScreen> createState() => _AddressBookScreenState();
}

class _AddressBookScreenState extends State<AddressBookScreen> {
  List<String> addresses = [
    '123 Main St, Davao City',
    '456 Flower Ave, Tagum',
  ];

  final addressController = TextEditingController();

  @override
  void dispose() {
    addressController.dispose();
    super.dispose();
  }

  void _addAddress() {
    if (addressController.text.isNotEmpty) {
      setState(() {
        addresses.add(addressController.text);
        addressController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Address Book'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w500),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE6E6FA), Colors.white], // Lavender to white
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              TextField(
                controller: addressController,
                decoration: InputDecoration(
                  labelText: 'Add new address',
                  labelStyle: const TextStyle(color: Color(0xFF212121)),
                  filled: true,
                  fillColor: Colors.white,
                  border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
                  enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFFB2EBF2)), borderRadius: BorderRadius.all(Radius.circular(16))),
                  focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF00BFAE)), borderRadius: BorderRadius.all(Radius.circular(16))),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.add, color: Color(0xFF00BFAE)),
                    onPressed: _addAddress,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: ListView.builder(
                  itemCount: addresses.length,
                  itemBuilder: (context, index) => Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 3,
                    color: Colors.white,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(addresses[index], style: const TextStyle(color: Color(0xFF212121), fontWeight: FontWeight.w500)),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Color(0xFFFF5252)),
                        onPressed: () {
                          setState(() {
                            addresses.removeAt(index);
                          });
                        },
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
  }
}
