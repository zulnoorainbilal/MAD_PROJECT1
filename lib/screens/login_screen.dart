import 'package:flutter/material.dart';
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
  bool hidePassword = true;

  String? selectedUserType;

  final List<String> userTypes = [
    'General Staff',
    'Admin',
  ];

  final List<String> adminEmails = [
    "mrzulnoorain@gmail.com",
    "junaid@gmail.com"
  ];
  final String adminPassword = "junaid";

  void _login() {
    if (!_formKey.currentState!.validate()) return;

    final email = emailController.text.trim();
    final password = passwordController.text;

    if (selectedUserType == "Admin") {
      if (adminEmails.contains(email) && password == adminPassword) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid Admin credentials")),
        );
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(
            userType: selectedUserType ?? "General Public / Household",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.eco,
                      size: 80,
                      color: Colors.teal,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Welcome to",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.teal,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Eco Waste Tracker",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 25),

                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Email Field
                          TextFormField(
                            controller: emailController,
                            style: const TextStyle(color: Colors.black87),
                            decoration: InputDecoration(
                              labelText: "Email",
                              floatingLabelBehavior: FloatingLabelBehavior.never,
                              labelStyle: TextStyle(color: Colors.teal.shade700),
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              prefixIcon: const Icon(Icons.email, color: Colors.teal),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) =>
                                (value != null && value.contains("@"))
                                    ? null
                                    : "Enter valid email",
                          ),
                          const SizedBox(height: 16),

                          // Password Field
                          TextFormField(
                            controller: passwordController,
                            obscureText: hidePassword,
                            style: const TextStyle(color: Colors.black87),
                            decoration: InputDecoration(
                              labelText: "Password",
                              floatingLabelBehavior: FloatingLabelBehavior.never,
                              labelStyle: TextStyle(color: Colors.teal.shade700),
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              prefixIcon: const Icon(Icons.lock, color: Colors.teal),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  hidePassword ? Icons.visibility_off : Icons.visibility,
                                  color: Colors.teal,
                                ),
                                onPressed: () {
                                  setState(() {
                                    hidePassword = !hidePassword;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            validator: (value) =>
                                (value != null && value.isNotEmpty)
                                    ? null
                                    : "Enter password",
                          ),
                          const SizedBox(height: 16),

                          // User Type Dropdown
                          DropdownButtonFormField<String>(
                            value: selectedUserType,
                            icon: const Icon(Icons.arrow_drop_down, color: Colors.teal),
                            dropdownColor: Colors.grey.shade100,
                            style: const TextStyle(color: Colors.black87),
                            decoration: InputDecoration(
                              labelText: "Select User Type",
                              floatingLabelBehavior: FloatingLabelBehavior.never,
                              labelStyle: TextStyle(color: Colors.teal.shade700),
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            items: userTypes
                                .map(
                                  (type) => DropdownMenuItem(
                                    value: type,
                                    child: Row(
                                      children: [
                                        Icon(
                                          type == "Admin"
                                              ? Icons.admin_panel_settings
                                              : Icons.person,
                                          color: Colors.teal,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(type),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedUserType = value;
                              });
                            },
                            validator: (value) =>
                                value == null ? "Select user type" : null,
                          ),
                          const SizedBox(height: 24),

                          // Login Button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton.icon(
                              onPressed: _login,
                              icon: const Icon(Icons.login),
                              label: const Text(
                                "Login",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Signup Link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Don’t have an account? ",
                                style: TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const SignupScreen()),
                                  );
                                },
                                child: const Text(
                                  "Sign Up",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal,
                                    decoration: TextDecoration.underline,
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
    );
  }
}
