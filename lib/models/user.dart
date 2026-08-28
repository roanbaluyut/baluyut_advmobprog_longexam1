class User {
  final int id;
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String? phone;
  final String? image;
  final String? gender;
  final int? age;
  final String? university;
  final String? city;
  final String? country;

  /// Only present right after a successful /user/login call.
  final String? accessToken;
  final String? refreshToken;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    this.phone,
    this.image,
    this.gender,
    this.age,
    this.university,
    this.city,
    this.country,
    this.accessToken,
    this.refreshToken,
  });

  String get fullName => '$firstName $lastName';

  factory User.fromJson(Map<String, dynamic> json) {
    final address = json['address'] as Map<String, dynamic>?;
    return User(
      id: json['id'] as int,
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      image: json['image'],
      gender: json['gender'],
      age: json['age'],
      university: json['university'],
      city: address != null ? address['city'] : null,
      country: address != null ? address['country'] : null,
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'username': username,
      'email': email,
      'phone': phone,
      'image': image,
      'gender': gender,
      'age': age,
      'university': university,
      'city': city,
      'country': country,
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    };
  }

  /// Merge extra profile data (e.g. from GET /users/{id}) into a session
  /// user created from the smaller /user/login payload.
  User copyWith(User other) {
    return User(
      id: other.id,
      firstName: other.firstName,
      lastName: other.lastName,
      username: other.username,
      email: other.email,
      phone: other.phone ?? phone,
      image: other.image ?? image,
      gender: other.gender ?? gender,
      age: other.age ?? age,
      university: other.university ?? university,
      city: other.city ?? city,
      country: other.country ?? country,
      accessToken: accessToken ?? other.accessToken,
      refreshToken: refreshToken ?? other.refreshToken,
    );
  }
}
