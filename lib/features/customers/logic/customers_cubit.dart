import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import '../data/customers_repository.dart';

part 'customers_state.dart';

class CustomersCubit extends Cubit<CustomersState> {
  final CustomersRepository customersRepository;

  CustomersCubit({required this.customersRepository}) : super(const CustomersInitial());

  Future<void> loadCustomers() async {
    try {
      emit(const CustomersLoading());
      // Add your customers loading logic here
      final customers = <dynamic>[]; // Replace with actual repository call
      emit(CustomersLoaded(customers: customers));
    } catch (e) {
      emit(CustomersError(message: e.toString()));
    }
  }
}
