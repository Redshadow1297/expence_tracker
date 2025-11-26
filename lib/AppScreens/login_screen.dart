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


  Future<void> getLoggedIn(String username, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: username,
        password: password,
      );

      print(userCredential);
      Get.offAllNamed('/dashboard', arguments: userCredential.user);

      Get.snackbar(
        "Login",
        "Successfully Logged In",
        backgroundColor: Colors.yellowAccent,
        icon: Icon(Icons.done, size: 25),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        Get.snackbar(
          "User not found",
          "Enter correct email",
          backgroundColor: Colors.redAccent,
        );
      } else if (e.code == 'wrong-password') {
        Get.snackbar(
          "Wrong Password",
          "Enter correct password",
          backgroundColor: Colors.redAccent,
        );
      } else {
        print("FirebaseAuth Error: ${e.message}");
        // Get.snackbar(
        //   "Error",
        //   e.message ?? "Unknown error",
        //   backgroundColor: Colors.redAccent,
        // );
      }
    } catch (ex) {
      print("Exception $ex");
      // Get.snackbar("Error", ex.toString());
    }
  }

  // Check if user is already logged in
  void _checkUserLogin() async {
   User? user = _auth.currentUser;
    if(user != null){
      print("User is already logged in: ${user.email}");
      Get.offAllNamed('/dashboard', arguments: user);
    }
  }

  @override
  void initState() {
    super.initState();
    _checkUserLogin();
    getLoggedIn(userNameController.text, passwordController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Expense Tracker", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.from(
          alpha: 1,
          red: 0.035,
          green: 0.49,
          blue: 0.58,
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Welcome Buddy!",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: const Color.from(
                        alpha: 1,
                        red: 0.035,
                        green: 0.49,
                        blue: 0.58,
                      ),
                    ),
                  ),
                  SizedBox(height: 40),
                  TextFormField(
                    controller: userNameController,
                    autofocus: true,
                    validator: (value) {
                      if (value!.isEmpty) return "Enter your mail id";
                      if (!RegExp(
                        r"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$",
                      ).hasMatch(value)) {
                        return "Enter valid email";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.email_outlined),
                      hintText: "Enter Username",
                      // errorText: "Please Enter Valid Username",
                      // errorBorder: OutlineInputBorder(
                      //   // borderSide: BorderSide(color: Colors.red),
                      // ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    autofocus: true,
                    validator: (value) {
                      if (value!.isEmpty) return "Enter Password";
                      return null;
                    },
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.remove_red_eye_outlined),
                      hintText: "Enter Password",
                      // errorText: "Please Enter Valid Password",
                      // errorBorder: OutlineInputBorder(
                      //   // borderSide: BorderSide(color: Colors.red),
                      // ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(height: 55),
                  InkWell(
                    onTap: () {
                      if (_formKey.currentState!.validate()) {
                        getLoggedIn(
                          userNameController.text.trim(),
                          passwordController.text.trim(),
                        );
                      }
                    },
                    child: Container(
                      height: 57,
                      decoration: BoxDecoration(
                        color: Color.from(
                          alpha: 1,
                          red: 0.035,
                          green: 0.49,
                          blue: 0.58,
                        ),
                        border: Border.all(),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          "LogIn",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "I'm new User",
                        style: TextStyle(
                          // fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(width: 28),
                      InkWell(
                        onTap: () {
                          // GetX
                          Get.toNamed('/signIn');
                        },
                        child: Text(
                          "SignUp",
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 21,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
