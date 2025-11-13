class User {
  final String id;
  final String name;
  final String? profilePictureUrl;

  User({
    required this.id,
    required this.name,
    this.profilePictureUrl,
  });
}
