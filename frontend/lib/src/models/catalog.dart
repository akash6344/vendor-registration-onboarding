class AppData {
  AppData({required this.categories, required this.plans});

  final List<Category> categories;
  final List<Plan> plans;

  Category? category(String? id) => categories.where((item) => item.id == id).firstOrNull;

  List<ServiceItem> servicesFor(List<String> subcategoryIds) {
    return [
      for (final category in categories)
        for (final subcategory in category.subcategories)
          if (subcategoryIds.contains(subcategory.id))
            for (final service in subcategory.services)
              service.copyWith(subcategoryName: subcategory.name),
    ];
  }

  List<ServiceItem> servicesByIds(List<String> ids) {
    final allSubcategoryIds = categories.expand((category) => category.subcategories).map((subcategory) => subcategory.id).toList();
    return servicesFor(allSubcategoryIds).where((item) => ids.contains(item.id)).toList();
  }
}

class Category {
  Category({
    required this.id,
    required this.name,
    required this.description,
    required this.subcategories,
  });

  final String id;
  final String name;
  final String description;
  final List<Subcategory> subcategories;

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      subcategories: (json['subcategories'] as List).map((item) => Subcategory.fromJson(item)).toList(),
    );
  }
}

class Subcategory {
  Subcategory({required this.id, required this.name, required this.services});

  final String id;
  final String name;
  final List<ServiceItem> services;

  factory Subcategory.fromJson(Map<String, dynamic> json) {
    return Subcategory(
      id: json['id'],
      name: json['name'],
      services: (json['services'] as List).map((item) => ServiceItem.fromJson(item)).toList(),
    );
  }
}

class ServiceItem {
  ServiceItem({required this.id, required this.name, this.subcategoryName = ''});

  final String id;
  final String name;
  final String subcategoryName;

  ServiceItem copyWith({String? subcategoryName}) {
    return ServiceItem(
      id: id,
      name: name,
      subcategoryName: subcategoryName ?? this.subcategoryName,
    );
  }

  factory ServiceItem.fromJson(Map<String, dynamic> json) {
    return ServiceItem(id: json['id'], name: json['name']);
  }
}

class Plan {
  Plan({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.durationDays,
    required this.features,
  });

  final String id;
  final String name;
  final String description;
  final int price;
  final int durationDays;
  final List<String> features;

  factory Plan.fromJson(Map<String, dynamic> json) {
    return Plan(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'],
      durationDays: json['durationDays'],
      features: List<String>.from(json['features']),
    );
  }
}

extension FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
