import 'package:blog_app/core/errors/app_error_mapper.dart';
import 'package:blog_app/shared/data/blog_repository.dart';
import 'package:blog_app/shared/models/blog_models.dart';
import 'package:blog_app/shared/models/blog_pagination_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class HomeFeedViewModel extends ChangeNotifier {
  HomeFeedViewModel({BlogRepository? repository})
    : _repository = repository ?? BlogRepository() {
    scrollController.addListener(_onScroll);
  }

  final BlogRepository _repository;

  final ScrollController scrollController = ScrollController();

  List<BlogModel> blogs = [];
  bool isLoading = false;
  bool hasMore = true;
  String? nextPageToken;
  int? restNextPageToLoad;
  String? selectedCategoryId;
  String? errorMessage;

  bool _feedBootstrapped = false;

  void ensureHomeFeedLoaded() {
    if (_feedBootstrapped) return;
    _feedBootstrapped = true;
    Future.microtask(() => fetchBlogs(refresh: true));
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;
    final pos = scrollController.position;
    const threshold = 220.0;
    if (pos.pixels >= pos.maxScrollExtent - threshold) {
      fetchBlogs();
    }
  }

  Future<void> fetchBlogs({bool refresh = false}) async {
    if (isLoading) return;
    if (!refresh && !hasMore) return;
    if (_repository.usesRestPagination &&
        !refresh &&
        restNextPageToLoad == null &&
        blogs.isNotEmpty) {
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    if (refresh) {
      blogs = [];
      nextPageToken = null;
      restNextPageToLoad = null;
      hasMore = true;
    }

    try {
      final label = (selectedCategoryId == null || selectedCategoryId!.isEmpty)
          ? null
          : selectedCategoryId;

      final BlogPaginationModel response;
      if (_repository.usesRestPagination) {
        final page = refresh ? 1 : (restNextPageToLoad ?? 1);
        response = await _repository.getBlogs(page: page, categoryId: label);
        restNextPageToLoad = response.nextPage;
        nextPageToken = null;
        hasMore = response.hasMore;
      } else {
        final token = refresh ? null : nextPageToken;
        response = await _repository.getBlogs(
          pageToken: token,
          categoryId: label,
        );
        nextPageToken = response.nextPageToken;
        restNextPageToLoad = null;
        hasMore = response.hasMore;
      }

      blogs = [...blogs, ...response.blogs];
    } on DioException catch (e) {
      errorMessage = AppErrorMapper.fromDio(
        e,
        operationFallback: 'Could not load blogs.',
      );
      hasMore = false;
    } catch (e, st) {
      errorMessage = AppErrorMapper.fromUnknown(
        e,
        st,
        fallback: 'Could not load blogs.',
      );
      hasMore = false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void selectCategory(String? categoryId) {
    selectedCategoryId = categoryId;
    fetchBlogs(refresh: true);
  }

  @override
  void dispose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.dispose();
  }
}
