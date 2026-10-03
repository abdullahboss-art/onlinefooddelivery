import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/User_Panel/cart_page.dart';

import 'food_detail_page.dart';

class FoodSearchResultsPage extends StatefulWidget {
  final List<Map<String, dynamic>> foods;
  final String originalMessage;

  const FoodSearchResultsPage({
    super.key,
    required this.foods,
    required this.originalMessage,
  });

  @override
  State<FoodSearchResultsPage> createState() =>
      _FoodSearchResultsPageState();
}

class _FoodSearchResultsPageState
    extends State<FoodSearchResultsPage> {
  Future<void> addToCart(
    Map<String, dynamic> food,
  ) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please login first"),
            backgroundColor: Colors.red,
          ),
        );

        return;
      }

      final cartRef =
          FirebaseFirestore.instance.collection("cart");

      final foodName =
          (food["name"] ?? "").toString();

      final existing = await cartRef
          .where(
            "userId",
            isEqualTo: user.uid,
          )
          .where(
            "name",
            isEqualTo: foodName,
          )
          .get();

      final requestedQuantity =
          int.tryParse(
                food["_requestedQuantity"]
                        ?.toString() ??
                    "1",
              ) ??
              1;

      if (existing.docs.isNotEmpty) {
        final doc = existing.docs.first;

        final currentQuantity =
            int.tryParse(
                  doc["quantity"]
                      .toString(),
                ) ??
                1;

        await doc.reference.update({
          "quantity":
              currentQuantity +
                  requestedQuantity,
        });
      } else {
        await cartRef.add({
          "userId": user.uid,
          "name": foodName,
          "price":
              double.tryParse(
                    food["price"]
                        .toString(),
                  ) ??
                  0,
          "image":
              food["image"] ?? "",
          "category":
              food["category"] ?? "",
          "quantity":
              requestedQuantity,
          "createdAt":
              FieldValue.serverTimestamp(),
        });
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "$foodName added to cart",
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Error adding to cart: $e",
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  double getFoodPrice(
    Map<String, dynamic> food,
  ) {
    return double.tryParse(
          food["price"].toString(),
        ) ??
        0;
  }

  int getRequestedQuantity(
    Map<String, dynamic> food,
  ) {
    return int.tryParse(
          food["_requestedQuantity"]
                  ?.toString() ??
              "1",
        ) ??
        1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFF101010),

      appBar: AppBar(
        backgroundColor:
            const Color(0xFF101010),
        elevation: 0,

        title: const Text(
          "Food Results",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseAuth
                        .instance
                        .currentUser ==
                    null
                ? const Stream<
                    QuerySnapshot>.empty()
                : FirebaseFirestore
                    .instance
                    .collection("cart")
                    .where(
                      "userId",
                      isEqualTo:
                          FirebaseAuth
                              .instance
                              .currentUser!
                              .uid,
                    )
                    .snapshots(),

            builder: (
              context,
              snapshot,
            ) {
              int totalQuantity = 0;

              if (snapshot.hasData) {
                for (final doc
                    in snapshot.data!.docs) {
                  final data =
                      doc.data()
                          as Map<String, dynamic>;

                  totalQuantity +=
                      int.tryParse(
                            data["quantity"]
                                .toString(),
                          ) ??
                          0;
                }
              }

              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.shopping_cart_outlined,
                      color: Colors.amber,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const CartPage(),
                        ),
                      );
                    },
                  ),

                  if (totalQuantity > 0)
                    Positioned(
                      right: 5,
                      top: 5,
                      child: Container(
                        padding:
                            const EdgeInsets.all(
                          4,
                        ),
                        decoration:
                            const BoxDecoration(
                          color: Colors.red,
                          shape:
                              BoxShape.circle,
                        ),
                        child: Text(
                          totalQuantity
                              .toString(),
                          style:
                              const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight:
                                FontWeight.bold,
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

      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin:
                const EdgeInsets.fromLTRB(
              14,
              12,
              14,
              8,
            ),
            padding:
                const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color:
                  const Color(0xFF202020),
              borderRadius:
                  BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.auto_awesome,
                  color: Colors.amber,
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Text(
                    "Results for: ${widget.originalMessage}",
                    style:
                        const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight:
                          FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: widget.foods.isEmpty
                ? const Center(
                    child: Text(
                      "No food found.",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding:
                        const EdgeInsets.all(
                      14,
                    ),
                    itemCount:
                        widget.foods.length,
                    itemBuilder:
                        (context, index) {
                      final food =
                          widget.foods[index];

                      final name =
                          (food["name"] ?? "")
                              .toString();

                      final category =
                          (food["category"] ??
                                  "")
                              .toString();

                      final image =
                          (food["image"] ?? "")
                              .toString();

                      final price =
                          getFoodPrice(food);

                      final quantity =
                          getRequestedQuantity(
                        food,
                      );

                      return Container(
                        margin:
                            const EdgeInsets
                                .only(
                          bottom: 14,
                        ),
                        decoration:
                            BoxDecoration(
                          color:
                              const Color(
                            0xFF202020,
                          ),
                          borderRadius:
                              BorderRadius
                                  .circular(
                            18,
                          ),
                        ),
                        child: Padding(
                          padding:
                              const EdgeInsets
                                  .all(
                            12,
                          ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          FoodDetailPage(
                                        food: food,
                                      ),
                                    ),
                                  );
                                },
                                child:
                                    ClipRRect(
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    14,
                                  ),
                                  child:
                                      SizedBox(
                                    height: 190,
                                    width:
                                        double.infinity,
                                    child: image
                                            .isNotEmpty
                                        ? Image
                                            .network(
                                            image,
                                            fit: BoxFit
                                                .cover,
                                            errorBuilder:
                                                (
                                              context,
                                              error,
                                              stackTrace,
                                            ) {
                                              return Container(
                                                color:
                                                    const Color(
                                                  0xFF303030,
                                                ),
                                                child:
                                                    const Icon(
                                                  Icons
                                                      .fastfood,
                                                  color:
                                                      Colors.white54,
                                                  size:
                                                      60,
                                                ),
                                              );
                                            },
                                          )
                                        : Container(
                                            color:
                                                const Color(
                                              0xFF303030,
                                            ),
                                            child:
                                                const Icon(
                                              Icons
                                                  .fastfood,
                                              color:
                                                  Colors.white54,
                                              size:
                                                  60,
                                            ),
                                          ),
                                  ),
                                ),
                              ),

                              const SizedBox(
                                height: 12,
                              ),

                              Text(
                                name,
                                style:
                                    const TextStyle(
                                  color:
                                      Colors.white,
                                  fontSize:
                                      19,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),

                              if (category
                                  .isNotEmpty)
                                Padding(
                                  padding:
                                      const EdgeInsets
                                          .only(
                                    top: 4,
                                  ),
                                  child: Text(
                                    category,
                                    style:
                                        const TextStyle(
                                      color: Colors
                                          .white54,
                                      fontSize:
                                          13,
                                    ),
                                  ),
                                ),

                              const SizedBox(
                                height: 8,
                              ),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment
                                        .spaceBetween,
                                children: [
                                  Text(
                                    "Rs. ${price.toStringAsFixed(0)}",
                                    style:
                                        const TextStyle(
                                      color:
                                          Colors.amber,
                                      fontSize:
                                          18,
                                      fontWeight:
                                          FontWeight
                                              .bold,
                                    ),
                                  ),

                                  if (quantity >
                                      1)
                                    Container(
                                      padding:
                                          const EdgeInsets
                                              .symmetric(
                                        horizontal:
                                            10,
                                        vertical:
                                            5,
                                      ),
                                      decoration:
                                          BoxDecoration(
                                        color: Colors
                                            .amber
                                            .withOpacity(
                                          0.15,
                                        ),
                                        borderRadius:
                                            BorderRadius
                                                .circular(
                                          10,
                                        ),
                                      ),
                                      child:
                                          Text(
                                        "Requested: $quantity",
                                        style:
                                            const TextStyle(
                                          color:
                                              Colors.amber,
                                          fontSize:
                                              12,
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),

                              const SizedBox(
                                height: 12,
                              ),

                              SizedBox(
                                width:
                                    double.infinity,
                                child:
                                    ElevatedButton
                                        .icon(
                                  onPressed:
                                      () {
                                    addToCart(
                                      food,
                                    );
                                  },
                                  icon:
                                      const Icon(
                                    Icons
                                        .add_shopping_cart,
                                    color:
                                        Colors.black,
                                  ),
                                  label:
                                      const Text(
                                    "Add to Cart",
                                    style:
                                        TextStyle(
                                      color:
                                          Colors.black,
                                      fontWeight:
                                          FontWeight
                                              .bold,
                                    ),
                                  ),
                                  style:
                                      ElevatedButton
                                          .styleFrom(
                                    backgroundColor:
                                        Colors.amber,
                                    padding:
                                        const EdgeInsets
                                            .symmetric(
                                      vertical:
                                          13,
                                    ),
                                    shape:
                                        RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius
                                              .circular(
                                        13,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}