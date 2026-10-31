class RentalMaterial {
  const RentalMaterial({
    required this.id,
    required this.category,
    required this.name,
    required this.pricePerDay,
    required this.totalStock,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String category;
  final String name;
  final int pricePerDay;
  final int? totalStock;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  RentalMaterial copyWith({
    String? category,
    String? name,
    int? pricePerDay,
    Object? totalStock = _unchanged,
    bool? isActive,
    DateTime? updatedAt,
  }) {
    return RentalMaterial(
      id: id,
      category: category ?? this.category,
      name: name ?? this.name,
      pricePerDay: pricePerDay ?? this.pricePerDay,
      totalStock: identical(totalStock, _unchanged)
          ? this.totalStock
          : totalStock as int?,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, Object?> toJson() => {
    'id': id,
    'category': category,
    'name': name,
    'pricePerDay': pricePerDay,
    'totalStock': totalStock,
    'isActive': isActive,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'updatedAt': updatedAt.toUtc().toIso8601String(),
  };
}

const _unchanged = Object();
