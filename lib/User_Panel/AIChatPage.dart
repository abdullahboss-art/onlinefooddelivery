import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:myapp/User_Panel/cart_page.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class AIChatPage extends StatefulWidget {
  final VoidCallback? onClose;

  const AIChatPage({
    super.key,
    this.onClose,
  });

  @override
  AIChatPageState createState() => AIChatPageState();
}

class AIChatPageState extends State<AIChatPage> {
  // ============================================================
  // COLORS
  // ============================================================

  static const Color yellow = Color(0xFFFFC107);
  static const Color background = Color(0xFF101010);
  static const Color card = Color(0xFF1A1A1A);
  static const Color darkCard = Color(0xFF242424);
  static const Color white = Colors.white;
  static const Color grey = Color(0xFFBDBDBD);

  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController _messageController =
      TextEditingController();

  final ScrollController _scrollController =
      ScrollController();

  final stt.SpeechToText _speech =
      stt.SpeechToText();

  final FlutterTts _flutterTts =
      FlutterTts();

  // ============================================================
  // BACKEND
  // ============================================================

  final String _backendUrl =
      "http://127.0.0.1:8000";

  // ============================================================
  // ORDER SUCCESS MEMORY
  // ============================================================

  // Ye flag tab true hoga jab order successfully place ho jayega.
  //
  // Static hone ki wajah se agar AIChatPage destroy bhi ho jaye
  // aur dobara create ho, flag app session ke andar available
  // rahega.
  static bool _orderPlacedPending = false;

  // ============================================================
  // STATES
  // ============================================================

  bool _isListening = false;
  bool _isLoading = false;

  String _selectedLanguage = "English";

  bool _conversationStarted = false;

  // ============================================================
  // MENU
  // ============================================================

  List<Map<String, dynamic>> _menuFoods = [];

  // ============================================================
  // ORDER STATES
  // ============================================================

  Map<String, dynamic>? _pendingFood;

  bool _waitingForQuantity = false;
  bool _waitingForConfirmation = false;
  bool _waitingForMoreFood = false;

  // ============================================================
  // DELIVERY ADDRESS
  // ============================================================

  bool _waitingForAddress = false;

  String? _deliveryAddress;

  // ============================================================
  // PENDING ORDER
  // ============================================================

  int? _pendingQuantity;

  double _pendingTotal = 0;

  // ============================================================
  // MESSAGES
  // ============================================================

