import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/database/models/product_model.dart';
import '../../../../core/database/models/payment_model.dart';
import '../../../../core/database/models/customer_model.dart';
import '../cubit/products_cubit.dart';
import '../../../payments/presentation/cubit/payments_cubit.dart';
import '../../../customers/presentation/cubit/customers_cubit.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../settings/data/settings_repository.dart';
import '../../../../core/utils/currency_utils.dart';

class ProductDetailsPage extends StatefulWidget {
  final int productId;

  const ProductDetailsPage({super.key, required this.productId});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  ProductModel? product;
  CustomerModel? customer;
  List<PaymentModel> payments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProductDetails();
    _loadProductPayments();
  }

  Future<void> _loadProductDetails() async {
    try {
      final productsCubit = context.read<ProductsCubit>();
      await productsCubit.getProduct(widget.productId);

      final state = productsCubit.state;
      if (state is ProductLoaded) {
        setState(() {
          product = state.product;
        });

        // Load customer details
        if (product != null) {
          final customersCubit = context.read<CustomersCubit>();
          await customersCubit.getCustomer(product!.customerId);

          final customerState = customersCubit.state;
          if (customerState is CustomerLoaded) {
            setState(() {
              customer = customerState.customer;
            });
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('خطأ في تحميل بيانات المنتج: $e')));
    }
  }

  Future<void> _loadProductPayments() async {
    try {
      final paymentsCubit = context.read<PaymentsCubit>();
      await paymentsCubit.getPaymentsByProduct(widget.productId);

      final state = paymentsCubit.state;
      if (state is PaymentsLoaded) {
        setState(() {
          payments = state.payments;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('خطأ في تحميل دفعات المنتج: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product?.productName ?? 'تفاصيل المنتج'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  Navigator.pushNamed(
                    context,
                    AppRoutes.addEditProduct,
                    arguments: {'productId': widget.productId, 'isEdit': true},
                  ).then((_) => _loadProductDetails());
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
                // تفاصيل المنتج
                if (product != null)
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
                        // اسم المنتج
                        Row(
                          children: [
                            const Icon(Icons.shopping_bag, color: Colors.blue),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                product!.productName,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (product!.isCompleted)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Text(
                                  'مكتمل',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),

                        // العميل
                        if (customer != null) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.person, color: Colors.grey),
                              const SizedBox(width: 8),
                              Text(
                                'العميل: ${customer!.customerName}',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ],

                        // تفاصيل المنتج
                        if (product!.details != null &&
                            product!.details!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.description, color: Colors.grey),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'التفاصيل: ${product!.details}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ],

                        const SizedBox(height: 16),

                        // معلومات السعر
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'السعر الأصلي',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  Text(
                                    CurrencyUtils.formatCurrency(
                                      product!.originalPrice,
                                    ),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'السعر النهائي',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  Text(
                                    CurrencyUtils.formatCurrency(
                                      product!.finalPrice,
                                    ),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // الربح
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'الربح',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  Text(
                                    CurrencyUtils.formatCurrency(
                                      product!.profit,
                                    ),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'فترة الدفع',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  Text(
                                    'كل ${product!.paymentIntervalDays} يوم',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // شريط التقدم
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'المدفوع: ${CurrencyUtils.formatCurrency(product!.totalPaid)}',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      Text(
                                        'المتبقي: ${CurrencyUtils.formatCurrency(product!.remainingBalance)}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: product!.remainingBalance == 0
                                              ? Colors.green
                                              : Colors.orange,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  LinearProgressIndicator(
                                    value: product!.finalPrice > 0
                                        ? (product!.totalPaid /
                                              product!.finalPrice)
                                        : 0.0,
                                    backgroundColor: Colors.grey[300],
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      product!.isCompleted
                                          ? Colors.green
                                          : Colors.blue,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${product!.paymentProgress.toInt()}% مكتمل',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        // ملاحظات
                        if (product!.notes != null &&
                            product!.notes!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.note, color: Colors.grey),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'ملاحظات: ${product!.notes}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                // عنوان الدفعات
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Icon(Icons.payment, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        'الدفعات',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // قائمة الدفعات
                Expanded(
                  child: payments.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.payment_outlined,
                                size: 64,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'لا توجد دفعات',
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
                          itemCount: payments.length,
                          itemBuilder: (context, index) {
                            final payment = payments[index];

                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.green,
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  CurrencyUtils.formatCurrency(
                                    payment.paymentAmount,
                                  ),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (payment.paymentDate != null)
                                      Text(
                                        'تاريخ الدفع: ${payment.paymentDate!.day}/${payment.paymentDate!.month}/${payment.paymentDate!.year}',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    if (payment.notes != null &&
                                        payment.notes!.isNotEmpty)
                                      Text(
                                        'ملاحظات: ${payment.notes}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      tooltip: 'إيصال',
                                      icon: const Icon(
                                        Icons.receipt_long,
                                        color: Colors.blue,
                                      ),
                                      onPressed: () {
                                        if (payment.receiptNumber == null) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'لا يوجد رقم إيصال لهذه الدفعة',
                                              ),
                                              backgroundColor: Colors.orange,
                                            ),
                                          );
                                          return;
                                        }

                                        Navigator.pushNamed(
                                          context,
                                          AppRoutes.paymentReceipt,
                                          arguments: {
                                            'receiptNumber':
                                                payment.receiptNumber,
                                            'paymentData': payment.toMap(),
                                            'productData': product?.toMap(),
                                            'customerData': customer?.toMap(),
                                          },
                                        );
                                      },
                                    ),
                                    IconButton(
                                      tooltip: 'حذف الدفعة',
                                      icon: const Icon(
                                        Icons.delete_forever,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        if (payment.paymentId == null) return;
                                        _confirmDeletePayment(
                                          payment.paymentId!,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: product != null && !product!.isCompleted
          ? FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.addPayment,
                  arguments: {
                    'productId': widget.productId,
                    'customerId': product!.customerId,
                  },
                ).then((_) => {_loadProductDetails(), _loadProductPayments()});
              },
              backgroundColor: Colors.blue,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  void _showDeleteDialog() {
    final _passwordController = TextEditingController();
    final _formKey = GlobalKey<FormState>();
    bool _obscurePassword = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('تأكيد الحذف'),
              content: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'هل أنت متأكد من حذف هذا المنتج؟\nسيتم حذف جميع الدفعات المرتبطة به.',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textDirection: TextDirection.ltr,
                      decoration: InputDecoration(
                        labelText: 'كلمة المرور',
                        hintText: 'أدخل كلمة مرور التطبيق',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'كلمة المرور مطلوبة';
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) => _verifyAndDelete(
                        _passwordController,
                        _formKey,
                        context,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('إلغاء'),
                ),
                TextButton(
                  onPressed: () =>
                      _verifyAndDelete(_passwordController, _formKey, context),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('حذف'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _verifyAndDelete(
    TextEditingController passwordController,
    GlobalKey<FormState> formKey,
    BuildContext dialogContext,
  ) async {
    if (!formKey.currentState!.validate()) return;

    try {
      final settingsRepository = context.read<SettingsRepository>();
      final isValid = await settingsRepository.validatePassword(
        passwordController.text.trim(),
      );

      if (isValid) {
        Navigator.of(dialogContext).pop(); // Close dialog
        await _deleteProduct();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('كلمة المرور غير صحيحة'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في التحقق من كلمة المرور: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteProduct() async {
    try {
      final productsCubit = context.read<ProductsCubit>();
      await productsCubit.deleteProduct(widget.productId);

      final state = productsCubit.state;
      if (state is ProductsLoaded) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حذف المنتج بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      } else if (state is ProductsError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في حذف المنتج: ${state.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في حذف المنتج: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _confirmDeletePayment(int paymentId) {
    final _passwordController = TextEditingController();
    final _formKey = GlobalKey<FormState>();
    bool _obscurePassword = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('تأكيد حذف الدفعة'),
              content: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'هل أنت متأكد من حذف هذه الدفعة؟ سيتم تحديث المبالغ تلقائياً.',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textDirection: TextDirection.ltr,
                      decoration: InputDecoration(
                        labelText: 'كلمة المرور',
                        hintText: 'أدخل كلمة مرور التطبيق',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'كلمة المرور مطلوبة';
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) => _verifyAndDeletePayment(
                        _passwordController,
                        _formKey,
                        context,
                        paymentId,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('إلغاء'),
                ),
                TextButton(
                  onPressed: () => _verifyAndDeletePayment(
                    _passwordController,
                    _formKey,
                    context,
                    paymentId,
                  ),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('حذف'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _verifyAndDeletePayment(
    TextEditingController passwordController,
    GlobalKey<FormState> formKey,
    BuildContext dialogContext,
    int paymentId,
  ) async {
    if (!formKey.currentState!.validate()) return;

    try {
      final settingsRepository = context.read<SettingsRepository>();
      final isValid = await settingsRepository.validatePassword(
        passwordController.text.trim(),
      );

      if (isValid) {
        Navigator.of(dialogContext).pop(); // Close dialog
        await _deletePayment(paymentId);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('كلمة المرور غير صحيحة'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في التحقق من كلمة المرور: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deletePayment(int paymentId) async {
    try {
      final paymentsCubit = context.read<PaymentsCubit>();
      await paymentsCubit.deletePayment(paymentId);

      // إعادة تحميل البيانات بعد الحذف
      await _loadProductDetails();
      await _loadProductPayments();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حذف الدفعة بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل حذف الدفعة: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
