import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'food_detail_page.dart';
import 'cart_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home.dart';  // ✅ Home page import

class CategoriesPage extends StatefulWidget {
  final String? initialCategory;

  const CategoriesPage({super.key, this.initialCategory});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  String _search = '';
  late String _selectedCategory;

  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = [
    'All',
    'Burger',
    'Pizza',
    'Broast',
    'Drinks',
    'Desserts',
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory ?? 'All';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int _getDiscount(String? id) {
    final n = int.tryParse(id ?? '') ?? (id?.hashCode ?? 0);
    final mod = n.abs() % 3;
    if (mod == 0) return 20;
    if (mod == 1) return 10;
    return 0;
  }

  Future<void> addToCart(Map<String, dynamic> food) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please login first"),
          ),
        );
        return;
      }

      final cartRef = FirebaseFirestore.instance.collection("cart");

      final existing = await cartRef
          .where("userId", isEqualTo: user.uid)
          .where("name", isEqualTo: food["name"])
          .get();

      if (existing.docs.isNotEmpty) {
        final doc = existing.docs.first;

        int currentQty = (doc["quantity"] ?? 1) as int;

        await doc.reference.update({
          "quantity": currentQty + 1,
        });
      } else {
        await cartRef.add({
          "userId": user.uid,
          "name": food["name"] ?? "",
          "price": double.tryParse(food["price"].toString()) ?? 0,
          "image": food["image"] ?? "",
          "category": food["category"] ?? "",
          "quantity": 1,
          "createdAt": FieldValue.serverTimestamp(),
        });
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.green,
          content: Text("${food["name"]} added to cart"),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(e.toString()),
        ),
      );
    }
  }

  Widget _foodTile(Map<String, dynamic> food) {
    final discount = _getDiscount(food["id"]?.toString());
    final rating = double.tryParse(food["rating"]?.toString() ?? "") ?? 0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FoodDetailPage(food: food),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    food["image"] ?? "",
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 70,
                      height: 70,
                      color: const Color(0xFF2A2A2A),
                      child: const Icon(Icons.fastfood,
                          color: Colors.white54),
                    ),
                  ),
                ),
                if (discount > 0)
                  Positioned(
                    top: 4,
                    left: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        "-$discount%",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food["name"] ?? "",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (rating > 0)
                    Row(
                      children: [
                        const Icon(Icons.star,
                            color: Color(0xFFFFC107), size: 13),
                        const SizedBox(width: 3),
                        Text(
                          rating.toStringAsFixed(1),
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  const SizedBox(height: 4),
                  Text(
                    "Rs ${food["price"]}",
                    style: const TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            InkWell(
              onTap: () => addToCart(food),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.add, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            // ✅ Back Button - Home Page pe navigate karega
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const HomePage(),  // ✅ Home page
              ),
            );
          },
        ),
        title: const Text(
          "Categories",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("cart")
                .where(
                  "userId",
                  isEqualTo: FirebaseAuth.instance.currentUser?.uid,
                )
                .snapshots(),
            builder: (context, snapshot) {
              int cartCount = 0;

              if (snapshot.hasData && snapshot.data != null) {
                for (var doc in snapshot.data!.docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  cartCount += ((data["quantity"] ?? 1) as num).toInt();
                }
              }

              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.shopping_cart,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CartPage(),
                        ),
                      );
                    },
                  ),
                  if (cartCount > 0)
                    Positioned(
                      right: 5,
                      top: 5,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          cartCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xff101010), Color(0xff1B1B1B)],
          ),
        ),
        child: SafeArea(
          child: StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance.collection("foods").snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child:
                      CircularProgressIndicator(color: Color(0xFFFFC107)),
                );
              }

              final allFoods = snapshot.data!.docs;

              final foods = allFoods.where((doc) {
                final data = doc.data() as Map<String, dynamic>;

                final name = (data["name"] ?? "").toString().toLowerCase();
                final category =
                    (data["category"] ?? "").toString().toLowerCase();

                final matchesSearch = name.contains(_search);
                final matchesCategory = _selectedCategory == "All"
                    ? true
                    : category == _selectedCategory.toLowerCase();

                return matchesSearch && matchesCategory;
              }).toList();

              return Row(
                children: [
                  // LEFT CATEGORY
                  Container(
                    width: 90,
                    padding: const EdgeInsets.only(top: 10),
                    child: ListView.builder(
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        final isSelected = category == _selectedCategory;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCategory = category;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.all(6),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.amber
                                  : const Color(0xFF1E1E1E),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: Colors.amber
                                            .withOpacity(0.35),
                                        blurRadius: 10,
                                        spreadRadius: 1,
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Center(
                              child: Text(
                                category,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.black
                                      : Colors.white,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // RIGHT SIDE
                  Expanded(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (value) {
                              setState(() {
                                _search = value.toLowerCase();
                              });
                            },
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: "Search food...",
                              hintStyle:
                                  const TextStyle(color: Colors.white54),
                              prefixIcon: const Icon(Icons.search,
                                  color: Colors.white),
                              filled: true,
                              fillColor: const Color(0xFF1E1E1E),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),

                        Expanded(
                          child: foods.isEmpty
                              ? Center(
                                  child: Text(
                                    "No food items found",
                                    style: TextStyle(
                                        color: Colors.grey.shade500),
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  itemCount: foods.length,
                                  itemBuilder: (context, index) {
                                    final data = foods[index].data()
                                        as Map<String, dynamic>;
                                    data["id"] = foods[index].id;
                                    return _foodTile(data);
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}