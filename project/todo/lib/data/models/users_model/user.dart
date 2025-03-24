class User {
  final int id;
  final String name;
  final String icon;
  final String color;

  User(
      {required this.id,
      required this.name,
      required this.icon,
      required this.color});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      icon: map['icon'],
      color: map['color'],
    );
  }
}
