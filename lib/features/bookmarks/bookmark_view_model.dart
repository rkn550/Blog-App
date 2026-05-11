import 'dart:convert';

import 'package:blog_app/core/errors/app_error_mapper.dart';
import 'package:blog_app/shared/models/blog_models.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookmarkViewModel extends ChangeNotifier {
  static const _prefsKey = 'bookmarks';

  List<BlogModel> bookmarks = [];
  String? errorMessage;

  bool _bootstrapDone = false;

  void dismissError() {
    if (errorMessage == null) return;
    errorMessage = null;
    notifyListeners();
  }

  void ensureLoaded() {
    if (_bootstrapDone) return;
    _bootstrapDone = true;
    Future.microtask(loadBookmarks);
  }

  Future<void> loadBookmarks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getStringList(_prefsKey) ?? [];
      final list = <BlogModel>[];
      for (final raw in data) {
        try {
          final decoded = jsonDecode(raw);
          if (decoded is Map<String, dynamic>) {
            list.add(BlogModel.fromJson(decoded));
          }
        } catch (e, st) {
          assert(() {
            debugPrint('Skipping corrupt bookmark entry: $e\n$st');
            return true;
          }());
        }
      }
      bookmarks = list;
      errorMessage = null;
    } catch (e, st) {
      errorMessage = AppErrorMapper.fromUnknown(
        e,
        st,
        fallback: 'Could not load saved bookmarks.',
      );
      bookmarks = [];
    }
    notifyListeners();
  }

  bool isBookmarked(String id) => bookmarks.any((e) => e.id == id);

  Future<void> toggleBookmark(BlogModel blog) async {
    final previous = List<BlogModel>.from(bookmarks);
    final exists = bookmarks.any((e) => e.id == blog.id);
    if (exists) {
      bookmarks = bookmarks.where((e) => e.id != blog.id).toList();
    } else {
      bookmarks = [...bookmarks, blog];
    }
    errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = bookmarks.map((e) => jsonEncode(e.toJson())).toList();
      await prefs.setStringList(_prefsKey, encoded);
    } catch (e, st) {
      bookmarks = previous;
      errorMessage = AppErrorMapper.fromUnknown(
        e,
        st,
        fallback: 'Could not save bookmarks.',
      );
      notifyListeners();
    }
  }
}
