import 'package:flutter/material.dart';

class CustomerDetailsPage extends StatelessWidget {
  final int customerId;

  const CustomerDetailsPage({super.key, required this.customerId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تفاصيل العميل')),
      body: Center(child: Text('تفاصيل العميل رقم: $customerId')),
    );
  }
}
