import '../../shared/models/order.dart';
import '../../shared/models/quote.dart';
import '../../shared/models/product.dart';

/// Mock API service for testing/development without a real backend
class MockApiService {
  static final MockApiService _instance = MockApiService._internal();

  factory MockApiService() {
    return _instance;
  }

  MockApiService._internal();

  // Mock Orders Data
  static final List<Order> _mockOrders = [
    Order(
      id: 'ORD001',
      clientId: 'CLI001',
      clientName: 'John Smith',
      clientPhone: '+1-555-1001',
      deliveryAddress: '123 Main St, Springfield',
      deliveryCity: 'Springfield',
      deliveryCountry: 'USA',
      items: [
        OrderItem(
          productId: 'PROD001',
          productName: 'Engine Oil 5L',
          unitPrice: 29.99,
          quantity: 2,
        ),
        OrderItem(
          productId: 'PROD002',
          productName: 'Air Filter',
          unitPrice: 14.99,
          quantity: 1,
        ),
      ],
      totalAmount: 84.97,
      taxAmount: 8.50,
      shippingAmount: 5.00,
      status: 'pending',
      paymentStatus: 'pending',
      paymentMethod: 'cod',
      createdAt: DateTime.now().subtract(Duration(days: 3)),
    ),
    Order(
      id: 'ORD002',
      clientId: 'CLI002',
      clientName: 'Jane Doe',
      clientPhone: '+1-555-1002',
      deliveryAddress: '456 Oak Ave, Shelbyville',
      deliveryCity: 'Shelbyville',
      deliveryCountry: 'USA',
      items: [
        OrderItem(
          productId: 'PROD003',
          productName: 'Brake Pads',
          unitPrice: 45.00,
          quantity: 1,
        ),
      ],
      totalAmount: 50.00,
      taxAmount: 5.00,
      shippingAmount: 5.00,
      status: 'shipped',
      paymentStatus: 'paid',
      paymentMethod: 'cod',
      createdAt: DateTime.now().subtract(Duration(days: 10)),
    ),
    Order(
      id: 'ORD003',
      clientId: 'CLI001',
      clientName: 'John Smith',
      clientPhone: '+1-555-1001',
      deliveryAddress: '123 Main St, Springfield',
      deliveryCity: 'Springfield',
      deliveryCountry: 'USA',
      items: [
        OrderItem(
          productId: 'PROD004',
          productName: 'Car Battery',
          unitPrice: 99.99,
          quantity: 1,
        ),
      ],
      totalAmount: 109.99,
      taxAmount: 11.00,
      shippingAmount: 5.00,
      status: 'delivered',
      paymentStatus: 'paid',
      paymentMethod: 'cod',
      createdAt: DateTime.now().subtract(Duration(days: 20)),
      deliveredAt: DateTime.now().subtract(Duration(days: 5)),
    ),
  ];

  // Mock Quotes Data
  static final List<Quote> _mockQuotes = [
    Quote(
      id: 'QT001',
      clientId: 'CLI003',
      clientName: 'Mike Johnson',
      clientEmail: 'mike@example.com',
      clientPhone: '+1-555-2001',
      description: 'Need radiator repair for 2018 Honda Civic',
      deliveryAddress: '789 Pine Rd, Capital City',
      items: [
        QuoteItem(
          productId: 'PROD005',
          productName: 'Radiator Assembly',
          quantity: 1,
          specifications: 'OEM Replacement, 2018 Honda Civic',
        ),
        QuoteItem(
          productId: 'PROD006',
          productName: 'Coolant Flush',
          quantity: 2,
          specifications: 'Premium Grade',
        ),
      ],
      totalAmount: 0,
      status: 'pending',
      createdAt: DateTime.now().subtract(Duration(days: 2)),
    ),
    Quote(
      id: 'QT002',
      clientId: 'CLI004',
      clientName: 'Sarah Williams',
      clientEmail: 'sarah@example.com',
      clientPhone: '+1-555-2002',
      description: 'Complete suspension rebuild parts needed',
      deliveryAddress: '321 Elm St, Metropolis',
      items: [
        QuoteItem(
          productId: 'PROD007',
          productName: 'Suspension Coils',
          quantity: 4,
          specifications: 'Front & Rear Set',
        ),
      ],
      totalAmount: 0,
      status: 'pending',
      createdAt: DateTime.now().subtract(Duration(days: 1)),
    ),
    Quote(
      id: 'QT003',
      clientId: 'CLI005',
      clientName: 'Robert Brown',
      clientEmail: 'robert@example.com',
      clientPhone: '+1-555-2003',
      description: 'Transmission fluid change and filter replacement',
      deliveryAddress: '654 Maple Way, Gotham',
      items: [
        QuoteItem(
          productId: 'PROD008',
          productName: 'Transmission Fluid',
          quantity: 5,
          specifications: 'Synthetic ATF',
        ),
      ],
      totalAmount: 250.00,
      status: 'accepted',
      createdAt: DateTime.now().subtract(Duration(days: 5)),
      respondedAt: DateTime.now().subtract(Duration(days: 3)),
      expiresAt: DateTime.now().add(Duration(days: 25)),
    ),
  ];

