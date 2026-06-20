import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FoodDetailPage extends StatefulWidget {
  final Map<String, dynamic>? food;

  const FoodDetailPage({super.key, this.food});

  @override
  State<FoodDetailPage> createState() => _FoodDetailPageState();
}

class _FoodDetailPageState extends State<FoodDetailPage> {
  int _qty = 1;

  Map<String, dynamic> get food => widget.food ?? {};

  Future<void> addToCart() async {
    final cartRef = FirebaseFirestore.instance.collection("cart");

    final existing = await cartRef
        .where("name", isEqualTo: food["name"])
        .get();

    if (existing.docs.isNotEmpty) {
      final doc = existing.docs.first;

      int currentQty = doc["quantity"] ?? 1;

      await doc.reference.update({
        "quantity": currentQty + _qty,
      });
    } else {
      await cartRef.add({
        "name": food["name"] ?? "",
        "price": double.tryParse(food["price"].toString()) ?? 0,
        "image": food["image"] ?? "",
        "category": food["category"] ?? "",
        "quantity": _qty,
        "createdAt": FieldValue.serverTimestamp(),
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green,
        content: Text("${food["name"]} added to cart"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String name = food["name"] ?? "";
    final String image = food["image"] ?? "";
    final String description = food["description"] ?? "";
    final double price =
        double.tryParse(food["price"].toString()) ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),

      body: Stack(
        children: [
          Column(
            children: [
              Container(
                height: 300,
                width: double.infinity,
                color: const Color(0xFF1E1E1E),
                child: image.isNotEmpty
                    ? Image.network(image, fit: BoxFit.cover)
                    : const Icon(Icons.fastfood,
                        size: 100, color: Colors.white),
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        "Rs ${price.toStringAsFixed(0)}",
                        style: const TextStyle(
                          color: Colors.amber,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        description,
                        style: const TextStyle(
                          color: Colors.white70,
                        ),
                      ),

                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Quantity",
                            style: TextStyle(color: Colors.white),
                          ),

                          Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    if (_qty > 1) _qty--;
                                  });
                                },
                                icon: const Icon(Icons.remove,
                                    color: Colors.white),
                              ),
                              Text(
                                "$_qty",
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18),
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    _qty++;
                                  });
                                },
                                icon: const Icon(Icons.add,
                                    color: Colors.amber),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back,
                  color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFF1A1A1A),
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total: Rs ${(price * _qty).toStringAsFixed(0)}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                    ),
                    onPressed: addToCart,
                    child: const Text(
                      "Add to Cart",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}