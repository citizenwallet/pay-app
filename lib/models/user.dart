class User {
  String name;
  String username;
  String account;

  String? imageUrl;
  String? description;
  String? placeId;

  User({
    required this.name,
    required this.username,
    required this.account,
    this.imageUrl,
    this.description,
    this.placeId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      account: json['account'],
      username: json['username'],
      name: json['name'],
      description: json['description'] == '' ? null : json['description'],
      imageUrl: json['image'] == '' ? null : json['image'],
      placeId: json['place_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'username': username,
      'account': account,
      'image': imageUrl,
      'description': description,
      'place_id': placeId,
    };
  }

  @override
  String toString() {
    return 'User(name: $name, username: $username, account: $account, imageUrl: $imageUrl, description: $description, placeId: $placeId)';
  }
}
