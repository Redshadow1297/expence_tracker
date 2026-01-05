import 'package:expence_tracker/CommonWidgets/app_buittons.dart';
import 'package:expence_tracker/CommonWidgets/app_snackbars.dart';
import 'package:expence_tracker/CommonWidgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscure = true;

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null || user.email == null) {
        throw FirebaseAuthException(code: 'no-user');
      }

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: _currentPasswordController.text.trim(),
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(_newPasswordController.text.trim());

      AppSnackbar.success("Success", "Password updated successfully");
      Navigator.pop(context);
    } catch (e) {
      AppSnackbar.error("Error", "Unable to update password");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: const CustomAppBar(
        title: "Change Password",
        subTitle: "Keep your account secure",
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _securityHeader(),
              const SizedBox(height: 20),
              _passwordCard(),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  text: "Update Password",
                  isLoading: _isLoading,
                  onPressed: _changePassword,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ---------- TOP INFO ----------
  Widget _securityHeader() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: const [
          CircleAvatar(
            radius: 24,
            backgroundColor: Color(0xFFEEF2FF),
            child: Icon(Icons.lock_outline, color: Colors.indigo),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "Use a strong password to protect your expenses & data",
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  /// ---------- PASSWORD CARD ----------
  Widget _passwordCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          _passwordField(
            controller: _currentPasswordController,
            label: "Current Password",
            icon: Icons.lock,
          ),
          const SizedBox(height: 16),
          _passwordField(
            controller: _newPasswordController,
            label: "New Password",
            icon: Icons.lock_outline,
          ),
          const SizedBox(height: 16),
          _passwordField(
            controller: _confirmPasswordController,
            label: "Confirm Password",
            icon: Icons.check_circle_outline,
            validator: (v) {
              if (v != _newPasswordController.text) {
                return "Passwords do not match";
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "• Password must be at least 6 characters",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  /// ---------- PASSWORD FIELD ----------
  Widget _passwordField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: _obscure,
      validator: validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return "Enter $label";
            }
            if (label == "New Password" && value.length < 6) {
              return "Minimum 6 characters required";
            }
            return null;
          },
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        suffixIcon: IconButton(
          icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
      ),
    );
  }
}
