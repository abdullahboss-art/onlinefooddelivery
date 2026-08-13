// // ─── USER MODEL ─────────────────────────────
// class AppUser {
//   final String name;
//   final String email;
//   final String? imageUrl;

//   AppUser({
//     required this.name,
//     required this.email,
//     this.imageUrl,
//   });
// }

// // ─── FOOD MODEL ─────────────────────────────
// class FoodItem {
//   final String id;
//   final String name;
//   final double price;
//   final double rating;
//   final String emoji;
//   final String category;
//   final String description;
//   final int reviews;

//   const FoodItem({
//     required this.id,
//     required this.name,
//     required this.price,
//     required this.rating,
//     required this.emoji,
//     required this.category,
//     required this.description,
//     required this.reviews,
//   });
// }

// // ─── CATEGORY MODEL ─────────────────────────
// class Category {
//   final String name;
//   final String emoji;

//   const Category({
//     required this.name,
//     required this.emoji,
//   });
// }



// // ─── CART SINGLETON ─────────────────────────
// class CartManager {
//   static final CartManager _instance = CartManager._internal();
//   factory CartManager() => _instance;
//   CartManager._internal();

//   final Map<String, int> _items = {};
//   final List<FoodItem> _allFoods = allFoods;

//   void add(String id) => _items[id] = (_items[id] ?? 0) + 1;

//   void remove(String id) {
//     if ((_items[id] ?? 0) > 1) {
//       _items[id] = _items[id]! - 1;
//     } else {
//       _items.remove(id);
//     }
//   }

//   void clear() => _items.clear();

//   int quantity(String id) => _items[id] ?? 0;

//   int get totalItems => _items.values.fold(0, (a, b) => a + b);

//   double get totalPrice {
//     double total = 0;
//     _items.forEach((id, qty) {
//       final food = _allFoods.firstWhere(
//         (f) => f.id == id,
//         orElse: () => allFoods[0],
//       );
//       total += food.price * qty;
//     });
//     return total;
//   }

//   List<MapEntry<FoodItem, int>> get cartItems {
//     return _items.entries.map((e) {
//       final food = _allFoods.firstWhere(
//         (f) => f.id == e.key,
//         orElse: () => allFoods[0],
//       );
//       return MapEntry(food, e.value);
//     }).toList();
//   }
// }

// // ─── FAVORITES SINGLETON ─────────────────────
// // ─── FAVORITES SINGLETON ─────────────────────
// class FavoritesManager {
//   static final FavoritesManager _instance = FavoritesManager._internal();
//   factory FavoritesManager() => _instance;
//   FavoritesManager._internal();

//   final Set<String> _favorites = {};

//   void toggle(String id) {
//     if (_favorites.contains(id)) {
//       _favorites.remove(id);
//     } else {
//       _favorites.add(id);
//     }
//   }

//   bool isFavorite(String id) => _favorites.contains(id);

//   List<FoodItem> get favoriteFoods =>
//       allFoods.where((f) => _favorites.contains(f.id)).toList();
  
//   // Add this getter for debugging
//   int get favoritesCount => _favorites.length;
  
