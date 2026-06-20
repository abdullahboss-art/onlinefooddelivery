import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


// Import your existing pages
import 'Order.dart';
import 'Manage_food.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white, size: 28),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        title: const Text(
          "Admin Dashboard",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: false,
        actions: [
          StreamBuilder<QuerySnapshot>(
            stream: firestore.collection("orders").snapshots(),
            builder: (context, snapshot) {
              int unreadCount = 0;
              if (snapshot.hasData) {
                unreadCount = snapshot.data!.docs.where((doc) {
                  var data = doc.data() as Map<String, dynamic>;
                  return data['seenByAdmin'] == false || data['seenByAdmin'] == null;
                }).length;
              }
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications, color: Colors.white, size: 28),
                    onPressed: () {
                      _showNotificationDrawer(context);
                    },
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          unreadCount.toString(),
                          style: const TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xff1a1a1a),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.admin_panel_settings, color: Colors.amber, size: 50),
                  const SizedBox(height: 10),
                  const Text(
                    "Admin Panel",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Manage your store",
                    style: TextStyle(color: Colors.grey[400], fontSize: 14),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.grey, thickness: 0.5),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(
                    icon: Icons.dashboard,
                    title: "Dashboard",
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.shopping_bag,
                    title: "Orders",
                    onTap: () {
                      Navigator.pop(context);
                      // You can show orders list here or navigate to orders page
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Orders section coming soon')),
                      );
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.fastfood,
                    title: "Manage Products",
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ManageFoodsPage()),
                      );
                    },
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.grey, thickness: 0.5),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Icon(Icons.logout, color: Colors.red, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    "Logout",
                    style: TextStyle(color: Colors.red[400], fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats Cards Row
            StreamBuilder<QuerySnapshot>(
              stream: firestore.collection("orders").snapshots(),
              builder: (context, ordersSnapshot) {
                int totalOrders = ordersSnapshot.hasData ? ordersSnapshot.data!.docs.length : 0;
                
                return StreamBuilder<QuerySnapshot>(
                  stream: firestore.collection("users").snapshots(),
                  builder: (context, usersSnapshot) {
                    int totalUsers = usersSnapshot.hasData ? usersSnapshot.data!.docs.length : 0;
                    
                    return StreamBuilder<QuerySnapshot>(
                      stream: firestore.collection("products").snapshots(),
                      builder: (context, productsSnapshot) {
                        int totalProducts = productsSnapshot.hasData ? productsSnapshot.data!.docs.length : 0;
                        
                        return StreamBuilder<QuerySnapshot>(
                          stream: firestore.collection("orders").snapshots(),
                          builder: (context, revenueSnapshot) {
                            double totalRevenue = 0;
                            if (revenueSnapshot.hasData) {
                              for (var doc in revenueSnapshot.data!.docs) {
                                var order = doc.data() as Map<String, dynamic>;
                                totalRevenue += (order['totalAmount'] ?? 0).toDouble();
                              }
                            }
                            
                            return Row(
                              children: [
                                Expanded(
                                  child: _buildStatCard(
                                    title: "Total Orders",
                                    value: totalOrders.toString(),
                                    icon: Icons.shopping_bag,
                                    color: Colors.blue,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildStatCard(
                                    title: "Total Users",
                                    value: totalUsers.toString(),
                                    icon: Icons.people,
                                    color: Colors.green,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildStatCard(
                                    title: "Total Products",
                                    value: totalProducts.toString(),
                                    icon: Icons.fastfood,
                                    color: Colors.orange,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildStatCard(
                                    title: "Total Revenue",
                                    value: "\$${totalRevenue.toStringAsFixed(2)}",
                                    icon: Icons.attach_money,
                                    color: Colors.amber,
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 24),

            // Recent Orders Section
            const Text(
              "Recent Orders",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            StreamBuilder<QuerySnapshot>(
              stream: firestore
                  .collection("orders")
                  .orderBy("createdAt", descending: true)
                  .limit(5)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Container(
                    height: 150,
                    decoration: BoxDecoration(
                      color: const Color(0xff1a1a1a),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.amber),
                    ),
                  );
                }
                
                var orders = snapshot.data!.docs;
                if (orders.isEmpty) {
                  return Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xff1a1a1a),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Center(
                      child: Text(
                        "No orders yet",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                }
                
                return Container(
                  decoration: BoxDecoration(
                    color: const Color(0xff1a1a1a),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: orders.map((doc) {
                      var order = doc.data() as Map<String, dynamic>;
                      return Column(
                        children: [
                          _buildRecentOrderItem(
                            orderId: order['orderId']?.toString() ?? doc.id.substring(0, 6),
                            date: _formatDate(order['createdAt']),
                            status: order['status'] ?? 'Pending',
                            docId: doc.id,
                          ),
                          if (orders.last != doc) const Divider(color: Colors.grey, height: 1),
                        ],
                      );
                    }).toList(),
                  ),
                );
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[400], size: 24),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      onTap: onTap,
    );
  }

  void _showNotificationDrawer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Color(0xff1a1a1a),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  "Notifications",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: firestore
                      .collection("orders")
                      .orderBy("createdAt", descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator(color: Colors.amber));
                    }
                    var orders = snapshot.data!.docs;
                    if (orders.isEmpty) {
                      return const Center(
                        child: Text("No orders available", style: TextStyle(color: Colors.grey)),
                      );
                    }
                    return ListView.builder(
                      controller: controller,
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        var doc = orders[index];
                        var order = doc.data() as Map<String, dynamic>;
                        bool isSeen = order['seenByAdmin'] == true;
                        return _buildNotificationItem(
                          orderId: order['orderId']?.toString() ?? doc.id.substring(0, 6),
                          date: _formatDate(order['createdAt']),
                          status: order['status'] ?? 'Pending',
                          isSeen: isSeen,
                          docId: doc.id,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationItem({
    required String orderId,
    required String date,
    required String status,
    required bool isSeen,
    required String docId,
  }) {
    Color statusColor = status == 'Open' || status == 'Pending'
        ? Colors.orange
        : status == 'Closed' || status == 'Delivered' || status == 'Completed'
            ? Colors.green
            : Colors.red;

    return GestureDetector(
  onTap: () async {
        if (!isSeen) {
          await firestore.collection("orders").doc(docId).update({'seenByAdmin': true});
        }
        Navigator.pop(context);
        _navigateToOrderPage(context);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSeen ? Colors.transparent : Colors.amber.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: isSeen ? Colors.transparent : Colors.blue,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Order #$orderId",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Date: $date",
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                status,
                style: TextStyle(color: statusColor, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

void _navigateToOrderPage(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const OrdersScreen(),
    ),
  );
}
String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'No date';
    if (timestamp is DateTime) {
      return "${timestamp.day.toString().padLeft(2, '0')}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.year}";
    }
    if (timestamp is Timestamp) {
      DateTime date = timestamp.toDate();
      return "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
    }
    return 'Invalid date';
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xff1a1a1a),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentOrderItem({
    required String orderId,
    required String date,
    required String status,
    required String docId,
  }) {
    Color statusColor = status == 'Open' || status == 'Pending'
        ? Colors.orange
        : status == 'Closed' || status == 'Delivered' || status == 'Completed'
            ? Colors.green
            : Colors.red;
            
    return GestureDetector(
      onTap: () => _navigateToOrderPage(context),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Order #$orderId",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Date: $date",
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                status,
                style: TextStyle(color: statusColor, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}