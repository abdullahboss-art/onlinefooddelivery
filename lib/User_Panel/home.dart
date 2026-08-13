
import 'package:flutter/material.dart';
import 'models.dart';
import 'food_detail_page.dart';
import 'cart_page.dart';
import 'categories_page.dart';
import 'view_details.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CartManager _cart = CartManager();
  final FavoritesManager _favManager = FavoritesManager();
  String _selectedCategory = 'All';
  String selectedAddress = "Home";
  String selectedAddressDetail = "123 Street, Karachi";

  // ── Offer Slider state ──
  final PageController _offerController = PageController();
  Timer? _offerAutoTimer;
  int _currentOfferPage = 0;

  // ── Flash Sale state ──
  Timer? _flashSaleTimer;
  Duration _flashSaleRemaining = const Duration(hours: 2, minutes: 15, seconds: 23);

  // ── Notifications state ──
  int _unreadNotifications = 5;
  final List<Map<String, String>> _notifications = [
    {
      "icon": "🚚",
      "title": "Order Out for Delivery",
      "subtitle": "Your Cheese Burger order is on the way!",
      "time": "2 min ago",
    },
    {
      "icon": "🔥",
      "title": "Flash Sale Live Now",
      "subtitle": "Get up to 50% off on Burger Combo",
      "time": "20 min ago",
    },
    {
      "icon": "🎉",
      "title": "New Restaurant Nearby",
      "subtitle": "Pizza Hut just joined — check it out",
      "time": "1 hour ago",
    },
    {
      "icon": "⭐",
      "title": "Rate Your Last Order",
      "subtitle": "Tell us how the BBQ Burger was",
      "time": "3 hours ago",
    },
    {
      "icon": "💳",
      "title": "Payment Successful",
      "subtitle": "Rs 850 charged for order #1042",
      "time": "1 day ago",
    },
  ];

  // Status/Story data
  final List<Map<String, String>> _stories = [
    {
      "image": "🍔",
      "name": "Burger",
      "bgColor": "#FF5722",
    },
    {
      "image": "🍕",
      "name": "Pizza",
      "bgColor": "#E91E63",
    },
    {
      "image": "🍜",
      "name": "Noodles",
      "bgColor": "#9C27B0",
    },
    {
      "image": "🥗",
      "name": "Salad",
      "bgColor": "#4CAF50",
    },
    {
      "image": "🥘",
      "name": "Biryani",
      "bgColor": "#FF9800",
    },
    {
      "image": "🍣",
      "name": "Sushi",
      "bgColor": "#00BCD4",
    },
  ];

  final List<Map<String, dynamic>> addresses = [
    {
      "title": "Current Location",
      "subtitle": "Using GPS",
      "icon": Icons.my_location,
      "default": false,
      "time": "20-25 mins"
    },
    {
      "title": "Home",
      "subtitle": "123 Street, Karachi",
      "icon": Icons.home,
      "default": true,
      "time": "20-25 mins"
    },
    {
      "title": "Office",
      "subtitle": "ABC Plaza, Karachi",
      "icon": Icons.work,
      "default": false,
      "time": "35-40 mins"
    }
  ];

  // ── Offer Slider data ──
  final List<Map<String, dynamic>> _offers = [
    {
      "emoji": "🔥",
      "title": "50% OFF",
      "subtitle": "On Burger Combo",
      "colors": [Color(0xFFFF5722), Color(0xFFFF9800)],
      "category": "Burger",
    },
    {
      "emoji": "🍕",
      "title": "Buy 1 Get 1",
      "subtitle": "On All Pizzas",
      "colors": [Color(0xFFE91E63), Color(0xFF9C27B0)],
      "category": "Pizza",
    },
    {
      "emoji": "🚚",
      "title": "Free Delivery",
      "subtitle": "On Orders Above \$20",
      "colors": [Color(0xFF4CAF50), Color(0xFF009688)],
      "category": "All",
    },
  ];

  // ── Nearby Restaurants data ──
  final List<Map<String, dynamic>> _restaurants = [
    {"name": "McDonald's", "emoji": "🍔", "rating": 4.5, "time": "20 mins", "freeDelivery": true},
    {"name": "Pizza Hut", "emoji": "🍕", "rating": 4.3, "time": "25 mins", "freeDelivery": true},
    {"name": "KFC", "emoji": "🍗", "rating": 4.6, "time": "18 mins", "freeDelivery": false},
    {"name": "Subway", "emoji": "🥪", "rating": 4.2, "time": "22 mins", "freeDelivery": true},
  ];

  @override
  void initState() {
    super.initState();
    _startOfferAutoSlide();
    _startFlashSaleCountdown();
  }

  @override
  void dispose() {
    _offerAutoTimer?.cancel();
    _flashSaleTimer?.cancel();
    _offerController.dispose();
    super.dispose();
  }

  void _startOfferAutoSlide() {
    _offerAutoTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!_offerController.hasClients) return;
      final next = (_currentOfferPage + 1) % _offers.length;
      _offerController.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  void _startFlashSaleCountdown() {
    _flashSaleTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_flashSaleRemaining.inSeconds > 0) {
          _flashSaleRemaining -= const Duration(seconds: 1);
        } else {
          _flashSaleRemaining = const Duration(hours: 2, minutes: 15, seconds: 23);
        }
      });
    });
  }

  // Simple deterministic discount generator so we don't need to touch FoodItem model
  int _getDiscount(String id) {
    final n = int.tryParse(id) ?? 0;
    if (n % 3 == 0) return 20;
    if (n % 2 == 0) return 10;
    return 0;
  }

  // Helper method to safely parse hex color
  Color _parseHexColor(String? hexColor) {
    if (hexColor == null || hexColor.isEmpty) {
      return const Color(0xFFFF5722);
    }
    try {
      final cleanHex = hexColor.replaceFirst('#', '');
      if (cleanHex.length != 6) {
        return const Color(0xFFFF5722);
      }
      return Color(int.parse(cleanHex, radix: 16) + 0xFF000000);
    } catch (e) {
      return const Color(0xFFFF5722);
    }
  }

  List<FoodItem> get _filteredFoods {
    if (_selectedCategory == 'All') return allFoods;
    return allFoods.where((f) => f.category == _selectedCategory).toList();
  }

  void _openFood(FoodItem food) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FoodDetailPage(
          food: {
            "id": food.id,
            "name": food.name,
            "emoji": food.emoji,
            "price": food.price,
            "category": food.category,
            "rating": food.rating,
            "reviews": food.reviews,
            "description": food.description,
          },
        ),
      ),
    ).then((_) => setState(() {}));
  }

  void _openCart() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CartPage()),
    ).then((_) => setState(() {}));
  }

  void _openStory(int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StoryViewer(
          stories: _stories,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() {});
  }

  // Called when "Order Now" is tapped on an offer banner.
  // Navigates to Categories page with the relevant category pre-selected
  // so the user can immediately browse and add matching items to cart.
  void _handleOfferTap(Map<String, dynamic> offer) {
    final category = offer["category"] as String? ?? "All";
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoriesPage(initialCategory: category),
      ),
    ).then((_) => setState(() {}));
  }

  void _showNotifications() {
    setState(() {
      _unreadNotifications = 0;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xff1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Notifications",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, color: Colors.white70),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.55,
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _notifications.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final n = _notifications[index];
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E1E1E),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              n["icon"] ?? "🔔",
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  n["title"] ?? "",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  n["subtitle"] ?? "",
                                  style: const TextStyle(
                                    color: Colors.white60,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  n["time"] ?? "",
                                  style: const TextStyle(
                                    color: Color(0xFFFFC107),
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFFFFC107),
          backgroundColor: const Color(0xFF1E1E1E),
          onRefresh: _onRefresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopBar(),
                const SizedBox(height: 8),
                _buildGreetingSection(),
                const SizedBox(height: 16),
                _buildSearchBar(),
                const SizedBox(height: 18),
                _buildOfferSlider(),
                const SizedBox(height: 16),
                _buildFlashSaleTimer(),
                const SizedBox(height: 20),
                _buildStatusSection(),
                const SizedBox(height: 24),
                _buildSectionHeader(
                  'Categories',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CategoriesPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 14),
                _buildCategories(),
                const SizedBox(height: 24),
                _buildSectionHeader(
                  'Popular Foods',
                  onTap: () {},
                ),
                const SizedBox(height: 14),
                _buildPopularFoods(),
                const SizedBox(height: 24),
                _buildSectionHeader(
                  'Nearby Restaurants',
                  onTap: () {},
                ),
                const SizedBox(height: 14),
                _buildNearbyRestaurants(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _cart.totalItems > 0
          ? FloatingActionButton.extended(
              onPressed: _openCart,
              backgroundColor: const Color(0xFFFFC107),
              foregroundColor: Colors.black,
              icon: const Icon(Icons.shopping_cart),
              label: Text(
                '${_cart.totalItems} • \$${_cart.totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            )
          : null,
    );
  }

  // ═══════════════════════ GREETING SECTION ═══════════════════════
  Widget _buildGreetingSection() {
    final hour = DateTime.now().hour;
    String greeting;
    String emoji;
    if (hour < 12) {
      greeting = "Good Morning";
      emoji = "☀️";
    } else if (hour < 17) {
      greeting = "Good Afternoon";
      emoji = "🌤️";
    } else {
      greeting = "Good Evening";
      emoji = "🌙";
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$emoji $greeting, Abdullah",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "What would you like to eat today?",
            style: TextStyle(
              color: Colors.white54,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════ OFFER SLIDER ═══════════════════════
  Widget _buildOfferSlider() {
    return SizedBox(
      height: 130,
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _offerController,
              itemCount: _offers.length,
              onPageChanged: (index) {
                setState(() => _currentOfferPage = index);
              },
              itemBuilder: (context, index) {
                final offer = _offers[index];
                final colors = offer["colors"] as List<Color>;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: colors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: colors.first.withOpacity(0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      children: [
                        Text(offer["emoji"] as String,
                            style: const TextStyle(fontSize: 38)),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                offer["title"] as String,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                offer["subtitle"] as String,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _handleOfferTap(offer),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.black26,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "Order Now",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(Icons.arrow_forward,
                                    color: Colors.white, size: 13),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_offers.length, (index) {
              final isActive = index == _currentOfferPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: isActive ? 18 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color:
                      isActive ? const Color(0xFFFFC107) : Colors.white24,
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════ FLASH SALE TIMER ═══════════════════════
  Widget _buildFlashSaleTimer() {
    final hours = _flashSaleRemaining.inHours.toString().padLeft(2, '0');
    final minutes =
        (_flashSaleRemaining.inMinutes % 60).toString().padLeft(2, '0');
    final seconds =
        (_flashSaleRemaining.inSeconds % 60).toString().padLeft(2, '0');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFFFC107).withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Text("⚡", style: TextStyle(fontSize: 20)),
                SizedBox(width: 8),
                Text(
                  "Flash Sale",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                _timeBox(hours),
                _timeSeparator(),
                _timeBox(minutes),
                _timeSeparator(),
                _timeBox(seconds),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _timeBox(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFFFC107),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        value,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _timeSeparator() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        ":",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildStatusSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Stories',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _stories.length,
            itemBuilder: (context, index) {
              final story = _stories[index];
              final bgColor = _parseHexColor(story['bgColor']);

              return GestureDetector(
                onTap: () => _openStory(index),
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  child: Column(
                    children: [
                      Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              bgColor,
                              bgColor.withOpacity(0.7),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFFFC107),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            story['image'] ?? '🍔',
                            style: const TextStyle(fontSize: 32),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        story['name'] ?? 'Food',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                const Icon(Icons.location_on,
                    color: Color(0xFFFFC107), size: 20),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Deliver To",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                        ),
                      ),
                      GestureDetector(
                        onTap: _showAddressDialog,
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                "$selectedAddress • $selectedAddressDetail",
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.white,
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: _openCart,
                child: Stack(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.shopping_cart_outlined,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    if (_cart.totalItems > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFC107),
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '${_cart.totalItems}',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _showNotifications,
                child: Stack(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.notifications_outlined,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    if (_unreadNotifications > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '$_unreadNotifications',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddressDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xff1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Select Address",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              ListView.builder(
                shrinkWrap: true,
                itemCount: addresses.length,
                itemBuilder: (context, index) {
                  final address = addresses[index];
                  return Card(
                    color: const Color(0xff2A2A2A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.amber,
                        child: Icon(
                          address["icon"] as IconData,
                          color: Colors.black,
                        ),
                      ),
                      title: Row(
                        children: [
                          Text(
                            address["title"] as String,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (address["default"] as bool)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                "Default",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            address["subtitle"] as String,
                            style: const TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            "Delivery ${address["time"]}",
                            style: const TextStyle(
                              color: Colors.amber,
                              fontSize: 12,
                            ),
                          )
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.white70,
                            ),
                            onPressed: () {
                              // TODO: Implement edit address
                            },
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.redAccent,
                            ),
                            onPressed: () {
                              // TODO: Implement delete address
                            },
                          ),
                        ],
                      ),
                      onTap: () {
                        setState(() {
                          selectedAddress = address["title"] as String;
                          selectedAddressDetail =
                              address["subtitle"] as String;
                        });
                        Navigator.pop(context);
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () {
                    // TODO: Implement add new address
                  },
                  icon: const Icon(Icons.add),
                  label: const Text(
                    "Add New Address",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: _showSearchSheet,
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  children: [
                    SizedBox(width: 14),
                    Icon(Icons.search,
                        color: Color(0xFF9E9E9E), size: 22),
                    SizedBox(width: 10),
                    Text(
                      'Search for food, cuisines...',
                      style: TextStyle(
                        color: Color(0xFF9E9E9E),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _showFilterSheet,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.tune,
                color: Color(0xFFFFC107),
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSearchSheet() {
    final List<String> suggestions = [
      'Pizza',
      'Burger',
      'Biryani',
      'Noodles',
      'Pasta',
      'Cold Brew',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xff1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  children: [
                    SizedBox(width: 14),
                    Icon(Icons.search, color: Color(0xFF9E9E9E), size: 22),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        autofocus: true,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Search for food, cuisines...',
                          hintStyle: TextStyle(color: Color(0xFF9E9E9E)),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    SizedBox(width: 14),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                "Popular Searches",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: suggestions.map((s) {
                  return GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        s,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFilterSheet() {
    // TODO: Implement filter sheet
  }

  Widget _buildSectionHeader(
    String title, {
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          GestureDetector(
            onTap: onTap,
            child: const Text(
              'View all',
              style: TextStyle(
                color: Color(0xFFFFC107),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: allCategories.length,
        itemBuilder: (context, index) {
          final cat = allCategories[index];
          final isSelected = _selectedCategory == cat.name;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = isSelected ? 'All' : cat.name;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: AnimatedScale(
                scale: isSelected ? 1.08 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFFFC107).withOpacity(0.2)
                            : const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFFFFC107)
                              : Colors.transparent,
                          width: 1.5,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: const Color(0xFFFFC107)
                                      .withOpacity(0.35),
                                  blurRadius: 12,
                                  spreadRadius: 1,
                                ),
                              ]
                            : [],
                      ),
                      child: Center(
                        child: Text(
                          cat.emoji,
                          style: const TextStyle(fontSize: 26),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      cat.name,
                      style: TextStyle(
                        color: isSelected
                            ? const Color(0xFFFFC107)
                            : Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPopularFoods() {
    final foods = _filteredFoods;

    return SizedBox(
      height: 240,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: foods.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 14),
            child: _buildFoodCard(foods[index]),
          );
        },
      ),
    );
  }

  // ═══════════════════════ PREMIUM FOOD CARD ═══════════════════════
  Widget _buildFoodCard(FoodItem food) {
    final isFav = _favManager.isFavorite(food.id);
    final discount = _getDiscount(food.id);

    return GestureDetector(
      onTap: () => _openFood(food),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 160,
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: Center(
                    child: Hero(
                      tag: 'food_${food.id}',
                      child: Text(
                        food.emoji,
                        style: const TextStyle(fontSize: 60),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.star,
                              color: Color(0xFFFFC107), size: 13),
                          const SizedBox(width: 3),
                          Text(
                            food.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        food.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '\$${food.price}',
                            style: const TextStyle(
                              color: Color(0xFFFFC107),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _cart.add(food.id);
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  duration: const Duration(seconds: 1),
                                  backgroundColor: Colors.green,
                                  content:
                                      Text("${food.name} added to cart"),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFC107),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.add_shopping_cart,
                                      color: Colors.black, size: 13),
                                  SizedBox(width: 3),
                                  Text(
                                    "Add",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              top: 8,
              left: 8,
              right: 8,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (discount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "-$discount%",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  else
                    const SizedBox(),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _favManager.toggle(food.id);
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.black45,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        color: isFav ? Colors.redAccent : Colors.white,
                        size: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════ NEARBY RESTAURANTS ═══════════════════════
  Widget _buildNearbyRestaurants() {
    return SizedBox(
      height: 170,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _restaurants.length,
        itemBuilder: (context, index) {
          final r = _restaurants[index];
          return Container(
            width: 160,
            margin: const EdgeInsets.only(right: 14),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    r["emoji"] as String,
                    style: const TextStyle(fontSize: 26),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  r["name"] as String,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.star,
                        color: Color(0xFFFFC107), size: 13),
                    const SizedBox(width: 3),
                    Text(
                      "${r["rating"]}",
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 11),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.access_time,
                        color: Colors.white54, size: 12),
                    const SizedBox(width: 3),
                    Text(
                      "${r["time"]}",
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                if (r["freeDelivery"] as bool)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "Free Delivery",
                      style: TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Story Viewer Page
class StoryViewer extends StatefulWidget {
  final List<Map<String, String>> stories;
  final int initialIndex;

  const StoryViewer({
    super.key,
    required this.stories,
    required this.initialIndex,
  });

  @override
  State<StoryViewer> createState() => _StoryViewerState();
}

class _StoryViewerState extends State<StoryViewer>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late int currentIndex;
  Timer? _timer;
  late AnimationController _progressController;
  bool _isPaused = false;
  double _currentProgress = 0.0;

  Color _parseHexColor(String? hexColor) {
    if (hexColor == null || hexColor.isEmpty) {
      return const Color(0xFFFF5722);
    }
    try {
      final cleanHex = hexColor.replaceFirst('#', '');
      if (cleanHex.length != 6) {
        return const Color(0xFFFF5722);
      }
      return Color(int.parse(cleanHex, radix: 16) + 0xFF000000);
    } catch (e) {
      return const Color(0xFFFF5722);
    }
  }

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    _progressController.addListener(() {
      setState(() {
        _currentProgress = _progressController.value;
      });
    });

    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_isPaused) {
        _nextStory();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isPaused) {
        _progressController.forward();
      }
    });
  }

  void _pauseStory() {
    if (!_isPaused) {
      setState(() {
        _isPaused = true;
      });
      _progressController.stop();
      _timer?.cancel();
    }
  }

  void _resumeStory() {
    if (_isPaused) {
      setState(() {
        _isPaused = false;
      });
      _progressController.forward();
    }
  }

  void _nextStory() {
    _progressController.stop();
    _progressController.reset();

    if (currentIndex < widget.stories.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  void _previousStory() {
    _progressController.stop();
    _progressController.reset();

    if (currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  void _closeViewer() {
    _progressController.stop();
    _timer?.cancel();
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _progressController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapUp: (details) {
          final screenWidth = MediaQuery.of(context).size.width;
          if (details.localPosition.dx < screenWidth / 3) {
            _previousStory();
          } else if (details.localPosition.dx > screenWidth * 2 / 3) {
            _nextStory();
          } else {
            if (_isPaused) {
              _resumeStory();
            } else {
              _pauseStory();
            }
          }
        },
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  currentIndex = index;
                  _currentProgress = 0.0;
                  _progressController.reset();
                });
                if (!_isPaused) {
                  _progressController.forward();
                }
              },
              itemCount: widget.stories.length,
              itemBuilder: (context, index) {
                final story = widget.stories[index];
                final bgColor = _parseHexColor(story['bgColor']);

                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        bgColor,
                        Colors.black,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          story['image'] ?? '🍔',
                          style: const TextStyle(fontSize: 150),
                        ),
                        const SizedBox(height: 30),
                        Text(
                          story['name'] ?? 'Food',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            _pauseStory();
                            final currentStory = widget.stories[currentIndex];
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ViewDetailPage(
                                  food: {
                                    "name": currentStory["name"] ?? "",
                                    "emoji": currentStory["image"] ?? "🍔",
                                    "price": 15,
                                    "rating": 4.8,
                                    "reviews": 120,
                                    "category": "Popular",
                                    "description":
                                        "${currentStory["name"] ?? "Food"} is one of our most popular dishes. Made with fresh ingredients and served hot.",
                                  },
                                ),
                              ),
                            ).then((_) {
                              _resumeStory();
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFC107),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            "View Details",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            Positioned(
              top: 40,
              left: 10,
              right: 10,
              child: Row(
                children: List.generate(widget.stories.length, (index) {
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      height: 3,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          width: index < currentIndex
                              ? double.infinity
                              : (index == currentIndex
                                  ? MediaQuery.of(context).size.width /
                                      widget.stories.length *
                                      _currentProgress
                                  : 0),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFC107),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            Positioned(
              top: 45,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              _parseHexColor(
                                  widget.stories[currentIndex]['bgColor']),
                              _parseHexColor(
                                      widget.stories[currentIndex]['bgColor'])
                                  .withOpacity(0.7),
                            ],
                          ),
                        ),
                        child: Center(
                          child: Text(
                            widget.stories[currentIndex]['image'] ?? '🍔',
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.stories[currentIndex]['name'] ?? 'Food',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const Text(
                            'Just now',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: _closeViewer,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Colors.black45,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_isPaused)
              Center(
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.pause,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}