//   // Add this method to print all favorites (for debugging)
//   void printFavorites() {
//     print("Current favorites: ${_favorites.length}");
//     for (var id in _favorites) {
//       final food = allFoods.firstWhere((f) => f.id == id);
//       print(" - ${food.name} (ID: $id)");
//     }
//   }
// }
// // ─── FOOD DATA ───────────────────────────────
// const List<FoodItem> allFoods = [
//   FoodItem(
//     id: '1',
//     name: 'Cheese Burger',
//     price: 5.99,
//     rating: 4.5,
//     emoji: '🍔',
//     category: 'Burger',
//     description: 'Juicy beef patty with melted cheddar, lettuce, tomato and special sauce in a brioche bun.',
//     reviews: 234,
//   ),
//   FoodItem(
//     id: '2',
//     name: 'Pepperoni Pizza',
//     price: 8.99,
//     rating: 4.7,
//     emoji: '🍕',
//     category: 'Pizza',
//     description: 'Classic hand-tossed pizza loaded with pepperoni, mozzarella and rich tomato sauce.',
//     reviews: 412,
//   ),
//   FoodItem(
//     id: '3',
//     name: 'Meat Special',
//     price: 8.50,
//     rating: 4.3,
//     emoji: '🌮',
//     category: 'Burger',
//     description: 'Double smash patty, bacon strips, caramelized onions and smoky BBQ sauce.',
//     reviews: 189,
//   ),
//   FoodItem(
//     id: '4',
//     name: 'Pasta Alfredo',
//     price: 7.49,
//     rating: 4.6,
//     emoji: '🍝',
//     category: 'Pasta',
//     description: 'Creamy Alfredo sauce tossed with fettuccine and topped with parmesan shavings.',
//     reviews: 301,
//   ),
//   FoodItem(
//     id: '5',
//     name: 'Veggie Pizza',
//     price: 7.99,
//     rating: 4.4,
//     emoji: '🥗',
//     category: 'Pizza',
//     description: 'Garden fresh veggies on a thin crispy crust with garlic olive oil base.',
//     reviews: 156,
//   ),
//   FoodItem(
//     id: '6',
//     name: 'BBQ Burger',
//     price: 6.99,
//     rating: 4.8,
//     emoji: '🍔',
//     category: 'Burger',
//     description: 'Smoky BBQ glazed patty with crispy onion rings and coleslaw.',
//     reviews: 523,
//   ),
//   FoodItem(
//     id: '7',
//     name: 'Cold Brew',
//     price: 3.99,
//     rating: 4.5,
//     emoji: '🥤',
//     category: 'Drinks',
//     description: 'Slow-steeped 24-hour cold brew coffee served over ice with oat milk.',
//     reviews: 88,
//   ),
//   FoodItem(
//     id: '8',
//     name: 'Pasta Arrabiata',
//     price: 6.99,
//     rating: 4.2,
//     emoji: '🍝',
//     category: 'Pasta',
//     description: 'Spicy tomato sauce with garlic and chili flakes over penne pasta.',
//     reviews: 167,
//   ),
// ];

// // ─── CATEGORIES ─────────────────────────────
// const List<Category> allCategories = [
//   Category(name: 'Burger', emoji: '🍔'),
//   Category(name: 'Pizza', emoji: '🍕'),
//   Category(name: 'Pasta', emoji: '🍝'),
//   Category(name: 'Drinks', emoji: '🥤'),
//   Category(name: 'More', emoji: '···'),
// ];

// ─── USER MODEL ─────────────────────────────
class AppUser {
  final String name;
  final String email;
  final String? imageUrl;

  AppUser({
    required this.name,
    required this.email,
    this.imageUrl,
  });
}

// ─── FOOD MODEL ─────────────────────────────
class FoodItem {
  final String id;
  final String name;
  final double price;
  final double rating;
  final String emoji;
  final String category;
  final String description;
  final int reviews;
  final String? image; // optional network image url (falls back to emoji)

  const FoodItem({
    required this.id,
    required this.name,
    required this.price,
    required this.rating,
    required this.emoji,
    required this.category,
    required this.description,
    required this.reviews,
    this.image,
  });
}

// ─── CATEGORY MODEL ─────────────────────────
class Category {
  final String name;
  final String emoji;

  const Category({
    required this.name,
    required this.emoji,
  });
}



// ─── CART SINGLETON ─────────────────────────
class CartManager {
  static final CartManager _instance = CartManager._internal();
  factory CartManager() => _instance;
  CartManager._internal();

  final Map<String, int> _items = {};
  final List<FoodItem> _allFoods = allFoods;

  void add(String id) => _items[id] = (_items[id] ?? 0) + 1;

  void remove(String id) {
    if ((_items[id] ?? 0) > 1) {
      _items[id] = _items[id]! - 1;
    } else {
      _items.remove(id);
    }
  }

  void clear() => _items.clear();

  int quantity(String id) => _items[id] ?? 0;

  int get totalItems => _items.values.fold(0, (a, b) => a + b);

  double get totalPrice {
    double total = 0;
    _items.forEach((id, qty) {
      final food = _allFoods.firstWhere(
        (f) => f.id == id,
        orElse: () => allFoods[0],
      );
      total += food.price * qty;
    });
    return total;
  }

