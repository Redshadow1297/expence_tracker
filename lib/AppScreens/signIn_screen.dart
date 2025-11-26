import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final mailId = TextEditingController();
  final password = TextEditingController();
  final reTypedPassword = TextEditingController();
  final mobileNumber = TextEditingController();
  final address = TextEditingController();
  final adharID = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void verifyAadhaar() {
    if (adharID.text.length != 12 ||
        !RegExp(r'^[0-9]+$').hasMatch(adharID.text)) {
      Get.snackbar(
        "Aadhaar Verification Failed",
        "Invalid Aadhaar Number. It should contain exactly 12 digits.",
        // backgroundColor: Colors.redAccent,
      );
    } else {
      Get.snackbar(
        "Verification Successful",
        "Aadhaar number is valid.",
        backgroundColor: Colors.yellowAccent,
        icon: Icon(Icons.done, size: 25),
      );
    }
  }

  Future<void> submitForm(
    String uFirstName,
    String uLastName,
    String uMailId,
    String uPassword,
    String uReTypedPassword,
    String uMobileNumber,
    String uAdharID,
    String uAddress,
  ) async {
    try {
      Get.dialog(
        Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      UserCredential uc = await _auth.createUserWithEmailAndPassword(
        email: uMailId,
        password: uPassword,
      );

      User? user = uc.user;

      await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
        'firstName': uFirstName,
        'lastName': uLastName,
        'emailId': uMailId,
        'mobileNumber': uMobileNumber,
        'adhaarNumber': uAdharID,
        'address': uAddress,
        'uId': user.uid,
        'createdAt': FieldValue.serverTimestamp(), //server's current time
      });

      Get.back();
      Get.snackbar(
        "Success",
        "Account Created Successfully!",
        backgroundColor: Colors.yellowAccent,
      );
      clearAllFields();
      Get.offAllNamed('/LoginPage');
    } on FirebaseAuthException catch (e) {
      Get.back();
      Get.snackbar(
        "Error",
        e.message ?? "Unknown error",
        backgroundColor: Colors.redAccent,
      );
    }
  }

//Clearing All fields after submitting
  void clearAllFields(){ 
    firstName.clear();
    lastName.clear();
    mailId.clear();
    password.clear();
    reTypedPassword.clear();
    mobileNumber.clear();
    adharID.clear();
    address.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Register Yourself",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 2, 125, 148),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Text(
                  "Welcome To Legends Empire!",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 2, 125, 148),
                  ),
                ),
                const SizedBox(height: 25),

                TextFormField(
                  controller: firstName,
                  decoration: _inputDecoration("First Name", Icons.person),
                  validator: (value) =>
                      value!.isEmpty ? "Enter first name" : null,
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: lastName,
                  decoration: _inputDecoration("Last Name", Icons.abc),
                  validator: (value) =>
                      value!.isEmpty ? "Enter last name" : null,
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: mailId,
                  decoration: _inputDecoration("Email", Icons.email_outlined),
                  validator: (value) {
                    if (value!.isEmpty) return "Enter email";
                    if (!RegExp(
                      r"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$",
                    ).hasMatch(value)) {
                      return "Enter valid email";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: password,
                  obscureText: true,
                  decoration: _inputDecoration("Password", Icons.password),
                  validator: (value) => value!.length < 6
                      ? "Password must be 6 characters or more"
                      : null,
                ),
                const SizedBox(height: 20),

                /// Confirm Password
                TextFormField(
                  controller: reTypedPassword,
                  obscureText: true,
                  decoration: _inputDecoration(
                    "Re-Type Password",
                    Icons.lock_outline,
                  ),
                  validator: (value) {
                    if (value!.isEmpty) return "Re-enter password";
                    if (value != password.text) return "Passwords do not match";
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: mobileNumber,
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration("Mobile Number", Icons.phone),
                  validator: (value) {
                    if (value!.length != 10) {
                      return "Enter 10-digit mobile number";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: address,
                  decoration: _inputDecoration(
                    "Address",
                    Icons.location_on_outlined,
                  ),
                  validator: (value) => value!.isEmpty ? "Enter address" : null,
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: adharID,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration(
                          "Aadhaar Number",
                          Icons.credit_card,
                        ),
                        validator: (value) {
                          if (value!.isEmpty) return "Enter Aadhaar number";
                          if (value.length != 12) {
                            return "Aadhaar must be 12 digits";
                          }
                          if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                            return "Only digits allowed";
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: verifyAadhaar,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                          ),
                          // color: Color.from(
                          //   alpha: 1,
                          //   red: 0.035,
                          //   green: 0.49,
                          //   blue: 0.58,
                          // ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          "Verify",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                InkWell(
                  onTap: () {
                    if (_formKey.currentState!.validate()) {
                      submitForm(
                        firstName.text,
                        lastName.text,
                        mailId.text,
                        password.text,
                        reTypedPassword.text,
                        mobileNumber.text,
                        adharID.text,
                        address.text,
                      );
                    }
                  },
                  child: Container(
                    height: 45,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                      ),
                      // color: Color.from(
                      //   alpha: 1,
                      //   red: 0.035,
                      //   green: 0.49,
                      //   blue: 0.58,
                      // ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Text(
                        "Submit Data",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData prefixIcon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(prefixIcon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}
