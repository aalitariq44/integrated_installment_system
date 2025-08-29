import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import '../data/products_repository.dart';

part 'products_state.dart';

class ProductsCubit extends Cubit<ProductsState> {
  final ProductsRepository productsRepository;

  ProductsCubit({required this.productsRepository})
    : super(const ProductsInitial());

  Future<void> loadProducts() async {
    try {
      emit(const ProductsLoading());
      // Add your products loading logic here
      final products = <dynamic>[]; // Replace with actual repository call
      emit(ProductsLoaded(products: products));
    } catch (e) {
      emit(ProductsError(message: e.toString()));
    }
  }
}
