import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/utils/currency_utils.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  bool _isLoading = true;
  Map<String, dynamic> _statistics = {};

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() => _isLoading = true);

    try {
      final dbHelper = context.read<DatabaseHelper>();

      // احصائيات عامة
      final customersCount = await dbHelper.count('customers');
      final productsCount = await dbHelper.count('products');
      final paymentsCount = await dbHelper.count('payments');

      // احصائيات الإيرادات
      final totalSalesResult = await dbHelper.rawQuery(
        'SELECT COALESCE(SUM(final_price), 0) as total FROM products',
      );
      final totalPaidResult = await dbHelper.rawQuery(
        'SELECT COALESCE(SUM(payment_amount), 0) as total FROM payments',
      );
      final totalProfitResult = await dbHelper.rawQuery(
        'SELECT COALESCE(SUM(final_price - original_price), 0) as total FROM products',
      );

      // منتجات مكتملة وغير مكتملة
      final completedProductsResult = await dbHelper.rawQuery(
        'SELECT COUNT(*) as count FROM products WHERE is_completed = 1',
      );
      final activeProductsResult = await dbHelper.rawQuery(
        'SELECT COUNT(*) as count FROM products WHERE is_completed = 0',
      );

      // دفعات هذا الشهر
      final thisMonthPaymentsResult = await dbHelper.rawQuery(
        '''SELECT COALESCE(SUM(payment_amount), 0) as total, COUNT(*) as count 
           FROM payments 
           WHERE strftime('%Y-%m', payment_date) = strftime('%Y-%m', 'now')''',
      );

      setState(() {
        _statistics = {
          'customersCount': customersCount,
          'productsCount': productsCount,
          'paymentsCount': paymentsCount,
          'totalSales': (totalSalesResult.first['total'] as num).toDouble(),
          'totalPaid': (totalPaidResult.first['total'] as num).toDouble(),
          'totalProfit': (totalProfitResult.first['total'] as num).toDouble(),
          'completedProducts': completedProductsResult.first['count'] as int,
          'activeProducts': activeProductsResult.first['count'] as int,
          'thisMonthPayments': (thisMonthPaymentsResult.first['total'] as num)
              .toDouble(),
          'thisMonthPaymentsCount':
              thisMonthPaymentsResult.first['count'] as int,
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في تحميل الإحصائيات: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإحصائيات'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStatistics,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStatistics,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // ملخص سريع
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.dashboard,
                                color: Colors.blue.shade600,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'الملخص العام',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  'العملاء',
                                  '${_statistics['customersCount']}',
                                  Icons.people,
                                  Colors.blue,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildStatCard(
                                  'المنتجات',
                                  '${_statistics['productsCount']}',
                                  Icons.shopping_bag,
                                  Colors.orange,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  'الدفعات',
                                  '${_statistics['paymentsCount']}',
                                  Icons.payment,
                                  Colors.green,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildStatCard(
                                  'مكتمل',
                                  '${_statistics['completedProducts']}',
                                  Icons.check_circle,
                                  Colors.teal,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // الإيرادات
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.monetization_on,
                                color: Colors.green.shade600,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'الإيرادات',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildRevenueRow(
                            'إجمالي المبيعات',
                            _statistics['totalSales'],
                            Colors.blue,
                          ),
                          const SizedBox(height: 12),
                          _buildRevenueRow(
                            'إجمالي المحصل',
                            _statistics['totalPaid'],
                            Colors.green,
                          ),
                          const SizedBox(height: 12),
                          _buildRevenueRow(
                            'إجمالي الأرباح',
                            _statistics['totalProfit'],
                            Colors.orange,
                          ),
                          const SizedBox(height: 12),
                          _buildRevenueRow(
                            'المبلغ المتبقي',
                            _statistics['totalSales'] -
                                _statistics['totalPaid'],
                            Colors.red,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // هذا الشهر
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                color: Colors.purple.shade600,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'هذا الشهر',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  'المحصل',
                                  CurrencyUtils.formatCurrency(
                                    _statistics['thisMonthPayments'],
                                  ),
                                  Icons.attach_money,
                                  Colors.green,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildStatCard(
                                  'عدد الدفعات',
                                  '${_statistics['thisMonthPaymentsCount']}',
                                  Icons.receipt,
                                  Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // حالة المنتجات
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.pie_chart,
                                color: Colors.indigo.shade600,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'حالة المنتجات',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildProgressCard(
                                  'نشط',
                                  _statistics['activeProducts'],
                                  _statistics['productsCount'],
                                  Colors.orange,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildProgressCard(
                                  'مكتمل',
                                  _statistics['completedProducts'],
                                  _statistics['productsCount'],
                                  Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 1,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'العملاء'),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'الإحصائيات',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushNamedAndRemoveUntil(context, AppRoutes.customers, (route) => false);
              break;
            case 1:
              // Already on statistics page
              break;
          }
        },
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueRow(String title, double amount, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 16)),
        Text(
          CurrencyUtils.formatCurrency(amount),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressCard(String title, int value, int total, Color color) {
    final percentage = total > 0 ? (value / total) : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            '$value',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
          const SizedBox(height: 4),
          Text(
            '${(percentage * 100).toInt()}%',
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
