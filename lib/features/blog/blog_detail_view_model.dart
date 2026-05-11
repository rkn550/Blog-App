import 'package:blog_app/core/errors/app_error_mapper.dart';
import 'package:blog_app/shared/data/blog_repository.dart';
import 'package:blog_app/shared/models/blog_models.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class BlogDetailViewModel extends ChangeNotifier {
  BlogDetailViewModel({
    required this.postId,
    BlogModel? initialPost,
    BlogRepository? repository,
  }) : _repository = repository ?? BlogRepository(),
       _blog = initialPost {
    if (_blog == null) {
      Future.microtask(_load);
    }
  }

  final String postId;
  final BlogRepository _repository;

  BlogModel? _blog;
  bool _loading = false;
  String? _error;

  BlogModel? get blog => _blog;
  bool get isLoading => _loading;
  String? get error => _error;

  Future<void> refresh() => _load();

  /// Returns `null` on success, or a user-facing error message.
  Future<String?> share() async {
    final b = _blog;
    if (b == null) return 'Nothing to share yet.';
    final link = b.postUrl;
    final text = link != null && link.isNotEmpty
        ? '${b.title}\n$link'
        : b.title;
    try {
      await SharePlus.instance.share(ShareParams(text: text));
      return null;
    } catch (e, st) {
      return AppErrorMapper.fromUnknown(
        e,
        st,
        fallback: 'Could not open the share sheet.',
      );
    }
  }

  Future<void> _load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _blog = await _repository.getBlog(postId);
    } on DioException catch (e) {
      _error = AppErrorMapper.fromDio(
        e,
        operationFallback: 'Could not load this post.',
      );
    } catch (e, st) {
      _error = AppErrorMapper.fromUnknown(
        e,
        st,
        fallback: 'Could not load this post.',
      );
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
