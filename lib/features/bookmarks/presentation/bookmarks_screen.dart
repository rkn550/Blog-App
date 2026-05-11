import 'package:blog_app/features/bookmarks/bookmark_view_model.dart';
import 'package:blog_app/router/app_router.dart';
import 'package:blog_app/shared/widgets/blog_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final marks = context.watch<BookmarkViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Bookmarks', style: TextStyle(fontSize: 20.sp)),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (marks.errorMessage != null)
            Material(
              color: Theme.of(context).colorScheme.errorContainer,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        marks.errorMessage!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                          fontSize: 13.sp,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Dismiss',
                      icon: Icon(Icons.close_rounded, size: 20.r),
                      onPressed: () =>
                          context.read<BookmarkViewModel>().dismissError(),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () =>
                  context.read<BookmarkViewModel>().loadBookmarks(),
              child: _BookmarksBody(marks: marks),
            ),
          ),
        ],
      ),
    );
  }
}

class _BookmarksBody extends StatelessWidget {
  const _BookmarksBody({required this.marks});

  final BookmarkViewModel marks;

  @override
  Widget build(BuildContext context) {
    if (marks.bookmarks.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: 100.h),
          Center(
            child: Text(
              'No bookmarks yet.\nOpen a post and tap the bookmark icon.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 15.sp,
              ),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(vertical: 8.h),
      itemCount: marks.bookmarks.length,
      itemBuilder: (context, index) {
        final blog = marks.bookmarks[index];
        return BlogCard(
          blog: blog,
          onTap: () =>
              context.push('${AppRoutePaths.post}/${blog.id}', extra: blog),
        );
      },
    );
  }
}
