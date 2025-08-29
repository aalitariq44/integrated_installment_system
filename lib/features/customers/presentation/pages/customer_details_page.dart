import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/database/models/customer_model.dart';
import '../../../../core/database/models/product_model.dart';
import '../cubit/customers_cubit.dart';
import '../../../products/presentation/cubit/products_cubit.dart';
import '../../../../app/routes/app_routes.dart';

class CustomerDetailsPage extends StatefulWidget {
  final int customerId;

  const CustomerDetailsPage({super.key, required this.customerId});

  @override
  State<CustomerDetailsPage> createState() => _CustomerDetailsPageState();
}

class _CustomerDetailsPageState extends State<CustomerDetailsPage> {
  CustomerModel? customer;
  List<ProductModel> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCustomerDetails();
    _loadCustomerProducts();
  }

  Future<void> _loadCustomerDetails() async {
    try {
      final customersCubit = context.read<CustomersCubit>();
      await customersCubit.getCustomer(widget.customerId);

      final state = customersCubit.state;
      if (state is CustomerLoaded) {
        setState(() {
          customer = state.customer;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('خطأ في تحميل بيانات العميل: $e')));
    }
  }

  Future<void> _loadCustomerProducts() async {
    try {
      final productsCubit = context.read<ProductsCubit>();
      await productsCubit.getProductsByCustomer(widget.customerId);

      final state = productsCubit.state;
      if (state is ProductsLoaded) {
        setState(() {
          products = state.products;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('خطأ في تحميل منتجات العميل: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(customer?.customerName ?? 'تفاصيل العميل'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  Navigator.pushNamed(
                    context,
                    AppRoutes.addEditCustomer,
                    arguments: {
                      'customerId': widget.customerId,
                      'isEdit': true,
                    },
                  ).then((_) => _loadCustomerDetails());
                  break;
                case 'delete':
                  _showDeleteDialog();
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('تعديل'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('حذف'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // معلومات العميل
                if (customer != null)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.blue,
                              radius: 30,
                              child: Text(
                                customer!.customerName.isNotEmpty
                                    ? customer!.customerName[0].toUpperCase()
                                    : '؟',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    customer!.customerName,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (customer!.phoneNumber != null)
                                    Text(
                                      'الهاتف: ${customer!.phoneNumber}',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (customer!.address != null) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.location_on, color: Colors.grey),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'العنوان: ${customer!.address}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (customer!.notes != null &&
                            customer!.notes!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.note, color: Colors.grey),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'ملاحظات: ${customer!.notes}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                // عنوان السلع
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Icon(Icons.shopping_bag, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        'السلع المشتراة',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // قائمة السلع
                Expanded(
                  child: products.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.shopping_bag_outlined,
                                size: 64,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'لا توجد سلع مشتراة',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            final product = products[index];
                            final progress = product.finalPrice > 0
                                ? (product.totalPaid / product.finalPrice)
                                : 0.0;

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                title: Text(
                                  product.productName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 8),
                                    Text(
                                      'السعر النهائي: ${product.finalPrice.toStringAsFixed(0)} د.ع',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    Text(
                                      'المدفوع: ${product.totalPaid.toStringAsFixed(0)} د.ع',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    Text(
                                      'المتبقي: ${product.remainingBalance.toStringAsFixed(0)} د.ع',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: product.remainingBalance == 0
                                            ? Colors.green
                                            : Colors.orange,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    LinearProgressIndicator(
                                      value: progress,
                                      backgroundColor: Colors.grey[300],
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        progress == 1.0
                                            ? Colors.green
                                            : Colors.blue,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${(progress * 100).toInt()}% مكتمل',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                                trailing: product.isCompleted
                                    ? Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: const Text(
                                          'مكتمل',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      )
                                    : null,
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.productDetails,
                                    arguments: product.productId,
                                  );
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            AppRoutes.addEditProduct,
            arguments: {'customerId': widget.customerId},
          ).then((_) => _loadCustomerProducts());
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('تأكيد الحذف'),
          content: const Text(
            'هل أنت متأكد من حذف هذا العميل؟\nسيتم حذف جميع السلع والدفعات المرتبطة به.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteCustomer();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('حذف'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteCustomer() async {
    try {
      final customersCubit = context.read<CustomersCubit>();
      await customersCubit.deleteCustomer(widget.customerId);

      final state = customersCubit.state;
      if (state is CustomersLoaded) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حذف العميل بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      } else if (state is CustomersError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في حذف العميل: ${state.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في حذف العميل: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
