import 'package:flutter/material.dart';

class SignupViewModel extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final mobileController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
