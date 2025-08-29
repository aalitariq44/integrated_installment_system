import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/database/models/payment_model.dart';
import '../../../../core/database/models/product_model.dart';
import '../../../../core/database/models/customer_model.dart';
import '../cubit/payments_cubit.dart';
import '../../../products/presentation/cubit/products_cubit.dart';
import '../../../customers/presentation/cubit/customers_cubit.dart';
import '../../../../app/routes/app_routes.dart';

class AddPaymentPage extends StatefulWidget {
  final int productId;
  final int customerId;

  const AddPaymentPage({
    super.key,
    required this.productId,
    required this.customerId,
  });

  @override
  State<AddPaymentPage> createState() => _AddPaymentPageState();
}

class _AddPaymentPageState extends State<AddPaymentPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  DateTime _paymentDate = DateTime.now();
  bool _isLoading = false;
  ProductModel? _product;
  CustomerModel? _customer;

  @override
  void initState() {
    super.initState();
    _loadProductAndCustomerData();
  }

  Future<void> _loadProductAndCustomerData() async {
    setState(() => _isLoading = true);

    try {
      // Load product data
      final productsCubit = context.read<ProductsCubit>();
      await productsCubit.getProduct(widget.productId);

      final productState = productsCubit.state;
      if (productState is ProductLoaded) {
        setState(() {
          _product = productState.product;
        });
      }

      // Load customer data
      final customersCubit = context.read<CustomersCubit>();
      await customersCubit.getCustomer(widget.customerId);

      final customerState = customersCubit.state;
      if (customerState is CustomerLoaded) {
        setState(() {
          _customer = customerState.customer;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('خطأ في تحميل البيانات: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _processPayment() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final paymentAmount = double.parse(_amountController.text.trim());

        // Generate receipt number
        final receiptNumber = 'REC${DateTime.now().millisecondsSinceEpoch}';

        // Calculate next due date based on payment interval
        DateTime? nextDueDate;
        if (_product != null) {
          nextDueDate = _paymentDate.add(
            Duration(days: _product!.paymentIntervalDays),
          );
        }

        final payment = PaymentModel(
          productId: widget.productId,
          customerId: widget.customerId,
          paymentAmount: paymentAmount,
          paymentDate: _paymentDate,
          nextDueDate: nextDueDate,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
          receiptNumber: receiptNumber,
          createdDate: DateTime.now(),
        );

        final paymentsCubit = context.read<PaymentsCubit>();
        await paymentsCubit.addPayment(payment);

        final state = paymentsCubit.state;
        if (state is PaymentProcessed) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.isCompleted
                    ? 'تم إضافة الدفعة بنجاح وتم إكمال المنتج!'
                    : 'تم إضافة الدفعة بنجاح',
              ),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate to receipt page
          Navigator.pushReplacementNamed(
            context,
            AppRoutes.paymentReceipt,
            arguments: {
              'receiptNumber': state.receiptNumber,
              'paymentData': payment.toMap(),
              'productData': _product?.toMap(),
              'customerData': _customer?.toMap(),
            },
          );
        } else if (state is PaymentsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('خطأ: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في معالجة الدفعة: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _paymentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _paymentDate) {
      setState(() {
        _paymentDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة دفعة'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading && (_product == null || _customer == null)
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // معلومات العميل والمنتج
                    if (_customer != null && _product != null)
                      Container(
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
                                const Icon(Icons.person, color: Colors.blue),
                                const SizedBox(width: 8),
                                Text(
                                  'العميل: ${_customer!.customerName}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.shopping_bag,
                                  color: Colors.blue,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'المنتج: ${_product!.productName}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'المدفوع',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      Text(
                                        '${_product!.totalPaid.toStringAsFixed(0)} ريال',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'المتبقي',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      Text(
                                        '${_product!.remainingBalance.toStringAsFixed(0)} ريال',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.orange,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 24),

                    // مبلغ الدفعة
                    TextFormField(
                      controller: _amountController,
                      decoration: const InputDecoration(
                        labelText: 'مبلغ الدفعة *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money),
                        suffixText: 'ريال',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'الرجاء إدخال مبلغ الدفعة';
                        }
                        final amount = double.tryParse(value.trim());
                        if (amount == null) {
                          return 'الرجاء إدخال رقم صحيح';
                        }
                        if (amount <= 0) {
                          return 'مبلغ الدفعة يجب أن يكون أكبر من صفر';
                        }
                        if (_product != null &&
                            amount > _product!.remainingBalance) {
                          return 'مبلغ الدفعة أكبر من المبلغ المتبقي';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // تاريخ الدفعة
                    InkWell(
                      onTap: _selectDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'تاريخ الدفعة',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.event),
                        ),
                        child: Text(
                          '${_paymentDate.day}/${_paymentDate.month}/${_paymentDate.year}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ملاحظات
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'ملاحظات الدفعة',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.note),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),

                    // أزرار العمل
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isLoading
                                ? null
                                : () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'إلغاء',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _processPayment,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    'إضافة الدفعة',
                                    style: TextStyle(fontSize: 16),
                                  ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ملاحظة
                    const Text(
                      '* الحقول المطلوبة',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