  List<MapEntry<FoodItem, int>> get cartItems {
    return _items.entries.map((e) {
      final food = _allFoods.firstWhere(
        (f) => f.id == e.key,
        orElse: () => allFoods[0],
      );
      return MapEntry(food, e.value);
    }).toList();
  }
}

// ─── FAVORITES SINGLETON ─────────────────────
class FavoritesManager {
  static final FavoritesManager _instance = FavoritesManager._internal();
  factory FavoritesManager() => _instance;
  FavoritesManager._internal();

  final Set<String> _favorites = {};

  void toggle(String id) {
    if (_favorites.contains(id)) {
      _favorites.remove(id);
    } else {
      _favorites.add(id);
    }
  }

  bool isFavorite(String id) => _favorites.contains(id);

  List<FoodItem> get favoriteFoods =>
      allFoods.where((f) => _favorites.contains(f.id)).toList();

  // Add this getter for debugging
  int get favoritesCount => _favorites.length;

  // Add this method to print all favorites (for debugging)
  void printFavorites() {
    print("Current favorites: ${_favorites.length}");
    for (var id in _favorites) {
      final food = allFoods.firstWhere((f) => f.id == id);
      print(" - ${food.name} (ID: $id)");
    }
  }
}
// ─── FOOD DATA ───────────────────────────────
const List<FoodItem> allFoods = [
  FoodItem(
    id: '1',
    name: 'Cheese Burger',
    price: 5.99,
    rating: 4.5,
    emoji: '🍔',
    category: 'Burger',
    description: 'Juicy beef patty with melted cheddar, lettuce, tomato and special sauce in a brioche bun.',
    reviews: 234,
  ),
  FoodItem(
    id: '2',
    name: 'Pepperoni Pizza',
    price: 8.99,
    rating: 4.7,
    emoji: '🍕',
    category: 'Pizza',
    description: 'Classic hand-tossed pizza loaded with pepperoni, mozzarella and rich tomato sauce.',
    reviews: 412,
  ),
  FoodItem(
    id: '3',
    name: 'Meat Special',
    price: 8.50,
    rating: 4.3,
    emoji: '🌮',
    category: 'Burger',
    description: 'Double smash patty, bacon strips, caramelized onions and smoky BBQ sauce.',
    reviews: 189,
  ),
  FoodItem(
    id: '4',
    name: 'Pasta Alfredo',
    price: 7.49,
    rating: 4.6,
    emoji: '🍝',
    category: 'Pasta',
    description: 'Creamy Alfredo sauce tossed with fettuccine and topped with parmesan shavings.',
    reviews: 301,
  ),
  FoodItem(
    id: '5',
    name: 'Veggie Pizza',
    price: 7.99,
    rating: 4.4,
    emoji: '🥗',
    category: 'Pizza',
    description: 'Garden fresh veggies on a thin crispy crust with garlic olive oil base.',
    reviews: 156,
  ),
  FoodItem(
    id: '6',
    name: 'BBQ Burger',
    price: 6.99,
    rating: 4.8,
    emoji: '🍔',
    category: 'Burger',
    description: 'Smoky BBQ glazed patty with crispy onion rings and coleslaw.',
    reviews: 523,
  ),
  FoodItem(
    id: '7',
    name: 'Cold Brew',
    price: 3.99,
    rating: 4.5,
    emoji: '🥤',
    category: 'Drinks',
    description: 'Slow-steeped 24-hour cold brew coffee served over ice with oat milk.',
    reviews: 88,
  ),
  FoodItem(
    id: '8',
    name: 'Pasta Arrabiata',
    price: 6.99,
    rating: 4.2,
    emoji: '🍝',
    category: 'Pasta',
    description: 'Spicy tomato sauce with garlic and chili flakes over penne pasta.',
    reviews: 167,
  ),
];

// ─── CATEGORIES ─────────────────────────────
const List<Category> allCategories = [
  Category(name: 'Burger', emoji: '🍔'),
  Category(name: 'Pizza', emoji: '🍕'),
  Category(name: 'Pasta', emoji: '🍝'),
  Category(name: 'Drinks', emoji: '🥤'),
  Category(name: 'More', emoji: '···'),
];