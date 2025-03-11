import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/gift_service.dart';
import '../utils/responsive_helper.dart';

class ProductCard extends ConsumerWidget {
  final String? title;
  final ProductSearchResult? product;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    this.title,
    this.onTap,
  })  : product = null;

  const ProductCard.fromProduct({
    super.key,
    required this.product,
    this.onTap,
  })  : title = null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Center(
                  child: product?.imageUrl != null
                      ? Image.network(
                          product!.imageUrl!,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.image_not_supported, size: 64),
                        )
                      : Icon(
                          Icons.card_giftcard,
                          size: 64,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title ?? product?.title ?? '',
                      style: GoogleFonts.poppins(
                        fontSize: ResponsiveHelper.isMobile(context) ? 14 : 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (product != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '₹${product!.price.toStringAsFixed(2)}',
                        style: GoogleFonts.poppins(
                          fontSize: ResponsiveHelper.isMobile(context) ? 16 : 18,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product!.platform,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontSize: ResponsiveHelper.isMobile(context) ? 12 : 14,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
