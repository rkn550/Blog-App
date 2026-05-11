import 'dart:async';

import 'package:blog_app/core/errors/app_error_mapper.dart';
import 'package:blog_app/shared/data/blog_repository.dart';
import 'package:blog_app/shared/models/blog_models.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class SearchViewModel extends ChangeNotifier {
  SearchViewModel({BlogRepository? repository})
    : _repository = repository ?? BlogRepository() {
    queryController.addListener(notifyListeners);
  }

  final BlogRepository _repository;

  final TextEditingController queryController = TextEditingController();

  Timer? debounce;
  bool isLoading = false;
  List<BlogModel> blogs = [];
  String? errorMessage;

  @override
  void dispose() {
    queryController.removeListener(notifyListeners);
    queryController.dispose();
    debounce?.cancel();
    super.dispose();
  }

  void onSearchChanged(String query) {
    debounce?.cancel();
    debounce = Timer(const Duration(milliseconds: 450), () {
      searchBlogs(query);
    });
  }

  void clearQuery() {
    queryController.clear();
    searchBlogs('');
  }

  Future<void> refresh() async {
    final q = queryController.text.trim();
    if (q.isEmpty) return;
    debounce?.cancel();
    await searchBlogs(q);
  }

  Future<void> searchBlogs(String query) async {
    final q = query.trim();
    if (q.isEmpty) {
      blogs = [];
      errorMessage = null;
      notifyListeners();
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.searchBlogs(q);
      blogs = result.blogs;
    } on DioException catch (e) {
      errorMessage = AppErrorMapper.fromDio(
        e,
        operationFallback: 'Search failed.',
      );
      blogs = [];
    } catch (e, st) {
      errorMessage = AppErrorMapper.fromUnknown(
        e,
        st,
        fallback: 'Search failed.',
      );
      blogs = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
