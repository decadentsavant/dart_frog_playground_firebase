class AuthUser {
  AuthUser({
    this.id,
    this.name,
    required this.email,
    required this.password,
    this.age,
    this.weight,
  });

  // this method is required to create a User
  // object from received JSON data
  AuthUser.fromJson(Map<String, dynamic> json)
      : id = json['id'] as String?,
        name = json['name'] as String?,
        email = json['email'] as String?,
        password = json['password'] as String?,
        age = json['age'] as int?,
        weight = json['weight'] as int?;

  final String? id;
  final String? name;
  final String? email;
  final String? password;
  final int? age;
  final int? weight;

  // this method is required to send data across as JSON
  // it just converts the object to a map
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'email': email,
        'password': password,
        'age': age,
        'weight': weight,
      };

  /// Method for copying the model
  AuthUser copyWith({
    String? id,
    String? name,
    String? email,
    String? password,
    int? age,
    int? weight,
  }) =>
      AuthUser(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email ?? this.email,
        password: password ?? this.password,
        age: age ?? this.age,
        weight: weight ?? this.weight,
      );
}
