import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/date_utils.dart' as AppDateUtils;

class AllPaymentsPage extends StatefulWidget {
  const AllPaymentsPage({super.key});

  @override
  State<AllPaymentsPage> createState() => _AllPaymentsPageState();
}

class _AllPaymentsPageState extends State<AllPaymentsPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _allPayments = [];
  List<Map<String, dynamic>> _filteredPayments = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAllPayments();
    _searchController.addListener(_filterPayments);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterPayments);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAllPayments() async {
    setState(() => _isLoading = true);
    try {
      final dbHelper = context.read<DatabaseHelper>();
      final payments = await dbHelper.rawQuery('''
        SELECT
          p.payment_id,
          p.payment_amount,
          p.payment_date,
          p.receipt_number,
          c.customer_name,
          prod.product_name
        FROM payments p
        JOIN customers c ON p.customer_id = c.customer_id
        JOIN products prod ON p.product_id = prod.product_id
        ORDER BY p.payment_date DESC
      ''');

      setState(() {
        _allPayments = payments;
        _filteredPayments = payments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في تحميل الدفعات: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _filterPayments() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredPayments = _allPayments.where((payment) {
        final customerName = (payment['customer_name'] as String).toLowerCase();
        final productName = (payment['product_name'] as String).toLowerCase();
        final receiptNumber = (payment['receipt_number'] as String? ?? '')
            .toLowerCase();
        return customerName.contains(query) ||
            productName.contains(query) ||
            receiptNumber.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('كل الدفعات'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAllPayments,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'البحث عن دفعة (اسم الزبون، السلعة، رمز الإيصال)',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredPayments.isEmpty
                ? const Center(child: Text('لا توجد دفعات لعرضها.'))
                : ListView.builder(
                    itemCount: _filteredPayments.length,
                    itemBuilder: (context, index) {
                      final payment = _filteredPayments[index];
                      return PaymentCard(
                        payment: payment,
                        sequenceNumber: index + 1,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class PaymentCard extends StatelessWidget {
  final Map<String, dynamic> payment;
  final int sequenceNumber;

  const PaymentCard({
    super.key,
    required this.payment,
    required this.sequenceNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$sequenceNumber - الزبون: ${payment['customer_name']}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  CurrencyUtils.formatCurrency(payment['payment_amount']),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'السلعة: ${payment['product_name']}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              'تاريخ الدفع: ${AppDateUtils.AppDateUtils.formatDate(DateTime.parse(payment['payment_date']))}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'رقم الإيصال: ${payment['payment_id']}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Text(
                  'رمز الإيصال: ${payment['receipt_number'] ?? 'N/A'}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
