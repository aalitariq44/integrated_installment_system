import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:integrated_installment_system/app/routes/app_routes.dart';
import '../../../../core/database/models/customer_model.dart';
import '../cubit/customers_cubit.dart';
import '../../../settings/presentation/cubit/settings_cubit.dart';

class CustomersPage extends StatefulWidget {
  const CustomersPage({super.key});

  @override
  State<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  String _searchQuery = '';
  late CustomersCubit _customersCubit;
  int _totalCustomersCount = 0;
  bool _isBackupLoading = false;

  @override
  void initState() {
    super.initState();
    _customersCubit = context.read<CustomersCubit>();
    _loadData();
  }

  Future<void> _loadData() async {
    await _customersCubit.loadCustomers();
    await _loadCustomersCount();
  }

  Future<void> _loadCustomersCount() async {
    try {
      final count = await _customersCubit.getCustomersCountAsync();
      setState(() {
        _totalCustomersCount = count;
      });
    } catch (e) {
      // Handle error silently or show snackbar if needed
    }
  }

  Future<void> _createBackup() async {
    if (_isBackupLoading) return; // Prevent multiple taps

    setState(() => _isBackupLoading = true);

    try {
      final settingsCubit = context.read<SettingsCubit>();
      await settingsCubit.createBackup();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم رفع النسخة الاحتياطية بنجاح'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في رفع النسخة الاحتياطية: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isBackupLoading = false);
      }
    }
  }

  List<CustomerModel> _filteredCustomers(List<CustomerModel> customers) {
    if (_searchQuery.isEmpty) return customers;
    return customers.where((customer) {
      return customer.customerName.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          (customer.phoneNumber?.contains(_searchQuery) ?? false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('العملاء'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          _isBackupLoading
              ? const SizedBox(
                  width: 48,
                  height: 48,
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.backup),
                  onPressed: _createBackup,
                ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'البحث عن عميل...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Total Customers Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.people, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'إجمالي العملاء: $_totalCustomersCount',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),

          // Customers List
          Expanded(
            child: BlocConsumer<CustomersCubit, CustomersState>(
              listener: (context, state) {
                if (state is CustomersLoaded) {
                  // Update count when customers are loaded
                  setState(() {
                    _totalCustomersCount = state.customers.length;
                  });
                }
              },
              builder: (context, state) {
                if (state is CustomersLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is CustomersError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'خطأ: ${state.message}',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.red,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => _customersCubit.loadCustomers(),
                          child: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  );
                } else if (state is CustomersLoaded) {
                  final filteredCustomers = _filteredCustomers(state.customers);

                  if (filteredCustomers.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'لا توجد عملاء',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredCustomers.length,
                    itemBuilder: (context, index) {
                      final customer = filteredCustomers[index];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue,
                            child: Text(
                              customer.customerName.isNotEmpty
                                  ? customer.customerName[0].toUpperCase()
                                  : '؟',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            customer.customerName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('رقم الزبون: ${customer.customerId}'),
                              const SizedBox(height: 4),
                              Text(
                                'الهاتف: ${customer.phoneNumber ?? 'لايوجد'}',
                              ),
                            ],
                          ),
                          onTap: () async {
                            await Navigator.pushNamed(
                              context,
                              AppRoutes.customerDetails,
                              arguments: customer.customerId,
                            );
                            _customersCubit.loadCustomers();
                          },
                        ),
                      );
                    },
                  );
                }
                return const Center(child: Text('لا توجد بيانات'));
              },
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.addEditCustomer);
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
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
              // Already on customers page
              break;
            case 1:
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.statistics,
                (route) => false,
              );
              break;
          }
        },
      ),
    );
  }
}
