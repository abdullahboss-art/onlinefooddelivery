import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:myapp/User_Panel/home.dart';

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({super.key});

  // ============================================================
  // GET USER ORDERS
  // ============================================================

  Stream<QuerySnapshot> getOrders() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Stream.empty();
    }

    return FirebaseFirestore.instance
        .collection("orders")
        .where(
          "userId",
          isEqualTo: user.uid,
        )
        .snapshots();
  }

  // ============================================================
  // STATUS COLOR
  // ============================================================

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

  // ============================================================
  // STATUS TEXT
  // ============================================================

  String statusText(String status) {
    switch (status) {
      case "Pending":
        return "Waiting for restaurant confirmation";

      case "Accepted":
        return "Order accepted by restaurant";

      case "Preparing":
        return "Your food is being prepared";

      case "Out For Delivery":
        return "Rider is on the way";

      case "Delivered":
        return "Order delivered 🎉";

      case "Cancelled":
        return "Order has been cancelled";

      default:
        return "";
    }
  }

  // ============================================================
  // SAVE DELIVERED ORDER FOR AI CHAT
  // ============================================================

  Future<void> saveDeliveredOrderForChat(
    String orderId,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setBool(
        "delivered_order_chat_pending",
        true,
      );

      await prefs.setString(
        "delivered_order_id",
        orderId,
      );
    } catch (e) {
      debugPrint(
        "Failed to save delivered order notification: $e",
      );
    }
  }

  // ============================================================
  // CHECK DELIVERED ORDERS
  // ============================================================

  Future<void> checkDeliveredOrders() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) return;

      final snapshot = await FirebaseFirestore.instance
          .collection("orders")
          .where(
            "userId",
            isEqualTo: user.uid,
          )
          .where(
            "status",
            isEqualTo: "Delivered",
          )
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return;

      final prefs = await SharedPreferences.getInstance();

      final alreadyPending =
          prefs.getBool(
                "delivered_order_chat_pending",
              ) ??
              false;

      if (alreadyPending) {
        return;
      }

      final orderId = snapshot.docs.first.id;

      await saveDeliveredOrderForChat(orderId);
    } catch (e) {
      debugPrint(
        "Delivered order check failed: $e",
      );
    }
  }

  // ============================================================
  // CANCEL ORDER
  // ============================================================

  Future<void> cancelOrder(
    BuildContext context,
    String orderId,
    String status,
  ) async {
    if (status != "Pending" && status != "Accepted") {
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xff1A1A1A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.red,
              ),
              SizedBox(width: 8),
              Text(
                "Cancel Order",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: const Text(
            "Are you sure you want to cancel this order?",
            style: TextStyle(
              color: Colors.white70,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text(
                "No",
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();

                try {
                  await FirebaseFirestore.instance
                      .collection("orders")
                      .doc(orderId)
                      .update({
                    "status": "Cancelled",
                  });

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Order cancelled successfully",
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Failed to cancel order: $e",
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text(
                "Yes, Cancel",
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // GO TO HOME
  // ============================================================

  Future<void> goToHome(
    BuildContext context,
  ) async {
    // Check if any order has been delivered.
    await checkDeliveredOrders();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const HomePage(),
      ),
      (route) => false,
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.person_off_rounded,
                color: Colors.white54,
                size: 55,
              ),
              const SizedBox(height: 15),
              const Text(
                "Please login first",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  goToHome(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                ),
                child: const Text("Go Home"),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () {
            goToHome(context);
          },
        ),

        title: const Text(
          "My Orders",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // ========================================================
      // ORDERS
      // ========================================================

      body: StreamBuilder<QuerySnapshot>(
        stream: getOrders(),
        builder: (context, snapshot) {
          // ======================================================
          // LOADING
          // ======================================================

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.amber,
              ),
            );
          }

          // ======================================================
          // ERROR
          // ======================================================

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: Text(
                  "Something went wrong.\n${snapshot.error}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.redAccent,
                  ),
                ),
              ),
            );
          }

          // ======================================================
          // NO ORDERS
          // ======================================================

          if (!snapshot.hasData ||
              snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.receipt_long_rounded,
                    size: 70,
                    color: Colors.white24,
                  ),

                  const SizedBox(height: 15),

                  const Text(
                    "No Orders Found",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "Your orders will appear here",
                    style: TextStyle(
                      color: Colors.white54,
                    ),
                  ),

                  const SizedBox(height: 25),

                  ElevatedButton.icon(
                    onPressed: () {
                      goToHome(context);
                    },
                    icon: const Icon(
                      Icons.home_rounded,
                    ),
                    label: const Text(
                      "Go Home",
                    ),
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.amber,
                      foregroundColor:
                          Colors.black,
                    ),
                  ),
                ],
              ),
            );
          }

          // ======================================================
          // DOCUMENTS
          // ======================================================

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(
              12,
              12,
              12,
              30,
            ),
            itemCount: docs.length,
            itemBuilder: (
              context,
              index,
            ) {
              final data =
                  docs[index].data()
                      as Map<String, dynamic>;

              final String status =
                  data["status"] ?? "Pending";

              final dynamic total =
                  data["totalAmount"] ?? 0;

              final String orderId =
                  docs[index].id;

              // ==================================================
              // ORDER ID
              // ==================================================

              final String shortOrderId =
                  orderId.length >= 6
                      ? orderId.substring(0, 6)
                      : orderId;

              // ==================================================
              // DELIVERED ORDER
              // ==================================================

              if (status == "Delivered") {
                WidgetsBinding.instance
                    .addPostFrameCallback((_) {
                  saveDeliveredOrderForChat(
                    orderId,
                  );
                });
              }

              return Container(
                margin:
                    const EdgeInsets.only(
                  bottom: 14,
                ),

                padding:
                    const EdgeInsets.all(16),

                decoration:
                    BoxDecoration(
                  color:
                      const Color(0xff171717),
                  borderRadius:
                      BorderRadius.circular(18),

                  border: Border.all(
                    color: Colors.white
                        .withOpacity(0.06),
                  ),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withOpacity(0.3),
                      blurRadius: 10,
                      offset:
                          const Offset(0, 5),
                    ),
                  ],
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    // ==================================================
                    // ORDER HEADER
                    // ==================================================

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding:
                                  const EdgeInsets
                                      .all(9),
                              decoration:
                                  BoxDecoration(
                                color: Colors
                                    .amber
                                    .withOpacity(
                                  0.12,
                                ),
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  10,
                                ),
                              ),
                              child:
                                  const Icon(
                                Icons
                                    .receipt_long_rounded,
                                color:
                                    Colors.amber,
                                size: 20,
                              ),
                            ),

                            const SizedBox(
                              width: 10,
                            ),

                            Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              children: [
                                const Text(
                                  "Order",
                                  style:
                                      TextStyle(
                                    color: Colors
                                        .white54,
                                    fontSize: 11,
                                  ),
                                ),

                                Text(
                                  "#$shortOrderId",
                                  style:
                                      const TextStyle(
                                    color:
                                        Colors.white,
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        // STATUS
                        Container(
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal: 11,
                            vertical: 6,
                          ),
                          decoration:
                              BoxDecoration(
                            color: statusColor(
                                    status)
                                .withOpacity(
                              0.15,
                            ),
                            borderRadius:
                                BorderRadius
                                    .circular(
                              20,
                            ),
                            border:
                                Border.all(
                              color:
                                  statusColor(
                                status,
                              ).withOpacity(
                                0.4,
                              ),
                            ),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              color:
                                  statusColor(
                                status,
                              ),
                              fontSize: 11,
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 18,
                    ),

                    // ==================================================
                    // TOTAL
                    // ==================================================

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,
                      children: [
                        const Text(
                          "Total Amount",
                          style:
                              TextStyle(
                            color:
                                Colors.white54,
                            fontSize: 12,
                          ),
                        ),

                        Text(
                          "Rs $total",
                          style:
                              const TextStyle(
                            color:
                                Colors.amber,
                            fontSize: 18,
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    // ==================================================
                    // STATUS MESSAGE
                    // ==================================================

                    Row(
                      children: [
                        Icon(
                          status ==
                                  "Delivered"
                              ? Icons
                                  .check_circle
                              : status ==
                                      "Cancelled"
                                  ? Icons.cancel
                                  : Icons
                                      .info_outline,
                          color:
                              statusColor(
                            status,
                          ),
                          size: 17,
                        ),

                        const SizedBox(
                          width: 7,
                        ),

                        Expanded(
                          child: Text(
                            statusText(
                              status,
                            ),
                            style:
                                const TextStyle(
                              color:
                                  Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // ==================================================
                    // CANCEL BUTTON
                    // ==================================================

                    if (status == "Pending" ||
                        status == "Accepted") ...[
                      const SizedBox(
                        height: 15,
                      ),

                      SizedBox(
                        width:
                            double.infinity,
                        child:
                            ElevatedButton
                                .icon(
                          onPressed: () {
                            cancelOrder(
                              context,
                              orderId,
                              status,
                            );
                          },
                          icon:
                              const Icon(
                            Icons
                                .close_rounded,
                            size: 18,
                          ),
                          label:
                              const Text(
                            "Cancel Order",
                            style:
                                TextStyle(
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),
                          style:
                              ElevatedButton
                                  .styleFrom(
                            backgroundColor:
                                Colors.red,
                            foregroundColor:
                                Colors.white,
                            padding:
                                const EdgeInsets
                                    .symmetric(
                              vertical: 12,
                            ),
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                12,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],

                    // ==================================================
                    // PREPARING / DELIVERY
                    // ==================================================

                    if (status ==
                            "Preparing" ||
                        status ==
                            "Out For Delivery") ...[
                      const SizedBox(
                        height: 15,
                      ),

                      Container(
                        width:
                            double.infinity,
                        padding:
                            const EdgeInsets
                                .all(11),
                        decoration:
                            BoxDecoration(
                          color: Colors.white
                              .withOpacity(
                            0.04,
                          ),
                          borderRadius:
                              BorderRadius
                                  .circular(
                            10,
                          ),
                        ),
                        child:
                            const Text(
                          "You cannot cancel after preparation has started.",
                          textAlign:
                              TextAlign.center,
                          style:
                              TextStyle(
                            color:
                                Colors.white38,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],

                    // ==================================================
                    // DELIVERED
                    // ==================================================

                    if (status ==
                        "Delivered") ...[
                      const SizedBox(
                        height: 15,
                      ),

                      Container(
                        width:
                            double.infinity,
                        padding:
                            const EdgeInsets
                                .all(11),
                        decoration:
                            BoxDecoration(
                          color: Colors.green
                              .withOpacity(
                            0.08,
                          ),
                          borderRadius:
                              BorderRadius
                                  .circular(
                            10,
                          ),
                        ),
                        child:
                            const Text(
                          "Order completed successfully 🎉",
                          textAlign:
                              TextAlign.center,
                          style:
                              TextStyle(
                            color:
                                Colors.green,
                            fontWeight:
                                FontWeight
                                    .bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],

                    // ==================================================
                    // CANCELLED
                    // ==================================================

                    if (status ==
                        "Cancelled") ...[
                      const SizedBox(
                        height: 15,
                      ),

                      Container(
                        width:
                            double.infinity,
                        padding:
                            const EdgeInsets
                                .all(11),
                        decoration:
                            BoxDecoration(
                          color: Colors.red
                              .withOpacity(
                            0.07,
                          ),
                          borderRadius:
                              BorderRadius
                                  .circular(
                            10,
                          ),
                        ),
                        child:
                            const Text(
                          "This order has been cancelled.",
                          textAlign:
                              TextAlign.center,
                          style:
                              TextStyle(
                            color: Colors
                                .redAccent,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}