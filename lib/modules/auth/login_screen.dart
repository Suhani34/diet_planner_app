import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'signup_screen.dart';
import '../diet/multi_parameter_form.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final AuthService authService = AuthService();

  bool isPasswordHidden = true;
  bool isLoading = false;

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      await authService.loginWithUsername(
        usernameController.text,
        passwordController.text,
      );

      setState(() {
        isLoading = false;
      });

      // ✅ Login hone ke baad Dashboard (MultiParameterForm) pe navigate karo
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const MultiParameterForm(),
          ),
        );
      }
    }
  }

  Future<void> _handleSocialLogin(Future<void> Function() loginMethod) async {
    setState(() => isLoading = true);
    await loginMethod();
    setState(() => isLoading = false);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const MultiParameterForm(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EBDD),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Icon(Icons.restaurant_menu, size: 80, color: Colors.black87),
                const SizedBox(height: 10),
                const Text("Personalized Diet Chat",
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87)),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))
                    ],
                  ),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: usernameController,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.person),
                          labelText: "Username",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return "Please enter username";
                          if (value.length < 3) return "Username must be at least 3 characters";
                          if (value.contains(" ")) return "Username should not contain spaces";
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: passwordController,
                        obscureText: isPasswordHidden,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock),
                          labelText: "Password",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                          suffixIcon: IconButton(
                            icon: Icon(isPasswordHidden ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setState(() => isPasswordHidden = !isPasswordHidden),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return "Please enter password";
                          if (value.length < 6) return "Password must be at least 6 characters";
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 22, width: 22,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text("Login", style: TextStyle(color: Colors.white)),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Forgot Password Clicked")));
                        },
                        child: const Text("Forgot Password?", style: TextStyle(color: Colors.black87)),
                      ),
                      const SizedBox(height: 15),
                      const Divider(),
                      const SizedBox(height: 15),
                      const Text("Or Continue With"),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _socialButton("assets/images/google.png",
                              () => _handleSocialLogin(authService.loginWithGoogle)),
                          _socialButton("assets/images/facebook.png",
                              () => _handleSocialLogin(authService.loginWithFacebook)),
                          _socialButton("assets/images/x.png",
                              () => _handleSocialLogin(authService.loginWithTwitter)),
                          _socialButton("assets/images/microsoft.png",
                              () => _handleSocialLogin(authService.loginWithMicrosoft)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SignupScreen()),
                          );
                        },
                        child: const Text(
                          "Don't have an account? Create New Account",
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _socialButton(String imagePath, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
        ),
        child: Image.asset(imagePath, height: 28),
      ),
    );
  }
}
