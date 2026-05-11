import 'package:blog_app/features/home/category_view_model.dart';
import 'package:blog_app/features/home/home_feed_view_model.dart';
import 'package:blog_app/router/app_router.dart';
import 'package:blog_app/shared/widgets/blog_card.dart';
import 'package:blog_app/shared/widgets/blog_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final homeVm = context.watch<HomeFeedViewModel>();
    final categories = context.watch<CategoryViewModel>();

    homeVm.ensureHomeFeedLoaded();

    return Scaffold(
      appBar: AppBar(
        title: Text('Blogs', style: TextStyle(fontSize: 20.sp)),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 52.h,
            child: categories.isLoading && categories.categories.length <= 1
                ? const CategoryChipsShimmer()
                : ListView.separated(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 8.h,
                    ),
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.categories.length,
                    separatorBuilder: (context, index) => SizedBox(width: 8.w),
                    itemBuilder: (context, index) {
                      final cat = categories.categories[index];
                      final selected =
                          (homeVm.selectedCategoryId ?? '') == cat.id;
                      return FilterChip(
                        label: Text(cat.name),
                        selected: selected,
                        onSelected: (_) {
                          context.read<HomeFeedViewModel>().selectCategory(
                            cat.isAll ? null : cat.id,
                          );
                        },
                      );
                    },
                  ),
          ),
          if (categories.errorMessage != null)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                categories.errorMessage!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 13.sp,
                ),
              ),
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () =>
                  context.read<HomeFeedViewModel>().fetchBlogs(refresh: true),
              child: _BlogList(homeVm: homeVm),
            ),
          ),
        ],
      ),
    );
  }
}

class _BlogList extends StatelessWidget {
  const _BlogList({required this.homeVm});

  final HomeFeedViewModel homeVm;

  @override
  Widget build(BuildContext context) {
    if (homeVm.errorMessage != null && homeVm.blogs.isEmpty) {
      return ListView(
        controller: homeVm.scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Padding(
            padding: EdgeInsets.all(24.r),
            child: Text(
              homeVm.errorMessage!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 14.sp,
              ),
            ),
          ),
        ],
      );
    }

    if (homeVm.blogs.isEmpty && homeVm.isLoading) {
      return ListView(
        controller: homeVm.scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(top: 8.h, bottom: 24.h),
        children: const [
          BlogCardShimmer(),
          BlogCardShimmer(),
          BlogCardShimmer(),
          BlogCardShimmer(),
        ],
      );
    }

    if (homeVm.blogs.isEmpty) {
      return ListView(
        controller: homeVm.scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: 120.h),
          Center(
            child: Text(
              'No posts yet. Pull to refresh.',
              style: TextStyle(fontSize: 15.sp),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      controller: homeVm.scrollController,
      padding: EdgeInsets.only(bottom: 24.h),
      itemCount:
          homeVm.blogs.length + (homeVm.hasMore || homeVm.isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= homeVm.blogs.length) {
          return const BlogListFooterShimmer();
        }
        final item = homeVm.blogs[index];
        return BlogCard(
          blog: item,
          onTap: () =>
              context.push('${AppRoutePaths.post}/${item.id}', extra: item),
        );
      },
    );
  }
}
