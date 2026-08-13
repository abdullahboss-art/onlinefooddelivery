import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'orders_page.dart';
import 'favorites_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final User? user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    createUserIfNotExists();
  }

  // ---------------- CREATE USER DOC ----------------
  Future<void> createUserIfNotExists() async {
    final doc = firestore.collection("users").doc(user!.uid);
    final snapshot = await doc.get();

    if (!snapshot.exists) {
      await doc.set({
        "name": user?.displayName ?? "User",
        "address": "",
        "payment": "Cash on Delivery",
        "email": user?.email ?? "",
      });
    }
  }

  // ---------------- UPDATE ADDRESS ONLY ----------------
  Future<void> updateAddress(String address) async {
    await firestore.collection("users").doc(user!.uid).set({
      "address": address,
    }, SetOptions(merge: true));
  }

  // ---------------- UPDATE PAYMENT ----------------
  Future<void> updatePayment(String payment) async {
    await firestore.collection("users").doc(user!.uid).set({
      "payment": payment,
    }, SetOptions(merge: true));
  }

  // ---------------- MENU TILE ----------------
  Widget menuTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        trailing: const Icon(Icons.arrow_forward_ios,
            color: Colors.white54, size: 16),
        onTap: onTap,
      ),
    );
  }

  // ---------------- ADDRESS EDIT ----------------
  void showAddress(String current) {
    final controller = TextEditingController(text: current);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Address"),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              updateAddress(controller.text.trim());
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  // ---------------- PAYMENT (PRO STYLE) ----------------
  void showPayment() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text("Cash on Delivery"),
              onTap: () {
                updatePayment("Cash on Delivery");
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text("EasyPaisa"),
              onTap: () {
                updatePayment("EasyPaisa");
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text("JazzCash"),
              onTap: () {
                updatePayment("JazzCash");
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  // ---------------- SETTINGS ----------------
  void showSettings() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Settings"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text("🔔 Notifications"),
            Text("🌙 Dark Mode"),
            Text("🔐 Change Password"),
            Text("🌍 Language"),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close")),
        ],
      ),
    );
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("No User Found")),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: firestore.collection("users").doc(user!.uid).snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.hasData && snapshot.data!.data() != null
            ? snapshot.data!.data() as Map<String, dynamic>
            : {};

        final name = data["name"] ?? "User";
        final email = user!.email ?? "";
        final address = data["address"] ?? "No Address";
        final payment = data["payment"] ?? "Cash on Delivery";
        final photo = user!.photoURL;

        return Scaffold(
          backgroundColor: const Color(0xff0E0E0E),
          appBar: AppBar(
            backgroundColor: const Color(0xff0E0E0E),
            title: const Text("My Profile"),
          ),

          body: SingleChildScrollView(
            child: Column(
              children: [

                const SizedBox(height: 20),

                // PROFILE CARD
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 15),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade900,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 35,
                        backgroundImage:
                            (photo != null && photo.isNotEmpty)
                                ? NetworkImage(photo)
                                : null,
                        child: photo == null
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                          Text(email,
                              style: const TextStyle(color: Colors.white70)),
                        ],
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                menuTile(
                  icon: Icons.location_on,
                  title: "My Address",
                  onTap: () => showAddress(address),
                ),

                menuTile(
                  icon: Icons.payment,
                  title: "Payment Methods",
                  onTap: showPayment,
                ),

                menuTile(
                  icon: Icons.shopping_bag,
                  title: "My Orders",
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const MyOrdersScreen()),
                  ),
                ),

                menuTile(
                  icon: Icons.favorite,
                  title: "My Favorites",
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const FavoritesPage()),
                  ),
                ),

                menuTile(
                  icon: Icons.settings,
                  title: "Settings",
                  onTap: showSettings,
                ),

                const SizedBox(height: 20),

                // LOGOUT
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 15),
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.all(14),
                    ),
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      if (mounted) Navigator.pop(context);
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text("Logout"),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }
}