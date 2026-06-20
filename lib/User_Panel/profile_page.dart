import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  final user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // UPDATE NAME
  void updateName(String name) async {
    await user!.updateDisplayName(name);
    await firestore.collection("users").doc(user!.uid).set({
      "name": name,
    }, SetOptions(merge: true));
  }

  // UPDATE ADDRESS
  void updateAddress(String address) async {
    await firestore.collection("users").doc(user!.uid).set({
      "address": address,
    }, SetOptions(merge: true));
  }

  // UPDATE PAYMENT
  void updatePayment(String payment) async {
    await firestore.collection("users").doc(user!.uid).set({
      "payment": payment,
    }, SetOptions(merge: true));
  }

  void showEditName(String current) {
    final controller = TextEditingController(text: current);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Name"),
        content: TextField(controller: controller),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              updateName(controller.text);
              setState(() {});
              Navigator.pop(context);
            },
            child: const Text("Save"),
          )
        ],
      ),
    );
  }

  void showAddress() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Address"),
        content: TextField(controller: controller),
        actions: [
          ElevatedButton(
            onPressed: () {
              updateAddress(controller.text);
              Navigator.pop(context);
            },
            child: const Text("Save"),
          )
        ],
      ),
    );
  }

  void showPayment() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Payment Method"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: "Cash / Card / EasyPaisa",
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              updatePayment(controller.text);
              Navigator.pop(context);
            },
            child: const Text("Save"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: firestore.collection("users").doc(user!.uid).snapshots(),
      builder: (context, snapshot) {

        final data = snapshot.data?.data() as Map<String, dynamic>? ?? {};

        final name = user?.displayName ?? data["name"] ?? "User";
        final email = user?.email ?? "";
        final address = data["address"] ?? "No Address";
        final payment = data["payment"] ?? "Not Set";

        return Scaffold(
          backgroundColor: const Color(0xFF121212),

          appBar: AppBar(
            backgroundColor: const Color(0xFF121212),
            title: const Text("Profile"),
          ),

          body: SingleChildScrollView(
            child: Column(
              children: [

                const SizedBox(height: 20),

                // NAME
                Text(
                  name,
                  style: const TextStyle(color: Colors.white, fontSize: 22),
                ),

                Text(email, style: const TextStyle(color: Colors.grey)),

                const SizedBox(height: 20),

                // EDIT NAME
                ListTile(
                  leading: const Icon(Icons.edit, color: Colors.yellow),
                  title: const Text("Edit Name", style: TextStyle(color: Colors.white)),
                  onTap: () => showEditName(name),
                ),

                // ADDRESS
                ListTile(
                  leading: const Icon(Icons.location_on, color: Colors.yellow),
                  title: Text(address, style: const TextStyle(color: Colors.white)),
                  subtitle: const Text("Tap to edit", style: TextStyle(color: Colors.grey)),
                  onTap: showAddress,
                ),

                // PAYMENT
                ListTile(
                  leading: const Icon(Icons.payment, color: Colors.yellow),
                  title: Text(payment, style: const TextStyle(color: Colors.white)),
                  subtitle: const Text("Tap to edit", style: TextStyle(color: Colors.grey)),
                  onTap: showPayment,
                ),

                const SizedBox(height: 30),

                // LOGOUT
                ElevatedButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pop(context);
                  },
                  child: const Text("Logout"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}