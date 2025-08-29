import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import '../data/customers_repository.dart';

part 'customers_state.dart';

class CustomersCubit extends Cubit<CustomersState> {
  final CustomersRepository customersRepository;

  CustomersCubit({required this.customersRepository}) : super(CustomersInitial());
}
