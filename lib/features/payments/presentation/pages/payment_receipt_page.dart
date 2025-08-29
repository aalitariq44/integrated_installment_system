import 'package:flutter/material.dart';

class PaymentReceiptPage extends StatelessWidget {
  final int paymentId;

  const PaymentReceiptPage({super.key, required this.paymentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إيصال الدفع'),
      ),
      body: Center(
        child: Text('إيصال الدفعة رقم: $paymentId'),
      ),
    );
  }
}
