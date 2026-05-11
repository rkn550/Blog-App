import 'package:blog_app/core/utils/date_utils.dart';
import 'package:blog_app/features/blog/blog_detail_view_model.dart';
import 'package:blog_app/shared/widgets/blog_shimmer.dart';
import 'package:blog_app/features/bookmarks/bookmark_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';

class BlogDetailScreen extends StatelessWidget {
  const BlogDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final detail = context.watch<BlogDetailViewModel>();
    final bookmarks = context.watch<BookmarkViewModel>();

    if (detail.isLoading && detail.blog == null) {
      return Scaffold(appBar: AppBar(), body: const BlogDetailShimmer());
    }

    if (detail.error != null && detail.blog == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24.r),
            child: Text(
              detail.error!,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp),
            ),
          ),
        ),
      );
    }

    final blog = detail.blog;
    if (blog == null) {
      return const Scaffold(body: SizedBox.shrink());
    }

    final bookmarked = bookmarks.isBookmarked(blog.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          blog.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 18.sp),
        ),
        actions: [
          IconButton(
            tooltip: bookmarked ? 'Remove bookmark' : 'Bookmark',
            onPressed: () => bookmarks.toggleBookmark(blog),
            icon: Icon(
              bookmarked ? Icons.bookmark_rounded : Icons.bookmark_add_outlined,
              size: 24.r,
            ),
          ),
          IconButton(
            tooltip: 'Share',
            onPressed: () async {
              final err = await detail.share();
              if (!context.mounted) return;
              if (err != null) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(err)));
              }
            },
            icon: Icon(Icons.share_rounded, size: 24.r),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: detail.refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 32.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppDateUtils.formatDateTime(blog.published),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 13.sp,
                ),
              ),
              SizedBox(height: 12.h),
              Html(
                data: blog.content,
                style: {
                  'body': Style(
                    fontSize: FontSize(15.sp),
                    margin: Margins.zero,
                  ),
                },
              ),
              if (detail.isLoading) const BlogDetailInlineShimmer(),
            ],
          ),
        ),
      ),
    );
  }
}
