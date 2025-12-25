class User {
  final int id;
  final String fullName;

  User({required this.id, required this.fullName});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(id: json['id'], fullName: json['fullName']);
  }

  String get initials {
    List<String> parts = fullName.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}';
    }
    return fullName[0];
  }
}
