class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String profession; // albañil, fontanero, electricista, etc.
  final bool isLoggedIn;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.profession,
    this.isLoggedIn = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      profession: json['profession'],
      isLoggedIn: json['isLoggedIn'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'profession': profession,
      'isLoggedIn': isLoggedIn,
    };
  }
}
