import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'main.dart'; // Import the HealthDashboard

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _signIn() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HealthDashboard()),
        (Route<dynamic> route) => false,
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Sign in failed: ${e.message}"),
          backgroundColor: Colors.red.shade400,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7FD), // Light pastel background
      appBar: AppBar(
        title: const Text(
          "Sign In",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 255, 116, 225),
        centerTitle: true,
        elevation: 2,
      ),
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 36.h),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFDE9F3), Color(0xFFFFF7FD)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 40.h),
              Text(
                "Welcome Back!",
                style: TextStyle(
                  fontSize: 30.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 193, 48, 193),
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                "Sign in to your account",
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.grey.shade800,
                ),
              ),
              SizedBox(height: 50.h),
              _buildTextField(
                controller: _emailController,
                labelText: "Email",
                icon: Icons.email_outlined,
              ),
              SizedBox(height: 30.h),
              _buildTextField(
                controller: _passwordController,
                labelText: "Password",
                icon: Icons.lock_outline,
                obscureText: true,
              ),
              SizedBox(height: 50.h),
              GestureDetector(
                onTap: _signIn,
                child: Container(
                  width: double.infinity,
                  height: 50.h,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color.fromARGB(255, 255, 116, 225), Color(0xFFB048B6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(25.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.pink.shade100,
                        offset: const Offset(0, 5),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "Sign In",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account?",
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade700),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigate to Sign Up page
                    },
                    child: Text(
                      "Sign Up",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color.fromARGB(255, 193, 48, 193),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    bool obscureText = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(25.r),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.shade50,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(fontSize: 14.sp, color: Colors.grey.shade800),
          prefixIcon: Icon(icon, color: Colors.pink.shade300),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.r),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.r),
            borderSide: const BorderSide(color: Color.fromARGB(255, 193, 48, 193), width: 1.5),
          ),
        ),
        style: TextStyle(fontSize: 14.sp, color: Colors.black),
      ),
    );
  }
}
