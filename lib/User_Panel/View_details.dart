

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import 'models.dart';

class ViewDetailPage extends StatefulWidget {
  final Map<String, dynamic> food;

  const ViewDetailPage({
    Key? key,
    required this.food,
  }) : super(key: key);

  @override
  State<ViewDetailPage> createState() => _ViewDetailPageState();
}

class _ViewDetailPageState extends State<ViewDetailPage> {
  late bool _isFavorite;
  final FavoritesManager _favManager = FavoritesManager();

  final ScreenshotController screenshotController =
      ScreenshotController();

  @override
  void initState() {
    super.initState();
    final foodId = widget.food["id"]?.toString() ?? "";
    _isFavorite = _favManager.isFavorite(foodId);
  }

  void _toggleFavorite() {
    final foodId = widget.food["id"]?.toString() ?? "";

    setState(() {
      _favManager.toggle(foodId);
      _isFavorite = _favManager.isFavorite(foodId);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        content: Text(
          _isFavorite
              ? "Added to favorites ❤️"
              : "Removed from favorites",
        ),
        backgroundColor:
            _isFavorite ? Colors.green : Colors.redAccent,
      ),
    );
  }

  Future<void> shareFoodCard() async {
    try {
      // WEB
      if (kIsWeb) {
        final String name =
            widget.food["name"]?.toString() ?? "Food";

        final String price =
            widget.food["price"]?.toString() ?? "0";

        final String emoji =
            widget.food["emoji"]?.toString() ?? "🍔";

        await Share.share(
          "$emoji $name\nPrice: \$$price\nOrder now from our app!",
          subject: name,
        );

        return;
      }

      // ANDROID / IOS
      final image = await screenshotController.capture(
        pixelRatio: 2,
      );

      if (image == null) return;

      final directory = await getTemporaryDirectory();

      final file = File(
        '${directory.path}/food_card.png',
      );

      await file.writeAsBytes(image);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: "Check out this delicious food!",
      );
    } catch (e) {
      debugPrint("Share Error: $e");
    }
  }

  Widget _circleButton({
    required IconData icon,
    required VoidCallback onTap,
    Color color = Colors.white,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(
          color: Color(0xff1A1A1A),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: color,
          size: 22,
        ),
      ),
    );
  }

  Widget _foodVisual(String? image, String emoji) {
    if (image != null && image.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          image,
          width: 180,
          height: 180,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Center(
            child: Text(emoji, style: const TextStyle(fontSize: 90)),
          ),
        ),
      );
    }
    return Center(
      child: Hero(
        tag: 'food_${widget.food["id"] ?? widget.food["name"]}',
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 90),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final food = widget.food;

    final String name = food["name"]?.toString() ?? "";
    final String emoji = food["emoji"]?.toString() ?? "🍔";
    final String? image = food["image"]?.toString();

    final String price =
        (food["price"] as num?)?.toStringAsFixed(2) ?? "0.00";

    final String rating =
        (food["rating"] as num?)?.toStringAsFixed(1) ?? "0.0";

    final String reviews =
        food["reviews"]?.toString() ?? "0";

    final String description =
        food["description"]?.toString() ??
            "Delicious food made with premium ingredients.";

    return Scaffold(
      backgroundColor: const Color(0xff0B0B0F),

      // ✅ SCREENSHOT WRAPPER (IMPORTANT)
      body: Screenshot(
        controller: screenshotController,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xff101010), Color(0xff1B1B1B)],
            ),
          ),
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    height: 350,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xff1A1A1A),
                          Color(0xff0B0B0F),
                        ],
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 50,
                    ),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        _circleButton(
                          icon: Icons.arrow_back,
                          onTap: () => Navigator.pop(context),
                        ),

                        Row(
                          children: [
                            _circleButton(
                              icon: _isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: _isFavorite
                                  ? Colors.red
                                  : Colors.white,
                              onTap: _toggleFavorite,
                            ),
                            const SizedBox(width: 12),

                            // ✅ SHARE IMAGE BUTTON
                            _circleButton(
                              icon: Icons.share,
                              onTap: shareFoodCard,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Positioned(
                    top: 130,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          color: const Color(0xff1A1A1A),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.withOpacity(0.15),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: _foodVisual(image, emoji),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Text(
                              "\$$price",
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        Row(
                          children: [
                            const Icon(Icons.star,
                                color: Colors.amber, size: 18),
                            const SizedBox(width: 5),
                            Text(rating,
                                style: const TextStyle(
                                    color: Colors.white)),
                            const SizedBox(width: 5),
                            Text(
                              "($reviews reviews)",
                              style:
                                  TextStyle(color: Colors.grey.shade500),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        const Text(
                          "Description",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          description,
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 40),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () =>
                                Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(15),
                              ),
                            ),
                            child: const Text(
                              "Close",
                              style: TextStyle(
                                fontSize: 16,
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
            ],
          ),
        ),
      ),
    );
  }
}