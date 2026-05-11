import 'package:blog_app/core/utils/validators.dart';
import 'package:blog_app/features/auth/auth_view_model.dart';
import 'package:blog_app/features/auth/login_view_model.dart';
import 'package:blog_app/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final form = context.read<LoginViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 440.w),
              child: Form(
                key: form.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Welcome back',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 24.sp,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Sign in to read posts, filter by category, and save bookmarks.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(height: 32.h),
                    TextFormField(
                      controller: form.emailController,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      validator: AppValidators.email,
                    ),
                    SizedBox(height: 16.h),
                    TextFormField(
                      controller: form.passwordController,
                      obscureText: true,
                      autofillHints: const [AutofillHints.password],
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                      validator: AppValidators.password,
                    ),
                    SizedBox(height: 24.h),
                    FilledButton(
                      onPressed: auth.isLoading
                          ? null
                          : () => _submitEmailLogin(context),
                      child: auth.isLoading
                          ? SizedBox(
                              height: 22.r,
                              width: 22.r,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : Text('Sign in', style: TextStyle(fontSize: 15.sp)),
                    ),
                    SizedBox(height: 12.h),
                    OutlinedButton.icon(
                      onPressed: auth.isLoading ? null : () => _google(context),
                      icon: Icon(Icons.g_mobiledata_rounded, size: 28.r),
                      label: Text(
                        'Continue with Google',
                        style: TextStyle(fontSize: 15.sp),
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'New here?',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 14.sp,
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.push(AppRoutePaths.signup),
                          child: const Text('Create an account'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> _submitEmailLogin(BuildContext context) async {
  final form = context.read<LoginViewModel>();
  final auth = context.read<AuthViewModel>();
  if (!(form.formKey.currentState?.validate() ?? false)) return;

  final err = await auth.login(
    email: form.emailController.text,
    password: form.passwordController.text,
  );
  if (!context.mounted) return;
  if (err != null) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    return;
  }
  context.go(AppRoutePaths.feed);
}

Future<void> _google(BuildContext context) async {
  final auth = context.read<AuthViewModel>();
  final err = await auth.signInWithGoogle();
  if (!context.mounted) return;
  if (err != null) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    return;
  }
  context.go(AppRoutePaths.feed);
}
