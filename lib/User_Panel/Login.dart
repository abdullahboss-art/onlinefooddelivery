import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/User_Panel/Signup.dart';
import 'package:myapp/User_Panel/ButtomNav.dart';
import 'package:myapp/User_Panel/home.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;
  bool obscurePassword = true;

  // Custom Alert Dialog Function - IMPROVED VERSION
  void showAlertDialog({
    required String title,
    required String message,
    bool isSuccess = false,
    String? userName,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.grey.shade900,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isSuccess ? Icons.check_circle : Icons.error,
                    color: isSuccess ? Colors.green : Colors.red,
                    size: 30,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ],
              ),
              if (userName != null) ...[
                const SizedBox(height: 8),
                Text(
                  userName,
                  style: const TextStyle(
                    color: Colors.amber,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (isSuccess) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const ButtomBar()),
                  );
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.amber,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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

  // ================= EMAIL LOGIN =================

  Future<void> loginUser() async {

    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() => loading = true);

      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final user = userCredential.user;
      final displayName = user?.displayName ?? emailController.text.trim().split('@')[0];

      // Success Alert Dialog with user name
      showAlertDialog(
        title: "Welcome Back!",
        message: "Login successful! 🎉",
        isSuccess: true,
        userName: "Welcome $displayName",
      );

    } on FirebaseAuthException catch (e) {
      setState(() => loading = false);
      
      String errorMessage = "";
      
      switch (e.code) {
        case 'user-not-found':
          errorMessage = "No account found with this email.\nPlease sign up first.";
          break;
        case 'wrong-password':
          errorMessage = "Incorrect password.\nPlease try again.";
          break;
        case 'invalid-email':
          errorMessage = "Email address is not valid.";
          break;
        case 'user-disabled':
          errorMessage = "This account has been disabled.\nPlease contact support.";
          break;
        case 'too-many-requests':
          errorMessage = "Too many failed attempts.\nPlease try again later.";
          break;
        default:
          errorMessage = e.message ?? "Login failed. Please try again.";
      }
      
      showAlertDialog(
        title: "Login Failed",
        message: errorMessage,
        isSuccess: false,
      );

    } catch (e) {
      setState(() => loading = false);
      
      showAlertDialog(
        title: "Error",
        message: "Something went wrong.\nPlease try again later.",
        isSuccess: false,
      );
    }
  }

  // ================= GOOGLE LOGIN =================

  Future<void> signInWithGoogle() async {

    try {
      setState(() => loading = true);

      final GoogleAuthProvider provider = GoogleAuthProvider();

      provider.setCustomParameters({
        'prompt': 'select_account',
      });

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithPopup(provider);

      final user = userCredential.user;
      final displayName = user?.displayName ?? "User";

      print("LOGIN SUCCESS: ${user?.email}");

      // Success Alert Dialog with user name
      showAlertDialog(
        title: "Welcome Back!",
        message: "Successfully signed in with Google! 🎉",
        isSuccess: true,
        userName: "Welcome $displayName",
      );

    } catch (e) {
      setState(() => loading = false);
      
      String errorMessage = "";
      
      if (e.toString().contains("popup-closed-by-user")) {
        errorMessage = "Google sign-in was cancelled.\nPlease try again.";
      } else if (e.toString().contains("network-error")) {
        errorMessage = "Network error.\nPlease check your connection.";
      } else {
        errorMessage = "Google sign-in failed.\nPlease try again.";
      }
      
      showAlertDialog(
        title: "Google Sign-In Failed",
        message: errorMessage,
        isSuccess: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.black,

      body: Stack(
        children: [

          SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: Image.network(
              "https://images.unsplash.com/photo-1495474472287-4d71bcdd2085",
              fit: BoxFit.cover,
            ),
          ),

          Container(
            color: Colors.black.withOpacity(0.78),
          ),

          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),

                child: Form(
                  key: _formKey,

                  child: Column(
                    children: [

                      const SizedBox(height: 100),

                      const Text(
                        "Welcome Back",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 45),

                      TextFormField(
                        controller: emailController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Email",
                          hintStyle: const TextStyle(color: Colors.white54),
                          prefixIcon: const Icon(Icons.email, color: Colors.amber),
                          filled: true,
                          fillColor: Colors.grey.shade900,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter email";
                          }
                          if (!value.contains("@")) {
                            return "Enter valid email";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      TextFormField(
                        controller: passwordController,
                        obscureText: obscurePassword,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Password",
                          hintStyle: const TextStyle(color: Colors.white54),
                          prefixIcon: const Icon(Icons.lock, color: Colors.amber),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.amber,
                            ),
                            onPressed: () {
                              setState(() {
                                obscurePassword = !obscurePassword;
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
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter password";
                          }
                          if (value.length < 6) {
                            return "Password must be at least 6 characters";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 25),

                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: loading ? null : loginUser,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: loading
                              ? const CircularProgressIndicator(
                                  color: Colors.black,
                                )
                              : const Text(
                                  "LOGIN",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      GestureDetector(
                        onTap: signInWithGoogle,
                        child: Container(
                          width: double.infinity,
                          height: 55,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade900,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.g_mobiledata,
                                  size: 35, color: Colors.amber),
                              SizedBox(width: 10),
                              Text(
                                "Continue with Google",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SignupPage(),
                            ),
                          );
                        },
                        child: const Text(
                          "Create Account",
                          style: TextStyle(
                            color: Colors.amber,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}