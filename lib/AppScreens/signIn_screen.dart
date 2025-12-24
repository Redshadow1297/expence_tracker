import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expence_tracker/CommonWidgets/app_buittons.dart';
import 'package:expence_tracker/CommonWidgets/app_lables.dart';
import 'package:expence_tracker/CommonWidgets/app_snackbars.dart';
import 'package:expence_tracker/CommonWidgets/custom_appbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

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
  XFile? pickedImage;
  final ImagePicker picker = ImagePicker();

  Future<void> pickProfileImage() async {
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        pickedImage = image;
      });
    }
  }

  Future<String?> uploadProfilePic(String uid) async {
    Get.snackbar("InProgress", "Image Uploading Under Development .");
    return null;
  //   if (pickedImage == null) return null;

  //   try {
  //     File file = File(pickedImage!.path);

  //     final ref = FirebaseStorage.instance
  //         .ref()
  //         .child('profilePics')
  //         .child('$uid.jpg');
  //     UploadTask uploadTask = ref.putFile(
  //       file,
  //       SettableMetadata(contentType: 'image/jpeg'),
  //     );
  //     TaskSnapshot snapshot = await uploadTask;
  //     String downloadUrl = await snapshot.ref.getDownloadURL();
  //     return downloadUrl;
  //   } catch (e) {
  //     debugPrint("UPLOAD ERROR: $e");
  //     return null;
  //   }
  }

  // Future<String?> uploadProfilePic(String uid) async {
  //   if (pickedImage == null) return null;
  //   try {
  //     final file = File(pickedImage!.path);
  //     final bytes = await file.readAsBytes();
  //     final ref = FirebaseStorage.instance.ref().child("profilePics/$uid.jpg");
  //     await ref.putData(bytes, SettableMetadata(contentType: "image/jpeg"));
  //     return await ref.getDownloadURL();
  //   } catch (e) {
  //     print("UPLOAD ERROR: $e");
  //     return null;
  //   }
  // }

  void verifyAadhaar() {
    if (adharID.text.length != 12 ||
        !RegExp(r'^[0-9]+$').hasMatch(adharID.text)) {
      Get.snackbar(
        "Aadhaar Verification Failed",
        "Invalid Aadhaar Number. It should contain exactly 12 digits.",
      );
    } else {
      AppSnackbar.success(
        "Verification Successful",
        "Aadhaar number is valid.",
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

      String? profileUrl = await uploadProfilePic(user!.uid);

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'firstName': uFirstName,
        'lastName': uLastName,
        'emailId': uMailId,
        'mobileNumber': uMobileNumber,
        'adhaarNumber': uAdharID,
        'address': uAddress,
        'profilePic': profileUrl ?? "",
        'uId': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      Get.back();
      clearAllFields();
      Get.offAllNamed('/LoginPage');
      AppSnackbar.success("Success", "Account Created Successfully!");
    } on FirebaseAuthException catch (e) {
      Get.back();
      AppSnackbar.error("Error", e.message ?? "Unknown error");
    }
  }

  void clearAllFields() {
    firstName.clear();
    lastName.clear();
    mailId.clear();
    password.clear();
    reTypedPassword.clear();
    mobileNumber.clear();
    adharID.clear();
    address.clear();
  }

  InputDecoration _inputDecoration(String hint, IconData prefixIcon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(prefixIcon, color: Color.fromARGB(255, 9, 125, 148)),
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 240, 245, 250),
      appBar: CustomAppBar(
        title: "Register Yourself",
        subTitle: "Save your all profile details here.",
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(height: 20),
                AppLabel.title(
                  "Welcome to Legends Empire !",
                  Colors.lightBlueAccent,
                ),
                SizedBox(height: 20),

                /// Profile Pic
                Center(
                  child: InkWell(
                    onTap: pickProfileImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: pickedImage != null
                          ? FileImage(File(pickedImage!.path))
                          : null,
                      child: pickedImage == null
                          ? Icon(
                              Icons.camera_alt,
                              size: 40,
                              color: Color.fromARGB(255, 9, 125, 148),
                            )
                          : null,
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // Input fields
                TextFormField(
                  controller: firstName,
                  decoration: _inputDecoration("First Name", Icons.person),
                  validator: (v) => v!.isEmpty ? "Enter first name" : null,
                ),
                SizedBox(height: 15),
                TextFormField(
                  controller: lastName,
                  decoration: _inputDecoration("Last Name", Icons.abc),
                  validator: (v) => v!.isEmpty ? "Enter last name" : null,
                ),
                SizedBox(height: 15),
                TextFormField(
                  controller: mailId,
                  decoration: _inputDecoration("Email", Icons.email_outlined),
                  validator: (v) {
                    if (v!.isEmpty) return "Enter email";
                    if (!RegExp(
                      r"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$",
                    ).hasMatch(v)) {
                      return "Enter valid email";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15),
                TextFormField(
                  controller: password,
                  obscureText: true,
                  decoration: _inputDecoration("Password", Icons.password),
                  validator: (v) => v!.length < 6
                      ? "Password must be 6 characters or more"
                      : null,
                ),
                SizedBox(height: 15),
                TextFormField(
                  controller: reTypedPassword,
                  obscureText: true,
                  decoration: _inputDecoration(
                    "Re-Type Password",
                    Icons.lock_outline,
                  ),
                  validator: (v) {
                    if (v!.isEmpty) return "Re-enter password";
                    if (v != password.text) return "Passwords do not match";
                    return null;
                  },
                ),
                SizedBox(height: 15),
                TextFormField(
                  controller: mobileNumber,
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration("Mobile Number", Icons.phone),
                  validator: (v) {
                    if (v!.length != 10) return "Enter 10-digit mobile number";
                    return null;
                  },
                ),
                SizedBox(height: 15),
                TextFormField(
                  controller: address,
                  decoration: _inputDecoration(
                    "Address",
                    Icons.location_on_outlined,
                  ),
                  validator: (v) => v!.isEmpty ? "Enter address" : null,
                ),
                SizedBox(height: 15),

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
                        validator: (v) {
                          if (v!.isEmpty) return "Enter Aadhaar number";
                          if (v.length != 12) {
                            return "Aadhaar must be 12 digits";
                          }
                          if (!RegExp(r'^[0-9]+$').hasMatch(v)) {
                            return "Only digits allowed";
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    InkWell(
                      onTap: verifyAadhaar,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          "Verify",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30),
                AppButton(text: "Submit Data", onPressed: () {
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
                }),
                SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
