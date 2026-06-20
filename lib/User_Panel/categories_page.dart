import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'food_detail_page.dart';
import 'cart_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  String _search = '';
  String _selectedCategory = 'All';

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
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
        backgroundColor: Colors.green,
        content: Text("${food["name"]} added to cart"),
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text(e.toString()),
      ),
    );
  }
}

  Widget _foodTile(Map<String, dynamic> food) {
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
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
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
                  color: Colors.grey,
                  child: const Icon(Icons.fastfood, color: Colors.white),
                ),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food["name"] ?? "",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Rs ${food["price"]}",
                    style: const TextStyle(color: Colors.amber),
                  ),
                ],
              ),
            ),

            InkWell(
              onTap: () => addToCart(food),
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
      backgroundColor: const Color(0xFF121212),

      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        centerTitle: true,
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
                ),
              ),
            ),
        ],
      );
    },
  ),
],
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("foods").snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final allFoods = snapshot.data!.docs;

          final foods = allFoods.where((doc) {
            final data = doc.data() as Map<String, dynamic>;

            final name = (data["name"] ?? "").toString().toLowerCase();
            final category = (data["category"] ?? "").toString().toLowerCase();

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
                color: const Color(0xFF121212),
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
                      child: Container(
                        margin: const EdgeInsets.all(6),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.amber : const Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            category,
                            style: TextStyle(
                              color: isSelected ? Colors.black : Colors.white,
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
                          hintStyle: const TextStyle(color: Colors.white54),
                          prefixIcon: const Icon(Icons.search, color: Colors.white),
                          filled: true,
                          fillColor: const Color(0xFF1E1E1E),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),

                    Expanded(
                      child: ListView.builder(
                        itemCount: foods.length,
                        itemBuilder: (context, index) {
                          final data = foods[index].data() as Map<String, dynamic>;
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
    );
  }
}