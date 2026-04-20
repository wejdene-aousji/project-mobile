import 'package:flutter/material.dart';
import '../../../core/config/app_config.dart';
import '../../../shared/models/cart_item.dart';

/// Cart Provider
class CartProvider extends ChangeNotifier {
  final Map<String, CartItem> _items = {};

  // Getters
  List<CartItem> get items => _items.values.toList();
  int get itemCount => _items.length;
  int get totalQuantity => _items.values.fold(0, (sum, item) => sum + item.quantity);
  double get totalPrice => _items.values.fold(0, (sum, item) => sum + item.totalPrice);

  /// Add item to cart
  void addItem({
    required String productId,
    required String productName,
    required double productPrice,
    required String? productImage,
    int quantity = 1,
  }) {
    if (_items.containsKey(productId)) {
      // Update quantity if already in cart
      final currentItem = _items[productId]!;
      if (currentItem.quantity + quantity <= AppConfig.cartMaxQuantity) {
        _items[productId] = currentItem.copyWith(
          quantity: currentItem.quantity + quantity,
        );
      }
    } else {
      // Add new item
      _items[productId] = CartItem(
        productId: productId,
        productName: productName,
        productPrice: productPrice,
        quantity: quantity,
        productImage: productImage,
      );
    }
    notifyListeners();
  }

  /// Update item quantity
  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeItem(productId);
    } else if (quantity <= AppConfig.cartMaxQuantity && _items.containsKey(productId)) {
      _items[productId] = _items[productId]!.copyWith(quantity: quantity);
      notifyListeners();
    }
  }

  /// Remove item from cart
  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  /// Clear cart
  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  /// Check if item exists in cart
  bool hasItem(String productId) => _items.containsKey(productId);

  /// Get item quantity
  int getQuantity(String productId) => _items[productId]?.quantity ?? 0;

  /// Get cart summary
  Map<String, dynamic> getCartSummary() {
    const taxRate = 0.1; // 10% tax
    const shippingCost = 5.0;

    final subtotal = totalPrice;
    final tax = subtotal * taxRate;
    final total = subtotal + tax + shippingCost;

    return {
      'subtotal': subtotal,
      'tax': tax,
      'shipping': shippingCost,
      'total': total,
    };
  }
}
