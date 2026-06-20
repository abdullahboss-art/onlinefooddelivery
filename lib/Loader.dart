import 'dart:async';
import 'package:flutter/material.dart';
import 'GetStartedPage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() =>
      _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  double progress = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    timer = Timer.periodic(
      const Duration(milliseconds: 40),
      (timer) {
        setState(() {
          progress++;
        });

        if (progress >= 100) {
          timer.cancel();

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const GetStartedPage(),
            ),
          );
        }
      },
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Color getProgressColor() {
    if (progress <= 33) {
      return Colors.red;
    } else if (progress <= 66) {
      return Colors.yellow;
    } else {
      return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          /// BACKGROUND
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0B0B0B),
                  Color(0xFF111111),
                  Color(0xFF1A1A1A),
                ],
              ),
            ),
          ),

          /// OVERLAY
          Container(
            color: Colors.black.withOpacity(0.2),
          ),

          /// CONTENT
          Center(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                /// ANIMATED LOGO
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    double scale =
                        1 + (_controller.value * 0.12);

                    return Transform.scale(
                      scale: scale,
                      child: child,
                    );
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber
                              .withOpacity(0.5),
                          blurRadius: 25,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Image.asset(
                      "images/assets/QuickBiteLogo.png",
                      height: 130,
                      width: 130,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                /// APP NAME
                const Text(
                  "QUICKBITE",
                  style: TextStyle(
                    color: Color(0xFFFFD700),
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),

                const SizedBox(height: 10),

                /// TAGLINE
                const Text(
                  "Fast Food Delivery",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 50),

                /// LOADER WITH LOGO
                SizedBox(
                  width: 180,
                  height: 180,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      /// PROGRESS CIRCLE
                      SizedBox(
                        width: 180,
                        height: 180,
                        child:
                            CircularProgressIndicator(
                          value: progress / 100,
                          strokeWidth: 10,
                          backgroundColor:
                              Colors.white24,
                          valueColor:
                              AlwaysStoppedAnimation<
                                  Color>(
                            getProgressColor(),
                          ),
                        ),
                      ),

                      /// LOGO INSIDE LOADER
                      ClipOval(
                        child: Image.asset(
                          "images/assets/QuickBiteLogo.png",
                          width: 140,
                          height: 140,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                /// PERCENTAGE
                Text(
                  "${progress.toInt()}%",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                /// LOADING TEXT
                Text(
                  progress < 30
                      ? "Loading Menu..."
                      : progress < 60
                          ? "Preparing Orders..."
                          : progress < 90
                              ? "Almost Ready..."
                              : "Welcome!",
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),

          /// FOOTER
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "Powered By Abdullah",
                style: TextStyle(
                  color: Colors.white
                      .withOpacity(0.9),
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}