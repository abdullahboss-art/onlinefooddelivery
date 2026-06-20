
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'Checkout.dart';
import 'package:firebase_auth/firebase_auth.dart';
class CartPage extends StatelessWidget {
  const CartPage({super.key});

  double _safeDouble(dynamic value) {
    return double.tryParse(value.toString()) ?? 0;
  }

  int _safeInt(dynamic value) {
    return int.tryParse(value.toString()) ?? 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),

      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        title: const Text(
          "My Cart",
          style: TextStyle(color: Colors.white),
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
    .collection("cart")
    .where(
      "userId",
      isEqualTo: FirebaseAuth.instance.currentUser!.uid,
    )
    .snapshots(),
builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                "Cart Empty",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          double total = 0;

          for (var doc in docs) {
            final price = _safeDouble(doc["price"]);
            final qty = _safeInt(doc["quantity"]);

            total += price * qty;
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final item = docs[index];

                    final price = _safeDouble(item["price"]);
                    final qty = _safeInt(item["quantity"]);

                    return Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(item["image"] ?? ""),
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item["name"] ?? "",
                                  style: const TextStyle(color: Colors.white),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Rs $price",
                                  style: const TextStyle(color: Colors.amber),
                                ),
                              ],
                            ),
                          ),

                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove,
                                    color: Colors.white),
                                onPressed: () async {
                                  if (qty > 1) {
                                    await item.reference.update({
                                      "quantity": qty - 1,
                                    });
                                  } else {
                                    await item.reference.delete();
                                  }
                                },
                              ),

                              Text(
                                "$qty",
                                style: const TextStyle(color: Colors.white),
                              ),

                              IconButton(
                                icon: const Icon(Icons.add,
                                    color: Colors.amber),
                                onPressed: () async {
                                  await item.reference.update({
                                    "quantity": qty + 1,
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      "Total : Rs ${total.toStringAsFixed(2)}",
                      style: const TextStyle(
                        color: Colors.amber,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  CheckoutPage(total: total),
                            ),
                          );
                        },
                        child: const Text(
                          "Proceed To Checkout",
                          style: TextStyle(color: Colors.black),
                        ),
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