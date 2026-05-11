import 'package:blog_app/features/search/search_view_model.dart';
import 'package:blog_app/router/app_router.dart';
import 'package:blog_app/shared/widgets/blog_card.dart';
import 'package:blog_app/shared/widgets/blog_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final search = context.watch<SearchViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Search', style: TextStyle(fontSize: 20.sp)),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
            child: TextField(
              controller: search.queryController,
              style: TextStyle(fontSize: 15.sp),
              decoration: InputDecoration(
                hintText: 'Search posts…',
                hintStyle: TextStyle(fontSize: 14.sp),
                border: const OutlineInputBorder(),
                prefixIcon: Icon(Icons.search_rounded, size: 22.r),
                suffixIcon: search.queryController.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear',
                        onPressed: () => search.clearQuery(),
                        icon: Icon(Icons.clear_rounded, size: 22.r),
                      ),
              ),
              textInputAction: TextInputAction.search,
              onChanged: (v) =>
                  context.read<SearchViewModel>().onSearchChanged(v),
            ),
          ),
          if (search.errorMessage != null)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  search.errorMessage!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 13.sp,
                  ),
                ),
              ),
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => context.read<SearchViewModel>().refresh(),
              child: _SearchResults(search: search),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({required this.search});

  final SearchViewModel search;

  @override
  Widget build(BuildContext context) {
    final hasQuery = search.queryController.text.trim().isNotEmpty;

    if (search.isLoading && search.blogs.isEmpty && hasQuery) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(top: 8.h, bottom: 24.h),
        children: const [
          BlogCardShimmer(),
          BlogCardShimmer(),
          BlogCardShimmer(),
        ],
      );
    }

    if (search.blogs.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: 80.h),
          Center(
            child: Text(
              hasQuery
                  ? 'No matching posts.'
                  : 'Type to search. Results update after a short pause.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 14.sp,
              ),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.only(bottom: 24.h),
      itemCount: search.blogs.length,
      itemBuilder: (context, index) {
        final blog = search.blogs[index];
        return BlogCard(
          blog: blog,
          onTap: () =>
              context.push('${AppRoutePaths.post}/${blog.id}', extra: blog),
        );
      },
    );
  }
}
