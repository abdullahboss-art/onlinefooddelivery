import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'categories_page.dart';

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({super.key});

  Stream<QuerySnapshot> getOrders() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Stream.empty();
    }

    return FirebaseFirestore.instance
        .collection("orders")
        .where("userId", isEqualTo: user.uid)
        .snapshots();
  }

  Color statusColor(String status) {
    switch (status) {
      case "Pending":
        return Colors.orange;
      case "Accepted":
        return Colors.blue;
      case "Preparing":
        return Colors.deepOrange;
      case "Out For Delivery":
        return Colors.purple;
      case "Delivered":
        return Colors.green;
      case "Cancelled":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String statusText(String status) {
    switch (status) {
      case "Pending":
        return "Waiting for restaurant confirmation";
      case "Accepted":
        return "Order accepted";
      case "Preparing":
        return "Food is being prepared";
      case "Out For Delivery":
        return "Rider is on the way";
      case "Delivered":
        return "Order delivered 🎉";
      case "Cancelled":
        return "Order cancelled";
      default:
        return "";
    }
  }

  Future<void> cancelOrder(BuildContext context, String orderId, String status) async {
    if (status == "Pending" || status == "Accepted") {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: const Color(0xff1A1A1A),
            title: const Text(
              "Cancel Order",
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              "Are you sure you want to cancel this order?",
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  "No",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await FirebaseFirestore.instance
                      .collection("orders")
                      .doc(orderId)
                      .update({
                    "status": "Cancelled",
                  });
                  
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Order cancelled successfully"),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                child: const Text(
                  "Yes, Cancel",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            "Please login first",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
     leading: IconButton(
  icon: const Icon(Icons.arrow_back),
  onPressed: () {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const CategoriesPage(),
      ),
    );
  },
),
        title: const Text("My Orders"),
        actions: [
          IconButton(
            icon: const Icon(Icons.category, color: Colors.white),
            onPressed: () {
              // Categories page open karo
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CategoriesPage()),
              );
            },
            tooltip: "Go to Categories",
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: getOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.amber),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No Orders Found",
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;

              final status = data["status"] ?? "Pending";
              final total = data["totalAmount"] ?? 0;
              final orderId = docs[index].id;

              // 🔥 FIX: Material widget wrap kiya error solve karne ke liye
              return Material(
                color: Colors.transparent,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xff1A1A1A),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Order #${orderId.substring(0, 6)}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor(status),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              status,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Rs $total",
                        style: const TextStyle(
                          color: Colors.amber,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        statusText(status),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 12),

                      if (status == "Pending" || status == "Accepted")
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          onPressed: () {
                            cancelOrder(context, orderId, status);
                          },
                          child: const Text("Cancel Order"),
                        ),

                      if (status == "Preparing" || status == "Out For Delivery")
                        const Text(
                          "You cannot cancel after preparation started",
                          style: TextStyle(
                            color: Colors.white38,
                            fontSize: 11,
                          ),
                        ),

                      if (status == "Delivered")
                        const Text(
                          "Order completed 🎉",
                          style: TextStyle(
                            color: Colors.green,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}