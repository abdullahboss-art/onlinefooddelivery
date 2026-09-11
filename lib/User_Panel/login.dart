
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:flutter/foundation.dart';
import 'package:myapp/User_Panel/ButtomNav.dart';
import 'package:myapp/User_Panel/Signup.dart';

class _AlomanColors {
  static const accent = Color(0xFFF6C51A); // yellow button
  static const fieldFill = Color(0x66141414); // translucent dark field
  static const fieldBorder = Color(0x33FFFFFF);
  static const textSecondary = Colors.white70;
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  bool loading = false;
  bool googleLoading = false;
  bool obscurePassword = true;
  bool _googleInitialized = false;

  @override
  void initState() {
    super.initState();
    // ✅ Initialize once when the page loads (v7+ requires this before
    // calling signOut()/authenticate() on GoogleSignIn.instance).
    _initGoogleSignIn();
  }

  Future<void> _initGoogleSignIn() async {
    try {
      await _googleSignIn.initialize(
        clientId:
            "588713164437-jm1mes4sacabv34fbmm6sevaeo4ktuji.apps.googleusercontent.com",
      );
      _googleInitialized = true;
    } catch (e) {
      debugPrint("GoogleSignIn init error: $e");
    }
  }

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
          backgroundColor: const Color(0xFF1B1B1B),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isSuccess ? Icons.check_circle : Icons.error,
                    color: isSuccess ? _AlomanColors.accent : Colors.redAccent,
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
                    color: _AlomanColors.accent,
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
                foregroundColor: _AlomanColors.accent,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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

  Future<void> loginUser() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() => loading = true);

      final userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final user = userCredential.user;
      final displayName =
          user?.displayName ?? emailController.text.trim().split('@')[0];

      setState(() => loading = false);

      if (mounted) {
        showAlertDialog(
          title: "Welcome Back!",
          message: "Login successful! 🎉",
          isSuccess: true,
          userName: "Welcome $displayName",
        );
      }
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

      if (mounted) {
        showAlertDialog(
          title: "Login Failed",
          message: errorMessage,
          isSuccess: false,
        );
      }
    } catch (e) {
      setState(() => loading = false);
      if (mounted) {
        showAlertDialog(
          title: "Error",
          message: "Something went wrong.\nPlease try again later.",
          isSuccess: false,
        );
      }
    }
  }

  // ✅ GOOGLE SIGN-IN — fixed order: initialize() BEFORE signOut()/authenticate()
  Future<void> signInWithGoogle() async {
    try {
      setState(() => googleLoading = true);

      // Flutter Web
      if (kIsWeb) {
        GoogleAuthProvider provider = GoogleAuthProvider();

        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithPopup(provider);

        User? user = userCredential.user;

        setState(() => googleLoading = false);

        if (!mounted) return;

        showAlertDialog(
          title: "Welcome Back!",
          message: "Successfully signed in with Google 🎉",
          isSuccess: true,
          userName: user?.displayName ?? user?.email ?? "User",
        );

        return;
      }

      // Android / iOS
      if (!_googleInitialized) {
        await _initGoogleSignIn();
      }

      await _googleSignIn.signOut();

      final GoogleSignInAccount googleUser =
          await _googleSignIn.authenticate();

      final GoogleSignInAuthentication googleAuth =
          googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      User? user = userCredential.user;

      setState(() => googleLoading = false);

      if (!mounted) return;

      showAlertDialog(
        title: "Welcome Back!",
        message: "Successfully signed in with Google 🎉",
        isSuccess: true,
        userName: user?.displayName ?? user?.email ?? "User",
      );
    } on FirebaseAuthException catch (e) {
      setState(() => googleLoading = false);

      showAlertDialog(
        title: "Google Sign-In Failed",
        message: e.message ?? e.code,
        isSuccess: false,
      );
    } catch (e) {
      setState(() => googleLoading = false);

      showAlertDialog(
        title: "Google Sign-In Failed",
        message: e.toString(),
        isSuccess: false,
      );
    }
  }

  // ✅ Forgot password — matches the "Forgot Password?" link in the design.
  Future<void> _handleForgotPassword() async {
    final controller = TextEditingController(text: emailController.text);

    final email = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1B1B1B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Reset Password",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Enter your email",
            hintStyle: const TextStyle(color: Colors.white54),
            filled: true,
            fillColor: Colors.black26,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel", style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text("Send Link",
                style: TextStyle(color: _AlomanColors.accent)),
          ),
        ],
      ),
    );

    if (email == null || email.trim().isEmpty) return;

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
      if (!mounted) return;
      showAlertDialog(
        title: "Email Sent",
        message: "A password reset link has been sent to $email.",
        isSuccess: true,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      showAlertDialog(
        title: "Reset Failed",
        message: e.message ?? "Could not send reset email.",
        isSuccess: false,
      );
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white60),
      prefixIcon: Icon(icon, color: Colors.white70, size: 20),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: _AlomanColors.fieldFill,
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _AlomanColors.fieldBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _AlomanColors.fieldBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _AlomanColors.accent, width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ---- Full-screen background image ----
          Image.asset(
            'images/assets/Splash.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // Fallback gradient if the image asset isn't found.
              return Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF2A2018), Color(0xFF0E0B08)],
                  ),
                ),
              );
            },
          ),

          // ---- Dark overlay so text stays readable ----
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.55),
                  Colors.black.withOpacity(0.35),
                  Colors.black.withOpacity(0.75),
                ],
                stops: const [0.0, 0.45, 1.0],
              ),
            ),
          ),

          // ---- Foreground content ----
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 8),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 60),

                        const Text(
                          "Welcome Back",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 40),

                        TextFormField(
                          controller: emailController,
                          style: const TextStyle(color: Colors.white),
                          decoration: _fieldDecoration(
                            hint: "Email",
                            icon: Icons.mail_outline,
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
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: passwordController,
                          obscureText: obscurePassword,
                          style: const TextStyle(color: Colors.white),
                          decoration: _fieldDecoration(
                            hint: "Password",
                            icon: Icons.lock_outline,
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: Colors.white70,
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() {
                                  obscurePassword = !obscurePassword;
                                });
                              },
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
                        const SizedBox(height: 6),

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _handleForgotPassword,
                            child: const Text(
                              "Forgot Password?",
                              style: TextStyle(
                                  color: _AlomanColors.textSecondary,
                                  fontSize: 13),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        SizedBox(
                          height: 55,
                          child: ElevatedButton(
                            onPressed: loading ? null : loginUser,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _AlomanColors.accent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            child: loading
                                ? const CircularProgressIndicator(
                                    color: Colors.black)
                                : const Text(
                                    "LOGIN",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        SizedBox(
                          height: 52,
                          child: OutlinedButton(
                            onPressed: googleLoading ? null : signInWithGoogle,
                            style: OutlinedButton.styleFrom(
                              backgroundColor: _AlomanColors.fieldFill,
                              side: const BorderSide(
                                color: _AlomanColors.fieldBorder,
                                width: 1,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: googleLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                      color: _AlomanColors.accent,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'images/assets/Google_logo.png',
                                        width: 20,
                                        height: 20,
                                        fit: BoxFit.contain,
                                        errorBuilder: (context, error, stackTrace) {
                                          return const Text(
                                            'G',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: _AlomanColors.accent,
                                            ),
                                          );
                                        },
                                      ),
                                      const SizedBox(width: 12),
                                      const Text(
                                        "Continue with Google",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        Center(
                          child: TextButton(
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
                                color: _AlomanColors.accent,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
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
