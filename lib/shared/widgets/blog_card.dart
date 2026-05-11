import 'package:blog_app/core/utils/date_utils.dart';
import 'package:blog_app/shared/models/blog_models.dart';
import 'package:blog_app/shared/widgets/blog_shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BlogCard extends StatelessWidget {
  final BlogModel blog;
  final VoidCallback? onTap;
  const BlogCard({super.key, required this.blog, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (blog.image.isNotEmpty)
              CachedNetworkImage(
                imageUrl: blog.image,
                height: 200.h,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    const BlogImagePlaceholderShimmer(),
                errorWidget: (context, url, error) => Container(
                  height: 160.h,
                  color: theme.colorScheme.surfaceContainerHighest,
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.article_outlined,
                    size: 48.r,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            else
              Container(
                height: 140.h,
                width: double.infinity,
                color: theme.colorScheme.surfaceContainerHighest,
                alignment: Alignment.center,
                child: Icon(
                  Icons.article_outlined,
                  size: 48.r,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    blog.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 16.sp,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    AppDateUtils.formatDate(blog.published),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
