import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

import 'home_screen.dart';
import 'signup_screen.dart';
import 'admin_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _keyboardFocus = FocusNode();

  bool hidePassword = true;
  bool _loading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _keyboardFocus.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    try {
      // 🔐 Firebase Auth
      UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        _showError("Login failed");
        return;
      }

      // 🔎 Admin check
      final adminQuery = await _firestore
          .collection('admin')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (adminQuery.docs.isNotEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminScreen()),
        );
        return;
      }

      // ⚡ FAST role check (PARALLEL – FIXED)
      String? userType;

      final results = await Future.wait([
        _firestore.collection('general_staff').doc(user.uid).get(),
        _firestore.collection('food_donors').doc(user.uid).get(),
        _firestore.collection('restaurant_staff').doc(user.uid).get(),
      ]);

      if (results[0].exists) {
        userType = "General Staff";
      } else if (results[1].exists) {
        userType = "Food Donor";
      } else if (results[2].exists) {
        userType = "Resturant_Chef_Staff";
      }

      if (userType == null) {
        await _auth.signOut();
        _showError("User role not found");
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(userType: userType),
        ),
      );
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? "Authentication failed");
    } catch (e) {
      _showError("Something went wrong");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: RawKeyboardListener(
          focusNode: _keyboardFocus,
          autofocus: true,
          onKey: (event) {
            if (event is RawKeyDownEvent) {
              if (event.logicalKey == LogicalKeyboardKey.arrowDown &&
                  _emailFocus.hasFocus) {
                FocusScope.of(context).requestFocus(_passwordFocus);
              }
              if (event.logicalKey == LogicalKeyboardKey.arrowUp &&
                  _passwordFocus.hasFocus) {
                FocusScope.of(context).requestFocus(_emailFocus);
              }
            }
          },
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 6,
                              offset: Offset(0, 4),
                            )
                          ],
                        ),
                        child: const Icon(Icons.eco,
                            size: 64, color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      const Text("Welcome to",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.teal)),
                      const Text("Eco Waste Tracker",
                          style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal)),
                      const SizedBox(height: 28),

                      /// FORM
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _buildTextField(
                              controller: emailController,
                              focusNode: _emailFocus,
                              label: "Email",
                              icon: Icons.email,
                              keyboardType: TextInputType.emailAddress,
                              validator: (val) => val != null &&
                                      val.contains("@")
                                  ? null
                                  : "Enter valid email",
                            ),
                            const SizedBox(height: 18),
                            _buildTextField(
                              controller: passwordController,
                              focusNode: _passwordFocus,
                              label: "Password",
                              icon: Icons.lock,
                              obscureText: hidePassword,
                              validator: (val) =>
                                  val != null && val.isNotEmpty
                                      ? null
                                      : "Enter password",
                              suffix: IconButton(
                                icon: Icon(hidePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility),
                                onPressed: () => setState(
                                    () => hidePassword = !hidePassword),
                              ),
                            ),
                            const SizedBox(height: 28),

                            /// ✅ FIXED LOGIN BUTTON
                            SizedBox(
                              width: 260,
                              height: 50,
                              child: _highlightButton(
                                label:
                                    _loading ? "Logging in..." : "Login",
                                onPressed:
                                    _loading ? null : _login,
                              ),
                            ),

                            const SizedBox(height: 22),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Don’t have an account? "),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const SignupScreen(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    "Sign Up",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      decoration:
                                          TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    String? Function(String?)? validator,
    Widget? suffix,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      obscureText: obscureText,
      textInputAction: TextInputAction.next,
      onFieldSubmitted: (_) {
        if (focusNode == _emailFocus) {
          FocusScope.of(context).requestFocus(_passwordFocus);
        } else if (focusNode == _passwordFocus && !_loading) {
          _login();
        }
      },
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey.shade100,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        prefixIcon: Icon(icon, color: Colors.teal),
        suffixIcon: suffix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      validator: validator,
    );
  }

  Widget _highlightButton({
    required String label,
    required VoidCallback? onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(2, 3))
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          label,
          style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.white),
        ),
      ),
    );
  }
}
