import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {

  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool loading = false;

  bool passwordVisible = false;
  bool confirmPasswordVisible = false;

  // Custom Alert Dialog Function
  void showAlertDialog(String title, String message, {bool isSuccess = false}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.grey.shade900,
          title: Row(
            children: [
              Icon(
                isSuccess ? Icons.check_circle : Icons.error,
                color: isSuccess ? Colors.green : Colors.red,
                size: 30,
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (isSuccess) {
                  // Navigate back to login page after success
                  Navigator.pop(context);
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.amber,
              ),
              child: const Text(
                "OK",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> signupUser() async {

    if (!formKey.currentState!.validate()) {
      return;
    }

    try {
      setState(() {
        loading = true;
      });

      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Success Alert Dialog
      showAlertDialog(
        "Success!",
        "Account created successfully! Welcome aboard 🎉",
        isSuccess: true,
      );

    } on FirebaseAuthException catch (e) {
      setState(() {
        loading = false;
      });
      
      String errorMessage = "";
      
      // Handle different Firebase Auth errors
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = "This email is already registered. Please login instead.";
          break;
        case 'weak-password':
          errorMessage = "Password is too weak. Please use a stronger password.";
          break;
        case 'invalid-email':
          errorMessage = "Email address is not valid.";
          break;
        case 'operation-not-allowed':
          errorMessage = "Email/password accounts are not enabled.";
          break;
        default:
          errorMessage = e.message ?? "Signup failed. Please try again.";
      }
      
      // Error Alert Dialog
      showAlertDialog(
        "Signup Failed",
        errorMessage,
        isSuccess: false,
      );
      
    } catch (e) {
      setState(() {
        loading = false;
      });
      
      // Generic Error Alert Dialog
      showAlertDialog(
        "Error",
        "Something went wrong. Please try again later.",
        isSuccess: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.black,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Form(
            key: formKey,

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                const SizedBox(height: 50),

                const Icon(
                  Icons.fastfood,
                  color: Colors.amber,
                  size: 80,
                ),

                const SizedBox(height: 20),

                const Text(
                  "Create Account",
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  "Signup to continue",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 40),

                /// NAME
                TextFormField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.white),

                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your name";
                    }

                    if (value.length < 3) {
                      return "Name must be at least 3 characters";
                    }

                    return null;
                  },

                  decoration: InputDecoration(
                    hintText: "Name",
                    hintStyle: const TextStyle(color: Colors.grey),

                    prefixIcon: const Icon(
                      Icons.person,
                      color: Colors.amber,
                    ),

                    filled: true,
                    fillColor: Colors.grey.shade900,

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// EMAIL
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.white),

                  validator: (value) {

                    if (value == null || value.isEmpty) {
                      return "Please enter email";
                    }

                    if (!value.contains("@") || !value.contains(".")) {
                      return "Enter valid email";
                    }

                    return null;
                  },

                  decoration: InputDecoration(
                    hintText: "Email",
                    hintStyle: const TextStyle(color: Colors.grey),

                    prefixIcon: const Icon(
                      Icons.email,
                      color: Colors.amber,
                    ),

                    filled: true,
                    fillColor: Colors.grey.shade900,

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// PASSWORD
                TextFormField(
                  controller: passwordController,
                  obscureText: !passwordVisible,
                  style: const TextStyle(color: Colors.white),

                  validator: (value) {

                    if (value == null || value.isEmpty) {
                      return "Please enter password";
                    }

                    if (value.length < 6) {
                      return "Password must be at least 6 characters";
                    }

                    return null;
                  },

                  decoration: InputDecoration(
                    hintText: "Password",
                    hintStyle: const TextStyle(color: Colors.grey),

                    prefixIcon: const Icon(
                      Icons.lock,
                      color: Colors.amber,
                    ),

                    suffixIcon: IconButton(
                      icon: Icon(
                        passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.amber,
                      ),

                      onPressed: () {
                        setState(() {
                          passwordVisible = !passwordVisible;
                        });
                      },
                    ),

                    filled: true,
                    fillColor: Colors.grey.shade900,

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// CONFIRM PASSWORD
                TextFormField(
                  controller: confirmPasswordController,
                  obscureText: !confirmPasswordVisible,
                  style: const TextStyle(color: Colors.white),

                  validator: (value) {

                    if (value == null || value.isEmpty) {
                      return "Confirm your password";
                    }

                    if (value != passwordController.text) {
                      return "Password does not match";
                    }

                    return null;
                  },

                  decoration: InputDecoration(
                    hintText: "Confirm Password",
                    hintStyle: const TextStyle(color: Colors.grey),

                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: Colors.amber,
                    ),

                    suffixIcon: IconButton(
                      icon: Icon(
                        confirmPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.amber,
                      ),

                      onPressed: () {
                        setState(() {
                          confirmPasswordVisible =
                          !confirmPasswordVisible;
                        });
                      },
                    ),

                    filled: true,
                    fillColor: Colors.grey.shade900,

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 35),

                /// SIGNUP BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 55,

                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),

                    onPressed: loading ? null : signupUser,

                    child: loading
                        ? const CircularProgressIndicator(
                            color: Colors.black,
                          )
                        : const Text(
                            "Signup",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 25),

                /// ALREADY ACCOUNT
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    const Text(
                      "Already have an account?",
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),

                    TextButton(
                      onPressed: () {

                        /// Login Page Open
                        Navigator.pop(context);

                      },

                      child: const Text(
                        "Login",
                        style: TextStyle(
                          color: Colors.amber,
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
      ),
    );
  }
}