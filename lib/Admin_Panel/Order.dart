import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          centerTitle: true,
          title: const Text(
            "All Orders",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Column(
          children: const [
            TabBar(
              indicatorColor: Colors.amber,
              labelColor: Colors.amber,
              unselectedLabelColor: Colors.grey,
              tabs: [
                Tab(text: "All"),
                Tab(text: "Pending"),
                Tab(text: "Delivered"),
                Tab(text: "Cancelled"),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  OrdersList(status: "All"),
                  OrdersList(status: "Pending"),
                  OrdersList(status: "Delivered"),
                  OrdersList(status: "Cancelled"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OrdersList extends StatelessWidget {
  final String status;

  const OrdersList({super.key, required this.status});

  Stream<QuerySnapshot> getOrders() {
    if (status == "All") {
      return FirebaseFirestore.instance
          .collection("orders")
          .orderBy("createdAt", descending: true)
          .snapshots();
    }

    return FirebaseFirestore.instance
        .collection("orders")
        .where("status", isEqualTo: status)
        .snapshots();
  }

  Color getStatusColor(String status) {
    switch (status) {
      case "Pending":
        return Colors.orange;
      case "Delivered":
        return Colors.green;
      case "Cancelled":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // 🔥 UPDATE STATUS FUNCTION
  Future<void> updateStatus(String docId, String newStatus) async {
    await FirebaseFirestore.instance
        .collection("orders")
        .doc(docId)
        .update({
      "status": newStatus,
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: getOrders(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              "No Orders Found",
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        var docs = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            var order = docs[index].data() as Map<String, dynamic>;

            String customer = order['customerName'] ?? "Unknown";
            String orderStatus = order['status'] ?? "Pending";
            double amount = (order['totalAmount'] ?? 0).toDouble();
            String orderId = order['orderId']?.toString() ??
                docs[index].id.substring(0, 6);

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xff1A1A1A),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Order #$orderId",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              customer,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: getStatusColor(orderStatus),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              orderStatus,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "\$${amount.toStringAsFixed(2)}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // 🔥 ADMIN ACTION BUTTONS
                  if (orderStatus == "Pending")
                    Row(
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          onPressed: () {
                            updateStatus(docs[index].id, "Delivered");
                          },
                          child: const Text("Mark Delivered"),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          onPressed: () {
                            updateStatus(docs[index].id, "Cancelled");
                          },
                          child: const Text("Cancel"),
                        ),
                      ],
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}