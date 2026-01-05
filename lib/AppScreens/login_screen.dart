import 'package:expence_tracker/CommonWidgets/app_buittons.dart';
import 'package:expence_tracker/CommonWidgets/app_lables.dart';
import 'package:expence_tracker/CommonWidgets/app_snackbars.dart';
import 'package:expence_tracker/CommonWidgets/custom_appbar.dart';
import 'package:expence_tracker/auth_BLoC/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final userNameController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  LoginBloc loginBloc = LoginBloc();

  Future<void> getLoggedIn(String username, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: username,
        password: password,
      );

      Get.offAllNamed(
        '/dashboard',
        arguments: {
          'uid': userCredential.user?.uid,
          'email': userCredential.user?.email,
        },
      );
      AppSnackbar.success('Login', 'Successfully Logged In');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        AppSnackbar.error("User not found", "Enter correct email");
      } else if (e.code == 'wrong-password') {
        AppSnackbar.warning("Wrong Password", "Enter correct password");
      } else {
        AppSnackbar.error("Error", e.message ?? "Something went wrong");
      }
    } catch (ex) {
      AppSnackbar.error("Error", ex.toString());
    }
  }

  void _checkUserLogin() async {
    User? user = _auth.currentUser;
    if (user != null) {
      Get.offAllNamed(
        '/dashboard',
        arguments: {'uid': user.uid, 'email': user.email},
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _checkUserLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: "Expense Tracker",
        subTitle: "Login to manage your expenses",
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 30),
                Text(
                  "Welcome Buddy!",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF096A94),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Text(
                  "Sign in to continue",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 40),

                // Email Field
                TextFormField(
                  controller: userNameController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value!.isEmpty) return "Enter your email";
                    if (!RegExp(r"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$")
                        .hasMatch(value)) return "Enter a valid email";
                    return null;
                  },
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.email_outlined, color: Colors.blueAccent),
                    hintText: "Email",
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // Password Field
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  validator: (value) => value!.isEmpty ? "Enter password" : null,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.lock_outline, color: Colors.blueAccent),
                    hintText: "Password",
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 30),

                // Login Button
                AppButton(
                  text: "Login",
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      getLoggedIn(
                        userNameController.text.trim(),
                        passwordController.text.trim(),
                      );
                    }
                  },
                ),
                SizedBox(height: 20),

                // SignUp Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppLabel.body("Don't have an account?", Colors.black54),
                    SizedBox(width: 8),
                    InkWell(
                      onTap: () => Get.toNamed('/signIn'),
                      child: Text(
                        "Sign Up",
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30),

                // Forgot Password
                InkWell(
                  onTap: () => Get.toNamed('/forgetPassword'),
                  child: AppLabel.body("Forgot Password?", Colors.blueAccent),
                ),
                SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
