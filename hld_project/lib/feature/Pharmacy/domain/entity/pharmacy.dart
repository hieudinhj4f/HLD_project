// feature/Pharmacy/domain/entity/pharmacy.dart

class Pharmacy {
  final String id;
  final String name;
  final String? imageUrl;
  final String? address;
  final String? phone;
  final String state; // Current Working, Pending, Inactive
  final int staffCount;

  // === CHỈ BỔ SUNG NHỮNG TRƯỜNG CẦN THIẾT NHẤT ===
  final String ownerId;     // UID chủ sở hữu
  final DateTime createdAt;
  final bool isActive;

  const Pharmacy({
    required this.id,
    required this.name,
    this.imageUrl,
    this.address,
    this.phone,
    required this.state,
    required this.staffCount,
    required this.ownerId,
    required this.createdAt,
    this.isActive = true,
  });

  // === COPY WITH (Tiện cho update) ===
  Pharmacy copyWith({
    String? id,
    String? name,
    String? imageUrl,
    String? address,
    String? phone,
    String? state,
    int? staffCount,
    String? ownerId,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return Pharmacy(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      state: state ?? this.state,
      staffCount: staffCount ?? this.staffCount,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }

  // === FROM JSON (Firestore) ===
  factory Pharmacy.fromJson(Map<String, dynamic> json) {
    return Pharmacy(
      id: json['id'] as String,
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String?,
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      state: json['state'] as String? ?? 'Pending',
      staffCount: (json['staffCount'] as num?)?.toInt() ?? 0,
      ownerId: json['ownerId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  // === TO JSON ===
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'address': address,
      'phone': phone,
      'state': state,
      'staffCount': staffCount,
      'ownerId': ownerId,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
    };
  }
}