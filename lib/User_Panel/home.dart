import 'dart:async';

import 'package:flutter/material.dart';
import 'package:myapp/User_Panel/AIChatPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';
import 'food_detail_page.dart';
import 'cart_page.dart';
import 'categories_page.dart';
import 'view_details.dart';

// ============================================================================
// APP THEME COLORS
// ============================================================================

class AppColors {
  static const Color background = Color(0xFF0B0B0B);
  static const Color surface = Color(0xFF151515);
  static const Color surface2 = Color(0xFF1D1D1D);
  static const Color surface3 = Color(0xFF252525);

  static const Color primary = Color(0xFFFFC107);
  static const Color primaryDark = Color(0xFFFFA000);

  static const Color white = Colors.white;
  static const Color white70 = Colors.white70;
  static const Color white54 = Colors.white54;
  static const Color white38 = Colors.white38;
  static const Color white24 = Colors.white24;

  static const Color success = Color(0xFF4CAF50);
  static const Color danger = Color(0xFFFF3D3D);

  static const Color greenAccent = Color(0xFF69F0AE);
}

// ============================================================================
// HOME PAGE
// ============================================================================

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CartManager _cart = CartManager();
  final FavoritesManager _favManager = FavoritesManager();

  // IMPORTANT:
  // Same AIChatPage instance ko alive rakhta hai.
  // Is se chat history close/open ke baad preserve rahegi.
  final GlobalKey<AIChatPageState> _chatKey =
      GlobalKey<AIChatPageState>();

  String _selectedCategory = 'All';

  String selectedAddress = "Home";
  String selectedAddressDetail = "123 Street, Karachi";

  // ==========================================================================
  // CHAT
  // ==========================================================================

  bool _isChatOpen = false;

  // ==========================================================================
  // OFFER SLIDER
  // ==========================================================================

  final PageController _offerController = PageController();
  Timer? _offerAutoTimer;
  int _currentOfferPage = 0;

  // ==========================================================================
  // FLASH SALE
  // ==========================================================================

  Timer? _flashSaleTimer;

  Duration _flashSaleRemaining =
      const Duration(hours: 2, minutes: 15, seconds: 23);

  // ==========================================================================
  // NOTIFICATIONS
  // ==========================================================================

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

  // ==========================================================================
  // STORIES
  // ==========================================================================

  final List<Map<String, String>> _stories = [
    {"image": "🍔", "name": "Burger", "bgColor": "#FF5722"},
    {"image": "🍕", "name": "Pizza", "bgColor": "#E91E63"},
    {"image": "🍜", "name": "Noodles", "bgColor": "#9C27B0"},
    {"image": "🥗", "name": "Salad", "bgColor": "#4CAF50"},
    {"image": "🥘", "name": "Biryani", "bgColor": "#FF9800"},
    {"image": "🍣", "name": "Sushi", "bgColor": "#00BCD4"},
  ];

  // ==========================================================================
  // ADDRESSES
  // ==========================================================================

  final List<Map<String, dynamic>> addresses = [
    {
      "title": "Current Location",
      "subtitle": "Using GPS",
      "icon": Icons.my_location,
      "default": false,
      "time": "20-25 mins",
    },
    {
      "title": "Home",
      "subtitle": "123 Street, Karachi",
      "icon": Icons.home,
      "default": true,
      "time": "20-25 mins",
    },
    {
      "title": "Office",
      "subtitle": "ABC Plaza, Karachi",
      "icon": Icons.work,
      "default": false,
      "time": "35-40 mins",
    },
  ];

  // ==========================================================================
  // OFFERS
  // ==========================================================================

  final List<Map<String, dynamic>> _offers = [
    {
      "emoji": "🔥",
      "title": "50% OFF",
      "subtitle": "On Burger Combo",
      "colors": [Color(0xFFFFB300), Color(0xFFFF6F00)],
      "category": "Burger",
    },
    {
      "emoji": "🍕",
      "title": "Buy 1 Get 1",
      "subtitle": "On All Pizzas",
      "colors": [Color(0xFFFFC107), Color(0xFFFF8F00)],
      "category": "Pizza",
    },
    {
      "emoji": "🚚",
      "title": "Free Delivery",
      "subtitle": "On Orders Above \$20",
      "colors": [Color(0xFF4CAF50), Color(0xFF087F23)],
      "category": "All",
    },
  ];

  // ==========================================================================
  // RESTAURANTS
  // ==========================================================================

  final List<Map<String, dynamic>> _restaurants = [
    {
      "name": "McDonald's",
      "emoji": "🍔",
      "rating": 4.5,
      "time": "20 mins",
      "freeDelivery": true,
    },
    {
      "name": "Pizza Hut",
      "emoji": "🍕",
      "rating": 4.3,
      "time": "25 mins",
      "freeDelivery": true,
    },
    {
      "name": "KFC",
      "emoji": "🍗",
      "rating": 4.6,
      "time": "18 mins",
      "freeDelivery": false,
    },
    {
      "name": "Subway",
      "emoji": "🥪",
      "rating": 4.2,
      "time": "22 mins",
      "freeDelivery": true,
    },
  ];

  // ==========================================================================
  // INIT
  // ==========================================================================

  @override
  void initState() {
    super.initState();

    _startOfferAutoSlide();
    _startFlashSaleCountdown();

    // IMPORTANT:
    // Yahan AIChatPage.startChat() call nahi karna.
    //
    // AI chat sirf _openChat() ke andar start hogi.
  }

  // ==========================================================================
  // DISPOSE
  // ==========================================================================

  @override
  void dispose() {
    _offerAutoTimer?.cancel();
    _flashSaleTimer?.cancel();
    _offerController.dispose();

    super.dispose();
  }

  // ==========================================================================
  // OPEN AI CHAT
  // ==========================================================================

  void _openChat() {
    if (!mounted) return;

    setState(() {
      _isChatOpen = true;
    });

    // Chat widget ko pehle screen par mount hone do.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _chatKey.currentState?.startChat();
    });
  }

  // ==========================================================================
  // CLOSE AI CHAT
  // ==========================================================================

  void _closeChat() {
    if (!mounted) return;

    setState(() {
      _isChatOpen = false;
    });

    // IMPORTANT:
    // Yahan AIChatPage ko dispose nahi kar rahe.
    //
    // Is liye:
    // previous messages
    // conversation
    // selected language
    // etc.
    //
    // preserve rahenge.
  }

  // ==========================================================================
  // CHAT OVERLAY
  // ==========================================================================

  Widget _buildChatOverlay() {
    final screenSize = MediaQuery.of(context).size;

    final double chatWidth =
        screenSize.width > 430 ? 395 : screenSize.width - 24;

    final double chatHeight =
        screenSize.height > 700
            ? 555
            : screenSize.height * 0.78;

    return Positioned.fill(
      child: Offstage(
        offstage: !_isChatOpen,
        child: Stack(
          children: [
            // ================================================================
            // DARK BACKGROUND
            // ================================================================

            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _closeChat,
                child: Container(
                  color: Colors.black.withOpacity(0.72),
                ),
              ),
            ),

            // ================================================================
            // CHAT BOX
            // ================================================================

            Center(
              child: SizedBox(
                width: chatWidth,
                height: chatHeight,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Material(
                    color: Colors.transparent,
                    child: AIChatPage(
                      key: _chatKey,
                      onClose: _closeChat,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // CHAT FAB
  // ==========================================================================

  Widget _buildChatFab() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.30),
            blurRadius: 18,
            spreadRadius: 2,
          ),
        ],
      ),
      child: FloatingActionButton(
        heroTag: 'chat_fab',
        onPressed: _openChat,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.black,
        elevation: 8,
        child: const Icon(
          Icons.smart_toy_rounded,
          size: 26,
        ),
      ),
    );
  }

  // ==========================================================================
  // OFFER AUTO SLIDE
  // ==========================================================================

  void _startOfferAutoSlide() {
    _offerAutoTimer = Timer.periodic(
      const Duration(seconds: 4),
      (timer) {
        if (!_offerController.hasClients) return;

        final next =
            (_currentOfferPage + 1) % _offers.length;

        _offerController.animateToPage(
          next,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      },
    );
  }

  // ==========================================================================
  // FLASH SALE COUNTDOWN
  // ==========================================================================

  void _startFlashSaleCountdown() {
    _flashSaleTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (!mounted) return;

        setState(() {
          if (_flashSaleRemaining.inSeconds > 0) {
            _flashSaleRemaining -=
                const Duration(seconds: 1);
          } else {
            _flashSaleRemaining =
                const Duration(
              hours: 2,
              minutes: 15,
              seconds: 23,
            );
          }
        });
      },
    );
  }

  // ==========================================================================
  // DISCOUNT
  // ==========================================================================

  int _getDiscount(String id) {
    final n = int.tryParse(id) ?? 0;

    if (n % 3 == 0) return 20;
    if (n % 2 == 0) return 10;

    return 0;
  }

  // ==========================================================================
  // HEX COLOR
  // ==========================================================================

  Color _parseHexColor(String? hexColor) {
    if (hexColor == null || hexColor.isEmpty) {
      return const Color(0xFFFF5722);
    }

    try {
      final cleanHex =
          hexColor.replaceFirst('#', '');

      if (cleanHex.length != 6) {
        return const Color(0xFFFF5722);
      }

      return Color(
        int.parse(cleanHex, radix: 16) +
            0xFF000000,
      );
    } catch (e) {
      return const Color(0xFFFF5722);
    }
  }

  // ==========================================================================
  // FILTERED FOODS
  // ==========================================================================

  List<FoodItem> get _filteredFoods {
    if (_selectedCategory == 'All') {
      return allFoods;
    }

    return allFoods
        .where(
          (f) => f.category == _selectedCategory,
        )
        .toList();
  }

  // ==========================================================================
  // OPEN FOOD
  // ==========================================================================

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
    ).then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  // ==========================================================================
  // OPEN CART
  // ==========================================================================

  void _openCart() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CartPage(),
      ),
    ).then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  // ==========================================================================
  // OPEN STORY
  // ==========================================================================

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

  // ==========================================================================
  // REFRESH
  // ==========================================================================

  Future<void> _onRefresh() async {
    await Future.delayed(
      const Duration(milliseconds: 800),
    );

    if (mounted) {
      setState(() {});
    }
  }

  // ==========================================================================
  // OFFER TAP
  // ==========================================================================

  void _handleOfferTap(
    Map<String, dynamic> offer,
  ) {
    final category =
        offer["category"] as String? ?? "All";

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoriesPage(
          initialCategory: category,
        ),
      ),
    ).then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  // ==========================================================================
  // NOTIFICATIONS
  // ==========================================================================

  void _showNotifications() {
    setState(() {
      _unreadNotifications = 0;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            20,
            20,
            20,
            30,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Notifications",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  // AI CHAT BUTTON
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(sheetContext);

                      Future.delayed(
                        const Duration(
                          milliseconds: 250,
                        ),
                        () {
                          if (!mounted) return;

                          _openChat();
                        },
                      );
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.surface2,
                        borderRadius:
                            BorderRadius.circular(13),
                        border: Border.all(
                          color: AppColors.primary
                              .withOpacity(0.30),
                        ),
                      ),
                      child: const Icon(
                        Icons.smart_toy_outlined,
                        color: AppColors.primary,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight:
                      MediaQuery.of(sheetContext)
                              .size
                              .height *
                          0.55,
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount:
                      _notifications.length,
                  separatorBuilder:
                      (_, __) =>
                          const SizedBox(height: 10),
                  itemBuilder:
                      (context, index) {
                    final n =
                        _notifications[index];

                    return Container(
                      padding:
                          const EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        color:
                            AppColors.surface2,
                        borderRadius:
                            BorderRadius.circular(
                          15,
                        ),
                        border: Border.all(
                          color: Colors.white
                              .withOpacity(0.04),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            alignment:
                                Alignment.center,
                            decoration:
                                BoxDecoration(
                              color:
                                  AppColors.background,
                              borderRadius:
                                  BorderRadius.circular(
                                12,
                              ),
                            ),
                            child: Text(
                              n["icon"] ?? "🔔",
                              style:
                                  const TextStyle(
                                fontSize: 21,
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              children: [
                                Text(
                                  n["title"] ?? "",
                                  style:
                                      const TextStyle(
                                    color:
                                        Colors.white,
                                    fontWeight:
                                        FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),

                                const SizedBox(
                                  height: 4,
                                ),

                                Text(
                                  n["subtitle"] ?? "",
                                  style:
                                      const TextStyle(
                                    color:
                                        Colors.white54,
                                    fontSize: 12,
                                  ),
                                ),

                                const SizedBox(
                                  height: 5,
                                ),

                                Text(
                                  n["time"] ?? "",
                                  style:
                                      const TextStyle(
                                    color:
                                        AppColors.primary,
                                    fontSize: 10,
                                    fontWeight:
                                        FontWeight.w600,
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

  // ==========================================================================
  // BUILD
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Chat open hai:
      // Android/Desktop back -> sirf chat close.
      //
      // Chat closed hai:
      // Normal HomePage back behavior.
      canPop: !_isChatOpen,

      onPopInvokedWithResult:
          (didPop, result) {
        if (!didPop && _isChatOpen) {
          _closeChat();
        }
      },

      child: Scaffold(
        backgroundColor:
            AppColors.background,

        body: Stack(
          children: [
            // ================================================================
            // MAIN HOME PAGE
            // ================================================================

            SafeArea(
              child: RefreshIndicator(
                color: AppColors.primary,
                backgroundColor:
                    AppColors.surface,
                onRefresh: _onRefresh,
                child: SingleChildScrollView(
                  physics:
                      const AlwaysScrollableScrollPhysics(
                    parent:
                        BouncingScrollPhysics(),
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      _buildTopBar(),

                      const SizedBox(height: 8),

                      _buildGreetingSection(),

                      const SizedBox(height: 18),

                      _buildOfferSlider(),

                      const SizedBox(height: 16),

                      _buildFlashSaleTimer(),

                      const SizedBox(height: 22),

                      _buildStatusSection(),

                      const SizedBox(height: 25),

                      _buildSectionHeader(
                        'Categories',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const CategoriesPage(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 14),

                      _buildCategories(),

                      const SizedBox(height: 25),

                      _buildSectionHeader(
                        'Popular Foods',
                        onTap: () {},
                      ),

                      const SizedBox(height: 14),

                      _buildPopularFoods(),

                      const SizedBox(height: 25),

                      _buildSectionHeader(
                        'Nearby Restaurants',
                        onTap: () {},
                      ),

                      const SizedBox(height: 14),

                      _buildNearbyRestaurants(),

                      const SizedBox(height: 25),
                    ],
                  ),
                ),
              ),
            ),

            // ================================================================
            // AI CHAT OVERLAY
            // ================================================================

            _buildChatOverlay(),
          ],
        ),

        // ====================================================================
        // FLOATING BUTTONS
        // ====================================================================

        floatingActionButton:
            _isChatOpen
                ? null
                : Column(
                    mainAxisSize:
                        MainAxisSize.min,
                    crossAxisAlignment:
                        CrossAxisAlignment.end,
                    children: [
                      if (_cart.totalItems > 0) ...[
                        Container(
                          decoration:
                              BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(
                              18,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors
                                    .primary
                                    .withOpacity(
                                  0.22,
                                ),
                                blurRadius: 15,
                                offset:
                                    const Offset(
                                  0,
                                  5,
                                ),
                              ),
                            ],
                          ),
                          child:
                              FloatingActionButton
                                  .extended(
                            heroTag:
                                'cart_fab',
                            onPressed:
                                _openCart,
                            backgroundColor:
                                AppColors.primary,
                            foregroundColor:
                                Colors.black,
                            elevation: 8,
                            icon: const Icon(
                              Icons
                                  .shopping_cart_rounded,
                            ),
                            label: Text(
                              '${_cart.totalItems} • \$${_cart.totalPrice.toStringAsFixed(2)}',
                              style:
                                  const TextStyle(
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),
                      ],

                      _buildChatFab(),
                    ],
                  ),
      ),
    );
  }

  // ==========================================================================
  // GREETING
  // ==========================================================================

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
      padding:
          const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text:
                      "$emoji $greeting, ",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
                const TextSpan(
                  text: "Abdullah",
                  style: TextStyle(
                    color:
                        AppColors.primary,
                    fontSize: 20,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            "What would you like to eat today?",
            style: TextStyle(
              color: AppColors.white54,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // OFFER SLIDER
  // ==========================================================================

  Widget _buildOfferSlider() {
    return SizedBox(
      height: 145,
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller:
                  _offerController,
              itemCount:
                  _offers.length,
              onPageChanged: (index) {
                setState(() {
                  _currentOfferPage =
                      index;
                });
              },
              itemBuilder:
                  (context, index) {
                final offer =
                    _offers[index];

                final colors =
                    offer["colors"]
                        as List<Color>;

                return Padding(
                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 20,
                  ),
                  child: Container(
                    decoration:
                        BoxDecoration(
                      gradient:
                          LinearGradient(
                        colors: colors,
                        begin:
                            Alignment.topLeft,
                        end: Alignment
                            .bottomRight,
                      ),
                      borderRadius:
                          BorderRadius
                              .circular(
                        20,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: colors
                              .first
                              .withOpacity(
                            0.28,
                          ),
                          blurRadius: 18,
                          offset:
                              const Offset(
                            0,
                            8,
                          ),
                        ),
                      ],
                    ),
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 18,
                      vertical: 15,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 58,
                          height: 58,
                          decoration:
                              BoxDecoration(
                            color: Colors
                                .white
                                .withOpacity(
                              0.12,
                            ),
                            shape:
                                BoxShape.circle,
                          ),
                          alignment:
                              Alignment.center,
                          child: Text(
                            offer["emoji"]
                                as String,
                            style:
                                const TextStyle(
                              fontSize: 34,
                            ),
                          ),
                        ),

                        const SizedBox(
                          width: 13,
                        ),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .center,
                            children: [
                              Text(
                                offer["title"]
                                    as String,
                                style:
                                    const TextStyle(
                                  color:
                                      Colors.white,
                                  fontSize: 20,
                                  fontWeight:
                                      FontWeight
                                          .w800,
                                ),
                              ),

                              const SizedBox(
                                height: 4,
                              ),

                              Text(
                                offer["subtitle"]
                                    as String,
                                style:
                                    const TextStyle(
                                  color:
                                      Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),

                        GestureDetector(
                          onTap: () =>
                              _handleOfferTap(
                            offer,
                          ),
                          child:
                              Container(
                            padding:
                                const EdgeInsets
                                    .symmetric(
                              horizontal: 12,
                              vertical: 9,
                            ),
                            decoration:
                                BoxDecoration(
                              color: Colors
                                  .black
                                  .withOpacity(
                                0.30,
                              ),
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                30,
                              ),
                            ),
                            child:
                                const Row(
                              mainAxisSize:
                                  MainAxisSize
                                      .min,
                              children: [
                                Text(
                                  "Order Now",
                                  style:
                                      TextStyle(
                                    color:
                                        Colors.white,
                                    fontSize:
                                        11,
                                    fontWeight:
                                        FontWeight
                                            .w700,
                                  ),
                                ),
                                SizedBox(
                                  width: 4,
                                ),
                                Icon(
                                  Icons
                                      .arrow_forward_rounded,
                                  color:
                                      Colors.white,
                                  size: 14,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 9),

          Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: List.generate(
              _offers.length,
              (index) {
                final isActive =
                    index ==
                        _currentOfferPage;

                return AnimatedContainer(
                  duration:
                      const Duration(
                    milliseconds: 300,
                  ),
                  margin:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 3,
                  ),
                  width:
                      isActive ? 18 : 6,
                  height: 5,
                  decoration:
                      BoxDecoration(
                    color: isActive
                        ? AppColors
                            .primary
                        : Colors.white24,
                    borderRadius:
                        BorderRadius
                            .circular(4),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // FLASH SALE
  // ==========================================================================

  Widget _buildFlashSaleTimer() {
    final hours =
        _flashSaleRemaining.inHours
            .toString()
            .padLeft(2, '0');

    final minutes =
        (_flashSaleRemaining
                    .inMinutes %
                60)
            .toString()
            .padLeft(2, '0');

    final seconds =
        (_flashSaleRemaining
                    .inSeconds %
                60)
            .toString()
            .padLeft(2, '0');

    return Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      child: Container(
        height: 68,
        padding:
            const EdgeInsets.symmetric(
          horizontal: 14,
        ),
        decoration:
            BoxDecoration(
          color: AppColors.surface,
          borderRadius:
              BorderRadius.circular(17),
          border: Border.all(
            color: AppColors.primary
                .withOpacity(0.48),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary
                  .withOpacity(0.07),
              blurRadius: 18,
            ),
          ],
        ),
        child: Row(
          children: [
            const Text(
              "⚡",
              style:
                  TextStyle(fontSize: 25),
            ),

            const SizedBox(width: 9),

            const Expanded(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment
                        .center,
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Text(
                    "Flash Sale",
                    style:
                        TextStyle(
                      color:
                          Colors.white,
                      fontSize: 15,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    "Limited Time Offers",
                    style:
                        TextStyle(
                      color:
                          Colors.white54,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),

            _timeBox(hours),
            _timeSeparator(),
            _timeBox(minutes),
            _timeSeparator(),
            _timeBox(seconds),

            const SizedBox(width: 7),

            const Icon(
              Icons.chevron_right_rounded,
              color:
                  Colors.white70,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _timeBox(String value) {
    return Container(
      width: 31,
      height: 31,
      alignment:
          Alignment.center,
      decoration:
          BoxDecoration(
        color: AppColors.primary,
        borderRadius:
            BorderRadius.circular(7),
      ),
      child: Text(
        value,
        style:
            const TextStyle(
          color: Colors.black,
          fontWeight:
              FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _timeSeparator() {
    return const Padding(
      padding:
          EdgeInsets.symmetric(
        horizontal: 3,
      ),
      child: Text(
        ":",
        style:
            TextStyle(
          color: Colors.white,
          fontWeight:
              FontWeight.bold,
        ),
      ),
    );
  }

  // ==========================================================================
  // STORIES
  // ==========================================================================

  Widget _buildStatusSection() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Padding(
          padding:
              EdgeInsets.symmetric(
            horizontal: 20,
          ),
          child: Text(
            'Stories',
            style:
                TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(height: 12),

        SizedBox(
          height: 101,
          child:
              ListView.builder(
            scrollDirection:
                Axis.horizontal,
            padding:
                const EdgeInsets
                    .symmetric(
              horizontal: 16,
            ),
            itemCount:
                _stories.length,
            itemBuilder:
                (context, index) {
              final story =
                  _stories[index];

              final bgColor =
                  _parseHexColor(
                story['bgColor'],
              );

              return GestureDetector(
                onTap: () =>
                    _openStory(index),
                child: Container(
                  margin:
                      const EdgeInsets
                          .only(
                    right: 12,
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 68,
                        height: 68,
                        padding:
                            const EdgeInsets
                                .all(2),
                        decoration:
                            BoxDecoration(
                          shape: BoxShape
                              .circle,
                          gradient:
                              LinearGradient(
                            colors: [
                              AppColors
                                  .primary,
                              bgColor,
                              bgColor
                                  .withOpacity(
                                0.6,
                              ),
                            ],
                          ),
                        ),
                        child: Container(
                          decoration:
                              BoxDecoration(
                            shape: BoxShape
                                .circle,
                            color: bgColor,
                          ),
                          child: Center(
                            child: Text(
                              story['image'] ??
                                  '🍔',
                              style:
                                  const TextStyle(
                                fontSize: 31,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 6,
                      ),

                      Text(
                        story['name'] ??
                            'Food',
                        style:
                            const TextStyle(
                          color:
                              Colors.white70,
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

  // ==========================================================================
  // ADDRESS
  // ==========================================================================

  void _showAddressDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor:
          AppColors.surface,
      shape:
          const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder:
          (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.fromLTRB(
              20,
              20,
              20,
              25,
            ),
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                // HEADER

                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration:
                          BoxDecoration(
                        color: AppColors
                            .primary
                            .withOpacity(
                          0.12,
                        ),
                        borderRadius:
                            BorderRadius
                                .circular(
                          13,
                        ),
                      ),
                      child:
                          const Icon(
                        Icons
                            .location_on_rounded,
                        color:
                            AppColors
                                .primary,
                        size: 22,
                      ),
                    ),

                    const SizedBox(
                        width: 12),

                    const Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          Text(
                            "Deliver To",
                            style:
                                TextStyle(
                              color:
                                  Colors.white,
                              fontSize: 19,
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),
                          SizedBox(
                              height: 3),
                          Text(
                            "Choose your delivery location",
                            style:
                                TextStyle(
                              color:
                                  Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                    GestureDetector(
                      onTap: () {
                        Navigator.pop(
                          bottomSheetContext,
                        );
                      },
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration:
                            BoxDecoration(
                          color:
                              AppColors
                                  .surface2,
                          borderRadius:
                              BorderRadius
                                  .circular(
                            11,
                          ),
                        ),
                        child:
                            const Icon(
                          Icons.close,
                          color:
                              Colors.white70,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                    height: 20),

                // CURRENT LOCATION

                GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedAddress =
                          "Current Location";

                      selectedAddressDetail =
                          "Using GPS";
                    });

                    Navigator.pop(
                      bottomSheetContext,
                    );

                    ScaffoldMessenger
                        .of(context)
                        .showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Current location selected",
                        ),
                        backgroundColor:
                            AppColors
                                .success,
                      ),
                    );
                  },
                  child: Container(
                    width:
                        double.infinity,
                    padding:
                        const EdgeInsets
                            .all(14),
                    margin:
                        const EdgeInsets
                            .only(
                      bottom: 14,
                    ),
                    decoration:
                        BoxDecoration(
                      color:
                          AppColors
                              .surface2,
                      borderRadius:
                          BorderRadius
                              .circular(
                        16,
                      ),
                      border:
                          Border.all(
                        color: selectedAddress ==
                                "Current Location"
                            ? AppColors
                                .primary
                            : Colors
                                .transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration:
                              BoxDecoration(
                            color: AppColors
                                .primary
                                .withOpacity(
                              0.12,
                            ),
                            borderRadius:
                                BorderRadius
                                    .circular(
                              12,
                            ),
                          ),
                          child:
                              const Icon(
                            Icons
                                .my_location,
                            color:
                                AppColors
                                    .primary,
                          ),
                        ),

                        const SizedBox(
                            width: 12),

                        const Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              Text(
                                "Current Location",
                                style:
                                    TextStyle(
                                  color:
                                      Colors.white,
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                  fontSize:
                                      14,
                                ),
                              ),
                              SizedBox(
                                  height: 4),
                              Text(
                                "Using GPS",
                                style:
                                    TextStyle(
                                  color:
                                      Colors.white54,
                                  fontSize:
                                      12,
                                ),
                              ),
                            ],
                          ),
                        ),

                        if (selectedAddress ==
                            "Current Location")
                          const Icon(
                            Icons
                                .check_circle_rounded,
                            color:
                                AppColors
                                    .primary,
                          )
                        else
                          const Icon(
                            Icons
                                .arrow_forward_ios_rounded,
                            color:
                                Colors.white38,
                            size: 15,
                          ),
                      ],
                    ),
                  ),
                ),

                const Text(
                  "Saved Addresses",
                  style:
                      TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(
                    height: 10),

                ...addresses
                    .where(
                      (address) =>
                          address["title"] !=
                          "Current Location",
                    )
                    .map(
                  (address) {
                    final String title =
                        address["title"]
                            as String;

                    final String subtitle =
                        address["subtitle"]
                            as String;

                    final IconData icon =
                        address["icon"]
                            as IconData;

                    final String time =
                        address["time"]
                            as String;

                    final bool isSelected =
                        selectedAddress ==
                            title;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedAddress =
                              title;

                          selectedAddressDetail =
                              subtitle;
                        });

                        Navigator.pop(
                          bottomSheetContext,
                        );

                        ScaffoldMessenger
                            .of(context)
                            .showSnackBar(
                          SnackBar(
                            content: Text(
                              "$title address selected",
                            ),
                            backgroundColor:
                                AppColors
                                    .success,
                          ),
                        );
                      },
                      child: Container(
                        width:
                            double.infinity,
                        padding:
                            const EdgeInsets
                                .all(14),
                        margin:
                            const EdgeInsets
                                .only(
                          bottom: 10,
                        ),
                        decoration:
                            BoxDecoration(
                          color:
                              AppColors
                                  .surface2,
                          borderRadius:
                              BorderRadius
                                  .circular(
                            16,
                          ),
                          border:
                              Border.all(
                            color:
                                isSelected
                                    ? AppColors
                                        .primary
                                    : Colors
                                        .transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration:
                                  BoxDecoration(
                                color:
                                    AppColors
                                        .background,
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  12,
                                ),
                              ),
                              child: Icon(
                                icon,
                                color:
                                    isSelected
                                        ? AppColors
                                            .primary
                                        : Colors
                                            .white70,
                              ),
                            ),

                            const SizedBox(
                                width: 12),

                            Expanded(
                              child:
                                  Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        title,
                                        style:
                                            const TextStyle(
                                          color:
                                              Colors.white,
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                          fontSize:
                                              14,
                                        ),
                                      ),

                                      if (address[
                                              "default"] ==
                                          true)
                                        Container(
                                          margin:
                                              const EdgeInsets
                                                  .only(
                                            left:
                                                8,
                                          ),
                                          padding:
                                              const EdgeInsets
                                                  .symmetric(
                                            horizontal:
                                                6,
                                            vertical:
                                                2,
                                          ),
                                          decoration:
                                              BoxDecoration(
                                            color: AppColors
                                                .primary
                                                .withOpacity(
                                              0.13,
                                            ),
                                            borderRadius:
                                                BorderRadius
                                                    .circular(
                                              5,
                                            ),
                                          ),
                                          child:
                                              const Text(
                                            "Default",
                                            style:
                                                TextStyle(
                                              color:
                                                  AppColors
                                                      .primary,
                                              fontSize:
                                                  9,
                                              fontWeight:
                                                  FontWeight
                                                      .bold,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),

                                  const SizedBox(
                                      height: 4),

                                  Text(
                                    subtitle,
                                    maxLines: 1,
                                    overflow:
                                        TextOverflow
                                            .ellipsis,
                                    style:
                                        const TextStyle(
                                      color:
                                          Colors.white54,
                                      fontSize:
                                          12,
                                    ),
                                  ),

                                  const SizedBox(
                                      height: 4),

                                  Row(
                                    children: [
                                      const Icon(
                                        Icons
                                            .access_time_rounded,
                                        color:
                                            Colors.white38,
                                        size: 12,
                                      ),
                                      const SizedBox(
                                          width: 4),
                                      Text(
                                        time,
                                        style:
                                            const TextStyle(
                                          color:
                                              Colors.white38,
                                          fontSize:
                                              10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            Icon(
                              isSelected
                                  ? Icons
                                      .check_circle_rounded
                                  : Icons
                                      .radio_button_unchecked_rounded,
                              color:
                                  isSelected
                                      ? AppColors
                                          .primary
                                      : Colors
                                          .white24,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(
                    height: 8),

                // ADD ADDRESS

                GestureDetector(
                  onTap: () {
                    Navigator.pop(
                      bottomSheetContext,
                    );

                    ScaffoldMessenger
                        .of(context)
                        .showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Add New Address feature coming soon",
                        ),
                        backgroundColor:
                            AppColors
                                .primary,
                      ),
                    );
                  },
                  child: Container(
                    width:
                        double.infinity,
                    padding:
                        const EdgeInsets
                            .symmetric(
                      vertical: 15,
                    ),
                    decoration:
                        BoxDecoration(
                      color:
                          AppColors.primary,
                      borderRadius:
                          BorderRadius
                              .circular(
                        15,
                      ),
                    ),
                    child:
                        const Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .center,
                      children: [
                        Icon(
                          Icons
                              .add_location_alt_rounded,
                          color:
                              Colors.black,
                          size: 20,
                        ),
                        SizedBox(
                            width: 8),
                        Text(
                          "Add New Address",
                          style:
                              TextStyle(
                            color:
                                Colors.black,
                            fontWeight:
                                FontWeight
                                    .bold,
                            fontSize: 14,
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
      },
    );
  }

  // ==========================================================================
  // TOP BAR
  // ==========================================================================

  Widget _buildTopBar() {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 12,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.location_on_rounded,
            color: AppColors.primary,
            size: 22,
          ),

          const SizedBox(width: 7),

          Expanded(
            child: GestureDetector(
              onTap:
                  _showAddressDialog,
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Deliver To",
                    style:
                        TextStyle(
                      color:
                          Colors.white54,
                      fontSize: 10,
                    ),
                  ),

                  const SizedBox(
                      height: 2),

                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "$selectedAddress • $selectedAddressDetail",
                          maxLines: 1,
                          overflow:
                              TextOverflow
                                  .ellipsis,
                          style:
                              const TextStyle(
                            color:
                                Colors.white,
                            fontWeight:
                                FontWeight
                                    .bold,
                            fontSize: 13,
                          ),
                        ),
                      ),

                      const Icon(
                        Icons
                            .keyboard_arrow_down_rounded,
                        color:
                            Colors.white,
                        size: 19,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 10),

          _topIconButton(
            icon: Icons
                .shopping_cart_outlined,
            badge:
                _cart.totalItems > 0
                    ? '${_cart.totalItems}'
                    : null,
            badgeColor:
                AppColors.primary,
            onTap: _openCart,
          ),

          const SizedBox(width: 9),

          _topIconButton(
            icon: Icons
                .notifications_none_rounded,
            badge:
                _unreadNotifications > 0
                    ? '$_unreadNotifications'
                    : null,
            badgeColor:
                Colors.redAccent,
            onTap:
                _showNotifications,
          ),
        ],
      ),
    );
  }

  Widget _topIconButton({
    required IconData icon,
    required VoidCallback onTap,
    String? badge,
    required Color badgeColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior:
            Clip.none,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration:
                BoxDecoration(
              color:
                  AppColors.surface,
              borderRadius:
                  BorderRadius
                      .circular(13),
              border:
                  Border.all(
                color: Colors.white
                    .withOpacity(
                  0.04,
                ),
              ),
            ),
            child: Icon(
              icon,
              color:
                  Colors.white,
              size: 22,
            ),
          ),

          if (badge != null)
            Positioned(
              right: -3,
              top: -4,
              child:
                  Container(
                constraints:
                    const BoxConstraints(
                  minWidth: 17,
                  minHeight: 17,
                ),
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 4,
                ),
                alignment:
                    Alignment.center,
                decoration:
                    BoxDecoration(
                  color:
                      badgeColor,
                  shape:
                      BoxShape.circle,
                ),
                child: Text(
                  badge,
                  style:
                      TextStyle(
                    color: badgeColor ==
                            AppColors
                                .primary
                        ? Colors
                            .black
                        : Colors
                            .white,
                    fontSize: 9,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ==========================================================================
  // SECTION HEADER
  // ==========================================================================

  Widget _buildSectionHeader(
    String title, {
    required VoidCallback onTap,
  }) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment
                .spaceBetween,
        children: [
          Text(
            title,
            style:
                const TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          GestureDetector(
            onTap: onTap,
            child: const Row(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                Text(
                  'View all',
                  style:
                      TextStyle(
                    color:
                        AppColors
                            .primary,
                    fontSize: 12,
                    fontWeight:
                        FontWeight
                            .w700,
                  ),
                ),
                SizedBox(width: 4),
                Icon(
                  Icons
                      .arrow_forward_rounded,
                  color:
                      AppColors
                          .primary,
                  size: 15,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // CATEGORIES
  // ==========================================================================

  Widget _buildCategories() {
    return SizedBox(
      height: 94,
      child:
          ListView.builder(
        scrollDirection:
            Axis.horizontal,
        padding:
            const EdgeInsets
                .symmetric(
          horizontal: 16,
        ),
        itemCount:
            allCategories.length,
        itemBuilder:
            (context, index) {
          final cat =
              allCategories[index];

          final isSelected =
              _selectedCategory ==
                  cat.name;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory =
                    isSelected
                        ? 'All'
                        : cat.name;
              });
            },
            child: Padding(
              padding:
                  const EdgeInsets
                      .symmetric(
                horizontal: 6,
              ),
              child:
                  AnimatedScale(
                scale:
                    isSelected
                        ? 1.05
                        : 1.0,
                duration:
                    const Duration(
                  milliseconds:
                      200,
                ),
                child:
                    Column(
                  children: [
                    AnimatedContainer(
                      duration:
                          const Duration(
                        milliseconds:
                            200,
                      ),
                      width: 62,
                      height: 62,
                      decoration:
                          BoxDecoration(
                        color:
                            isSelected
                                ? AppColors
                                    .primary
                                    .withOpacity(
                                  0.14,
                                )
                                : AppColors
                                    .surface,
                        border:
                            Border.all(
                          color:
                              isSelected
                                  ? AppColors
                                      .primary
                                  : Colors
                                      .white
                                      .withOpacity(
                                    0.05,
                                  ),
                          width:
                              isSelected
                                  ? 1.5
                                  : 1,
                        ),
                        borderRadius:
                            BorderRadius
                                .circular(
                          17,
                        ),
                        boxShadow:
                            isSelected
                                ? [
                                    BoxShadow(
                                      color: AppColors
                                          .primary
                                          .withOpacity(
                                        0.12,
                                      ),
                                      blurRadius:
                                          10,
                                    ),
                                  ]
                                : null,
                      ),
                      child:
                          Center(
                        child:
                            Text(
                          cat.emoji,
                          style:
                              const TextStyle(
                            fontSize:
                                27,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                        height: 6),

                    Text(
                      cat.name,
                      style:
                          TextStyle(
                        color: isSelected
                            ? AppColors
                                .primary
                            : Colors
                                .white70,
                        fontSize:
                            11,
                        fontWeight:
                            isSelected
                                ? FontWeight
                                    .bold
                                : FontWeight
                                    .normal,
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

  // ==========================================================================
  // POPULAR FOODS
  // ==========================================================================

  Widget _buildPopularFoods() {
    final foods =
        _filteredFoods;

    return SizedBox(
      height: 240,
      child:
          ListView.builder(
        scrollDirection:
            Axis.horizontal,
        padding:
            const EdgeInsets
                .symmetric(
          horizontal: 16,
        ),
        itemCount:
            foods.length,
        itemBuilder:
            (context, index) {
          return Padding(
            padding:
                const EdgeInsets
                    .only(
              right: 13,
            ),
            child:
                _buildFoodCard(
              foods[index],
            ),
          );
        },
      ),
    );
  }

  // ==========================================================================
  // FOOD CARD
  // ==========================================================================

  Widget _buildFoodCard(
    FoodItem food,
  ) {
    final isFav =
        _favManager
            .isFavorite(
      food.id,
    );

    final discount =
        _getDiscount(
      food.id,
    );

    return GestureDetector(
      onTap: () =>
          _openFood(food),
      child: Container(
        width: 160,
        decoration:
            BoxDecoration(
          color:
              AppColors.surface,
          borderRadius:
              BorderRadius
                  .circular(
            18,
          ),
          border:
              Border.all(
            color: Colors.white
                .withOpacity(
              0.045,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors
                  .black
                  .withOpacity(
                0.18,
              ),
              blurRadius: 10,
              offset:
                  const Offset(
                0,
                5,
              ),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              children: [
                SizedBox(
                  height: 120,
                  width:
                      double.infinity,
                  child: Center(
                    child: Hero(
                      tag:
                          'food_${food.id}',
                      child:
                          Text(
                        food.emoji,
                        style:
                            const TextStyle(
                          fontSize:
                              66,
                        ),
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding:
                      const EdgeInsets
                          .fromLTRB(
                    11,
                    0,
                    10,
                    11,
                  ),
                  child:
                      Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons
                                .star_rounded,
                            color:
                                AppColors
                                    .primary,
                            size: 14,
                          ),
                          const SizedBox(
                              width: 3),
                          Text(
                            food.rating
                                .toStringAsFixed(
                              1,
                            ),
                            style:
                                const TextStyle(
                              color:
                                  Colors
                                      .white70,
                              fontSize:
                                  11,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                          height: 4),

                      Text(
                        food.name,
                        maxLines: 1,
                        overflow:
                            TextOverflow
                                .ellipsis,
                        style:
                            const TextStyle(
                          color:
                              Colors.white,
                          fontWeight:
                              FontWeight
                                  .w600,
                          fontSize:
                              13,
                        ),
                      ),

                      const SizedBox(
                          height: 6),

                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .spaceBetween,
                        children: [
                          Text(
                            '\$${food.price}',
                            style:
                                const TextStyle(
                              color:
                                  AppColors
                                      .primary,
                              fontSize:
                                  14,
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),

                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _cart.add(
                                  food.id,
                                );
                              });

                              ScaffoldMessenger
                                  .of(
                                context,
                              ).showSnackBar(
                                SnackBar(
                                  duration:
                                      const Duration(
                                    seconds:
                                        1,
                                  ),
                                  backgroundColor:
                                      AppColors
                                          .success,
                                  behavior:
                                      SnackBarBehavior
                                          .floating,
                                  content:
                                      Text(
                                    "${food.name} added to cart",
                                  ),
                                ),
                              );
                            },
                            child:
                                Container(
                              width: 31,
                              height: 31,
                              decoration:
                                  const BoxDecoration(
                                color:
                                    AppColors
                                        .primary,
                                shape:
                                    BoxShape
                                        .circle,
                              ),
                              child:
                                  const Icon(
                                Icons
                                    .shopping_cart_rounded,
                                color:
                                    Colors
                                        .black,
                                size: 15,
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

            // DISCOUNT

            if (discount > 0)
              Positioned(
                top: 8,
                left: 8,
                child:
                    Container(
                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 7,
                    vertical: 4,
                  ),
                  decoration:
                      BoxDecoration(
                    color:
                        AppColors
                            .danger,
                    borderRadius:
                        BorderRadius
                            .circular(
                      7,
                    ),
                  ),
                  child:
                      Text(
                    "-$discount%",
                    style:
                        const TextStyle(
                      color:
                          Colors.white,
                      fontSize: 9,
                      fontWeight:
                          FontWeight
                              .bold,
                    ),
                  ),
                ),
              ),

            // FAVORITE

            Positioned(
              top: 8,
              right: 8,
              child:
                  GestureDetector(
                onTap: () {
                  setState(() {
                    _favManager
                        .toggle(
                      food.id,
                    );
                  });
                },
                child:
                    Container(
                  width: 29,
                  height: 29,
                  decoration:
                      BoxDecoration(
                    color: Colors
                        .black
                        .withOpacity(
                      0.45,
                    ),
                    shape:
                        BoxShape
                            .circle,
                  ),
                  child:
                      Icon(
                    isFav
                        ? Icons
                            .favorite_rounded
                        : Icons
                            .favorite_border_rounded,
                    color: isFav
                        ? Colors
                            .redAccent
                        : Colors
                            .white,
                    size: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // NEARBY RESTAURANTS
  // ==========================================================================

  Widget _buildNearbyRestaurants() {
    return SizedBox(
      height: 170,
      child:
          ListView.builder(
        scrollDirection:
            Axis.horizontal,
        padding:
            const EdgeInsets
                .symmetric(
          horizontal: 16,
        ),
        itemCount:
            _restaurants.length,
        itemBuilder:
            (context, index) {
          final r =
              _restaurants[index];

          return Container(
            width: 160,
            margin:
                const EdgeInsets
                    .only(
              right: 13,
            ),
            padding:
                const EdgeInsets
                    .all(14),
            decoration:
                BoxDecoration(
              color:
                  AppColors.surface,
              borderRadius:
                  BorderRadius
                      .circular(
                18,
              ),
              border:
                  Border.all(
                color: Colors
                    .white
                    .withOpacity(
                  0.045,
                ),
              ),
            ),
            child:
                Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  alignment:
                      Alignment.center,
                  decoration:
                      BoxDecoration(
                    color:
                        AppColors
                            .surface2,
                    borderRadius:
                        BorderRadius
                            .circular(
                      13,
                    ),
                  ),
                  child:
                      Text(
                    r["emoji"]
                        as String,
                    style:
                        const TextStyle(
                      fontSize: 26,
                    ),
                  ),
                ),

                const SizedBox(
                    height: 10),

                Text(
                  r["name"]
                      as String,
                  style:
                      const TextStyle(
                    color:
                        Colors.white,
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow:
                      TextOverflow
                          .ellipsis,
                ),

                const SizedBox(
                    height: 6),

                Row(
                  children: [
                    const Icon(
                      Icons
                          .star_rounded,
                      color:
                          AppColors
                              .primary,
                      size: 13,
                    ),

                    const SizedBox(
                        width: 3),

                    Text(
                      "${r["rating"]}",
                      style:
                          const TextStyle(
                        color:
                            Colors
                                .white70,
                        fontSize: 11,
                      ),
                    ),

                    const SizedBox(
                        width: 8),

                    const Icon(
                      Icons
                          .access_time_rounded,
                      color:
                          Colors
                              .white54,
                      size: 12,
                    ),

                    const SizedBox(
                        width: 3),

                    Text(
                      "${r["time"]}",
                      style:
                          const TextStyle(
                        color:
                            Colors
                                .white70,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                    height: 6),

                if (r["freeDelivery"]
                    as bool)
                  Container(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration:
                        BoxDecoration(
                      color: AppColors
                          .success
                          .withOpacity(
                        0.13,
                      ),
                      borderRadius:
                          BorderRadius
                              .circular(
                        20,
                      ),
                    ),
                    child:
                        const Text(
                      "Free Delivery",
                      style:
                          TextStyle(
                        color:
                            AppColors
                                .greenAccent,
                        fontSize: 9,
                        fontWeight:
                            FontWeight
                                .w600,
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

// ============================================================================
// STORY VIEWER
// ============================================================================

class StoryViewer extends StatefulWidget {
  final List<Map<String, String>> stories;
  final int initialIndex;

  const StoryViewer({
    super.key,
    required this.stories,
    required this.initialIndex,
  });

  @override
  State<StoryViewer> createState() =>
      _StoryViewerState();
}

class _StoryViewerState
    extends State<StoryViewer>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late int currentIndex;
  late AnimationController _progressController;

  bool _isPaused = false;
  double _currentProgress = 0.0;

  static const Duration _storyDuration =
      Duration(seconds: 10);

  // ==========================================================================
  // HEX COLOR
  // ==========================================================================

  Color _parseHexColor(
      String? hexColor) {
    if (hexColor == null ||
        hexColor.isEmpty) {
      return const Color(
        0xFFFF5722,
      );
    }

    try {
      final cleanHex =
          hexColor.replaceFirst(
        '#',
        '',
      );

      if (cleanHex.length != 6) {
        return const Color(
          0xFFFF5722,
        );
      }

      return Color(
        int.parse(
              cleanHex,
              radix: 16,
            ) +
            0xFF000000,
      );
    } catch (e) {
      return const Color(
        0xFFFF5722,
      );
    }
  }

  // ==========================================================================
  // INIT
  // ==========================================================================

  @override
  void initState() {
    super.initState();

    currentIndex =
        widget.initialIndex;

    _pageController =
        PageController(
      initialPage:
          widget.initialIndex,
    );

    _progressController =
        AnimationController(
      vsync: this,
      duration:
          _storyDuration,
    );

    _progressController
        .addListener(() {
      if (!mounted) return;

      setState(() {
        _currentProgress =
            _progressController
                .value;
      });
    });

    _progressController
        .addStatusListener(
      (status) {
        if (status ==
                AnimationStatus
                    .completed &&
            !_isPaused) {
          _nextStory();
        }
      },
    );

    WidgetsBinding.instance
        .addPostFrameCallback(
      (_) {
        if (!_isPaused) {
          _progressController
              .forward(
            from: 0.0,
          );
        }
      },
    );
  }

  // ==========================================================================
  // PAUSE / RESUME
  // ==========================================================================

  void _pauseStory() {
    if (!_isPaused) {
      setState(() {
        _isPaused = true;
      });

      _progressController
          .stop();
    }
  }

  void _resumeStory() {
    if (_isPaused) {
      setState(() {
        _isPaused = false;
      });

      _progressController
          .forward();
    }
  }

  // ==========================================================================
  // NEXT / PREVIOUS
  // ==========================================================================

  void _nextStory() {
    _progressController
        .stop();

    _progressController
        .reset();

    if (currentIndex <
        widget.stories.length - 1) {
      _pageController
          .nextPage(
        duration:
            const Duration(
          milliseconds: 300,
        ),
        curve:
            Curves.easeInOut,
      );
    } else {
      Navigator.pop(
        context,
      );
    }
  }

  void _previousStory() {
    _progressController
        .stop();

    _progressController
        .reset();

    if (currentIndex > 0) {
      _pageController
          .previousPage(
        duration:
            const Duration(
          milliseconds: 300,
        ),
        curve:
            Curves.easeInOut,
      );
    } else {
      Navigator.pop(
        context,
      );
    }
  }

  // ==========================================================================
  // CLOSE
  // ==========================================================================

  void _closeViewer() {
    _progressController
        .stop();

    Navigator.pop(
      context,
    );
  }

  // ==========================================================================
  // DISPOSE
  // ==========================================================================

  @override
  void dispose() {
    _progressController
        .dispose();

    _pageController
        .dispose();

    super.dispose();
  }

  // ==========================================================================
  // BUILD
  // ==========================================================================

  @override
  Widget build(
      BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.black,
      body:
          GestureDetector(
        onTapUp:
            (details) {
          final screenWidth =
              MediaQuery.of(
            context,
          ).size.width;

          if (details.localPosition
                  .dx <
              screenWidth / 3) {
            _previousStory();
          } else if (details
                  .localPosition
                  .dx >
              screenWidth *
                  2 /
                  3) {
            _nextStory();
          } else {
            if (_isPaused) {
              _resumeStory();
            } else {
              _pauseStory();
            }
          }
        },
        child:
            Stack(
          children: [
            // ================================================================
            // STORY PAGES
            // ================================================================

            PageView.builder(
              controller:
                  _pageController,
              onPageChanged:
                  (index) {
                setState(() {
                  currentIndex =
                      index;
                  _currentProgress =
                      0.0;
                });

                _progressController
                    .stop();

                _progressController
                    .reset();

                if (!_isPaused) {
                  _progressController
                      .forward(
                    from: 0.0,
                  );
                }
              },
              itemCount:
                  widget.stories.length,
              itemBuilder:
                  (context, index) {
                final story =
                    widget.stories[
                        index];

                final bgColor =
                    _parseHexColor(
                  story[
                      'bgColor'],
                );

                return Container(
                  decoration:
                      BoxDecoration(
                    gradient:
                        LinearGradient(
                      colors: [
                        bgColor,
                        Colors.black,
                        Colors.black,
                      ],
                      begin:
                          Alignment
                              .topCenter,
                      end: Alignment
                          .bottomCenter,
                    ),
                  ),
                  child:
                      Center(
                    child:
                        Column(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .center,
                      children: [
                        Text(
                          story[
                                  'image'] ??
                              '🍔',
                          style:
                              const TextStyle(
                            fontSize:
                                150,
                          ),
                        ),

                        const SizedBox(
                            height: 30),

                        Text(
                          story[
                                  'name'] ??
                              'Food',
                          style:
                              const TextStyle(
                            color:
                                Colors.white,
                            fontSize:
                                28,
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),

                        const SizedBox(
                            height: 20),

                        ElevatedButton(
                          onPressed:
                              () {
                            _pauseStory();

                            final currentStory =
                                widget.stories[
                                    currentIndex];

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) =>
                                        ViewDetailPage(
                                  food: {
                                    "name":
                                        currentStory["name"] ??
                                            "",
                                    "emoji":
                                        currentStory["image"] ??
                                            "🍔",
                                    "price":
                                        15,
                                    "rating":
                                        4.8,
                                    "reviews":
                                        120,
                                    "category":
                                        "Popular",
                                    "description":
                                        "${currentStory["name"] ?? "Food"} is one of our most popular dishes. Made with fresh ingredients and served hot.",
                                  },
                                ),
                              ),
                            ).then(
                              (_) {
                                if (mounted) {
                                  _resumeStory();
                                }
                              },
                            );
                          },
                          style:
                              ElevatedButton
                                  .styleFrom(
                            backgroundColor:
                                AppColors
                                    .primary,
                            foregroundColor:
                                Colors
                                    .black,
                            elevation:
                                4,
                            padding:
                                const EdgeInsets
                                    .symmetric(
                              horizontal:
                                  32,
                              vertical:
                                  12,
                            ),
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                30,
                              ),
                            ),
                          ),
                          child:
                              const Text(
                            "View Details",
                            style:
                                TextStyle(
                              fontSize:
                                  16,
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // ================================================================
            // PROGRESS BARS
            // ================================================================

            Positioned(
              top: 40,
              left: 10,
              right: 10,
              child:
                  Row(
                children:
                    List.generate(
                  widget.stories
                      .length,
                  (index) {
                    return Expanded(
                      child:
                          Container(
                        margin:
                            const EdgeInsets
                                .symmetric(
                          horizontal:
                              3,
                        ),
                        height: 3,
                        decoration:
                            BoxDecoration(
                          color: Colors
                              .white
                              .withOpacity(
                            0.30,
                          ),
                          borderRadius:
                              BorderRadius
                                  .circular(
                            2,
                          ),
                        ),
                        child:
                            Align(
                          alignment:
                              Alignment
                                  .centerLeft,
                          child:
                              Container(
                            width:
                                index <
                                        currentIndex
                                    ? double
                                        .infinity
                                    : index ==
                                            currentIndex
                                        ? MediaQuery.of(
                                                    context)
                                                .size
                                                .width /
                                            widget
                                                .stories
                                                .length *
                                            _currentProgress
                                        : 0,
                            decoration:
                                BoxDecoration(
                              color:
                                  AppColors
                                      .primary,
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // ================================================================
            // STORY HEADER
            // ================================================================

            Positioned(
              top: 45,
              left: 20,
              right: 20,
              child:
                  Row(
                mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration:
                            BoxDecoration(
                          shape:
                              BoxShape
                                  .circle,
                          gradient:
                              LinearGradient(
                            colors: [
                              AppColors
                                  .primary,
                              _parseHexColor(
                                widget
                                        .stories[
                                    currentIndex][
                                    'bgColor'],
                              ),
                            ],
                          ),
                        ),
                        child:
                            Center(
                          child:
                              Text(
                            widget
                                    .stories[
                                currentIndex][
                                'image'] ??
                                '🍔',
                            style:
                                const TextStyle(
                              fontSize:
                                  24,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(
                          width: 10),

                      Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          Text(
                            widget
                                    .stories[
                                currentIndex][
                                'name'] ??
                                'Food',
                            style:
                                const TextStyle(
                              color:
                                  Colors.white,
                              fontWeight:
                                  FontWeight
                                      .bold,
                              fontSize:
                                  14,
                            ),
                          ),
                          const Text(
                            'Just now',
                            style:
                                TextStyle(
                              color:
                                  Colors.white70,
                              fontSize:
                                  10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  GestureDetector(
                    onTap:
                        _closeViewer,
                    child:
                        Container(
                      width: 40,
                      height: 40,
                      decoration:
                          const BoxDecoration(
                        color:
                            Colors.black45,
                        shape:
                            BoxShape
                                .circle,
                      ),
                      child:
                          const Icon(
                        Icons.close,
                        color:
                            Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ================================================================
            // PAUSE ICON
            // ================================================================

            if (_isPaused)
              Center(
                child:
                    Container(
                  width: 60,
                  height: 60,
                  decoration:
                      BoxDecoration(
                    color: Colors
                        .black
                        .withOpacity(
                      0.65,
                    ),
                    shape:
                        BoxShape
                            .circle,
                    border:
                        Border.all(
                      color: AppColors
                          .primary
                          .withOpacity(
                        0.35,
                      ),
                    ),
                  ),
                  child:
                      const Icon(
                    Icons
                        .pause_rounded,
                    color:
                        Colors.white,
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