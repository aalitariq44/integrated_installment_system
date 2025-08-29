import 'package:flutter/material.dart';

class AddEditCustomerPage extends StatelessWidget {
  final int? customerId;
  final bool isEdit;

  const AddEditCustomerPage({
    super.key,
    this.customerId,
    this.isEdit = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'تعديل العميل' : 'إضافة عميل جديد'),
      ),
      body: const Center(
        child: Text('صفحة إضافة/تعديل العميل'),
      ),
    );
  }
}
