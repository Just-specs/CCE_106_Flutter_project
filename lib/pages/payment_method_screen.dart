import 'package:flutter/material.dart';
import 'package:fresh_petals/models/order.dart';

class PaymentMethodScreen extends StatefulWidget {
  const PaymentMethodScreen({super.key});

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  final voucherController = TextEditingController();
  String appliedVoucher = '';
  int selectedPayment = 2; // 0: Card, 1: Gcash, 2: COD
  double orderTotal = 5.00;

    void _showOrderSummaryModal() {
      showDialog(
        context: context,
        builder: (context) => Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            constraints: const BoxConstraints(maxWidth: 400, minWidth: 220),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.shopping_cart, color: Color(0xFF7C4DFF)),
                    SizedBox(width: 10),
                    Text('Order Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  ],
                ),
                const SizedBox(height: 18),
                // Example order details, replace with real data as needed
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('Subtotal:', style: TextStyle(fontSize: 16)),
                    Text('₱245.00', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('Shipping:', style: TextStyle(fontSize: 16)),
                    Text('₱0.00', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                const Divider(height: 24, thickness: 1),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    Text('₱${orderTotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF7C4DFF))),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C4DFF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Close', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  void _applyVoucher() {
    setState(() {
      appliedVoucher = voucherController.text;
      voucherController.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Voucher applied: $appliedVoucher')),
    );
  }

  void _placeOrder() {
    // Add a new order to the shared list
    final newOrder = Order(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      item: 'Order placed at ${DateTime.now().toLocal()}',
      imageUrl: '', // TODO: Replace with actual product image URL if available
      status: 'Pending',
    );
    Order.addOrder(newOrder);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.7,
          constraints: const BoxConstraints(maxWidth: 350, minWidth: 220),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Color(0xFF7C4DFF), size: 48),
              const SizedBox(height: 18),
              const Text(
                'Order placed!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF212121)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'Thank you for your purchase.',
                style: TextStyle(fontSize: 15, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C4DFF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop(); // Return to previous screen (e.g., Profile)
                  },
                  child: const Text('Close', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    voucherController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Method'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              Card(
                color: const Color(0xFFF3EDF9),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
                child: ListTile(
                  leading: const Icon(Icons.shopping_cart, color: Color(0xFF7C4DFF)),
                  title: const Text('Show Order Summary', style: TextStyle(fontWeight: FontWeight.w500)),
                  trailing: Text('₱${orderTotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  onTap: _showOrderSummaryModal,
                ),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: voucherController,
                    decoration: const InputDecoration(labelText: 'Voucher Code'),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _applyVoucher,
                  child: const Text('Apply'),
                ),
              ],
            ),
            if (appliedVoucher.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text('Applied: $appliedVoucher', style: const TextStyle(color: Colors.green)),
              ),
            const SizedBox(height: 16),
            const Text('Payment', style: TextStyle(fontWeight: FontWeight.bold)),
            const Text('All transactions are secured and encrypted', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 8),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: Column(
                children: [
                  RadioListTile<int>(
                    value: 0,
                    groupValue: selectedPayment,
                    onChanged: (val) => setState(() => selectedPayment = val ?? 0),
                    title: const Text('Credit / Debit Card'),
                  ),
                  RadioListTile<int>(
                    value: 1,
                    groupValue: selectedPayment,
                    onChanged: (val) => setState(() => selectedPayment = val ?? 1),
                    title: const Text('Gcash'),
                  ),
                  RadioListTile<int>(
                    value: 2,
                    groupValue: selectedPayment,
                    onChanged: (val) => setState(() => selectedPayment = val ?? 2),
                    title: const Text('Cash on Delivery'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _placeOrder,
                child: const Text('Place Order', style: TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Return to Shipping'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
