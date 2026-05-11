import 'package:blog_app/features/bookmarks/bookmark_view_model.dart';
import 'package:blog_app/features/home/category_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    context.read<BookmarkViewModel>().ensureLoaded();
    context.read<CategoryViewModel>().ensureLoaded();

    final shell = navigationShell;
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: shell.goBranch,
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home_outlined, size: 24.r),
            selectedIcon: Icon(Icons.home_rounded, size: 24.r),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_rounded, size: 24.r),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_outline_rounded, size: 24.r),
            selectedIcon: Icon(Icons.bookmark_rounded, size: 24.r),
            label: 'Bookmarks',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded, size: 24.r),
            selectedIcon: Icon(Icons.person_rounded, size: 24.r),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
