class Customer {
  const Customer({
    required this.id,
    required this.fullName,
    required this.address,
    required this.phone,
    required this.notes,
    required this.idPhotoFrontPath,
    required this.idPhotoBackPath,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String fullName;
  final String address;
  final String? phone;
  final String? notes;
  final String idPhotoFrontPath;
  final String? idPhotoBackPath;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Customer copyWith({
    String? fullName,
    String? address,
    Object? phone = _unchanged,
    Object? notes = _unchanged,
    String? idPhotoFrontPath,
    Object? idPhotoBackPath = _unchanged,
    bool? isActive,
    DateTime? updatedAt,
  }) {
    return Customer(
      id: id,
      fullName: fullName ?? this.fullName,
      address: address ?? this.address,
      phone: identical(phone, _unchanged) ? this.phone : phone as String?,
      notes: identical(notes, _unchanged) ? this.notes : notes as String?,
      idPhotoFrontPath: idPhotoFrontPath ?? this.idPhotoFrontPath,
      idPhotoBackPath: identical(idPhotoBackPath, _unchanged)
          ? this.idPhotoBackPath
          : idPhotoBackPath as String?,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, Object?> toJson() => {
    'id': id,
    'fullName': fullName,
    'address': address,
    'phone': phone,
    'notes': notes,
    'idPhotoFrontPath': idPhotoFrontPath,
    'idPhotoBackPath': idPhotoBackPath,
    'isActive': isActive,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'updatedAt': updatedAt.toUtc().toIso8601String(),
  };
}

const _unchanged = Object();
