import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ManageFoodsPage extends StatefulWidget {
  const ManageFoodsPage({super.key});

  @override
  State<ManageFoodsPage> createState() => _ManageFoodsPageState();
}

class _ManageFoodsPageState extends State<ManageFoodsPage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  String searchText = "";
  String selectedCategory = "Burger";

  /// ================= DIALOG =================
  void showFoodDialog({
    String? docId,
    String? oldName,
    String? oldPrice,
    String? oldImage,
    String? oldCategory,
  }) {
    nameController.text = oldName ?? "";
    priceController.text = oldPrice ?? "";

    final TextEditingController imageController =
        TextEditingController(text: oldImage ?? "");

    selectedCategory = oldCategory ?? "Burger";

    bool isEdit = docId != null;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialog) {
            return Dialog(
              backgroundColor: const Color(0xff111111),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isEdit ? "Edit Food" : "Add Food",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 15),

                      /// IMAGE
                      TextField(
                        controller: imageController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          prefixIcon:
                              Icon(Icons.image, color: Colors.amber),
                          hintText: "Image URL",
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                      ),

                      const SizedBox(height: 10),

                      /// PREVIEW
                      Container(
                        height: 140,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xff1A1A1A),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: imageController.text.isEmpty
                            ? const Icon(Icons.image,
                                color: Colors.grey, size: 50)
                            : Image.network(
                                imageController.text,
                                fit: BoxFit.cover,
                              ),
                      ),

                      const SizedBox(height: 10),

                      /// NAME
                      TextField(
                        controller: nameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: "Food Name",
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                      ),

                      const SizedBox(height: 10),

                      /// PRICE
                      TextField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: "Price",
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                      ),

                      const SizedBox(height: 10),

                      /// CATEGORY
                      DropdownButtonFormField<String>(
                        value: selectedCategory,
                        dropdownColor: const Color(0xff1A1A1A),
                        items: [
                          "Burger",
                          "Pizza",
                          "Broast",
                          "Drinks",
                          "Desserts",
                        ].map((cat) {
                          return DropdownMenuItem(
                            value: cat,
                            child: Text(
                              cat,
                              style: const TextStyle(color: Colors.white),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedCategory = value!;
                          });
                        },
                        decoration: const InputDecoration(
                          hintText: "Category",
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// BUTTONS
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Cancel",
                                style: TextStyle(color: Colors.grey)),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber,
                              foregroundColor: Colors.black,
                            ),
                            onPressed: () async {
                              if (nameController.text.isEmpty ||
                                  priceController.text.isEmpty) {
                                return;
                              }

                              final data = {
                                "name": nameController.text.trim(),
                                "price": priceController.text.trim(),
                                "image": imageController.text.trim(),
                                "category": selectedCategory,
                                "createdAt": Timestamp.now(),
                              };

                              if (isEdit) {
                                await firestore
                                    .collection("foods")
                                    .doc(docId)
                                    .update(data);
                              } else {
                                await firestore
                                    .collection("foods")
                                    .add(data);
                              }

                              Navigator.pop(context);
                            },
                            child: Text(isEdit ? "Update" : "Add"),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// ================= DELETE =================
  void deleteFood(String id) {
    firestore.collection("foods").doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Manage Foods"),
      ),

      body: Column(
        children: [
          /// SEARCH
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchText = value.toLowerCase();
                });
              },
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "Search food...",
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
          ),

          /// ADD BUTTON
          ElevatedButton(
            onPressed: () => showFoodDialog(),
            child: const Text("Add Food"),
          ),

          const SizedBox(height: 10),

          /// LIST
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: firestore.collection("foods").snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final foods = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return data['name']
                      .toString()
                      .toLowerCase()
                      .contains(searchText);
                }).toList();

                return ListView.builder(
                  itemCount: foods.length,
                  itemBuilder: (context, index) {
                    final doc = foods[index];
                    final food = doc.data() as Map<String, dynamic>;

                    return Card(
                      color: const Color(0xff111111),
                      child: ListTile(
                        leading: Image.network(food['image'],
                            width: 60, height: 60, fit: BoxFit.cover),

                        title: Text(food['name'],
                            style: const TextStyle(color: Colors.white)),

                        subtitle: Text(
                          "${food['category']} | Rs ${food['price']}",
                          style: const TextStyle(color: Colors.grey),
                        ),

                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit,
                                  color: Colors.amber),
                              onPressed: () {
                                showFoodDialog(
                                  docId: doc.id,
                                  oldName: food['name'],
                                  oldPrice: food['price'],
                                  oldImage: food['image'],
                                  oldCategory: food['category'],
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Colors.red),
                              onPressed: () => deleteFood(doc.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}