  final List<Map<String, dynamic>> _messages = [];

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    // IMPORTANT:
    // Yahan startConversation call nahi karna.
    // HomePage se chat open hone par startChat() call hoga.
    _setupTts();
  }

  // ============================================================
  // PUBLIC START CHAT
  // ============================================================

  Future<void> startChat() async {
    if (_conversationStarted) {
      return;
    }

    _conversationStarted = true;

    await _startConversation();
  }

  // ============================================================
  // PUBLIC DELIVERED ORDER MESSAGE
  // ============================================================

  Future<void> showDeliveredOrderMessage() async {
    if (!mounted) return;

    const message =
        "🎉 Your order has been delivered!\n\n"
        "Thank you for ordering from QuickBite ❤️\n"
        "We hope you enjoyed your meal!\n\n"
        "Have a great day!";

    _addBotMessage(message);

    await _speak(
      "Your order has been delivered. "
      "Thank you for ordering from QuickBite. "
      "We hope you enjoyed your meal. "
      "Have a great day.",
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _messageController.dispose();

    _scrollController.dispose();

    _flutterTts.stop();

    _speech.stop();

    super.dispose();
  }

  // ============================================================
  // TTS
  // ============================================================

  Future<void> _setupTts() async {
    try {
      await _flutterTts.setSpeechRate(0.48);

      await _flutterTts.setVolume(1.0);

      await _flutterTts.setPitch(1.0);
    } catch (_) {}
  }

  Future<void> _speak(String text) async {
    try {
      await _flutterTts.stop();

      if (_selectedLanguage == "Urdu") {
        await _flutterTts.setLanguage("ur-PK");
      } else {
        await _flutterTts.setLanguage("en-US");
      }

      await _flutterTts.speak(text);
    } catch (_) {}
  }

  // ============================================================
  // START CONVERSATION
  // ============================================================

  Future<void> _startConversation() async {
    await Future.delayed(
      const Duration(milliseconds: 400),
    );

    if (!mounted) return;

    // ==========================================================
    // CHECK PREVIOUS SUCCESSFUL ORDER
    // ==========================================================

    if (_orderPlacedPending) {
      _orderPlacedPending = false;

      const successMessage =
          "🎉 Thank you Sir!\n\n"
          "Your order has been placed successfully.\n"
          "Your food will be prepared shortly.\n\n"
          "Have a great day! ❤️";

      setState(() {
        _messages.add({
          "sender": "bot",
          "text": successMessage,
        });
      });

      _scrollToBottom();

      await _speak(
        "Thank you Sir. "
        "Your order has been placed successfully. "
        "Your food will be prepared shortly. "
        "Have a great day.",
      );

      await _loadMenu();

      return;
    }

    // ==========================================================
    // NORMAL FIRST CHAT
    // ==========================================================

    setState(() {
      _messages.add({
        "sender": "bot",
        "text":
            "Hello Sir 👋\n"
            "How can I help you today?\n\n"
            "Please choose something from our menu.",
        "showMenu": true,
      });
    });

    _scrollToBottom();

    await _speak(
      "Hello Sir. "
      "How can I help you today? "
      "Please choose something from our menu.",
    );

    await _loadMenu();
  }

  // ============================================================
  // LOAD FOOD MENU
  // ============================================================

  Future<List<Map<String, dynamic>>> loadAllFoods() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("foods")
          .get();

      final List<Map<String, dynamic>> foods = [];

      for (final doc in snapshot.docs) {
        final data = Map<String, dynamic>.from(
          doc.data(),
        );

        data["foodId"] =
            data["foodId"] ?? doc.id;

        foods.add(data);
      }

      return foods;
    } catch (e) {
      debugPrint(
        "Food loading error: $e",
      );

      return [];
    }
  }

  Future<void> _loadMenu() async {
    final foods = await loadAllFoods();

    if (!mounted) return;

    setState(() {
      _menuFoods = foods;
    });

    if (foods.isEmpty) {
      _addBotMessage(
        "Sorry Sir 😔\n"
        "I couldn't load the menu right now.",
      );
    }

    _scrollToBottom();
  }

  // ============================================================
  // MESSAGE HELPERS
  // ============================================================

  void _addBotMessage(
    String text, {
    bool showMenu = false,
  }) {
    if (!mounted) return;

    setState(() {
      _messages.add({
        "sender": "bot",
        "text": text,
        "showMenu": showMenu,
      });
    });

    _scrollToBottom();
  }

  void _addUserMessage(String text) {
    if (!mounted) return;

    setState(() {
      _messages.add({
        "sender": "user",
        "text": text,
      });
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(
      const Duration(milliseconds: 100),
      () {
        if (!_scrollController.hasClients) {
          return;
        }

        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(
            milliseconds: 300,
          ),
          curve: Curves.easeOut,
        );
      },
    );
  }

  // ============================================================
  // NORMALIZE
  // ============================================================

  String _normalize(String text) {
    return text
        .toLowerCase()
        .replaceAll(
          RegExp(r'[^a-z0-9\s]'),
          ' ',
        )
        .replaceAll(
          RegExp(r'\s+'),
          ' ',
        )
        .trim();
  }

  // ============================================================
  // INTEGER
  // ============================================================

  int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is double) {
      return value.toInt();
    }

    return int.tryParse(
          value?.toString() ?? "",
        ) ??
        0;
  }

  // ============================================================
  // DOUBLE
  // ============================================================

  double _toDouble(dynamic value) {
    if (value is double) {
      return value;
    }

    if (value is int) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? "",
        ) ??
        0;
  }

  // ============================================================
  // QUANTITY
  // ============================================================

  int? _detectQuantity(String text) {
    final normalized = _normalize(text);

    final digitMatch = RegExp(
      r'\b(\d+)\b',
    ).firstMatch(normalized);

    if (digitMatch != null) {
      final number = int.tryParse(
        digitMatch.group(1)!,
      );

      if (number != null &&
          number >= 1 &&
          number <= 50) {
        return number;
      }
    }

    const englishNumbers = {
      "one": 1,
      "two": 2,
      "three": 3,
      "four": 4,
      "five": 5,
      "six": 6,
      "seven": 7,
      "eight": 8,
      "nine": 9,
      "ten": 10,
      "eleven": 11,
      "twelve": 12,
      "thirteen": 13,
      "fourteen": 14,
      "fifteen": 15,
      "sixteen": 16,
      "seventeen": 17,
      "eighteen": 18,
      "nineteen": 19,
      "twenty": 20,
    };

    for (final entry
        in englishNumbers.entries) {
      if (normalized
          .split(' ')
          .contains(entry.key)) {
        return entry.value;
      }
    }

    const romanUrduNumbers = {
      "ek": 1,
      "aik": 1,
      "do": 2,
      "teen": 3,
      "char": 4,
      "chaar": 4,
      "paanch": 5,
      "panch": 5,
      "che": 6,
      "chay": 6,
      "chey": 6,
      "saat": 7,
      "aath": 8,
      "aat": 8,
      "nau": 9,
      "nao": 9,
      "das": 10,
    };

    for (final entry
        in romanUrduNumbers.entries) {
      if (normalized
          .split(' ')
          .contains(entry.key)) {
        return entry.value;
      }
    }

    return null;
  }

  // ============================================================
  // FIND FOOD
  // ============================================================

  Map<String, dynamic>? _findFood(
    String text,
  ) {
    final normalized = _normalize(text);

    Map<String, dynamic>? bestFood;
    int bestScore = 0;

    for (final food in _menuFoods) {
      final name = _normalize(
        (food["name"] ?? "").toString(),
      );

      final category = _normalize(
        (food["category"] ?? "").toString(),
      );

      int score = 0;

      if (name.isNotEmpty &&
          normalized.contains(name)) {
        score += 100;
      }

      final nameWords =
          name.split(' ');

      for (final word in nameWords) {
        if (word.length >= 3 &&
            normalized.contains(word)) {
          score += 20;
        }
      }

      if (category.isNotEmpty &&
          normalized.contains(category)) {
        score += 10;
      }

      if (score > bestScore) {
        bestScore = score;
        bestFood = food;
      }
    }

    return bestScore > 0
        ? bestFood
        : null;
  }

  // ============================================================
  // FOOD REQUEST
  // ============================================================

  bool _looksLikeFoodRequest(
    String text,
  ) {
    final normalized =
        _normalize(text);

    final food =
        _findFood(text);

    if (food != null) {
      return true;
    }

    const foodWords = [
      "food",
      "dish",
      "pizza",
      "burger",
      "biryani",
      "chicken",
      "rice",
      "pasta",
      "sandwich",
      "fries",
      "drink",
      "juice",
      "coke",
      "coffee",
      "tea",
      "shawarma",
      "kebab",
      "salad",
      "order",
      "khana",
      "mujhe",
      "chahiye",
      "dena",
      "give me",
      "i want",
      "i need",
      "get me",
      "can i have",
      "can i get",
    ];

    return foodWords.any(
      (word) =>
          normalized.contains(word),
    );
  }

  // ============================================================
  // MENU REQUEST
  // ============================================================

  bool _isMenuRequest(
    String text,
  ) {
    final normalized =
        _normalize(text);

    const menuWords = [
      "menu",
      "show menu",
      "show me menu",
      "open menu",
      "full menu",
      "food menu",
      "what is on menu",
      "what do you have",
      "available food",
      "menu dikhao",
      "menu dikhado",
      "menu batao",
      "menu btao",
      "khane ka menu",
      "khana dikhao",
      "kya available hai",
      "kya kya hai",
      "kya milta hai",
    ];

    return menuWords.any(
      (word) =>
          normalized == word ||
          normalized.contains(word),
    );
  }

  // ============================================================
  // CART COLLECTION
  // ============================================================

  CollectionReference<Map<String, dynamic>>
      get _cartCollection =>
          FirebaseFirestore.instance
              .collection("cart");

  // ============================================================
  // ADD FOOD TO CART
  // ============================================================

  Future<bool> addFoodToCart(
    Map<String, dynamic> food,
    int quantity,
  ) async {
    final user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      _addBotMessage(
        "Please login first before adding items to your cart.",
      );

      await _speak(
        "Please login first before adding items to your cart.",
      );

      return false;
    }

    try {
      final foodId =
          (food["foodId"] ?? "")
              .toString();

      final name =
          (food["name"] ?? "Food")
              .toString();

      final price =
          _toDouble(food["price"]);

      final image =
          (food["image"] ?? "")
              .toString();

      final category =
          (food["category"] ?? "")
              .toString();

      final existing =
          await _cartCollection
              .where(
                "userId",
                isEqualTo: user.uid,
              )
              .where(
                "name",
                isEqualTo: name,
              )
              .limit(1)
              .get();

      if (existing.docs.isNotEmpty) {
        final doc =
            existing.docs.first;

        final currentQuantity =
            _toInt(
          doc.data()["quantity"],
        );

        await doc.reference.update({
          "quantity":
              currentQuantity +
                  quantity,
          "updatedAt":
              FieldValue.serverTimestamp(),
        });
      } else {
        await _cartCollection.add({
          "userId": user.uid,
          "foodId": foodId,
          "name": name,
          "price": price,
          "image": image,
          "category": category,
          "quantity": quantity,
          "createdAt":
              FieldValue.serverTimestamp(),
          "updatedAt":
              FieldValue.serverTimestamp(),
        });
      }

      return true;
    } catch (e) {
      debugPrint(
        "Add to cart error: $e",
      );

      return false;
    }
  }

  // ============================================================
  // ASK QUANTITY
  // ============================================================

  Future<void> _askForQuantity(
    Map<String, dynamic> food,
  ) async {
    final name =
        (food["name"] ?? "food")
            .toString();

    setState(() {
      _pendingFood = food;
      _pendingQuantity = null;
      _pendingTotal = 0;

      _waitingForQuantity = true;
      _waitingForConfirmation = false;
      _waitingForMoreFood = false;
      _waitingForAddress = false;
    });

    final message =
        "Great choice! 😋\n"
        "How many $name would you like?";

    _addBotMessage(message);

    await _speak(
      "Great choice. "
      "How many $name would you like?",
    );
  }

  // ============================================================
  // PREPARE ORDER
  // ============================================================

  Future<void> _prepareOrder(
    Map<String, dynamic> food,
    int quantity,
  ) async {
    final name =
        (food["name"] ?? "Food")
            .toString();

    final price =
        _toDouble(food["price"]);

    final total =
        price * quantity;

    setState(() {
      _pendingFood = food;
      _pendingQuantity = quantity;
      _pendingTotal = total;

      _waitingForQuantity = false;
      _waitingForConfirmation = true;
      _waitingForMoreFood = false;
      _waitingForAddress = false;
    });

    final message =
        "$quantity × $name\n"
        "Price: Rs. ${price.toStringAsFixed(0)} each\n"
        "Total: Rs. ${total.toStringAsFixed(0)} 💰\n\n"
        "Are you sure you want to add this to your cart?\n"
        "Please say Yes or No.";

    _addBotMessage(message);

    await _speak(
      "$quantity $name. "
      "The price is "
      "${price.toStringAsFixed(0)} "
      "rupees each. "
      "Your total is "
      "${total.toStringAsFixed(0)} "
      "rupees. "
      "Are you sure you want "
      "to add this to your cart?",
    );
  }

  // ============================================================
  // COMPLETE PENDING ORDER
  // ============================================================

  Future<void> _completePendingOrder(
    int quantity,
  ) async {
    if (_pendingFood == null) {
      return;
    }

    await _prepareOrder(
      _pendingFood!,
      quantity,
    );
  }

  // ============================================================
  // DIRECT ORDER
  // ============================================================

  Future<void> _addDirectOrder(
    Map<String, dynamic> food,
    int quantity,
  ) async {
    await _prepareOrder(
      food,
      quantity,
    );
  }

  // ============================================================
  // YES
  // ============================================================

  bool _isYesResponse(
    String text,
  ) {
    final normalized =
        _normalize(text);

    const exactYes = [
      "yes",
      "yeah",
      "yep",
      "yup",
      "sure",
      "okay",
      "ok",
      "confirm",
      "confirmed",
      "haan",
      "han",
      "ji",
      "jee",
      "bilkul",
      "theek",
      "thik",
      "yes please",
      "haan please",
      "ji bilkul",
      "haan ji",
      "han ji",
      "add it",
      "add it please",
      "proceed",
      "continue",
    ];

    return exactYes.contains(
      normalized,
    );
  }

  // ============================================================
  // NO
  // ============================================================

  bool _isNoResponse(
    String text,
  ) {
    final normalized =
        _normalize(text);

    const exactNo = [
      "no",
      "nope",
      "nah",
      "nahi",
      "nahin",
      "na",
      "cancel",
      "cancel it",
      "no thanks",
      "not now",
      "dont",
      "do not",
      "nahi chahiye",
      "nahi karna",
      "cancel kar do",
    ];

    return exactNo.contains(
      normalized,
    );
  }

  // ============================================================
  // HANDLE CONFIRMATION
  // ============================================================

  Future<void> _handleConfirmation(
    String text,
  ) async {
    if (_isYesResponse(text)) {
      if (_pendingFood == null ||
          _pendingQuantity == null) {
        return;
      }

      final food = _pendingFood!;
      final quantity =
          _pendingQuantity!;

      final name =
          (food["name"] ?? "Food")
              .toString();

      setState(() {
        _isLoading = true;
      });

      final success =
          await addFoodToCart(
        food,
        quantity,
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (!success) {
        _addBotMessage(
          "Sorry Sir 😔\n"
          "I couldn't add this item to your cart. Please try again.",
        );

        await _speak(
          "Sorry Sir. "
          "I couldn't add this item to your cart. "
          "Please try again.",
        );

        return;
      }

      setState(() {
        _waitingForConfirmation =
            false;

        _waitingForQuantity =
            false;

        _pendingFood = null;
        _pendingQuantity = null;
        _pendingTotal = 0;

        _waitingForMoreFood = true;
        _waitingForAddress = false;
      });

      final message =
          "$quantity × $name has been added to your cart 🛒\n\n"
          "Would you like anything else?";

      _addBotMessage(message);

      await _speak(
        "$quantity $name has been added to your cart. "
        "Would you like anything else?",
      );

      return;
    }

    if (_isNoResponse(text)) {
      setState(() {
        _waitingForConfirmation =
            false;

        _waitingForQuantity =
            false;

        _pendingFood = null;
        _pendingQuantity = null;
        _pendingTotal = 0;

        _waitingForMoreFood = false;
      });

      const message =
          "No problem Sir 👍\n"
          "Your order has been cancelled.\n\n"
          "You can choose another item from the menu.";

      _addBotMessage(
        message,
        showMenu: true,
      );

      await _speak(
        "No problem Sir. "
        "Your order has been cancelled. "
        "You can choose another item from the menu.",
      );

      return;
    }

    final newQuantity =
        _detectQuantity(text);

    if (newQuantity != null &&
        _pendingFood != null) {
      await _prepareOrder(
        _pendingFood!,
        newQuantity,
      );

      return;
    }

    const message =
        "Please say Yes to confirm your order "
        "or No to cancel it.";

    _addBotMessage(message);

    await _speak(
      "Please say yes to confirm your order "
      "or no to cancel it.",
    );
  }

  // ============================================================
  // HANDLE MORE FOOD
  // ============================================================

  Future<void> _handleMoreFood(
    String text,
  ) async {
    if (_isYesResponse(text)) {
      setState(() {
        _waitingForMoreFood = false;
      });

      await _showMenu();

      return;
    }

    if (_isNoResponse(text)) {
      setState(() {
        _waitingForMoreFood = false;
        _waitingForAddress = true;
      });

      _addBotMessage(
        "Sure Sir 👍\n\n"
        "Please provide your complete delivery address.",
      );

      await _speak(
        "Sure Sir. "
        "Please provide your complete delivery address.",
      );

      return;
    }

    final food =
        _findFood(text);

    if (food != null) {
      setState(() {
        _waitingForMoreFood = false;
      });

      await _handleFoodOrder(text);

      return;
    }

    if (_isMenuRequest(text)) {
      setState(() {
        _waitingForMoreFood = false;
      });

      await _showMenu();

      return;
    }

    const message =
        "Please say Yes if you want something else, "
        "or No if you are finished.";

    _addBotMessage(message);

    await _speak(
      "Please say yes if you want something else, "
      "or no if you are finished.",
    );
  }

  // ============================================================
  // DELIVERY ADDRESS
  // ============================================================

  Future<void> _handleDeliveryAddress(
    String text,
  ) async {
    final address = text.trim();

    if (address.isEmpty) {
      _addBotMessage(
        "Please provide a valid delivery address.",
      );

      await _speak(
        "Please provide a valid delivery address.",
      );

      return;
    }

    setState(() {
      _deliveryAddress = address;
      _waitingForAddress = false;
    });

    _addBotMessage(
      "Perfect Sir 👍\n\n"
      "Delivery address saved:\n"
      "$address\n\n"
      "Opening your cart...",
    );

    await _speak(
      "Perfect Sir. "
      "Your delivery address has been saved. "
      "Opening your cart.",
    );

    await Future.delayed(
      const Duration(
        milliseconds: 700,
      ),
    );

    if (!mounted) return;

    final result =
        await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CartPage(
          deliveryAddress:
              _deliveryAddress,
        ),
      ),
    );

    if (result == true &&
        mounted) {
      await _showOrderThankYou();
    }
  }

  // ============================================================
  // ORDER SUCCESS
  // ============================================================

  Future<void> _showOrderThankYou() async {
    // Flag set first.
    _orderPlacedPending = true;

    _clearPendingOrder();

    if (!mounted) return;

    setState(() {
      _waitingForAddress = false;
      _waitingForMoreFood = false;
      _deliveryAddress = null;
    });

    const message =
        "🎉 Thank you Sir!\n\n"
        "Your order has been placed successfully.\n"
        "Your food will be prepared shortly.\n\n"
        "Have a great day! ❤️";

    // Current chatbot mein message show.
    _addBotMessage(message);

    // Current chatbot mein show ho gaya.
    _orderPlacedPending = false;

    await _speak(
      "Thank you Sir. "
      "Your order has been placed successfully. "
      "Your food will be prepared shortly. "
      "Have a great day.",
    );
  }

  // ============================================================
  // CLEAR PENDING ORDER
  // ============================================================

  void _clearPendingOrder() {
    if (!mounted) return;

    setState(() {
      _pendingFood = null;
      _pendingQuantity = null;
      _pendingTotal = 0;

      _waitingForQuantity = false;
      _waitingForConfirmation = false;
      _waitingForMoreFood = false;
    });
  }

  // ============================================================
  // HANDLE FOOD ORDER
  // ============================================================

  Future<void> _handleFoodOrder(
    String text,
  ) async {
    final food =
        _findFood(text);

    if (food == null) {
      String displayName =
          text.trim();

      final quantity =
          _detectQuantity(text);

      if (quantity != null) {
        displayName =
            displayName.replaceAll(
          RegExp(r'\b\d+\b'),
          '',
        );
      }

      final normalized =
          _normalize(displayName);

      const numberWords = [
        "one",
        "two",
        "three",
        "four",
        "five",
        "six",
        "seven",
        "eight",
        "nine",
        "ten",
        "ek",
        "aik",
        "do",
        "teen",
        "char",
        "chaar",
        "paanch",
        "panch",
        "che",
        "chay",
        "saat",
        "aath",
        "nau",
        "das",
      ];

      for (final word
          in numberWords) {
        displayName =
            displayName.replaceAll(
          RegExp(
            r'\b' +
                RegExp.escape(word) +
                r'\b',
          ),
          '',
        );
      }

      displayName =
          displayName.trim();

      if (displayName.isEmpty) {
        displayName = normalized;
      }

      final message =
          "Sorry Sir 😔\n"
          "We don't have \"$displayName\" in our menu right now.\n\n"
          "Please choose something from the available menu.";

      _addBotMessage(
        message,
        showMenu: true,
      );

      await _speak(
        "Sorry Sir. "
        "We don't have $displayName "
        "in our menu right now. "
        "Please choose something from "
        "the available menu.",
      );

      return;
    }

    final quantity =
        _detectQuantity(text);

    if (quantity != null) {
      await _addDirectOrder(
        food,
        quantity,
      );

      return;
    }

    await _askForQuantity(food);
  }

  // ============================================================
  // OPEN CART
  // ============================================================

  Future<void> _openCart() async {
    final result =
        await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const CartPage(),
      ),
    );

    if (result == true &&
        mounted) {
      await _showOrderThankYou();
    }
  }

  // ============================================================
  // SHOW MENU
  // ============================================================

  Future<void> _showMenu() async {
    if (_menuFoods.isEmpty) {
      await _loadMenu();
    }

    final message =
        "Here is our menu 👇\n"
        "Tap any food to order it.";

    _addBotMessage(
      message,
      showMenu: true,
    );

    await _speak(
      "Here is our menu. "
      "Tap any food to order it.",
    );
  }

  // ============================================================
  // SELECT FOOD
  // ============================================================

  Future<void> _selectFood(
    Map<String, dynamic> food,
  ) async {
    _clearPendingOrder();

    final name =
        (food["name"] ?? "Food")
            .toString();

    _addUserMessage(name);

    await _askForQuantity(food);
  }

  // ============================================================
  // SEND MESSAGE
  // ============================================================

  Future<void> _sendMessage() async {
    final text =
        _messageController.text.trim();

    if (text.isEmpty ||
        _isLoading) {
      return;
    }

    _messageController.clear();

    _addUserMessage(text);

    if (_waitingForAddress) {
      await _handleDeliveryAddress(
        text,
      );
      return;
    }

    if (_waitingForMoreFood) {
      await _handleMoreFood(text);
      return;
    }

    if (_waitingForConfirmation &&
        _pendingFood != null) {
      await _handleConfirmation(
        text,
      );
      return;
    }

    if (_waitingForQuantity &&
        _pendingFood != null) {
      final quantity =
          _detectQuantity(text);

      if (quantity == null) {
        const message =
            "Please tell me a valid quantity.\n\n"
            "For example: 2, three, 5, do, teen, etc.";

        _addBotMessage(message);

        await _speak(
          "Please tell me a valid quantity. "
          "For example, two or three.",
        );

        return;
      }

      await _completePendingOrder(
        quantity,
      );

      return;
    }

    if (_isMenuRequest(text)) {
      await _showMenu();
      return;
    }

    final normalized =
        _normalize(text);

    const greetings = [
      "hello",
      "hi",
      "hey",
      "salam",
      "assalam o alaikum",
      "aoa",
    ];

    if (greetings.contains(
      normalized,
    )) {
      const message =
          "Hello Sir 👋\n"
          "How can I help you?\n\n"
          "You can choose something from our menu.";

      _addBotMessage(
        message,
        showMenu: true,
      );

      await _speak(
        "Hello Sir. "
        "How can I help you? "
        "You can choose something "
        "from our menu.",
      );

      return;
    }

    if (normalized == "cart" ||
        normalized == "open cart" ||
        normalized == "show cart" ||
        normalized == "my cart") {
      _addBotMessage(
        "Opening your cart 🛒...",
      );

      await _speak(
        "Opening your cart.",
      );

      await Future.delayed(
        const Duration(
          milliseconds: 500,
        ),
      );

      if (!mounted) return;

      await _openCart();

      return;
    }

    if (_looksLikeFoodRequest(
      text,
    )) {
      await _handleFoodOrder(
        text,
      );
      return;
    }

    final food =
        _findFood(text);

    if (food != null) {
      await _handleFoodOrder(
        text,
      );
      return;
    }

    await _askAI(text);
  }

  // ============================================================
  // AI BACKEND
  // ============================================================

  Future<void> _askAI(
    String text,
  ) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response =
          await http.post(
        Uri.parse(
          "$_backendUrl/chat",
        ),
        headers: {
          "Content-Type":
              "application/json",
        },
        body: jsonEncode({
          "message": text,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data =
            jsonDecode(
          response.body,
        );

        final reply =
            data["response"] ??
                data["message"] ??
                data["reply"] ??
                "Sorry Sir, I couldn't understand that.";

        _addBotMessage(
          reply.toString(),
        );

        await _speak(
          reply.toString(),
        );
      } else {
        _addBotMessage(
          "Sorry Sir 😔\n"
          "I couldn't connect to the AI assistant right now.",
        );
      }
    } catch (e) {
      debugPrint(
        "AI error: $e",
      );

      if (!mounted) return;

      _addBotMessage(
        "Sorry Sir 😔\n"
        "The AI assistant is currently unavailable.",
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ============================================================
  // VOICE INPUT
  // ============================================================

  Future<void> _startListening() async {
    if (_isListening) {
      await _speech.stop();

      if (!mounted) return;

      setState(() {
        _isListening = false;
      });

      return;
    }

    final available =
        await _speech.initialize(
      onStatus: (status) {
        if (!mounted) return;

        if (status == "done" ||
            status == "notListening") {
          setState(() {
            _isListening = false;
          });
        }
      },
      onError: (error) {
        if (!mounted) return;

        setState(() {
          _isListening = false;
        });
      },
    );

    if (!available) {
      _addBotMessage(
        "Sorry Sir, microphone is not available.",
      );

      return;
    }

    if (!mounted) return;

    setState(() {
      _isListening = true;
    });

    await _speech.listen(
      onResult: (result) {
        if (!mounted) return;

        setState(() {
          _messageController.text =
              result.recognizedWords;

          _messageController.selection =
              TextSelection.fromPosition(
            TextPosition(
              offset:
                  _messageController
                      .text
                      .length,
            ),
          );
        });

        if (result.finalResult) {
          setState(() {
            _isListening = false;
          });

          if (_messageController
              .text
              .trim()
              .isNotEmpty) {
            _sendMessage();
          }
        }
      },
      listenMode:
          stt.ListenMode.confirmation,
    );
  }

  // ============================================================
  // MENU WIDGET
  // ============================================================

  Widget _buildMenuWidget() {
    if (_menuFoods.isEmpty) {
      return const Padding(
        padding:
            EdgeInsets.all(20),
        child: Center(
          child:
              CircularProgressIndicator(
            color: yellow,
          ),
        ),
      );
    }

    return Padding(
      padding:
          const EdgeInsets.fromLTRB(
        12,
        10,
        12,
        20,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration:
                    BoxDecoration(
                  color: yellow
                      .withOpacity(
                    0.12,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),
                child: const Icon(
                  Icons
                      .restaurant_menu_rounded,
                  color: yellow,
                  size: 23,
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              const Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Text(
                    "Our Menu",
                    style:
                        TextStyle(
                      color: white,
                      fontSize: 19,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    "Choose something delicious",
                    style:
                        TextStyle(
                      color: grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(
            height: 15,
          ),

          GridView.builder(
            shrinkWrap: true,
            physics:
                const NeverScrollableScrollPhysics(),
            itemCount:
                _menuFoods.length,
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio:
                  0.68,
            ),
            itemBuilder:
                (context, index) {
              final food =
                  _menuFoods[index];

              final name =
                  (food["name"] ??
                          "Food")
                      .toString();

              final price =
                  _toDouble(
                food["price"],
              );

              final image =
                  (food["image"] ??
                          "")
                      .toString();

              final category =
                  (food["category"] ??
                          "")
                      .toString();

              return GestureDetector(
                onTap: () {
                  _selectFood(food);
                },
                child: Container(
                  decoration:
                      BoxDecoration(
                    color:
                        const Color(
                      0xFF181818,
                    ),
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
                        0.07,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors
                            .black
                            .withOpacity(
                          0.25,
                        ),
                        blurRadius: 8,
                        offset:
                            const Offset(
                          0,
                          4,
                        ),
                      ),
                    ],
                  ),
                  child:
                      ClipRRect(
                    borderRadius:
                        BorderRadius
                            .circular(
                      18,
                    ),
                    child:
                        Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        Expanded(
                          flex: 6,
                          child:
                              Stack(
                            children: [
                              Positioned.fill(
                                child: image
                                        .isNotEmpty
                                    ? Image
                                        .network(
                                        image,
                                        fit: BoxFit
                                            .cover,
                                        errorBuilder:
                                            (
                                          context,
                                          error,
                                          stackTrace,
                                        ) {
                                          return _foodPlaceholder();
                                        },
                                      )
                                    : _foodPlaceholder(),
                              ),

                              Positioned.fill(
                                child:
                                    DecoratedBox(
                                  decoration:
                                      BoxDecoration(
                                    gradient:
                                        LinearGradient(
                                      begin:
                                          Alignment.topCenter,
                                      end:
                                          Alignment.bottomCenter,
                                      colors: [
                                        Colors
                                            .transparent,
                                        Colors
                                            .black
                                            .withOpacity(
                                          0.55,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              if (category
                                  .isNotEmpty)
                                Positioned(
                                  top: 9,
                                  left: 9,
                                  child:
                                      Container(
                                    padding:
                                        const EdgeInsets
                                            .symmetric(
                                      horizontal:
                                          8,
                                      vertical:
                                          5,
                                    ),
                                    decoration:
                                        BoxDecoration(
                                      color: Colors
                                          .black
                                          .withOpacity(
                                        0.65,
                                      ),
                                      borderRadius:
                                          BorderRadius
                                              .circular(
                                        8,
                                      ),
                                    ),
                                    child:
                                        Text(
                                      category,
                                      maxLines:
                                          1,
                                      overflow:
                                          TextOverflow
                                              .ellipsis,
                                      style:
                                          const TextStyle(
                                        color:
                                            white,
                                        fontSize:
                                            10,
                                        fontWeight:
                                            FontWeight
                                                .w500,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        Expanded(
                          flex: 4,
                          child:
                              Padding(
                            padding:
                                const EdgeInsets
                                    .fromLTRB(
                              11,
                              9,
                              9,
                              9,
                            ),
                            child:
                                Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              children: [
                                Text(
                                  name,
                                  maxLines:
                                      2,
                                  overflow:
                                      TextOverflow
                                          .ellipsis,
                                  style:
                                      const TextStyle(
                                    color:
                                        white,
                                    fontSize:
                                        14,
                                    fontWeight:
                                        FontWeight
                                            .w700,
                                    height:
                                        1.2,
                                  ),
                                ),

                                const Spacer(),

                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment
                                          .spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,
                                      children: [
                                        const Text(
                                          "Price",
                                          style:
                                              TextStyle(
                                            color:
                                                grey,
                                            fontSize:
                                                10,
                                          ),
                                        ),
                                        const SizedBox(
                                          height:
                                              2,
                                        ),
                                        Text(
                                          "Rs. ${price.toStringAsFixed(0)}",
                                          style:
                                              const TextStyle(
                                            color:
                                                yellow,
                                            fontSize:
                                                15,
                                            fontWeight:
                                                FontWeight
                                                    .w800,
                                          ),
                                        ),
                                      ],
                                    ),

                                    Container(
                                      width:
                                          36,
                                      height:
                                          36,
                                      decoration:
                                          BoxDecoration(
                                        color:
                                            yellow,
                                        borderRadius:
                                            BorderRadius
                                                .circular(
                                          11,
                                        ),
                                      ),
                                      child:
                                          const Icon(
                                        Icons
                                            .add_rounded,
                                        color:
                                            Colors
                                                .black,
                                        size:
                                            22,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FOOD PLACEHOLDER
  // ============================================================

  Widget _foodPlaceholder() {
    return Container(
      color:
          const Color(0xFF242424),
      child: const Center(
        child: Icon(
          Icons.restaurant_rounded,
          color: yellow,
          size: 42,
        ),
      ),
    );
  }

  // ============================================================
  // MESSAGE BUBBLE
  // ============================================================

  Widget _buildMessage(
    Map<String, dynamic> message,
  ) {
    final isUser =
        message["sender"] == "user";

    final text =
        message["text"].toString();

    return Align(
      alignment: isUser
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        constraints:
            const BoxConstraints(
          maxWidth: 330,
        ),
        margin:
            const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 6,
        ),
        padding:
            const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 12,
        ),
        decoration:
            BoxDecoration(
          color: isUser
              ? yellow
              : card,
          borderRadius:
              BorderRadius.circular(
            16,
          ),
          border: isUser
              ? null
              : Border.all(
                  color: yellow
                      .withOpacity(
                    0.15,
                  ),
                ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isUser
                ? Colors.black
                : white,
            fontSize: 14.5,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          background,

      appBar: AppBar(
        backgroundColor:
            background,
        elevation: 0,

        title: const Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor:
                  yellow,
              child: Icon(
                Icons.smart_toy,
                color: Colors.black,
              ),
            ),

            SizedBox(
              width: 10,
            ),

            Text(
              "AI Food Assistant",
              style: TextStyle(
                color: white,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ],
        ),

        actions: [
          IconButton(
            onPressed: () {
              if (widget.onClose !=
                  null) {
                widget.onClose!();
              } else if (
                  Navigator.canPop(
                context,
              )) {
                Navigator.pop(
                  context,
                );
              }
            },
            icon: const Icon(
              Icons.close_rounded,
              color: white,
            ),
          ),
        ],
      ),

      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child:
                  ListView.builder(
                controller:
                    _scrollController,
                padding:
                    const EdgeInsets.only(
                  top: 10,
                  bottom: 10,
                ),
                itemCount:
                    _messages.length,
                itemBuilder:
                    (context, index) {
                  final message =
                      _messages[index];

                  return Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .stretch,
                    children: [
                      _buildMessage(
                        message,
                      ),

                      if (message[
                              "showMenu"] ==
                          true)
                        _buildMenuWidget(),
                    ],
                  );
                },
              ),
            ),

            if (_isLoading)
              const Padding(
                padding:
                    EdgeInsets.only(
                  bottom: 8,
                ),
                child:
                    CircularProgressIndicator(
                  color: yellow,
                  strokeWidth: 2,
                ),
              ),

            Container(
              padding:
                  const EdgeInsets.fromLTRB(
                12,
                8,
                12,
                12,
              ),
              decoration:
                  const BoxDecoration(
                color: card,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap:
                        _startListening,
                    child:
                        Container(
                      width: 48,
                      height: 48,
                      decoration:
                          BoxDecoration(
                        color:
                            _isListening
                                ? yellow
                                : darkCard,
                        shape:
                            BoxShape.circle,
                      ),
                      child:
                          Icon(
                        _isListening
                            ? Icons.mic
                            : Icons
                                .mic_none,
                        color:
                            _isListening
                                ? Colors.black
                                : yellow,
                      ),
                    ),
                  ),

                  const SizedBox(
                    width: 8,
                  ),

                  Expanded(
                    child:
                        TextField(
                      controller:
                          _messageController,
                      style:
                          const TextStyle(
                        color: white,
                      ),
                      minLines: 1,
                      maxLines: 4,
                      decoration:
                          InputDecoration(
                        hintText:
                            "Type your message...",
                        hintStyle:
                            const TextStyle(
                          color: grey,
                        ),
                        filled: true,
                        fillColor:
                            darkCard,
                        border:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            25,
                          ),
                          borderSide:
                              BorderSide.none,
                        ),
                        contentPadding:
                            const EdgeInsets
                                .symmetric(
                          horizontal:
                              18,
                          vertical:
                              12,
                        ),
                      ),
                      onSubmitted:
                          (_) =>
                              _sendMessage(),
                    ),
                  ),

                  const SizedBox(
                    width: 8,
                  ),

                  GestureDetector(
                    onTap:
                        _sendMessage,
                    child:
                        Container(
                      width: 48,
                      height: 48,
                      decoration:
                          const BoxDecoration(
                        color: yellow,
                        shape:
                            BoxShape.circle,
                      ),
                      child:
                          const Icon(
                        Icons.send,
                        color:
                            Colors.black,
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
}