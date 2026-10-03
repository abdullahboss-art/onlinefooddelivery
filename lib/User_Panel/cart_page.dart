import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'Checkout.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartPage extends StatelessWidget {
  final String? deliveryAddress;

  const CartPage({
    super.key,
    this.deliveryAddress,
  });

  // ============================================================
  // SAFE HELPERS
  // ============================================================

  double _safeDouble(dynamic value) {
    return double.tryParse(value.toString()) ?? 0;
  }

  int _safeInt(dynamic value) {
    return int.tryParse(value.toString()) ?? 1;
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF101010),
      extendBodyBehindAppBar: true,

      // ==========================================================
      // APP BAR
      // ==========================================================

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Text(
          "My Cart",
          style: TextStyle(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // ==========================================================
      // BODY
      // ==========================================================

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0D0D0D),
              Color(0xFF171717),
              Color(0xFF101010),
            ],
          ),
        ),

        child: SafeArea(
          child: user == null
              ? _buildLoginRequired()
              : StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("cart")
                      .where(
                        "userId",
                        isEqualTo: user.uid,
                      )
                      .snapshots(),

                  builder: (context, snapshot) {
                    // =================================================
                    // LOADING
                    // =================================================

                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Color(0xFFFFC107),
                        ),
                      );
                    }

                    // =================================================
                    // ERROR
                    // =================================================

                    if (snapshot.hasError) {
                      return _buildError();
                    }

                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Color(0xFFFFC107),
                        ),
                      );
                    }

                    final docs = snapshot.data!.docs;

                    // =================================================
                    // EMPTY CART
                    // =================================================

                    if (docs.isEmpty) {
                      return _buildEmptyCart(context);
                    }

                    // =================================================
                    // CALCULATE TOTAL
                    // =================================================

                    double total = 0;

                    for (final doc in docs) {
                      final price = _safeDouble(doc["price"]);
                      final qty = _safeInt(doc["quantity"]);

                      total += price * qty;
                    }

                    // =================================================
                    // CART UI
                    // =================================================

                    return Column(
                      children: [
                        const SizedBox(height: 55),

                        // Small cart info
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                          ),
                          child: Row(
                            children: [
                              Text(
                                "${docs.length} ${docs.length == 1 ? "item" : "items"}",
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 13,
                                ),
                              ),

                              const Spacer(),

                              const Icon(
                                Icons.shopping_bag_outlined,
                                color: Colors.amber,
                                size: 18,
                              ),

                              const SizedBox(width: 6),

                              Text(
                                "QuickBite",
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 8),

                        // =================================================
                        // ITEMS
                        // =================================================

                        Expanded(
                          child: ListView.builder(
                            physics: const BouncingScrollPhysics(),

                            padding: const EdgeInsets.fromLTRB(
                              16,
                              8,
                              16,
                              20,
                            ),

                            itemCount: docs.length,

                            itemBuilder: (context, index) {
                              final item = docs[index];

                              final price =
                                  _safeDouble(item["price"]);

                              final qty =
                                  _safeInt(item["quantity"]);

                              final data =
                                  item.data()
                                      as Map<String, dynamic>;

                              final image =
                                  data["image"] ?? "";

                              final name =
                                  data["name"] ?? "Food Item";

                              final itemTotal =
                                  price * qty;

                              return _buildCartItem(
                                context: context,
                                item: item,
                                name: name.toString(),
                                image: image.toString(),
                                price: price,
                                qty: qty,
                                itemTotal: itemTotal,
                              );
                            },
                          ),
                        ),

                        // =================================================
                        // BOTTOM CHECKOUT PANEL
                        // =================================================

                        _buildBottomCheckout(
                          context: context,
                          total: total,
                        ),
                      ],
                    );
                  },
                ),
        ),
      ),
    );
  }

  // ============================================================
  // CART ITEM
  // ============================================================

  Widget _buildCartItem({
    required BuildContext context,
    required QueryDocumentSnapshot item,
    required String name,
    required String image,
    required double price,
    required int qty,
    required double itemTotal,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),

      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(
        color: const Color(0xFF1B1B1B),

        borderRadius: BorderRadius.circular(18),

        border: Border.all(
          color: Colors.white.withOpacity(0.055),
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,

        children: [
          // ==========================================================
          // IMAGE
          // ==========================================================

          Container(
            width: 68,
            height: 68,

            decoration: BoxDecoration(
              color: const Color(0xFF292929),
              borderRadius: BorderRadius.circular(15),
            ),

            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),

              child: image.isNotEmpty
                  ? Image.network(
                      image,
                      fit: BoxFit.cover,

                      loadingBuilder:
                          (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        }

                        return const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.amber,
                            ),
                          ),
                        );
                      },

                      errorBuilder: (_, __, ___) {
                        return const Icon(
                          Icons.fastfood_rounded,
                          color: Colors.white38,
                          size: 28,
                        );
                      },
                    )
                  : const Icon(
                      Icons.fastfood_rounded,
                      color: Colors.white38,
                      size: 28,
                    ),
            ),
          ),

          const SizedBox(width: 13),

          // ==========================================================
          // NAME + PRICE
          // ==========================================================

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  name,

                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,

                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  "Rs ${price.toStringAsFixed(0)}",

                  style: const TextStyle(
                    color: Colors.amber,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  "Subtotal: Rs ${itemTotal.toStringAsFixed(0)}",

                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // ==========================================================
          // QUANTITY
          // ==========================================================

          Container(
            height: 38,

            decoration: BoxDecoration(
              color: const Color(0xFF292929),
              borderRadius: BorderRadius.circular(12),

              border: Border.all(
                color: Colors.white.withOpacity(0.06),
              ),
            ),

            child: Row(
              mainAxisSize: MainAxisSize.min,

              children: [
                // MINUS
                InkWell(
                  borderRadius: BorderRadius.circular(10),

                  onTap: () async {
                    if (qty > 1) {
                      await item.reference.update({
                        "quantity": qty - 1,
                      });
                    } else {
                      await item.reference.delete();
                    }
                  },

                  child: const SizedBox(
                    width: 34,
                    height: 38,

                    child: Icon(
                      Icons.remove,
                      color: Colors.white70,
                      size: 17,
                    ),
                  ),
                ),

                // NUMBER
                Container(
                  constraints: const BoxConstraints(
                    minWidth: 25,
                  ),

                  alignment: Alignment.center,

                  child: Text(
                    "$qty",

                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // PLUS
                InkWell(
                  borderRadius: BorderRadius.circular(10),

                  onTap: () async {
                    await item.reference.update({
                      "quantity": qty + 1,
                    });
                  },

                  child: const SizedBox(
                    width: 34,
                    height: 38,

                    child: Icon(
                      Icons.add,
                      color: Colors.amber,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BOTTOM CHECKOUT
  // ============================================================

  Widget _buildBottomCheckout({
    required BuildContext context,
    required double total,
  }) {
    final hasAddress =
        deliveryAddress != null &&
        deliveryAddress!.trim().isNotEmpty;

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.fromLTRB(
        18,
        16,
        18,
        18,
      ),

      decoration: BoxDecoration(
        color: const Color(0xFF1B1B1B),

        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(26),
        ),

        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.06),
          ),
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),

      child: Column(
        children: [
          // ==========================================================
          // ADDRESS
          // ==========================================================

          if (hasAddress)
            Container(
              width: double.infinity,

              margin: const EdgeInsets.only(
                bottom: 14,
              ),

              padding: const EdgeInsets.all(13),

              decoration: BoxDecoration(
                color: const Color(0xFF242424),

                borderRadius: BorderRadius.circular(15),

                border: Border.all(
                  color: Colors.amber.withOpacity(0.15),
                ),
              ),

              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Container(
                    width: 34,
                    height: 34,

                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.10),
                      borderRadius:
                          BorderRadius.circular(10),
                    ),

                    child: const Icon(
                      Icons.location_on_rounded,
                      color: Colors.amber,
                      size: 19,
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [
                        const Text(
                          "Delivery Address",
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          deliveryAddress!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,

                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // ==========================================================
          // TOTAL ROW
          // ==========================================================

          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,

            children: [
              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  const Text(
                    "Total Amount",
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),

                  const SizedBox(height: 3),

                  const Text(
                    "Including all selected items",
                    style: TextStyle(
                      color: Colors.white24,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),

              Text(
                "Rs ${total.toStringAsFixed(2)}",

                style: const TextStyle(
                  color: Colors.amber,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          // ==========================================================
          // CHECKOUT BUTTON
          // ==========================================================

          SizedBox(
            width: double.infinity,
            height: 53,

            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,

                foregroundColor: Colors.black,

                elevation: 0,

                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(16),
                ),
              ),

              onPressed: () async {
                final result = await Navigator.push(
                  context,

                  MaterialPageRoute(
                    builder: (_) => CheckoutPage(
                      total: total,

                      // AI chatbot se address
                      deliveryAddress:
                          deliveryAddress,
                    ),
                  ),
                );

                // ====================================================
                // ORDER SUCCESS
                // ====================================================

                if (result == true &&
                    context.mounted) {
                  Navigator.pop(
                    context,
                    true,
                  );
                }
              },

              child: const Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,

                children: [
                  Icon(
                    Icons.lock_outline_rounded,
                    size: 18,
                  ),

                  SizedBox(width: 8),

                  Text(
                    "Proceed To Checkout",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  SizedBox(width: 6),

                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 19,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EMPTY CART
  // ============================================================

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),

        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            Container(
              width: 105,
              height: 105,

              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.08),
                shape: BoxShape.circle,

                border: Border.all(
                  color: Colors.amber.withOpacity(0.12),
                ),
              ),

              child: const Center(
                child: Text(
                  "🛒",
                  style: TextStyle(
                    fontSize: 48,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              "Your Cart is Empty",

              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              "Looks like you haven't added\n"
              "anything to your cart yet.",

              textAlign: TextAlign.center,

              style: TextStyle(
                color: Colors.grey.shade500,
                height: 1.5,
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              height: 48,

              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  elevation: 0,

                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                  ),

                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(14),
                  ),
                ),

                onPressed: () {
                  Navigator.pop(context);
                },

                child: const Row(
                  mainAxisSize: MainAxisSize.min,

                  children: [
                    Icon(
                      Icons.restaurant_menu_rounded,
                      size: 18,
                    ),

                    SizedBox(width: 8),

                    Text(
                      "Browse Foods",
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
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

  // ============================================================
  // LOGIN REQUIRED
  // ============================================================

  Widget _buildLoginRequired() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),

        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            const Icon(
              Icons.person_outline_rounded,
              color: Colors.amber,
              size: 60,
            ),

            const SizedBox(height: 18),

            const Text(
              "Please Login First",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              "Please login to view your cart.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white54,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),

        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.redAccent,
              size: 50,
            ),

            const SizedBox(height: 15),

            const Text(
              "Something went wrong",
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              "Unable to load your cart right now.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white54,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}