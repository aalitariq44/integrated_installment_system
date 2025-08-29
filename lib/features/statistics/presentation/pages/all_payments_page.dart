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

  String _sortBy = 'payment_date'; // Default sort by date
  bool _sortAscending = false; // Default sort descending (newest to oldest)

  int _totalPaymentsCount = 0;
  double _totalPaymentsAmount = 0.0;

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
        ORDER BY $_sortBy ${_sortAscending ? 'ASC' : 'DESC'}
      ''');

      setState(() {
        _allPayments = payments;
        _filterPayments(); // Call filter to initialize filtered list and totals
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
    List<Map<String, dynamic>> tempFilteredPayments = _allPayments.where((payment) {
      final customerName = (payment['customer_name'] as String).toLowerCase();
      final productName = (payment['product_name'] as String).toLowerCase();
      final receiptNumber = (payment['receipt_number'] as String? ?? '').toLowerCase();
      return customerName.contains(query) ||
          productName.contains(query) ||
          receiptNumber.contains(query);
    }).toList();

    double currentTotalAmount = 0.0;
    for (var payment in tempFilteredPayments) {
      currentTotalAmount += (payment['payment_amount'] as num).toDouble();
    }

    setState(() {
      _filteredPayments = tempFilteredPayments;
      _totalPaymentsCount = _filteredPayments.length;
      _totalPaymentsAmount = currentTotalAmount;
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
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (String result) {
              setState(() {
                if (result == 'toggle_order') {
                  _sortAscending = !_sortAscending;
                } else {
                  _sortBy = result;
                }
                _loadAllPayments(); // Reload with new sorting
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'payment_date',
                child: Text('الفرز حسب التاريخ ${_sortBy == 'payment_date' ? (_sortAscending ? '(تصاعدي)' : '(تنازلي)') : ''}'),
              ),
              PopupMenuItem<String>(
                value: 'payment_amount',
                child: Text('الفرز حسب المبلغ ${_sortBy == 'payment_amount' ? (_sortAscending ? '(تصاعدي)' : '(تنازلي)') : ''}'),
              ),
              const PopupMenuDivider(),
              PopupMenuItem<String>(
                value: 'toggle_order',
                child: Text(_sortAscending ? 'فرز تنازلي' : 'فرز تصاعدي'),
              ),
            ],
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
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Card(
                  color: Colors.blue.shade50,
                  elevation: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        Text(
                          'مجموع الدفعات',
                          style: TextStyle(
                              fontSize: 14, color: Colors.blue.shade800),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$_totalPaymentsCount',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Card(
                  color: Colors.green.shade50,
                  elevation: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        Text(
                          'مجموع المبلغ',
                          style: TextStyle(
                              fontSize: 14, color: Colors.green.shade800),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          CurrencyUtils.formatCurrency(_totalPaymentsAmount),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
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
