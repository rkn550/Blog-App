import 'package:blog_app/core/errors/app_error_mapper.dart';
import 'package:blog_app/shared/data/blog_repository.dart';
import 'package:blog_app/shared/models/category_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class CategoryViewModel extends ChangeNotifier {
  CategoryViewModel({BlogRepository? repository})
    : _repository = repository ?? BlogRepository();

  final BlogRepository _repository;

  List<CategoryModel> categories = const [CategoryModel(id: '', name: 'All')];
  bool isLoading = false;
  String? errorMessage;

  bool _bootstrapDone = false;

  void ensureLoaded() {
    if (_bootstrapDone) return;
    _bootstrapDone = true;
    Future.microtask(loadCategories);
  }

  Future<void> loadCategories() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final list = await _repository.getCategories();
      categories = [const CategoryModel(id: '', name: 'All'), ...list];
    } on DioException catch (e) {
      errorMessage = AppErrorMapper.fromDio(
        e,
        operationFallback: 'Could not load categories.',
      );
      categories = const [CategoryModel(id: '', name: 'All')];
    } catch (e, st) {
      errorMessage = AppErrorMapper.fromUnknown(
        e,
        st,
        fallback: 'Could not load categories.',
      );
      categories = const [CategoryModel(id: '', name: 'All')];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
