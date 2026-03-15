import 'package:flutter/material.dart';
import '../../../models/customer_model.dart';

class WishlistPreview extends StatelessWidget {
  final Customer customer;

  const WishlistPreview({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    if (customer.safeWishlist.isEmpty) {
      return const SizedBox();
    }

    return Container(
      padding: const EdgeInsets.all(12),

      child: Row(
        children: [
          const Icon(Icons.bookmark, color: Colors.amber),

          const SizedBox(width: 6),

          Text(
            "${customer.safeWishlist.length} wishlist items",
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
