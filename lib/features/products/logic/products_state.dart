part of 'products_cubit.dart';

@immutable
abstract class ProductsState {
  const ProductsState();
}

class ProductsInitial extends ProductsState {
  const ProductsInitial();
}

class ProductsLoading extends ProductsState {
  const ProductsLoading();
}

class ProductsLoaded extends ProductsState {
  final List<dynamic> products; // Replace with proper Product model

  const ProductsLoaded({required this.products});
}

class ProductsError extends ProductsState {
  final String message;

  const ProductsError({required this.message});
}
