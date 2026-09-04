class ServiceDetail {
  ServiceDetail({
    required this.price,
    required this.pricingType,
    required this.images,
    required this.videos,
  });

  final double price;
  final String pricingType;
  final List<String> images;
  final List<String> videos;

  factory ServiceDetail.empty() {
    return ServiceDetail(price: 0, pricingType: 'FIXED', images: [], videos: []);
  }

  factory ServiceDetail.fromJson(Map<String, dynamic> json) {
    return ServiceDetail(
      price: (json['price'] ?? 0).toDouble(),
      pricingType: json['pricingType'] ?? 'FIXED',
      images: List<String>.from(json['images'] ?? []),
      videos: List<String>.from(json['videos'] ?? []),
    );
  }

  ServiceDetail copyWith({
    double? price,
    String? pricingType,
    List<String>? images,
    List<String>? videos,
  }) {
    return ServiceDetail(
      price: price ?? this.price,
      pricingType: pricingType ?? this.pricingType,
      images: images ?? this.images,
      videos: videos ?? this.videos,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'price': price,
      'pricingType': pricingType,
      'images': images,
      'videos': videos,
    };
  }
}
