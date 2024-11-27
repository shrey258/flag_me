import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/wish_list_provider.dart';
import '../models/wish_list_item.dart';
import '../utils/responsive_helper.dart';

class ProductCard extends ConsumerStatefulWidget {
  final Map<String, dynamic> product;
  final String occasionId;

  const ProductCard({
    super.key,
    required this.product,
    required this.occasionId,
  });

  @override
  ConsumerState<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends ConsumerState<ProductCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onHover(bool isHovered) {
    if (isHovered) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    setState(() {
      _isHovered = isHovered;
    });
  }

  void _addToWishList() {
    final item = WishListItem(
      id: widget.product['id'] as String? ?? UniqueKey().toString(),
      name: widget.product['name'] as String,
      price: widget.product['price'] as double,
      imageUrl: widget.product['image'] as String,
      store: widget.product['store'] as String,
      rating: widget.product['rating'] as double,
      occasionId: widget.occasionId,
      dateAdded: DateTime.now(),
    );

    ref.read(wishListProvider.notifier).addItem(item);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ${item.name} to wish list'),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () {
            ref.read(wishListProvider.notifier).removeItem(item.id);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wishListItems = ref.watch(wishListProvider);
    final isInWishList = wishListItems.any(
      (item) =>
          item.name == widget.product['name'] &&
          item.occasionId == widget.occasionId,
    );

    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? Colors.black.withOpacity(0.1)
                    : Colors.black.withOpacity(0.05),
                blurRadius: _isHovered ? 15 : 10,
                offset: Offset(0, _isHovered ? 5 : 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Image.network(
                        widget.product['image'] as String,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.image_not_supported),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: Icon(
                        isInWishList
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: isInWishList ? Colors.red : Colors.white,
                      ),
                      onPressed: _addToWishList,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black.withOpacity(0.5),
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product['name'] as String,
                        style: GoogleFonts.poppins(
                          fontSize: ResponsiveHelper.isMobile(context) ? 14 : 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.product['store'] as String,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize:
                              ResponsiveHelper.isMobile(context) ? 12 : 14,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Text(
                            '\$${(widget.product['price'] as double).toStringAsFixed(2)}',
                            style: GoogleFonts.poppins(
                              fontSize:
                                  ResponsiveHelper.isMobile(context) ? 16 : 18,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                size: ResponsiveHelper.isMobile(context) ? 16 : 18,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                (widget.product['rating'] as double)
                                    .toStringAsFixed(1),
                                style: TextStyle(
                                  fontSize: ResponsiveHelper.isMobile(context)
                                      ? 12
                                      : 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
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
  }
}
