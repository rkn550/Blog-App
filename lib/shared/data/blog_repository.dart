import 'package:blog_app/core/api/api_client.dart';
import 'package:blog_app/core/constants/app_constant.dart';
import 'package:blog_app/core/errors/app_error_mapper.dart';
import 'package:blog_app/shared/models/blog_models.dart';
import 'package:blog_app/shared/models/blog_pagination_model.dart';
import 'package:blog_app/shared/models/category_model.dart';
import 'package:dio/dio.dart';

class BlogRepository {
  BlogRepository({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  bool get usesRestPagination => _client.isRestBackend;

  Map<String, dynamic> _bloggerQuery({String? pageToken, String? label}) {
    final q = <String, dynamic>{
      'key': AppConstants.apiKey,
      'maxResults': AppConstants.postsPageSize,
      'fetchBodies': true,
      'fetchImages': true,
    };
    if (pageToken != null && pageToken.isNotEmpty) {
      q['pageToken'] = pageToken;
    }
    if (label != null && label.isNotEmpty) {
      q['labels'] = label;
    }
    return q;
  }

  Future<BlogPaginationModel> getBlogs({
    String? pageToken,
    int? page,
    String? categoryId,
  }) async {
    if (_client.isRestBackend) {
      return _getBlogsRest(page: page ?? 1, categoryId: categoryId);
    }
    final response = await _client.dio.get<Map<String, dynamic>>(
      '/posts',
      queryParameters: _bloggerQuery(pageToken: pageToken, label: categoryId),
    );
    final data = response.data;
    if (response.statusCode != 200 || data == null) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message:
            AppErrorMapper.apiErrorFromBody(data) ?? 'Failed to load posts',
      );
    }
    return BlogPaginationModel.fromBloggerJson(data);
  }

