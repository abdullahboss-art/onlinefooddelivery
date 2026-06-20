

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
  String _selectedCategory = 'All';

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

  // Open status/story viewer
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(),
              const SizedBox(height: 16),
              _buildSearchBar(),
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
            ],
          ),
        ),
      ),
    );
  }

  // New Status Section (replaces banner)
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
                              Color(int.parse(_stories[index]['bgColor']!.substring(1, 7), radix: 16) + 0xFF000000),
                              Color(int.parse(_stories[index]['bgColor']!.substring(1, 7), radix: 16) + 0xFF000000).withOpacity(0.7),
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
                            _stories[index]['image']!,
                            style: const TextStyle(fontSize: 32),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _stories[index]['name']!,
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
          Row(
            children: [
              const Icon(Icons.location_on,
                  color: Color(0xFFFFC107), size: 20),
              const SizedBox(width: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Deliver to',
                    style:
                        TextStyle(color: Color(0xFF9E9E9E), fontSize: 11),
                  ),
                  GestureDetector(
                    onTap: () => _showAddressDialog(),
                    child: const Row(
                      children: [
                        Text(
                          'Home - 123, Street, City',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.white,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
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
            ],
          ),
        ],
      ),
    );
  }

  void _showAddressDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Address',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _addressTile(Icons.home, 'Home', '123, Street, City'),
            _addressTile(Icons.work, 'Work', '456, Office Road, City'),
            _addressTile(
                Icons.add_location_alt, 'Add New', 'Add new address'),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _addressTile(
      IconData icon,
      String title,
      String subtitle,
      ) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFFFFC107)),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style:
            const TextStyle(color: Color(0xFF9E9E9E), fontSize: 12),
      ),
      onTap: () => Navigator.pop(context),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _showSearchSheet(),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  children: [
                    const SizedBox(width: 14),
                    Icon(Icons.search,
                        color: Color(0xFF9E9E9E), size: 22),
                    const SizedBox(width: 10),
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
            onTap: () => _showFilterSheet(),
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

  void _showSearchSheet() {}

  void _showFilterSheet() {}

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
                _selectedCategory =
                    isSelected ? 'All' : cat.name;
              });
            },
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6),
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFFFC107)
                              .withOpacity(0.2)
                          : const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(16),
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
          );
        },
      ),
    );
  }

  Widget _buildPopularFoods() {
    final foods = _filteredFoods;

    return SizedBox(
      height: 200,
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

  Widget _buildFoodCard(FoodItem food) {
    return GestureDetector(
      onTap: () => _openFood(food),
      child: Container(
        width: 155,
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Text(
                  food.emoji,
                  style: const TextStyle(fontSize: 65),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Text(
                    food.name,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '\$${food.price}',
                    style: const TextStyle(
                      color: Color(0xFFFFC107),
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
}

// Story Viewer Page - Instagram style with working pause and close
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

class _StoryViewerState extends State<StoryViewer> with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late int currentIndex;
  Timer? _timer;
  late AnimationController _progressController;
  bool _isPaused = false;
  double _currentProgress = 0.0;

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
          // Handle tap for pause/resume - Instagram style
          final screenWidth = MediaQuery.of(context).size.width;
          if (details.localPosition.dx < screenWidth / 3) {
            // Left third - previous
            _previousStory();
          } else if (details.localPosition.dx > screenWidth * 2 / 3) {
            // Right third - next
            _nextStory();
          } else {
            // Middle third - pause/resume
            if (_isPaused) {
              _resumeStory();
            } else {
              _pauseStory();
            }
          }
        },
        child: Stack(
          children: [
            // Page View for stories
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
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(int.parse(story['bgColor']!.substring(1, 7), radix: 16) + 0xFF000000),
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
                          story['image']!,
                          style: const TextStyle(fontSize: 150),
                        ),
                        const SizedBox(height: 30),
                        Text(
                          story['name']!,
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
                            final story = widget.stories[currentIndex];
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ViewDetailPage(
                                  food: {
                                    "name": story["name"] ?? "",
                                    "emoji": story["image"] ?? "🍔",
                                    "price": 15,
                                    "rating": 4.8,
                                    "reviews": 120,
                                    "category": "Popular",
                                    "description":
                                        "${story["name"] ?? "Food"} is one of our most popular dishes. Made with fresh ingredients and served hot.",
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
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            "View Details",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // Progress bars at top
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
                                  ? MediaQuery.of(context).size.width / widget.stories.length * _currentProgress
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

            // Top bar with close button and name
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
                              Color(int.parse(widget.stories[currentIndex]['bgColor']!.substring(1, 7), radix: 16) + 0xFF000000),
                              Color(int.parse(widget.stories[currentIndex]['bgColor']!.substring(1, 7), radix: 16) + 0xFF000000).withOpacity(0.7),
                            ],
                          ),
                        ),
                        child: Center(
                          child: Text(
                            widget.stories[currentIndex]['image']!,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.stories[currentIndex]['name']!,
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

            // Pause indicator overlay
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