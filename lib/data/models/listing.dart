class Listing {
  final String id;
  final String title;
  final double price;
  final String imageUrl;
  final String status;
  final int views;
  final int likes;

  Listing({
    required this.id,
    required this.title,
    required this.price,
    required this.imageUrl,
    this.status = 'active',
    this.views = 0,
    this.likes = 0,
  });
}
