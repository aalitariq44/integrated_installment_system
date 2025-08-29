import 'package:flutter/material.dart';
import '../../../customers/presentation/pages/customers_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // For simplicity, we'll directly show the customers page
    return const CustomersPage();
  }
}
