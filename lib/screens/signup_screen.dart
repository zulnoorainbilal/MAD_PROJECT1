import 'package:flutter/material.dart';
import 'login_screen.dart';

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
                    // Back Button
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

                    const Icon(
                      Icons.eco,
                      size: 60,
                      color: Colors.teal,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Welcome to",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.teal,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      "Eco Waste Tracker",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // First Name
                          _buildTextField(
                            controller: firstNameController,
                            label: "First Name",
                            icon: Icons.person,
                            validator: (value) =>
                                (value != null && value.isNotEmpty)
                                    ? null
                                    : "Enter first name",
                          ),
                          const SizedBox(height: 10),

                          // Last Name
                          _buildTextField(
                            controller: lastNameController,
                            label: "Last Name",
                            icon: Icons.person_outline,
                            validator: (value) =>
                                (value != null && value.isNotEmpty)
                                    ? null
                                    : "Enter last name",
                          ),
                          const SizedBox(height: 10),

                          // Email
                          _buildTextField(
                            controller: emailController,
                            label: "Email",
                            icon: Icons.email,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) =>
                                (value != null && value.contains("@"))
                                    ? null
                                    : "Enter valid email",
                          ),
                          const SizedBox(height: 10),

                          // Password
                          _buildTextField(
                            controller: passwordController,
                            label: "Password",
                            icon: Icons.lock,
                            obscureText: hidePassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                hidePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.teal,
                              ),
                              onPressed: () {
                                setState(() {
                                  hidePassword = !hidePassword;
                                });
                              },
                            ),
                            validator: (value) =>
                                (value != null && value.length >= 6)
                                    ? null
                                    : "Password must be 6+ chars",
                          ),
                          const SizedBox(height: 10),

                          // Confirm Password
                          _buildTextField(
                            controller: confirmPasswordController,
                            label: "Confirm Password",
                            icon: Icons.lock_outline,
                            obscureText: hidePassword,
                            validator: (value) => value ==
                                    passwordController.text
                                ? null
                                : "Passwords do not match",
                          ),
                          const SizedBox(height: 10),

                          // User Type Dropdown
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: DropdownButtonFormField<String>(
                              value: selectedUserType,
                              icon: const Icon(Icons.arrow_drop_down,
                                  color: Colors.teal),
                              dropdownColor: Colors.grey.shade100,
                              style: const TextStyle(color: Colors.black87),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                labelText: "Select User Type",
                                prefixIcon:
                                    Icon(Icons.person_pin, color: Colors.teal),
                              ),
                              items: userTypes
                                  .map(
                                    (type) => DropdownMenuItem(
                                      value: type,
                                      child: Row(
                                        children: [
                                          Icon(
                                            type == "Food Donor"
                                                ? Icons.food_bank
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
                                  value == null ? "Please select a user type" : null,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Register Button
                          SizedBox(
                            width: double.infinity,
                            height: 45,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const LoginScreen()),
                                  );
                                }
                              },
                              icon: const Icon(Icons.app_registration),
                              label: const Text(
                                "Register",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
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

  // Helper function for TextFormFields
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(color: Colors.black87),
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.teal.shade700),
          prefixIcon: Icon(icon, color: Colors.teal),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
        ),
        validator: validator,
      ),
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
