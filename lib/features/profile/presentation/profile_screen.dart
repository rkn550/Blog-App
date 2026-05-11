import 'package:blog_app/features/auth/auth_view_model.dart';
import 'package:blog_app/router/app_router.dart';
import 'package:blog_app/services/profile_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final user = auth.user;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: TextStyle(fontSize: 20.sp)),
      ),
      body: ListView(
        padding: EdgeInsets.all(20.r),
        children: [
          CircleAvatar(
            radius: 40.r,
            child: Icon(
              Icons.person_rounded,
              size: 40.r,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'Account',
            style: theme.textTheme.titleMedium?.copyWith(fontSize: 18.sp),
          ),
          SizedBox(height: 8.h),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Name', style: TextStyle(fontSize: 14.sp)),
            subtitle: Text(
              user?.displayName ?? '—',
              style: TextStyle(fontSize: 15.sp),
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Email', style: TextStyle(fontSize: 14.sp)),
            subtitle: Text(
              user?.email ?? '—',
              style: TextStyle(fontSize: 15.sp),
            ),
          ),
          FutureBuilder<String?>(
            future: ProfileStorage().getMobile(),
            builder: (context, snap) {
              if (snap.hasError) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Mobile', style: TextStyle(fontSize: 14.sp)),
                  subtitle: Text(
                    'Could not load saved number.',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                );
              }
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Mobile', style: TextStyle(fontSize: 14.sp)),
                subtitle: Text(
                  snap.data ?? '—',
                  style: TextStyle(fontSize: 15.sp),
                ),
              );
            },
          ),
          SizedBox(height: 24.h),
          FilledButton.tonal(
            onPressed: () async {
              final err = await context.read<AuthViewModel>().logout();
              if (!context.mounted) return;
              if (err != null) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(err)));
                return;
              }
              context.go(AppRoutePaths.login);
            },
            child: Text('Log out', style: TextStyle(fontSize: 15.sp)),
          ),
        ],
      ),
    );
  }
}
