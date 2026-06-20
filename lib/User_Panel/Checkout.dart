import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'orders_page.dart';
import 'package:url_launcher/url_launcher.dart';

class CheckoutPage extends StatefulWidget {
  final double total;

  const CheckoutPage({
    super.key,
    required this.total,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  final accountNameController = TextEditingController();
  final accountNumberController = TextEditingController();
  final bankNameController = TextEditingController();

  String payment = "Cash";
  bool loading = false;

  Future<void> openWhatsApp() async {
    const String phone = "923001234567";

    final Uri url = Uri.parse(
      "https://wa.me/$phone?text=${Uri.encodeComponent("Hello, I need help with my order.")}",
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    accountNameController.dispose();
    accountNumberController.dispose();
    bankNameController.dispose();
    super.dispose();
  }

  Future<void> placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception("User not logged in");
      }

      // GET USER CART
      final cartSnapshot = await FirebaseFirestore.instance
          .collection("cart")
          .where("userId", isEqualTo: user.uid)
          .get();

      List items = cartSnapshot.docs.map((e) {
        final data = e.data();
        return {
          "name": data["name"],
          "price": data["price"],
          "quantity": data["quantity"],
        };
      }).toList();

      // SAVE ORDER FIRST
      await FirebaseFirestore.instance.collection("orders").add({
        "userId": user.uid,
        "customerName": nameController.text.trim(),
        "phone": phoneController.text.trim(),
        "address": addressController.text.trim(),
        "paymentMethod": payment,
        "bankDetails": payment == "Bank"
            ? {
                "accountName": accountNameController.text.trim(),
                "accountNumber": accountNumberController.text.trim(),
                "bankName": bankNameController.text.trim(),
              }
            : null,
        "status": "Pending",
        "totalAmount": widget.total,
        "items": items,
        "createdAt": FieldValue.serverTimestamp(),
      });

      // CLEAR CART (BATCH DELETE)
      WriteBatch batch = FirebaseFirestore.instance.batch();
      for (var doc in cartSnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Order Placed Successfully 🎉"),
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MyOrdersScreen()),
        (route) => false,
      );

      // CLEAR FIELDS
      nameController.clear();
      phoneController.clear();
      addressController.clear();
      accountNameController.clear();
      accountNumberController.clear();
      bankNameController.clear();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  Widget buildInputField({
    required String label,
    required TextEditingController controller,
    TextInputType? type,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: const Color(0xFF1E1E1E),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        validator: validator ??
            (value) {
              if (value == null || value.trim().isEmpty) {
                return "Enter $label";
              }
              return null;
            },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        title: const Text("Checkout"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [

              // CUSTOMER INFO
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    buildInputField(label: "Full Name", controller: nameController),
                    buildInputField(label: "Phone", controller: phoneController),
                    buildInputField(label: "Address", controller: addressController),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // PAYMENT METHOD
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    RadioListTile(
                      value: "Cash",
                      groupValue: payment,
                      onChanged: (v) => setState(() => payment = v.toString()),
                      title: const Text("Cash On Delivery",
                          style: TextStyle(color: Colors.white)),
                    ),
                    RadioListTile(
                      value: "Bank",
                      groupValue: payment,
                      onChanged: (v) => setState(() => payment = v.toString()),
                      title: const Text("Bank Transfer",
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),

              // BANK FIELDS
              if (payment == "Bank") ...[
                const SizedBox(height: 10),
                buildInputField(
                    label: "Account Name",
                    controller: accountNameController),
                buildInputField(
                    label: "Account Number",
                    controller: accountNumberController),
                buildInputField(
                    label: "Bank Name",
                    controller: bankNameController),
              ],

              const SizedBox(height: 20),

              // TOTAL
              Text(
                "Total: Rs ${widget.total.toStringAsFixed(2)}",
                style: const TextStyle(color: Colors.white, fontSize: 20),
              ),

              const SizedBox(height: 20),

              // BUTTON
              ElevatedButton(
                onPressed: loading ? null : placeOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  padding: const EdgeInsets.all(16),
                ),
                child: loading
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text("Place Order"),
              ),

              const SizedBox(height: 20),

              Center(
                child: TextButton(
                  onPressed: openWhatsApp,
                  child: const Text(
                    "Need Help? WhatsApp Us",
                    style: TextStyle(color: Colors.green),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}