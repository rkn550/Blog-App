import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

Color _highlightFor(BuildContext context) {
  final base = Theme.of(context).colorScheme.surfaceContainerHighest;
  return Color.lerp(base, Theme.of(context).colorScheme.onSurface, 0.12) ??
      base;
}

class BlogImagePlaceholderShimmer extends StatelessWidget {
  const BlogImagePlaceholderShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceContainerHighest;
    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: _highlightFor(context),
      child: Container(
        height: 200.h,
        width: double.infinity,
        color: Colors.white,
      ),
    );
  }
}

class BlogCardShimmer extends StatelessWidget {
  const BlogCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceContainerHighest;
    final w = MediaQuery.sizeOf(context).width;
    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: _highlightFor(context),
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200.h,
              width: double.infinity,
              color: Colors.white,
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 18.h,
                    width: w * 0.72,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Container(
                    height: 12.h,
                    width: 100.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4.r),
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

class BlogListFooterShimmer extends StatelessWidget {
  const BlogListFooterShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceContainerHighest;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      child: Shimmer.fromColors(
        baseColor: base,
        highlightColor: _highlightFor(context),
        child: Container(
          height: 48.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
      ),
    );
  }
}

class CategoryChipsShimmer extends StatelessWidget {
  const CategoryChipsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceContainerHighest;
    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: _highlightFor(context),
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        scrollDirection: Axis.horizontal,
        itemCount: 6,
        separatorBuilder: (context, _) => SizedBox(width: 8.w),
        itemBuilder: (context, _) => Container(
          width: 72.w,
          height: 32.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
      ),
    );
  }
}

class BlogDetailShimmer extends StatelessWidget {
  const BlogDetailShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceContainerHighest;
    final w = MediaQuery.sizeOf(context).width;
    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: _highlightFor(context),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 32.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 12.h,
              width: 140.w,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
            SizedBox(height: 16.h),
            ...List.generate(
              8,
              (i) => Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                child: Container(
                  height: 12.h,
                  width: i.isEven ? w * 0.92 : w * 0.65,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BlogDetailInlineShimmer extends StatelessWidget {
  const BlogDetailInlineShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceContainerHighest;
    return Padding(
      padding: EdgeInsets.only(top: 16.h),
      child: Shimmer.fromColors(
        baseColor: base,
        highlightColor: _highlightFor(context),
        child: Container(
          height: 56.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
      ),
    );
  }
}
