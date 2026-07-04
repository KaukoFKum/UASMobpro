import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'home_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  bool isPasswordHidden = true;

  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      String message = "Login gagal";

      if (e.code == 'user-not-found') {
        message = "User tidak ditemukan";
      } else if (e.code == 'wrong-password') {
        message = "Password salah";
      } else if (e.code == 'invalid-email') {
        message = "Format email tidak valid";
      } else if (e.code == 'invalid-credential') {
        message = "Email atau password salah";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Widget buildTextField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: const Color(0xffF8FAFD),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.12),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    const Icon(
                      Icons.lock_outline,
                      size: 66,
                      color: Colors.blueAccent,
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      "Login",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Masuk ke GoldenPark Smart Resident",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 24),
                    buildTextField(
                      label: "Email",
                      icon: Icons.email_outlined,
                      controller: emailController,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Email wajib diisi";
                        }
                        if (!value.contains("@")) {
                          return "Format email tidak valid";
                        }
                        return null;
                      },
                    ),
                    buildTextField(
                      label: "Password",
                      icon: Icons.lock_outline,
                      controller: passwordController,
                      obscureText: isPasswordHidden,
                      suffixIcon: IconButton(
                        icon: Icon(
                          isPasswordHidden
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            isPasswordHidden = !isPasswordHidden;
                          });
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Password wajib diisi";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: isLoading ? null : login,
                        icon: isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.login),
                        label: Text(isLoading ? "Loading..." : "Login"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegisterPage(),
                          ),
                        );
                      },
                      child: const Text("Belum punya akun? Register"),
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