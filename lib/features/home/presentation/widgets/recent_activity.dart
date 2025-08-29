import 'package:flutter/material.dart';

class RecentActivity extends StatelessWidget {
  final List<Map<String, dynamic>> activities;

  const RecentActivity({
    super.key,
    required this.activities,
  });

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(
            child: Text('لا توجد أنشطة حديثة'),
          ),
        ),
      );
    }

    return Card(
      child: Column(
        children: [
          ...activities.take(5).map((activity) {
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: _getActivityColor(activity['activity_type']),
                child: Icon(
                  _getActivityIcon(activity['activity_type']),
                  color: Colors.white,
                  size: 20,
                ),
              ),
              title: Text(
                _getActivityTitle(activity),
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: Text(
                _getActivitySubtitle(activity),
              ),
              trailing: Text(
                _formatDate(activity['activity_date']),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            );
          }),
          if (activities.length > 5)
            TextButton(
              onPressed: () {
                // Navigate to full activity list
              },
              child: const Text('عرض المزيد'),
            ),
        ],
      ),
    );
  }

  Color _getActivityColor(String? type) {
    switch (type) {
      case 'payment':
        return Colors.green;
      case 'product':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getActivityIcon(String? type) {
    switch (type) {
      case 'payment':
        return Icons.payment;
      case 'product':
        return Icons.inventory;
      default:
        return Icons.list;
    }
  }

  String _getActivityTitle(Map<String, dynamic> activity) {
    final type = activity['activity_type'];
    if (type == 'payment') {
      return 'دفعة جديدة';
    } else if (type == 'product') {
      return 'منتج جديد';
    }
    return 'نشاط جديد';
  }

  String _getActivitySubtitle(Map<String, dynamic> activity) {
    final customerName = activity['customer_name'] ?? '';
    final productName = activity['product_name'] ?? '';
    final amount = activity['amount']?.toString() ?? '0';
    
    if (activity['activity_type'] == 'payment') {
      return '$customerName - $amount ر.س';
    } else if (activity['activity_type'] == 'product') {
      return '$customerName - $productName';
    }
    return customerName;
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}
