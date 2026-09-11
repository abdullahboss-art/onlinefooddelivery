
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:myapp/User_Panel/ButtomNav.dart';
import 'package:myapp/User_Panel/Signup.dart';

class _AlomanColors {
  static const accent = Color(0xFFF6C51A);
  static const fieldFill = Color(0x66141414);
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

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool loading = false;
  bool googleLoading = false;
  bool obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // ============================================================
  // ALERT DIALOG
  // ============================================================

  void showAlertDialog({
    required String title,
    required String message,
    bool isSuccess = false,
    String? userName,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
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
                    color:
                        isSuccess ? _AlomanColors.accent : Colors.redAccent,
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
                Navigator.of(dialogContext).pop();

                if (isSuccess && mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ButtomBar(),
                    ),
                  );
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: _AlomanColors.accent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
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

  // ============================================================
  // EMAIL / PASSWORD LOGIN
  // ============================================================

  Future<void> loginUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      setState(() {
        loading = true;
      });

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final User? user = userCredential.user;

      final String displayName =
          user?.displayName ??
          emailController.text.trim().split('@').first;

      if (!mounted) return;

      setState(() {
        loading = false;
      });

      showAlertDialog(
        title: "Welcome Back!",
        message: "Login successful! 🎉",
        isSuccess: true,
        userName: "Welcome $displayName",
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      String errorMessage;

      switch (e.code) {
        case 'user-not-found':
          errorMessage =
              "No account found with this email.\nPlease sign up first.";
          break;

        case 'wrong-password':
          errorMessage =
              "Incorrect password.\nPlease try again.";
          break;

        case 'invalid-credential':
          errorMessage =
              "The email or password is incorrect.\nPlease try again.";
          break;

        case 'invalid-email':
          errorMessage =
              "Email address is not valid.";
          break;

        case 'user-disabled':
          errorMessage =
              "This account has been disabled.\nPlease contact support.";
          break;

        case 'too-many-requests':
          errorMessage =
              "Too many failed attempts.\nPlease try again later.";
          break;

        default:
          errorMessage =
              e.message ?? "Login failed. Please try again.";
      }

      showAlertDialog(
        title: "Login Failed",
        message: errorMessage,
        isSuccess: false,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      showAlertDialog(
        title: "Error",
        message:
            "Something went wrong.\nPlease try again later.",
        isSuccess: false,
      );
    }
  }

  // ============================================================
  // GOOGLE SIGN-IN
  // Compatible with google_sign_in 6.3.0
  // ============================================================

  Future<void> signInWithGoogle() async {
    if (googleLoading) {
      return;
    }

    try {
      setState(() {
        googleLoading = true;
      });

      // ========================================================
      // FLUTTER WEB
      // ========================================================

      if (kIsWeb) {
        final GoogleAuthProvider provider = GoogleAuthProvider();

        provider.setCustomParameters({
          'prompt': 'select_account',
        });

        final UserCredential userCredential =
            await FirebaseAuth.instance.signInWithPopup(
          provider,
        );

        final User? user = userCredential.user;

        if (!mounted) return;

        setState(() {
          googleLoading = false;
        });

        showAlertDialog(
          title: "Welcome Back!",
          message: "Successfully signed in with Google 🎉",
          isSuccess: true,
          userName:
              user?.displayName ??
              user?.email ??
              "User",
        );

        return;
      }

      // ========================================================
      // ANDROID / IOS
      // google_sign_in 6.3.0
      // ========================================================

      final GoogleSignIn googleSignIn = GoogleSignIn();

      final GoogleSignInAccount? googleUser =
          await googleSignIn.signIn();

      // User cancelled Google account selection.
      if (googleUser == null) {
        if (!mounted) return;

        setState(() {
          googleLoading = false;
        });

        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential =
          GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(
        credential,
      );

      final User? user = userCredential.user;

      if (!mounted) return;

      setState(() {
        googleLoading = false;
      });

      showAlertDialog(
        title: "Welcome Back!",
        message: "Successfully signed in with Google 🎉",
        isSuccess: true,
        userName:
            user?.displayName ??
            user?.email ??
            "User",
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      setState(() {
        googleLoading = false;
      });

      String errorMessage;

      switch (e.code) {
        case 'account-exists-with-different-credential':
          errorMessage =
              "An account already exists with the same email using a different sign-in method.";
          break;

        case 'popup-closed-by-user':
          errorMessage =
              "Google sign-in was cancelled.";
          break;

        case 'cancelled-popup-request':
          errorMessage =
              "Google sign-in was cancelled.";
          break;

        case 'operation-not-allowed':
          errorMessage =
              "Google Sign-In is not enabled in Firebase Authentication.";
          break;

        default:
          errorMessage =
              e.message ??
              "Google Sign-In failed. Please try again.";
      }

      showAlertDialog(
        title: "Google Sign-In Failed",
        message: errorMessage,
        isSuccess: false,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        googleLoading = false;
      });

      showAlertDialog(
        title: "Google Sign-In Failed",
        message:
            "Something went wrong while signing in with Google.\n\n$e",
        isSuccess: false,
      );
    }
  }

  // ============================================================
  // FORGOT PASSWORD
  // ============================================================

  Future<void> _handleForgotPassword() async {
    final TextEditingController controller =
        TextEditingController(
      text: emailController.text.trim(),
    );

    final String? email = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1B1B1B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Reset Password",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(
              color: Colors.white,
            ),
            decoration: InputDecoration(
              hintText: "Enter your email",
              hintStyle: const TextStyle(
                color: Colors.white54,
              ),
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
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text(
                "Cancel",
                style: TextStyle(
                  color: Colors.white54,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(
                  controller.text.trim(),
                );
              },
              child: const Text(
                "Send Link",
                style: TextStyle(
                  color: _AlomanColors.accent,
                ),
              ),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (email == null || email.trim().isEmpty) {
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: email.trim(),
      );

      if (!mounted) return;

      showAlertDialog(
        title: "Email Sent",
        message:
            "A password reset link has been sent to ${email.trim()}.",
        isSuccess: true,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      showAlertDialog(
        title: "Reset Failed",
        message:
            e.message ?? "Could not send reset email.",
        isSuccess: false,
      );
    } catch (e) {
      if (!mounted) return;

      showAlertDialog(
        title: "Reset Failed",
        message:
            "Something went wrong.\nPlease try again later.",
        isSuccess: false,
      );
    }
  }

  // ============================================================
  // INPUT FIELD DECORATION
  // ============================================================

  InputDecoration _fieldDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Colors.white60,
      ),
      prefixIcon: Icon(
        icon,
        color: Colors.white70,
        size: 20,
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: _AlomanColors.fieldFill,
      contentPadding: const EdgeInsets.symmetric(
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: _AlomanColors.fieldBorder,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: _AlomanColors.fieldBorder,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: _AlomanColors.accent,
          width: 1.4,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Colors.redAccent,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Colors.redAccent,
          width: 1.4,
        ),
      ),
    );
  }

