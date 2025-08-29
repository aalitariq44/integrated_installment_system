import 'package:flutter/material.dart';

class AddEditProductPage extends StatelessWidget {
  final int? customerId;
  final int? productId;
  final bool isEdit;

  const AddEditProductPage({
    super.key,
    this.customerId,
    this.productId,
    this.isEdit = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'تعديل المنتج' : 'إضافة منتج جديد'),
      ),
      body: const Center(
        child: Text('صفحة إضافة/تعديل المنتج'),
      ),
    );
  }
}
