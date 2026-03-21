class UserProfile {
  String name;
  int age;
  String gender;
  int avatarIndex;

  UserProfile({
    required this.name,
    required this.age,
    required this.gender,
    this.avatarIndex = 0,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'age': age,
        'gender': gender,
        'avatarIndex': avatarIndex,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        name: json['name'] ?? '',
        age: json['age'] ?? 0,
        gender: json['gender'] ?? '',
        avatarIndex: json['avatarIndex'] ?? 0,
      );
}
