class AdminDTO{
  final int id;
  final String email;
  late String name;
  late String password;

  AdminDTO({required this.id, required this.email, required this.name, required this.password});

  factory AdminDTO.fromJson(Map<String, dynamic> json) {
    return AdminDTO(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      password: json['password'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id' : id,
    'email': email,
    'name': name,
    'password': password,
  };

}