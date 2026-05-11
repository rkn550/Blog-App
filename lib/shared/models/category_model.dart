class CategoryModel {
  final String id;
  final String name;

  const CategoryModel({required this.id, required this.name});

  bool get isAll => id.isEmpty;

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id']?.toString() ?? '',
      name:
          (json['name'] ?? json['title'] ?? json['label'])?.toString() ?? '',
    );
  }
}
