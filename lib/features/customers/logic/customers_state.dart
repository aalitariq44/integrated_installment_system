part of 'customers_cubit.dart';

@immutable
abstract class CustomersState {
  const CustomersState();
}

class CustomersInitial extends CustomersState {
  const CustomersInitial();
}

class CustomersLoading extends CustomersState {
  const CustomersLoading();
}

class CustomersLoaded extends CustomersState {
  final List<dynamic> customers; // Replace with proper Customer model

  const CustomersLoaded({required this.customers});
}

class CustomersError extends CustomersState {
  final String message;

  const CustomersError({required this.message});
}
