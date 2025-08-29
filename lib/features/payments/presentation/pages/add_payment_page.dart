import 'package:flutter/material.dart';

class AddPaymentPage extends StatelessWidget {
  final int productId;

  const AddPaymentPage({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إضافة دفعة')),
      body: Center(child: Text('إضافة دفعة للمنتج رقم: $productId')),
    );
  }
}
