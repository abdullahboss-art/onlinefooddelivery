import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    final foodId = widget.food["id"]?.toString() ?? "";
    _isFavorite = _favManager.isFavorite(foodId);
    print("📱 ViewDetailPage loaded - Food: ${widget.food["name"]}, Is Favorite: $_isFavorite");
  }

  void _toggleFavorite() {
    final foodId = widget.food["id"]?.toString() ?? "";
    
    setState(() {
      _favManager.toggle(foodId);
      _isFavorite = _favManager.isFavorite(foodId);
      print("❤️ Toggled favorite - Food: ${widget.food["name"]}, Now: $_isFavorite");
      _favManager.printFavorites(); // Debug print
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isFavorite ? "✅ Added to favorites" : "❌ Removed from favorites",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: _isFavorite ? Colors.green : Colors.red,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _shareFood() {
    final String name = widget.food["name"]?.toString() ?? "Food Item";
    final String emoji = widget.food["emoji"]?.toString() ?? "🍔";
    final String price = widget.food["price"]?.toString() ?? "0";
    final String description = widget.food["description"]?.toString() ??
        "Delicious food prepared with premium ingredients.";
    
    final String shareMessage = '''
🍽️ Check out this delicious food!

$emoji $name
💰 Price: \$$price
📝 $description

Order now from our app! 🚀
    ''';
    
    Share.share(
      shareMessage,
      subject: 'Check out $name',
    );
  }

  @override
  Widget build(BuildContext context) {
    final String name = widget.food["name"]?.toString() ?? "Food Item";
    final String emoji = widget.food["emoji"]?.toString() ?? "🍔";
    final String description = widget.food["description"]?.toString() ??
        "Delicious food prepared with premium ingredients.";
    final String price = widget.food["price"]?.toString() ?? "0";
    final String rating = widget.food["rating"]?.toString() ?? "0";
    final String reviews = widget.food["reviews"]?.toString() ?? "0";

    return Scaffold(
      body: Column(
        children: [
          Stack(
            children: [
              Container(
                height: 350,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xffFF9800),
                      Color(0xffA85D00),
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: _toggleFavorite,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: _isFavorite ? Colors.red : Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: _shareFood,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.share,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
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
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        emoji,
                        style: const TextStyle(fontSize: 100),
                      ),
                    ),
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          "\$$price",
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xffFF9800),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Color(0xFFFFC107),
                          size: 18,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          rating,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          "($reviews reviews)",
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      "Description",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      description,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 30),

                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.share,
                            color: Color(0xffFF9800),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: const Text(
                              "Share this food with friends",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: _shareFood,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xffFF9800),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                "Share",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xffFF9800),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
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
    );
  }
}