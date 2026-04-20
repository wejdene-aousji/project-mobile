import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../shared/widgets/index.dart';
import '../../providers/product_provider.dart';
import '../../widgets/client_bottom_nav_bar.dart';

/// Products List Screen
class ProductsListScreen extends StatefulWidget {
  const ProductsListScreen({super.key});

  @override
  State<ProductsListScreen> createState() => _ProductsListScreenState();
}

class _ProductsListScreenState extends State<ProductsListScreen> {
  late ProductProvider _productProvider;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _productProvider = context.read<ProductProvider>();
    _productProvider.fetchProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Products',
        showBackButton: false,
        actions: [
          IconButton(
            tooltip: 'Profile',
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.clientProfile),
          ),
        ],
      ),
      bottomNavigationBar: const ClientBottomNavBar(currentIndex: 0),
      body: Consumer<ProductProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const CustomLoadingIndicator(message: 'Loading products...');
          }

          if (provider.error != null) {
            return EmptyState(
              icon: Icons.error,
              title: 'Error',
              message: provider.error!,
              action: CustomButton(
                label: 'Retry',
                onPressed: () {
                  provider.fetchProducts();
                },
              ),
            );
          }

          return Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: CustomTextField(
                  label: 'Search products',
                  hint: 'Search...',
                  controller: _searchController,
                  prefixIcon: Icons.search,
                  onChanged: () {
                    provider.searchProducts(_searchController.text);
                  },
                ),
              ),
              // Categories
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: provider.categories.length,
                  itemBuilder: (context, index) {
                    final category = provider.categories[index];
                    final isSelected = category == provider.selectedCategory;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (_) {
                          provider.filterByCategory(category);
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              // Products Grid
              Expanded(
                child: provider.products.isEmpty
                    ? EmptyState(
                        icon: Icons.shopping_bag,
                        title: 'No Products',
                        message: 'No products found matching your criteria',
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: provider.products.length,
                        itemBuilder: (context, index) {
                          final product = provider.products[index];
                          return _ProductCard(product: product);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Product Card Widget
class _ProductCard extends StatelessWidget {
  final dynamic product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      onTap: () {
        Navigator.of(context).pushNamed(AppRoutes.clientProductDetail,
            arguments: product.id);
      },
      padding: EdgeInsets.zero,
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Container(
            height: 120,
            color: Colors.grey[200],
            child: product.imageUrl != null
                ? Image.network(product.imageUrl!, fit: BoxFit.cover)
                : Center(
                    child: Icon(
                      Icons.image_not_supported,
                      color: Colors.grey[400],
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                // Price
                Row(
                  children: [
                    if (product.hasDiscount) ...[
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      '\$${product.effectivePrice.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Stock Status
                Text(
                  product.isInStock ? 'In Stock' : 'Out of Stock',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: product.isInStock ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
