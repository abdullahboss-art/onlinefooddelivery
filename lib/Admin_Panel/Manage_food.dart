
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
              backgroundColor: const Color(0xff1a1a1a),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
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
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),

                      /// IMAGE
                      TextField(
                        controller: imageController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          prefixIcon:
                              const Icon(Icons.image, color: Colors.amber),
                          hintText: "Image URL",
                          hintStyle: const TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: const Color(0xff0f0f0f),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xff333333),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xff333333),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      /// PREVIEW
                      Container(
                        height: 140,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xff0f0f0f),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xff333333),
                          ),
                        ),
                        child: imageController.text.isEmpty
                            ? const Icon(Icons.image,
                                color: Colors.grey, size: 50)
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  imageController.text,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.image,
                                        color: Colors.grey, size: 50);
                                  },
                                ),
                              ),
                      ),

                      const SizedBox(height: 15),

                      /// NAME
                      TextField(
                        controller: nameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Food Name",
                          hintStyle: const TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: const Color(0xff0f0f0f),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xff333333),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xff333333),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      /// PRICE
                      TextField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Price",
                          hintStyle: const TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: const Color(0xff0f0f0f),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xff333333),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xff333333),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      /// CATEGORY
                      DropdownButtonFormField<String>(
                        value: selectedCategory,
                        dropdownColor: const Color(0xff1a1a1a),
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
                          setDialog(() {
                            selectedCategory = value!;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: "Category",
                          hintStyle: const TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: const Color(0xff0f0f0f),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xff333333),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xff333333),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// BUTTONS
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              "Cancel",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () async {
                              if (nameController.text.isEmpty ||
                                  priceController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Please fill all fields"),
                                  ),
                                );
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

                              if (context.mounted) {
                                Navigator.pop(context);
                              }
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
      backgroundColor: const Color(0xff0f0f0f),
      appBar: AppBar(
        backgroundColor: const Color(0xff0f0f0f),
        elevation: 0,
        title: const Text(
          "Manage Foods",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.grey),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          /// SEARCH
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 10, 15, 15),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        searchText = value.toLowerCase();
                      });
                    },
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      hintText: "Search food...",
                      hintStyle: const TextStyle(color: Colors.grey),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xff1a1a1a),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 15,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                /// ADD BUTTON
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => showFoodDialog(),
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text(
                    "Add Food",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// LIST
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: firestore
                  .collection("foods")
                  .orderBy("createdAt", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Colors.amber,
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "No foods added yet",
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                final foods = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return data['name']
                      .toString()
                      .toLowerCase()
                      .contains(searchText);
                }).toList();

                if (foods.isEmpty) {
                  return const Center(
                    child: Text(
                      "No foods found",
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  itemCount: foods.length,
                  itemBuilder: (context, index) {
                    final doc = foods[index];
                    final food = doc.data() as Map<String, dynamic>;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xff1a1a1a),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xff2a2a2a),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              /// IMAGE
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  width: 70,
                                  height: 70,
                                  color: const Color(0xff0f0f0f),
                                  child: food['image'] != null &&
                                          food['image'].toString().isNotEmpty
                                      ? Image.network(
                                          food['image'],
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error,
                                              stackTrace) {
                                            return const Icon(Icons.image,
                                                color: Colors.grey);
                                          },
                                        )
                                      : const Icon(Icons.image,
                                          color: Colors.grey),
                                ),
                              ),

                              const SizedBox(width: 15),

                              /// TEXT CONTENT
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      food['name'] ?? "Unknown",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 5),
                                    Row(
                                      children: [
                                        Text(
                                          food['category'] ?? "N/A",
                                          style: const TextStyle(
                                            color: Color(0xff888888),
                                            fontSize: 13,
                                          ),
                                        ),
                                        const Text(
                                          " | ",
                                          style: TextStyle(
                                            color: Color(0xff444444),
                                          ),
                                        ),
                                        Text(
                                          "Rs ${food['price'] ?? "0"}",
                                          style: const TextStyle(
                                            color: Color(0xff888888),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 10),

                              /// ACTION BUTTONS
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.amber.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.amber,
                                        size: 20,
                                      ),
                                      constraints:
                                          const BoxConstraints(
                                        minWidth: 40,
                                        minHeight: 40,
                                      ),
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
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                        size: 20,
                                      ),
                                      constraints:
                                          const BoxConstraints(
                                        minWidth: 40,
                                        minHeight: 40,
                                      ),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              backgroundColor:
                                                  const Color(0xff1a1a1a),
                                              title: const Text(
                                                "Delete Food",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                              content: Text(
                                                "Are you sure you want to delete ${food['name']}?",
                                                style: const TextStyle(
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                          context),
                                                  child: const Text(
                                                    "Cancel",
                                                    style: TextStyle(
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    deleteFood(doc.id);
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text(
                                                    "Delete",
                                                    style: TextStyle(
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
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

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    super.dispose();
  }
}