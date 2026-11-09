class MerchantModel {
  final String id;
  final String name;
  final String mid;
  final String city;
  final String avatarInitials;

  const MerchantModel({
    required this.id,
    required this.name,
    required this.mid,
    required this.city,
    required this.avatarInitials,
  });

  factory MerchantModel.defaultMerchant() {
    return const MerchantModel(
      id: 'warung-maju',
      name: 'Warung Maju',
      mid: '8801-2290',
      city: 'Jakarta',
      avatarInitials: 'WM',
    );
  }

  factory MerchantModel.fromJson(Map<String, dynamic> json) {
    return MerchantModel(
      id: json['id'] as String? ?? 'warung-maju',
      name: json['name'] as String? ?? 'Warung Maju',
      mid: json['mid'] as String? ?? '8801-2290',
      city: json['city'] as String? ?? 'Jakarta',
      avatarInitials: json['avatarInitials'] as String? ?? 'WM',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'mid': mid,
    'city': city,
    'avatarInitials': avatarInitials,
  };
}
