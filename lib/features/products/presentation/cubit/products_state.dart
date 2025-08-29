part of 'products_cubit.dart';

abstract class ProductsState extends Equatable {
  const ProductsState();

  @override
  List<Object?> get props => [];
}

class ProductsInitial extends ProductsState {
  const ProductsInitial();
}

class ProductsLoading extends ProductsState {
  const ProductsLoading();
}

class ProductsLoaded extends ProductsState {
  final List<ProductModel> products;

  const ProductsLoaded({required this.products});

  @override
  List<Object?> get props => [products];
}

class ProductLoaded extends ProductsState {
  final ProductModel product;

  const ProductLoaded({required this.product});

  @override
  List<Object?> get props => [product];
}

class ProductsStatisticsLoaded extends ProductsState {
  final Map<String, dynamic> statistics;

  const ProductsStatisticsLoaded({required this.statistics});

  @override
  List<Object?> get props => [statistics];
}

class ProductsWithPaymentDetailsLoaded extends ProductsState {
  final List<Map<String, dynamic>> products;

  const ProductsWithPaymentDetailsLoaded({required this.products});

  @override
  List<Object?> get props => [products];
}

class OverdueProductsLoaded extends ProductsState {
  final List<Map<String, dynamic>> products;

  const OverdueProductsLoaded({required this.products});

  @override
  List<Object?> get props => [products];
}

class ProductsExported extends ProductsState {
  final List<Map<String, dynamic>> data;

  const ProductsExported({required this.data});

  @override
  List<Object?> get props => [data];
}

class ProductsImported extends ProductsState {
  final int importedCount;
  final int skippedCount;
  final int errorCount;

  const ProductsImported({
    required this.importedCount,
    required this.skippedCount,
    required this.errorCount,
  });

  @override
  List<Object?> get props => [importedCount, skippedCount, errorCount];
}

class ProductValidated extends ProductsState {
  final bool isValid;
  final List<String> errors;

  const ProductValidated({required this.isValid, required this.errors});

  @override
  List<Object?> get props => [isValid, errors];
}

class ProductsError extends ProductsState {
  final String message;

  const ProductsError({required this.message});

  @override
  List<Object?> get props => [message];
}
