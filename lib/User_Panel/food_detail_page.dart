// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';

// class FoodDetailPage extends StatefulWidget {
//   final Map<String, dynamic>? food;

//   const FoodDetailPage({super.key, this.food});

//   @override
//   State<FoodDetailPage> createState() => _FoodDetailPageState();
// }

// class _FoodDetailPageState extends State<FoodDetailPage> {
//   int _qty = 1;

//   Map<String, dynamic> get food => widget.food ?? {};

//   Future<void> addToCart() async {
//     final cartRef = FirebaseFirestore.instance.collection("cart");

//     final existing = await cartRef
//         .where("name", isEqualTo: food["name"])
//         .get();

//     if (existing.docs.isNotEmpty) {
//       final doc = existing.docs.first;

//       int currentQty = doc["quantity"] ?? 1;

//       await doc.reference.update({
//         "quantity": currentQty + _qty,
//       });
//     } else {
//       await cartRef.add({
//         "name": food["name"] ?? "",
//         "price": double.tryParse(food["price"].toString()) ?? 0,
//         "image": food["image"] ?? "",
//         "category": food["category"] ?? "",
//         "quantity": _qty,
//         "createdAt": FieldValue.serverTimestamp(),
//       });
//     }

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         backgroundColor: Colors.green,
//         content: Text("${food["name"]} added to cart"),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final String name = food["name"] ?? "";
//     final String image = food["image"] ?? "";
//     final String description = food["description"] ?? "";
//     final double price =
//         double.tryParse(food["price"].toString()) ?? 0;

//     return Scaffold(
//       backgroundColor: const Color(0xFF121212),

//       body: Stack(
//         children: [
//           Column(
//             children: [
//               Container(
//                 height: 300,
//                 width: double.infinity,
//                 color: const Color(0xFF1E1E1E),
//                 child: image.isNotEmpty
//                     ? Image.network(image, fit: BoxFit.cover)
//                     : const Icon(Icons.fastfood,
//                         size: 100, color: Colors.white),
//               ),

//               Expanded(
//                 child: Padding(
//                   padding: const EdgeInsets.all(20),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         name,
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 24,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),

//                       const SizedBox(height: 10),

//                       Text(
//                         "Rs ${price.toStringAsFixed(0)}",
//                         style: const TextStyle(
//                           color: Colors.amber,
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),

//                       const SizedBox(height: 10),

//                       Text(
//                         description,
//                         style: const TextStyle(
//                           color: Colors.white70,
//                         ),
//                       ),

//                       const SizedBox(height: 20),

//                       Row(
//                         mainAxisAlignment:
//                             MainAxisAlignment.spaceBetween,
//                         children: [
//                           const Text(
//                             "Quantity",
//                             style: TextStyle(color: Colors.white),
//                           ),

//                           Row(
//                             children: [
//                               IconButton(
//                                 onPressed: () {
//                                   setState(() {
//                                     if (_qty > 1) _qty--;
//                                   });
//                                 },
//                                 icon: const Icon(Icons.remove,
//                                     color: Colors.white),
//                               ),
//                               Text(
//                                 "$_qty",
//                                 style: const TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 18),
//                               ),
//                               IconButton(
//                                 onPressed: () {
//                                   setState(() {
//                                     _qty++;
//                                   });
//                                 },
//                                 icon: const Icon(Icons.add,
//                                     color: Colors.amber),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),

//           Positioned(
//             top: MediaQuery.of(context).padding.top + 10,
//             left: 10,
//             child: IconButton(
//               icon: const Icon(Icons.arrow_back,
//                   color: Colors.white),
//               onPressed: () => Navigator.pop(context),
//             ),
//           ),

//           Positioned(
//             bottom: 0,
//             left: 0,
//             right: 0,
//             child: Container(
//               padding: const EdgeInsets.all(20),
//               decoration: const BoxDecoration(
//                 color: Color(0xFF1A1A1A),
//                 borderRadius:
//                     BorderRadius.vertical(top: Radius.circular(20)),
//               ),
//               child: Row(
//                 mainAxisAlignment:
//                     MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     "Total: Rs ${(price * _qty).toStringAsFixed(0)}",
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),

//                   ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.amber,
//                     ),
//                     onPressed: addToCart,
//                     child: const Text(
//                       "Add to Cart",
//                       style: TextStyle(color: Colors.black),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


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
  }

  Widget _foodVisual(String image, String emoji) {
    if (image.isNotEmpty) {
      return Image.network(
        image,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFFFC107)),
          );
        },
        errorBuilder: (_, __, ___) => Center(
          child: Text(
            emoji.isNotEmpty ? emoji : '🍽️',
            style: const TextStyle(fontSize: 100),
          ),
        ),
      );
    }
    return Center(
      child: Hero(
        tag: 'food_${food["id"] ?? food["name"]}',
        child: Text(
          emoji.isNotEmpty ? emoji : '🍽️',
          style: const TextStyle(fontSize: 100),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String name = food["name"] ?? "";
    final String image = food["image"] ?? "";
    final String emoji = food["emoji"] ?? "";
    final String description = food["description"] ?? "";
    final double price =
        double.tryParse(food["price"].toString()) ?? 0;
    final double rating =
        double.tryParse(food["rating"]?.toString() ?? "") ?? 0;
    final String reviews = food["reviews"]?.toString() ?? "";

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xff101010), Color(0xff1B1B1B)],
          ),
        ),
        child: Stack(
          children: [
            Column(
              children: [
                Container(
                  height: 300,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(28),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _foodVisual(image, emoji),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
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
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (rating > 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E1E1E),
                                    borderRadius:
                                        BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.star,
                                          color: Color(0xFFFFC107),
                                          size: 14),
                                      const SizedBox(width: 4),
                                      Text(
                                        rating.toStringAsFixed(1),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (reviews.isNotEmpty) ...[
                                        const SizedBox(width: 4),
                                        Text(
                                          "($reviews)",
                                          style: TextStyle(
                                            color: Colors.grey.shade500,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                            ],
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

                          const SizedBox(height: 14),

                          const Text(
                            "Description",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            description,
                            style: const TextStyle(
                              color: Colors.white70,
                              height: 1.5,
                            ),
                          ),

                          const SizedBox(height: 24),

                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E1E1E),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Quantity",
                                  style: TextStyle(color: Colors.white),
                                ),
                                Row(
                                  children: [
                                    _qtyButton(
                                      icon: Icons.remove,
                                      onTap: () {
                                        setState(() {
                                          if (_qty > 1) _qty--;
                                        });
                                      },
                                    ),
                                    SizedBox(
                                      width: 36,
                                      child: Text(
                                        "$_qty",
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    _qtyButton(
                                      icon: Icons.add,
                                      color: Colors.amber,
                                      onTap: () {
                                        setState(() {
                                          _qty++;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // extra bottom padding so content doesn't hide
                          // behind the fixed bottom bar
                          const SizedBox(height: 110),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              left: 10,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.black45,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),

            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                decoration: const BoxDecoration(
                  color: Color(0xFF1A1A1A),
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black38,
                      blurRadius: 12,
                      offset: Offset(0, -4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Total",
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          "Rs ${(price * _qty).toStringAsFixed(0)}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 28, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: addToCart,
                      child: const Text(
                        "Add to Cart",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _qtyButton({
    required IconData icon,
    required VoidCallback onTap,
    Color color = Colors.white,
  }) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, color: color, size: 20),
    );
  }
}