import 'product.dart';

/// Listing is a simplified view model for Product
/// It provides a compatibility layer for UI components
class Listing {
  final String id;
  final String title;
  final double price;
  final String imageUrl;
  final int views;
  final Product? product; // Optional reference to full product

  Listing({
    required this.id,
    required this.title,
    required this.price,
    required this.imageUrl,
    this.views = 0,
    this.product,
  });

  /// Create a Listing from a Product
  factory Listing.fromProduct(Product product) {
    return Listing(
      id: product.id,
      title: product.name,
      price: product.price,
      imageUrl: product.imageUrls.isNotEmpty ? product.imageUrls[0] : '',
      product: product,
    );
  }

  /// Convert back to Product if available
  Product? toProduct() => product;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Listing && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
