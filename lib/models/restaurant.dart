class Restaurant {
  String? id;
  String? name;
  String? description;
  String? pictureId;
  String? city;
  double? rating;
  String? address; // For detail page

  Restaurant({
    this.id,
    this.name,
    this.description,
    this.pictureId,
    this.city,
    this.rating,
    this.address,
  });

  // Factory constructor for parsing the list API response
  factory Restaurant.fromJsonList(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'] as String?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      pictureId: json['pictureId'] as String?,
      city: json['city'] as String?,
      rating: (json['rating'] as num?)?.toDouble(), // Correct conversion [cite: 28]
    );
  }

  // Factory constructor for parsing the detail API response
  factory Restaurant.fromJsonDetail(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'] as String?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      pictureId: json['pictureId'] as String?,
      city: json['city'] as String?,
      address: json['address'] as String?,
      rating: (json['rating'] as num?)?.toDouble(), // Correct conversion [cite: 28]
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'pictureId': pictureId,
      'city': city,
      'rating': rating,
      'address': address,
    };
  }
}