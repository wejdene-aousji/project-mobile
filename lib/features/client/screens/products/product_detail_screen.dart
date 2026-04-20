import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../shared/widgets/index.dart';
import '../../providers/product_provider.dart';
import '../../providers/cart_provider.dart';

/// Product Detail Screen
class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({
    super.key,
    required this.productId,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchProductById(widget.productId);
    });
  }

  void _addToCart() {
    final product = context.read<ProductProvider>().selectedProduct;
    if (product != null) {
      context.read<CartProvider>().addItem(
        productId: product.id,
        productName: product.name,
        productPrice: product.effectivePrice,
        productImage: product.imageUrl,
        quantity: _quantity,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Added to cart!'),
          action: SnackBarAction(
            label: 'View Cart',
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.clientCart);
            },
          ),
        ),
      );
    }
  }

  void _buyNow() {
    _addToCart();
    Navigator.of(context).pushNamed(AppRoutes.clientCart);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Product Details',
        actions: [
          IconButton(
            tooltip: 'Profile',
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.clientProfile),
          ),
        ],
      ),
      body: Consumer<ProductProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const CustomLoadingIndicator(message: 'Loading product...');
          }

          final product = provider.selectedProduct;
          if (product == null) {
            return EmptyState(
              icon: Icons.error,
              title: 'Product Not Found',
              message: provider.error ?? 'Could not load product details',
            );
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                Container(
                  height: 300,
                  color: Colors.grey[200],
                  child: product.imageUrl != null
                      ? Image.network(product.imageUrl!, fit: BoxFit.cover)
                      : Center(
                          child: Icon(
                            Icons.image_not_supported,
                            color: Colors.grey[400],
                            size: 80,
                          ),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        product.name,
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      const SizedBox(height: 8),
                      // Category
                      Text(
                        product.category,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Price
                      Row(
                        children: [
                          if (product.hasDiscount) ...[
                            Text(
                              '\$${product.price.toStringAsFixed(2)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 16),
                          ],
                          Text(
                            '\$${product.effectivePrice.toStringAsFixed(2)}',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      if (product.hasDiscount) ...[
                        const SizedBox(height: 8),
                        Chip(
                          label: Text(
                            'Save ${product.discountPercentage?.toStringAsFixed(0)}%',
                          ),
                          backgroundColor:
                              Theme.of(context).colorScheme.error.withOpacity(0.2),
                          labelStyle: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      // Stock Status
                      Row(
                        children: [
                          Text(
                            'In Stock: ',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            '${product.stock} units',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: product.isInStock ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Description
                      Text(
                        'Description',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 24),
                      // Quantity Selector
                      Row(
                        children: [
                          Text(
                            'Quantity',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: _quantity > 1
                                ? () => setState(() => _quantity--)
                                : null,
                            icon: const Icon(Icons.remove),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _quantity.toString(),
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                          IconButton(
                            onPressed: _quantity < product.stock
                                ? () => setState(() => _quantity++)
                                : null,
                            icon: const Icon(Icons.add),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedCustomButton(
                              label: 'Add to Cart',
                              onPressed: product.isInStock ? _addToCart : () {},
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomButton(
                              label: 'Buy Now',
                              onPressed: product.isInStock ? _buyNow : null,
                            ),
                          ),
                        ],
                      ),
                    ],
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
