import 'package:blog_app/core/utils/validators.dart';
import 'package:blog_app/features/auth/auth_view_model.dart';
import 'package:blog_app/features/auth/signup_view_model.dart';
import 'package:blog_app/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final form = context.read<SignupViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: SafeArea(
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
                    'Sign up',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 24.sp,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  TextFormField(
                    controller: form.nameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: AppValidators.name,
                  ),
                  SizedBox(height: 16.h),
                  TextFormField(
                    controller: form.emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    validator: AppValidators.email,
                  ),
                  SizedBox(height: 16.h),
                  TextFormField(
                    controller: form.mobileController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Mobile',
                      border: OutlineInputBorder(),
                    ),
                    validator: AppValidators.mobile,
                  ),
                  SizedBox(height: 16.h),
                  TextFormField(
                    controller: form.passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                    validator: AppValidators.password,
                  ),
                  SizedBox(height: 28.h),
                  FilledButton(
                    onPressed: auth.isLoading ? null : () => _submit(context),
                    child: auth.isLoading
                        ? SizedBox(
                            height: 22.r,
                            width: 22.r,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : Text('Sign up', style: TextStyle(fontSize: 15.sp)),
                  ),
                  SizedBox(height: 12.h),
                  TextButton(
                    onPressed: () => context.pop(),
                    child: Text(
                      'Already have an account? Sign in',
                      style: TextStyle(fontSize: 14.sp),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> _submit(BuildContext context) async {
  final form = context.read<SignupViewModel>();
  final auth = context.read<AuthViewModel>();
  if (!(form.formKey.currentState?.validate() ?? false)) return;

  final err = await auth.signup(
    name: form.nameController.text,
    email: form.emailController.text,
    mobile: form.mobileController.text,
    password: form.passwordController.text,
  );
  if (!context.mounted) return;
  if (err != null) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    return;
  }
  context.go(AppRoutePaths.feed);
}
