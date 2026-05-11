import 'package:blog_app/firebase_options.dart';
import 'package:blog_app/router/app_router.dart';
import 'package:blog_app/features/auth/auth_view_model.dart';
import 'package:blog_app/features/bookmarks/bookmark_view_model.dart';
import 'package:blog_app/features/home/category_view_model.dart';
import 'package:blog_app/features/home/home_feed_view_model.dart';
import 'package:blog_app/features/search/search_view_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: 'assets/.env');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await GoogleSignIn.instance.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => HomeFeedViewModel()),
        ChangeNotifierProvider(create: (_) => CategoryViewModel()),
        ChangeNotifierProvider(create: (_) => BookmarkViewModel()),
        ChangeNotifierProvider(create: (_) => SearchViewModel()),
      ],
      child: const BlogApp(),
    ),
  );
}

class BlogApp extends StatelessWidget {
  const BlogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Blog App',
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: const Color(0xFF006A6A),
        ),
        routerConfig: createAppRouter(context.read<AuthViewModel>()),
      ),
    );
  }
}
