//login_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/meal_plan_model.dart';
import '../../services/api_service.dart';
import '../../widgets/app_background.dart';
import '../dashboard/dashboard_screen.dart';
import '../diet/multi_parameter_form.dart';
import 'auth_service.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final AuthService authService = AuthService();

  bool isPasswordHidden = true;
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRedirect(User user) async {
    try {
      final bool profileComplete = await ApiService.isProfileComplete(user.uid);

      if (!mounted) return;

      if (!profileComplete) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const MultiParameterForm(),
          ),
        );
        return;
      }

      try {
        final mealPlanJson = await ApiService.getLatestMealPlan(user.uid);
        final mealPlan = MealPlanModel.fromJson(mealPlanJson);

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => DashboardScreen(mealPlan: mealPlan),
          ),
        );
      } catch (e) {
        debugPrint("Latest meal fetch failed: $e");

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const DashboardScreen(mealPlan: null),
          ),
        );
      }
    } catch (e) {
      debugPrint("Profile status check failed: $e");

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const MultiParameterForm(),
        ),
      );
    }
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final credential = await authService.loginWithEmail(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      final user = credential.user;
      if (user == null) throw Exception("User not found");

      await _handleRedirect(user);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login failed: $e")),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => isLoading = true);

    try {
      final credential = await authService.loginWithGoogle();

      final user = credential.user;
      if (user == null) throw Exception("Google user not found");

      await _handleRedirect(user);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Google login failed: $e")),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _handleFacebookLogin() async {
    setState(() => isLoading = true);

    try {
      final credential = await authService.loginWithFacebook();

      final user = credential.user;
      if (user == null) throw Exception("Facebook user not found");

      await _handleRedirect(user);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Facebook login failed: $e")),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _handleXLogin() async {
    setState(() => isLoading = true);

    try {
      final credential = await authService.loginWithX();

      final user = credential.user;
      if (user == null) throw Exception("X user not found");

      await _handleRedirect(user);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("X login failed: $e")),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _handleMicrosoftLogin() async {
    setState(() => isLoading = true);

    try {
      final credential = await authService.loginWithMicrosoft();

      final user = credential.user;
      if (user == null) throw Exception("Microsoft user not found");

      await _handleRedirect(user);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Microsoft login failed: $e")),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.black54),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _socialButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            icon,
            size: 28,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: Form(
              key: _formKey,
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDF8F4),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    const CircleAvatar(
                      radius: 34,
                      backgroundColor: Color(0xFFFFE9DA),
                      child: Icon(
                        Icons.restaurant_menu_rounded,
                        size: 34,
                        color: Color(0xFFF29D72),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Welcome Back",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF272525),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Login to continue your diet journey",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _inputDecoration(
                        label: "Email",
                        icon: Icons.email_outlined,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Please enter email";
                        }
                        if (!value.contains("@")) {
                          return "Please enter a valid email";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: passwordController,
                      obscureText: isPasswordHidden,
                      decoration: _inputDecoration(
                        label: "Password",
                        icon: Icons.lock_outline_rounded,
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              isPasswordHidden = !isPasswordHidden;
                            });
                          },
                          icon: Icon(
                            isPasswordHidden
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Please enter password";
                        }
                        if (value.trim().length < 6) {
                          return "Password must be at least 6 characters";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF29D72),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                "Login",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: isLoading ? null : () {},
                      child: const Text(
                        "Forgot Password?",
                        style: TextStyle(color: Colors.black87),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Or continue with",
                      style: TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _socialButton(
                          icon: Icons.g_mobiledata_rounded,
                          onTap: _handleGoogleLogin,
                        ),
                        _socialButton(
                          icon: Icons.facebook_rounded,
                          onTap: _handleFacebookLogin,
                        ),
                        _socialButton(
                          icon: Icons.alternate_email_rounded,
                          onTap: _handleXLogin,
                        ),
                        _socialButton(
                          icon: Icons.business_rounded,
                          onTap: _handleMicrosoftLogin,
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    TextButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SignupScreen(),
                                ),
                              );
                            },
                      child: const Text(
                        "Don't have an account? Create New Account",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black87),
                      ),
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