  // Mock Products Data
  static final List<Product> _mockProducts = [
    Product(
      id: 'PROD001',
      name: 'Engine Oil 5L',
      description: 'High-quality synthetic engine oil for most vehicles',
      price: 29.99,
      stock: 150,
      category: 'Fluids & Lubricants',
      supplierId: 'SUP001',
      createdAt: DateTime.now().subtract(Duration(days: 90)),
    ),
    Product(
      id: 'PROD002',
      name: 'Air Filter',
      description: 'Original equipment air filter replacement',
      price: 14.99,
      stock: 300,
      category: 'Filters',
      supplierId: 'SUP002',
      createdAt: DateTime.now().subtract(Duration(days: 85)),
    ),
    Product(
      id: 'PROD003',
      name: 'Brake Pads',
      description: 'Premium brake pads with superior stopping power',
      price: 45.00,
      stock: 80,
      category: 'Braking System',
      supplierId: 'SUP003',
      createdAt: DateTime.now().subtract(Duration(days: 75)),
    ),
    Product(
      id: 'PROD004',
      name: 'Car Battery',
      description: 'Heavy duty car battery, 12V 600CCA',
      price: 99.99,
      stock: 45,
      category: 'Electrical',
      supplierId: 'SUP001',
      createdAt: DateTime.now().subtract(Duration(days: 60)),
    ),
    Product(
      id: 'PROD005',
      name: 'Radiator Assembly',
      description: 'Complete radiator assembly for cooling system',
      price: 189.99,
      stock: 25,
      category: 'Cooling System',
      supplierId: 'SUP004',
      createdAt: DateTime.now().subtract(Duration(days: 45)),
    ),
  ];

  // Simulate API delay
  Future<void> _delay() async {
    await Future.delayed(Duration(milliseconds: 500));
  }

  // Orders API
  Future<List<Order>> fetchAllOrders() async {
    await _delay();
    return List.from(_mockOrders);
  }

  Future<Order?> fetchOrderById(String orderId) async {
    await _delay();
    try {
      return _mockOrders.firstWhere((o) => o.id == orderId);
    } catch (e) {
      return null;
    }
  }

  Future<bool> updateOrderStatus(String orderId, String newStatus) async {
    await _delay();
    try {
      final index = _mockOrders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        final order = _mockOrders[index];
        _mockOrders[index] = Order(
          id: order.id,
          clientId: order.clientId,
          clientName: order.clientName,
          clientPhone: order.clientPhone,
          deliveryAddress: order.deliveryAddress,
          deliveryCity: order.deliveryCity,
          deliveryCountry: order.deliveryCountry,
          items: order.items,
          totalAmount: order.totalAmount,
          taxAmount: order.taxAmount,
          shippingAmount: order.shippingAmount,
          status: newStatus,
          paymentStatus: order.paymentStatus,
          paymentMethod: order.paymentMethod,
          notes: order.notes,
          createdAt: order.createdAt,
          deliveredAt: newStatus == 'delivered' ? DateTime.now() : order.deliveredAt,
        );
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Quotes API
  Future<List<Quote>> fetchAllQuotes() async {
    await _delay();
    return List.from(_mockQuotes);
  }

  Future<Quote?> fetchQuoteById(String quoteId) async {
    await _delay();
    try {
      return _mockQuotes.firstWhere((q) => q.id == quoteId);
    } catch (e) {
      return null;
    }
  }

  Future<bool> addQuotePrice(String quoteId, double price, DateTime? expiryDate) async {
    await _delay();
    try {
      final index = _mockQuotes.indexWhere((q) => q.id == quoteId);
      if (index != -1) {
        final quote = _mockQuotes[index];
        _mockQuotes[index] = Quote(
          id: quote.id,
          clientId: quote.clientId,
          clientName: quote.clientName,
          clientEmail: quote.clientEmail,
          clientPhone: quote.clientPhone,
          description: quote.description,
          deliveryAddress: quote.deliveryAddress,
          items: quote.items,
          totalAmount: price,
          status: quote.status,
          rejectReason: quote.rejectReason,
          createdAt: quote.createdAt,
          respondedAt: DateTime.now(),
          expiresAt: expiryDate,
        );
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Products API
  Future<List<Product>> fetchAllProducts() async {
    await _delay();
    return List.from(_mockProducts);
  }

  Future<Product?> fetchProductById(String productId) async {
    await _delay();
    try {
      return _mockProducts.firstWhere((p) => p.id == productId);
    } catch (e) {
      return null;
    }
  }

  Future<bool> createProduct({
    required String name,
    required String description,
    required double price,
    required int stock,
    String? category,
  }) async {
    await _delay();
    try {
      final newProduct = Product(
        id: 'PROD${_mockProducts.length + 100}',
        name: name,
        description: description,
        price: price,
        stock: stock,
        category: category ?? 'General',
        supplierId: 'SUP001',
        createdAt: DateTime.now(),
      );
      _mockProducts.add(newProduct);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateProduct({
    required String productId,
    required String name,
    required String description,
    required double price,
    required int stock,
    String? category,
  }) async {
    await _delay();
    try {
      final index = _mockProducts.indexWhere((p) => p.id == productId);
      if (index != -1) {
        final oldProduct = _mockProducts[index];
        _mockProducts[index] = Product(
          id: productId,
          name: name,
          description: description,
          price: price,
          stock: stock,
          category: category ?? 'General',
          supplierId: oldProduct.supplierId,
          createdAt: oldProduct.createdAt,
          updatedAt: DateTime.now(),
        );
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteProduct(String productId) async {
    await _delay();
    try {
      _mockProducts.removeWhere((p) => p.id == productId);
      return true;
    } catch (e) {
      return false;
    }
  }
}
