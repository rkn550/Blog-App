class BlogModel {
  final String id;
  final String title;
  final String content;
  final String image;
  final DateTime published;
  final List<String> labels;
  final String? postUrl;

  BlogModel({
    required this.id,
    required this.title,
    required this.content,
    required this.image,
    required this.published,
    required this.labels,
    this.postUrl,
  });

  static List<String> _coerceStringList(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .map((e) {
          if (e is String) return e;
          if (e is Map && e['name'] != null) return e['name'].toString();
          return e?.toString() ?? '';
        })
        .where((s) => s.isNotEmpty)
        .toList();
  }

  static String _parseContent(dynamic raw) {
    if (raw == null) return '';
    if (raw is String) return raw;
    if (raw is Map && raw['value'] is String) return raw['value'] as String;
    return '';
  }

  static String _parseTitle(dynamic raw) {
    if (raw == null) return '';
    if (raw is String) return raw;
    if (raw is Map && raw['value'] is String) return raw['value'] as String;
    return raw.toString();
  }

  static String _firstImageUrl(Map<String, dynamic> json) {
    final images = json['images'];
    if (images is List && images.isNotEmpty) {
      final first = images.first;
      if (first is Map && first['url'] is String) {
        return first['url'] as String;
      }
    }
    return '';
  }

  factory BlogModel.fromJson(Map<String, dynamic> json) {
    final legacyImage = json['image'] ?? json['thumbnail'] ?? json['cover_image'];
    final String imageUrl = legacyImage is String && legacyImage.isNotEmpty
        ? legacyImage
        : _firstImageUrl(json);
    final rawPublished =
        json['published'] ??
        json['published_at'] ??
        json['created_at'] ??
        DateTime.now().toIso8601String();
    final contentRaw =
        json['content'] ?? json['html'] ?? json['body'] ?? json['description'];
    return BlogModel(
      id: json['id']?.toString() ?? '',
      title: _parseTitle(json['title']),
      content: _parseContent(contentRaw),
      image: imageUrl,
      published: DateTime.tryParse(rawPublished.toString()) ?? DateTime.now(),
      labels: _coerceStringList(
        json['labels'] ?? json['tags'] ?? json['categories'],
      ),
      postUrl: json['url']?.toString() ?? json['link']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'image': image,
      'published': published.toIso8601String(),
      'labels': labels,
      'url': postUrl,
    };
  }
}