  // ============================================================
  // BUILD UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ======================================================
          // BACKGROUND IMAGE
          // ======================================================

          Image.asset(
            'images/assets/Splash.png',
            fit: BoxFit.cover,
            errorBuilder: (
              context,
              error,
              stackTrace,
            ) {
              return Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF2A2018),
                      Color(0xFF0E0B08),
                    ],
                  ),
                ),
              );
            },
          ),

          // ======================================================
          // DARK OVERLAY
          // ======================================================

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
                stops: const [
                  0.0,
                  0.45,
                  1.0,
                ],
              ),
            ),
          ),

          // ======================================================
          // LOGIN CONTENT
          // ======================================================

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 26,
                  vertical: 8,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 420,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 60),

                        // ==================================================
                        // TITLE
                        // ==================================================

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

                        // ==================================================
                        // EMAIL
                        // ==================================================

                        TextFormField(
                          controller: emailController,
                          keyboardType:
                              TextInputType.emailAddress,
                          textInputAction:
                              TextInputAction.next,
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                          decoration: _fieldDecoration(
                            hint: "Email",
                            icon: Icons.mail_outline,
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return "Please enter email";
                            }

                            if (!value.contains("@")) {
                              return "Enter valid email";
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // ==================================================
                        // PASSWORD
                        // ==================================================

                        TextFormField(
                          controller: passwordController,
                          obscureText: obscurePassword,
                          textInputAction:
                              TextInputAction.done,
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                          decoration: _fieldDecoration(
                            hint: "Password",
                            icon: Icons.lock_outline,
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscurePassword
                                    ? Icons
                                        .visibility_off_outlined
                                    : Icons
                                        .visibility_outlined,
                                color: Colors.white70,
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() {
                                  obscurePassword =
                                      !obscurePassword;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty) {
                              return "Please enter password";
                            }

                            if (value.length < 6) {
                              return "Password must be at least 6 characters";
                            }

                            return null;
                          },
                          onFieldSubmitted: (_) {
                            if (!loading) {
                              loginUser();
                            }
                          },
                        ),

                        const SizedBox(height: 6),

                        // ==================================================
                        // FORGOT PASSWORD
                        // ==================================================

                        Align(
                          alignment:
                              Alignment.centerRight,
                          child: TextButton(
                            onPressed:
                                _handleForgotPassword,
                            child: const Text(
                              "Forgot Password?",
                              style: TextStyle(
                                color:
                                    _AlomanColors
                                        .textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // ==================================================
                        // LOGIN BUTTON
                        // ==================================================

                        SizedBox(
                          height: 55,
                          child: ElevatedButton(
                            onPressed:
                                loading
                                    ? null
                                    : loginUser,
                            style:
                                ElevatedButton.styleFrom(
                              backgroundColor:
                                  _AlomanColors.accent,
                              disabledBackgroundColor:
                                  _AlomanColors.accent
                                      .withOpacity(0.6),
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                  14,
                                ),
                              ),
                              elevation: 0,
                            ),
                            child: loading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child:
                                        CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.black,
                                    ),
                                  )
                                : const Text(
                                    "LOGIN",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight:
                                          FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // ==================================================
                        // GOOGLE BUTTON
                        // ==================================================

                        SizedBox(
                          height: 52,
                          child: OutlinedButton(
                            onPressed:
                                googleLoading
                                    ? null
                                    : signInWithGoogle,
                            style:
                                OutlinedButton.styleFrom(
                              backgroundColor:
                                  _AlomanColors.fieldFill,
                              side: const BorderSide(
                                color:
                                    _AlomanColors
                                        .fieldBorder,
                                width: 1,
                              ),
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                  14,
                                ),
                              ),
                            ),
                            child: googleLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child:
                                        CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                      color:
                                          _AlomanColors
                                              .accent,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment
                                            .center,
                                    children: [
                                      Image.asset(
                                        'images/assets/Google_logo.png',
                                        width: 20,
                                        height: 20,
                                        fit: BoxFit.contain,
                                        errorBuilder: (
                                          context,
                                          error,
                                          stackTrace,
                                        ) {
                                          return const Text(
                                            'G',
                                            style:
                                                TextStyle(
                                              fontSize: 20,
                                              fontWeight:
                                                  FontWeight
                                                      .bold,
                                              color:
                                                  _AlomanColors
                                                      .accent,
                                            ),
                                          );
                                        },
                                      ),
                                      const SizedBox(
                                        width: 12,
                                      ),
                                      const Text(
                                        "Continue with Google",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight:
                                              FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ==================================================
                        // CREATE ACCOUNT
                        // ==================================================

                        Center(
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const SignupPage(),
                                ),
                              );
                            },
                            child: const Text(
                              "Create Account",
                              style: TextStyle(
                                color:
                                    _AlomanColors.accent,
                                fontSize: 15,
                                fontWeight:
                                    FontWeight.bold,
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
