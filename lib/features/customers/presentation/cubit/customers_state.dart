part of 'customers_cubit.dart';

abstract class CustomersState extends Equatable {
  const CustomersState();

  @override
  List<Object?> get props => [];
}

class CustomersInitial extends CustomersState {
  const CustomersInitial();
}

class CustomersLoading extends CustomersState {
  const CustomersLoading();
}

class CustomersLoaded extends CustomersState {
  final List<CustomerModel> customers;

  const CustomersLoaded({required this.customers});

  @override
  List<Object?> get props => [customers];
}

class CustomerLoaded extends CustomersState {
  final CustomerModel customer;

  const CustomerLoaded({required this.customer});

  @override
  List<Object?> get props => [customer];
}

class CustomersStatisticsLoaded extends CustomersState {
  final Map<String, dynamic> statistics;

  const CustomersStatisticsLoaded({required this.statistics});

  @override
  List<Object?> get props => [statistics];
}

class CustomersWithProductsLoaded extends CustomersState {
  final List<Map<String, dynamic>> customers;

  const CustomersWithProductsLoaded({required this.customers});

  @override
  List<Object?> get props => [customers];
}

class CustomersWithOverdueLoaded extends CustomersState {
  final List<Map<String, dynamic>> customers;

  const CustomersWithOverdueLoaded({required this.customers});

  @override
  List<Object?> get props => [customers];
}

class CustomersExported extends CustomersState {
  final List<Map<String, dynamic>> data;

  const CustomersExported({required this.data});

  @override
  List<Object?> get props => [data];
}

class CustomersImported extends CustomersState {
  final int importedCount;
  final int skippedCount;
  final int errorCount;

  const CustomersImported({
    required this.importedCount,
    required this.skippedCount,
    required this.errorCount,
  });

  @override
  List<Object?> get props => [importedCount, skippedCount, errorCount];
}

class CustomerValidated extends CustomersState {
  final bool isValid;
  final List<String> errors;

  const CustomerValidated({
    required this.isValid,
    required this.errors,
  });

  @override
  List<Object?> get props => [isValid, errors];
}

class CustomersError extends CustomersState {
  final String message;

  const CustomersError({required this.message});

  @override
  List<Object?> get props => [message];
}
