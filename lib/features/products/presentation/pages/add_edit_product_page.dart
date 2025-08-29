import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/database/models/product_model.dart';
import '../../../../core/database/models/customer_model.dart';
import '../cubit/products_cubit.dart';
import '../../../customers/presentation/cubit/customers_cubit.dart';

class AddEditProductPage extends StatefulWidget {
  final int? customerId;
  final int? productId;
  final bool isEdit;

  const AddEditProductPage({
    super.key,
    this.customerId,
    this.productId,
    this.isEdit = false,
  });

  @override
  State<AddEditProductPage> createState() => _AddEditProductPageState();
}

class _AddEditProductPageState extends State<AddEditProductPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();
  final TextEditingController _originalPriceController =
      TextEditingController();
  final TextEditingController _finalPriceController = TextEditingController();
  final TextEditingController _paymentIntervalController =
      TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  DateTime _saleDate = DateTime.now();
  bool _isLoading = false;
  ProductModel? _existingProduct;
  CustomerModel? _customer;
  int? _selectedCustomerId;

  @override
  void initState() {
    super.initState();
    _selectedCustomerId = widget.customerId;
    if (widget.isEdit && widget.productId != null) {
      _loadProductData();
    }
    if (widget.customerId != null) {
      _loadCustomerData();
    }
  }

  Future<void> _loadProductData() async {
    setState(() => _isLoading = true);

    try {
      final productsCubit = context.read<ProductsCubit>();
      await productsCubit.getProduct(widget.productId!);

      final state = productsCubit.state;
      if (state is ProductLoaded) {
        _existingProduct = state.product;
        _nameController.text = state.product.productName;
        _detailsController.text = state.product.details ?? '';
        _originalPriceController.text = state.product.originalPrice.toString();
        _finalPriceController.text = state.product.finalPrice.toString();
        _paymentIntervalController.text = state.product.paymentIntervalDays
            .toString();
        _notesController.text = state.product.notes ?? '';
        _saleDate = state.product.saleDate ?? DateTime.now();
        _selectedCustomerId = state.product.customerId;
        _loadCustomerData();
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('خطأ في تحميل بيانات المنتج: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadCustomerData() async {
    if (_selectedCustomerId != null) {
      try {
        final customersCubit = context.read<CustomersCubit>();
        await customersCubit.getCustomer(_selectedCustomerId!);

        final state = customersCubit.state;
        if (state is CustomerLoaded) {
          setState(() {
            _customer = state.customer;
          });
        }
      } catch (e) {
        // Handle error silently
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _detailsController.dispose();
    _originalPriceController.dispose();
    _finalPriceController.dispose();
    _paymentIntervalController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final originalPrice = double.parse(
          _originalPriceController.text.trim(),
        );
        final finalPrice = double.parse(_finalPriceController.text.trim());
        final paymentInterval = int.parse(
          _paymentIntervalController.text.trim(),
        );

        final product = ProductModel(
          productId: widget.isEdit ? widget.productId : null,
          customerId: _selectedCustomerId!,
          productName: _nameController.text.trim(),
          details: _detailsController.text.trim().isEmpty
              ? null
              : _detailsController.text.trim(),
          originalPrice: originalPrice,
          finalPrice: finalPrice,
          paymentIntervalDays: paymentInterval,
          saleDate: _saleDate,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
          totalPaid: widget.isEdit ? _existingProduct?.totalPaid ?? 0.0 : 0.0,
          remainingAmount: finalPrice,
          isCompleted: false,
          createdDate: widget.isEdit
              ? _existingProduct?.createdDate
              : DateTime.now(),
          updatedDate: DateTime.now(),
        );

        final productsCubit = context.read<ProductsCubit>();

        if (widget.isEdit) {
          await productsCubit.updateProduct(product);
        } else {
          await productsCubit.addProduct(product);
        }

        final state = productsCubit.state;
        if (state is ProductsLoaded || state is ProductLoaded) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.isEdit
                    ? 'تم تعديل المنتج بنجاح'
                    : 'تم إضافة المنتج بنجاح',
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else if (state is ProductsError) {
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
            content: Text('خطأ في حفظ المنتج: $e'),
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
      initialDate: _saleDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _saleDate) {
      setState(() {
        _saleDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? 'تعديل المنتج' : 'إضافة منتج جديد'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // معلومات العميل
                    if (_customer != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Row(
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
                      ),
                    const SizedBox(height: 16),

                    // اسم السلعة
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'اسم السلعة *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.shopping_bag),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'الرجاء إدخال اسم السلعة';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // تفاصيل السلعة
                    TextFormField(
                      controller: _detailsController,
                      decoration: const InputDecoration(
                        labelText: 'تفاصيل السلعة',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),

                    // السعر الأصلي
                    TextFormField(
                      controller: _originalPriceController,
                      decoration: const InputDecoration(
                        labelText: 'السعر الأصلي (بدون فوائد) *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.money),
                        suffixText: 'ريال',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'الرجاء إدخال السعر الأصلي';
                        }
                        if (double.tryParse(value.trim()) == null) {
                          return 'الرجاء إدخال رقم صحيح';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        // Auto-calculate final price if not manually entered
                        if (_finalPriceController.text.isEmpty) {
                          _finalPriceController.text = value;
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // السعر النهائي
                    TextFormField(
                      controller: _finalPriceController,
                      decoration: const InputDecoration(
                        labelText: 'السعر النهائي (بعد الفوائد) *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money),
                        suffixText: 'ريال',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'الرجاء إدخال السعر النهائي';
                        }
                        if (double.tryParse(value.trim()) == null) {
                          return 'الرجاء إدخال رقم صحيح';
                        }
                        final originalPrice =
                            double.tryParse(
                              _originalPriceController.text.trim(),
                            ) ??
                            0;
                        final finalPrice = double.tryParse(value.trim()) ?? 0;
                        if (finalPrice < originalPrice) {
                          return 'السعر النهائي يجب أن يكون أكبر من أو يساوي السعر الأصلي';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // فترة الدفع
                    TextFormField(
                      controller: _paymentIntervalController,
                      decoration: const InputDecoration(
                        labelText: 'عدد الأيام بين كل دفعة *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today),
                        suffixText: 'يوم',
                        helperText: 'مثلاً: 30 للشهر، 7 للأسبوع',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'الرجاء إدخال فترة الدفع';
                        }
                        if (int.tryParse(value.trim()) == null) {
                          return 'الرجاء إدخال رقم صحيح';
                        }
                        final days = int.tryParse(value.trim()) ?? 0;
                        if (days <= 0) {
                          return 'فترة الدفع يجب أن تكون أكبر من صفر';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // تاريخ البيع
                    InkWell(
                      onTap: _selectDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'تاريخ البيع',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.event),
                        ),
                        child: Text(
                          '${_saleDate.day}/${_saleDate.month}/${_saleDate.year}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ملاحظات
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'ملاحظات',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.note),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),

                    // زر الحفظ
                    ElevatedButton(
                      onPressed: _selectedCustomerId == null || _isLoading
                          ? null
                          : _saveProduct,
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
                          : Text(
                              widget.isEdit ? 'تعديل المنتج' : 'إضافة المنتج',
                              style: const TextStyle(fontSize: 18),
                            ),
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
