import 'package:blog_app/features/auth/auth_view_model.dart';
import 'package:blog_app/features/auth/login_view_model.dart';
import 'package:blog_app/features/auth/presentation/login_screen.dart';
import 'package:blog_app/features/auth/presentation/signup_screen.dart';
import 'package:blog_app/features/auth/signup_view_model.dart';
import 'package:blog_app/features/blog/blog_detail_view_model.dart';
import 'package:blog_app/features/blog/presentation/blog_detail_screen.dart';
import 'package:blog_app/features/bookmarks/presentation/bookmarks_screen.dart';
import 'package:blog_app/features/home/presentation/home_screen.dart';
import 'package:blog_app/features/profile/presentation/profile_screen.dart';
import 'package:blog_app/features/search/presentation/search_screen.dart';
import 'package:blog_app/features/shell/presentation/home_shell.dart';
import 'package:blog_app/shared/models/blog_models.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

abstract class AppRoutePaths {
  static const login = '/login';
  static const signup = '/signup';
  static const feed = '/feed';
  static const search = '/search';
  static const bookmarks = '/bookmarks';
  static const profile = '/profile';
  static const post = '/post';
}

GoRouter createAppRouter(AuthViewModel auth) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutePaths.feed,
    refreshListenable: auth,
    redirect: (context, state) {
      final loggedIn = FirebaseAuth.instance.currentUser != null;
      final loc = state.matchedLocation;
      final atAuth = loc == AppRoutePaths.login || loc == AppRoutePaths.signup;
      if (!loggedIn && !atAuth) return AppRoutePaths.login;
      if (loggedIn && atAuth) return AppRoutePaths.feed;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutePaths.login,
        builder: (context, state) => ChangeNotifierProvider(
          create: (_) => LoginViewModel(),
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutePaths.signup,
        builder: (context, state) => ChangeNotifierProvider(
          create: (_) => SignupViewModel(),
          child: const SignupScreen(),
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return HomeShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutePaths.feed,
                name: 'feed',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutePaths.search,
                name: 'search',
                builder: (context, state) => const SearchScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutePaths.bookmarks,
                name: 'bookmarks',
                builder: (context, state) => const BookmarksScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutePaths.profile,
                name: 'profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '${AppRoutePaths.post}/:id',
        name: 'post',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final extra = state.extra;
          final initial = extra is BlogModel ? extra : null;
          return ChangeNotifierProvider(
            create: (_) => BlogDetailViewModel(postId: id, initialPost: initial),
            child: const BlogDetailScreen(),
          );
        },
      ),
    ],
  );
}
