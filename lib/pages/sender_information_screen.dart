import 'package:flutter/material.dart';
import 'payment_method_screen.dart';

class SenderInformationScreen extends StatefulWidget {
  const SenderInformationScreen({super.key});

  @override
  State<SenderInformationScreen> createState() => _SenderInformationScreenState();
}

class _SenderInformationScreenState extends State<SenderInformationScreen> {
  final emailController = TextEditingController();
  final contactController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final messageController = TextEditingController();
  final instructionsController = TextEditingController();
  bool isAnonymous = false;
  int orderReceiver = 0; // 0: self, 1: someone else
  String address = '';

  @override
  void dispose() {
    emailController.dispose();
    contactController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    messageController.dispose();
    instructionsController.dispose();
    super.dispose();
  }

  void _setAddress() async {
    final controller = TextEditingController(text: address);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Shipping Address'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter shipping address'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      setState(() {
        address = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sender Information'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: ListTile(
                // Removed cart icon
                title: const Text('Show Order Summary'),
                trailing: const Text('₱245.00', style: TextStyle(fontWeight: FontWeight.bold)),
                onTap: () {
                  // TODO: Show order summary modal
                },
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: contactController,
              decoration: const InputDecoration(labelText: 'Contact Number'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: firstNameController,
              decoration: const InputDecoration(labelText: 'First Name'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: lastNameController,
              decoration: const InputDecoration(labelText: 'Last Name'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: messageController,
              decoration: const InputDecoration(labelText: 'Optional: Message for recipient'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: instructionsController,
              decoration: const InputDecoration(labelText: 'Special Instructions for the rider'),
            ),
            const SizedBox(height: 8),
            CheckboxListTile(
              value: isAnonymous,
              onChanged: (val) => setState(() => isAnonymous = val ?? false),
              title: const Text('Yes, I want to make the sender anonymous'),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: orderReceiver == 0 ? const Color(0xFF7C4DFF) : Colors.white,
                      foregroundColor: orderReceiver == 0 ? Colors.white : Colors.black87,
                      elevation: orderReceiver == 0 ? 2 : 0,
                      side: BorderSide(color: const Color(0xFF7C4DFF), width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () => setState(() => orderReceiver = 0),
                    child: const Text('I will receive the order.', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: orderReceiver == 1 ? const Color(0xFF7C4DFF) : Colors.white,
                      foregroundColor: orderReceiver == 1 ? Colors.white : Colors.black87,
                      elevation: orderReceiver == 1 ? 2 : 0,
                      side: BorderSide(color: const Color(0xFF7C4DFF), width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () => setState(() => orderReceiver = 1),
                    child: const Text('Someone else', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Recipient Information', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.deepPurple),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    address.isEmpty ? 'Shipping Address' : address,
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
                TextButton.icon(
                  onPressed: _setAddress,
                  icon: const Icon(Icons.add, color: Colors.black),
                  label: const Text('Set an address', style: TextStyle(color: Colors.black)),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF7C4DFF), // Modern visible purple
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () async {
                  // Error handling: validate required fields
                  if (emailController.text.isEmpty ||
                      contactController.text.isEmpty ||
                      firstNameController.text.isEmpty ||
                      lastNameController.text.isEmpty ||
                      address.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please fill in all required fields (Email, Contact, Name, Address).'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Proceed to Payment?'),
                      content: const Text('Are you sure you want to continue to payment method?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Continue'),
                        ),
                      ],
                    ),
                  );
                  if (!mounted) return;
                  if (confirmed == true) {
                    Navigator.push(
                      // ignore: use_build_context_synchronously
                      context,
                      MaterialPageRoute(builder: (context) => const PaymentMethodScreen()),
                    );
                  }
                },
                child: const Text('Checkout', style: TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Return to Cart'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
