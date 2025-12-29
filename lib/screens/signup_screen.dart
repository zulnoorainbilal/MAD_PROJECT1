import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 🔥 ADDED
import 'login_screen.dart';
import '../services/firestore_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool hidePassword = true;

  String? selectedUserType;
  final List<String> userTypes = [
    'General staff',
    'Food Donor',
    'Resturant_Chef_Staff'
  ];

  final FirestoreService _firestoreService = FirestoreService();

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
                width: MediaQuery.of(context).size.width * 0.9,
                padding: const EdgeInsets.all(20),
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
                    Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.teal),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LoginScreen()),
                          );
                        },
                      ),
                    ),

                    const Icon(Icons.eco, size: 60, color: Colors.teal),
                    const SizedBox(height: 16),

                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildTextField(
                            controller: firstNameController,
                            label: "First Name",
                            icon: Icons.person,
                            validator: (v) =>
                                v!.isEmpty ? "Enter first name" : null,
                          ),
                          const SizedBox(height: 10),

                          _buildTextField(
                            controller: lastNameController,
                            label: "Last Name",
                            icon: Icons.person_outline,
                            validator: (v) =>
                                v!.isEmpty ? "Enter last name" : null,
                          ),
                          const SizedBox(height: 10),

                          _buildTextField(
                            controller: emailController,
                            label: "Email",
                            icon: Icons.email,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) =>
                                v!.contains("@") ? null : "Invalid email",
                          ),
                          const SizedBox(height: 10),

                          _buildTextField(
                            controller: passwordController,
                            label: "Password",
                            icon: Icons.lock,
                            obscureText: hidePassword,
                            validator: (v) =>
                                v!.length >= 6 ? null : "Min 6 chars",
                          ),
                          const SizedBox(height: 10),

                          _buildTextField(
                            controller: confirmPasswordController,
                            label: "Confirm Password",
                            icon: Icons.lock_outline,
                            obscureText: hidePassword,
                            validator: (v) => v == passwordController.text
                                ? null
                                : "Passwords mismatch",
                          ),
                          const SizedBox(height: 10),

                          DropdownButtonFormField<String>(
                            value: selectedUserType,
                            decoration: const InputDecoration(
                              labelText: "Select User Type",
                            ),
                            items: userTypes
                                .map((e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e),
                                    ))
                                .toList(),
                            onChanged: (v) =>
                                setState(() => selectedUserType = v),
                            validator: (v) =>
                                v == null ? "Select user type" : null,
                          ),
                          const SizedBox(height: 20),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              child: const Text("Register"),
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  try {
                                    // 🔥 AUTH
                                    UserCredential userCredential =
                                        await FirebaseAuth.instance
                                            .createUserWithEmailAndPassword(
                                      email:
                                          emailController.text.trim(),
                                      password:
                                          passwordController.text.trim(),
                                    );

                                    // 🔥 FIRESTORE
                                    await _firestoreService.saveUser(
                                      uid: userCredential.user!.uid,
                                      firstName:
                                          firstNameController.text.trim(),
                                      lastName:
                                          lastNameController.text.trim(),
                                      email:
                                          emailController.text.trim(),
                                      userType: selectedUserType!,
                                    );

                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const LoginScreen()),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(e.toString())),
                                    );
                                  }
                                }
                              },
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
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
      validator: validator,
    );
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