  Future<BlogPaginationModel> _getBlogsRest({
    required int page,
    String? categoryId,
  }) async {
    final qp = <String, dynamic>{
      'page': page,
      'per_page': AppConstants.postsPageSize,
    };
    if (categoryId != null && categoryId.isNotEmpty) {
      qp['category_id'] = categoryId;
    }
    final response = await _client.dio.get<dynamic>(
      '/blogs',
      queryParameters: qp,
    );
    final data = response.data;
    if (response.statusCode != 200 || data == null) {
      final map = data is Map<String, dynamic> ? data : <String, dynamic>{};
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message:
            AppErrorMapper.apiErrorFromBody(map) ?? 'Failed to load posts',
      );
    }
    if (data is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Unexpected blogs response',
      );
    }
    return _parseRestBlogPage(data, page);
  }

  Future<BlogModel> getBlog(String id) async {
    if (_client.isRestBackend) {
      final response = await _client.dio.get<dynamic>('/blog/$id');
      final raw = response.data;
      if (response.statusCode != 200 || raw == null) {
        final map = raw is Map<String, dynamic> ? raw : <String, dynamic>{};
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message:
              AppErrorMapper.apiErrorFromBody(map) ?? 'Failed to load post',
        );
      }
      final Map<String, dynamic> map;
      if (raw is Map<String, dynamic>) {
        final inner = raw['data'];
        map = inner is Map<String, dynamic>
            ? Map<String, dynamic>.from(inner)
            : Map<String, dynamic>.from(raw);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Unexpected post response',
        );
      }
      return BlogModel.fromJson(map);
    }

    final response = await _client.dio.get<Map<String, dynamic>>(
      '/posts/$id',
      queryParameters: {'key': AppConstants.apiKey},
    );
    final data = response.data;
    if (response.statusCode != 200 || data == null) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: AppErrorMapper.apiErrorFromBody(data) ?? 'Failed to load post',
      );
    }
    return BlogModel.fromJson(data);
  }

  Future<List<CategoryModel>> getCategories() async {
    if (_client.isRestBackend) {
      final response = await _client.dio.get<dynamic>('/categories');
      final data = response.data;
      if (response.statusCode != 200 || data == null) {
        final map = data is Map<String, dynamic> ? data : <String, dynamic>{};
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message:
              AppErrorMapper.apiErrorFromBody(map) ??
              'Failed to load categories',
        );
      }
      return _parseRestCategories(data);
    }

    final response = await _client.dio.get<Map<String, dynamic>>(
      '/posts',
      queryParameters: {
        'key': AppConstants.apiKey,
        'maxResults': 100,
        'fetchBodies': false,
        'fetchImages': false,
      },
    );
    final data = response.data;
    if (response.statusCode != 200 || data == null) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message:
            AppErrorMapper.apiErrorFromBody(data) ??
            'Failed to load categories',
      );
    }
    final items = data['items'];
    final labels = <String>{};
    if (items is List) {
      for (final item in items) {
        if (item is Map<String, dynamic>) {
          final ls = item['labels'];
          if (ls is List) {
            for (final l in ls) {
              if (l is String && l.isNotEmpty) labels.add(l);
            }
          }
        }
      }
    }
    final sorted = labels.toList()..sort();
    return sorted
        .map((e) => CategoryModel(id: e, name: e))
        .toList(growable: false);
  }

  Future<BlogPaginationModel> searchBlogs(String query) async {
    if (_client.isRestBackend) {
      final response = await _client.dio.get<dynamic>(
        '/search',
        queryParameters: {'q': query},
      );
      final data = response.data;
      if (response.statusCode != 200 || data == null) {
        final map = data is Map<String, dynamic> ? data : <String, dynamic>{};
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: AppErrorMapper.apiErrorFromBody(map) ?? 'Search failed',
        );
      }
      if (data is Map<String, dynamic>) {
        final page = _parseRestBlogPage(data, 1);
        return BlogPaginationModel(
          blogs: page.blogs,
          hasMore: false,
        );
      }
      if (data is List) {
        final blogs = data
            .whereType<Map<String, dynamic>>()
            .map(BlogModel.fromJson)
            .toList();
        return BlogPaginationModel(
          blogs: blogs,
          nextPageToken: null,
          nextPage: null,
          hasMore: false,
        );
      }
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Unexpected search response',
      );
    }

    final response = await _client.dio.get<Map<String, dynamic>>(
      '/posts/search',
      queryParameters: {
        'key': AppConstants.apiKey,
        'q': query,
        'fetchBodies': true,
        'fetchImages': true,
      },
    );
    final data = response.data;
    if (response.statusCode != 200 || data == null) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: AppErrorMapper.apiErrorFromBody(data) ?? 'Search failed',
      );
    }
    return BlogPaginationModel.fromBloggerJson(data);
  }

  static List<Map<String, dynamic>> _extractItemMaps(dynamic root) {
    if (root is List) {
      return root.whereType<Map<String, dynamic>>().toList();
    }
    if (root is Map<String, dynamic>) {
      for (final key in ['data', 'items', 'blogs', 'results', 'posts']) {
        final v = root[key];
        if (v is List) {
          return v.whereType<Map<String, dynamic>>().toList();
        }
      }
    }
    return [];
  }

  static BlogPaginationModel _parseRestBlogPage(
    Map<String, dynamic> body,
    int requestedPage,
  ) {
    final list = _extractItemMaps(body);
    if (list.isEmpty && body['data'] is Map<String, dynamic>) {
      final inner = body['data'] as Map<String, dynamic>;
      final nested = _extractItemMaps(inner);
      if (nested.isNotEmpty) {
        return _parseRestBlogPageFromList(nested, body, requestedPage);
      }
    }
    return _parseRestBlogPageFromList(list, body, requestedPage);
  }

  static BlogPaginationModel _parseRestBlogPageFromList(
    List<Map<String, dynamic>> list,
    Map<String, dynamic> body,
    int requestedPage,
  ) {
    final blogs = list.map(BlogModel.fromJson).toList();
    final pagination = _restPaginationHints(body, requestedPage, blogs.length);
    return BlogPaginationModel(
      blogs: blogs,
      nextPageToken: null,
      nextPage: pagination.nextPage,
      hasMore: pagination.hasMore,
    );
  }

  static ({bool hasMore, int? nextPage}) _restPaginationHints(
    Map<String, dynamic> root,
    int requestedPage,
    int itemCount,
  ) {
    final meta = root['meta'];
    if (meta is Map) {
      final cur = int.tryParse(meta['current_page']?.toString() ?? '');
      final last = int.tryParse(meta['last_page']?.toString() ?? '');
      if (cur != null && last != null && cur > 0 && last > 0) {
        final more = cur < last;
        return (hasMore: more, nextPage: more ? cur + 1 : null);
      }
    }
    final cur2 = int.tryParse(root['current_page']?.toString() ?? '');
    final last2 =
        int.tryParse(root['last_page']?.toString() ?? '') ??
        int.tryParse(root['total_pages']?.toString() ?? '');
    if (cur2 != null && last2 != null && cur2 > 0 && last2 > 0) {
      final more = cur2 < last2;
      return (hasMore: more, nextPage: more ? cur2 + 1 : null);
    }
    final nextLink = root['next_page_url']?.toString();
    if (nextLink != null && nextLink.isNotEmpty) {
      return (hasMore: true, nextPage: requestedPage + 1);
    }
    if (itemCount >= AppConstants.postsPageSize) {
      return (hasMore: true, nextPage: requestedPage + 1);
    }
    return (hasMore: false, nextPage: null);
  }

  static List<CategoryModel> _parseRestCategories(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(CategoryModel.fromJson)
          .toList();
    }
    if (data is Map<String, dynamic>) {
      var maps = _extractItemMaps(data);
      if (maps.isEmpty) {
        final c = data['categories'];
        if (c is List) {
          maps = c.whereType<Map<String, dynamic>>().toList();
        }
      }
      return maps.map(CategoryModel.fromJson).toList();
    }
    return [];
  }
}
