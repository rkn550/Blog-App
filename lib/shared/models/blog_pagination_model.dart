import 'package:blog_app/shared/models/blog_models.dart';

class BlogPaginationModel {
  BlogPaginationModel({
    required this.blogs,
    this.nextPageToken,
    this.nextPage,
    required this.hasMore,
  });

  final List<BlogModel> blogs;
  final String? nextPageToken;

  final int? nextPage;

  final bool hasMore;

  factory BlogPaginationModel.fromBloggerJson(Map<String, dynamic> json) {
    final items = json['items'];
    final list = items is List<dynamic>
        ? items
              .whereType<Map<String, dynamic>>()
              .map(BlogModel.fromJson)
              .toList()
        : <BlogModel>[];
    final token = json['nextPageToken']?.toString();
    final hasMore = token != null && token.isNotEmpty;
    return BlogPaginationModel(
      blogs: list,
      nextPageToken: token,
      nextPage: null,
      hasMore: hasMore,
    );
  }
}
