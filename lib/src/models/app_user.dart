class AppUser {
  const AppUser({
    required this.id,
    required this.username,
    required this.fullName,
    required this.credits,
    required this.isVip,
    this.email,
    this.avatarUrl,
    this.age,
    this.jobTitle,
    this.gender,
    this.partner,
  });

  final int id;
  final String username;
  final String fullName;
  final int credits;
  final bool isVip;
  final String? email;
  final String? avatarUrl;
  final int? age;
  final String? jobTitle;
  final String? gender;
  final String? partner;

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'] as int,
        username: json['username'] as String,
        fullName: json['full_name'] as String,
        credits: json['credits'] as int? ?? 0,
        isVip: json['is_vip'] as bool? ?? false,
        email: json['email'] as String?,
        avatarUrl: json['avatar_url'] as String?,
        age: json['age'] as int?,
        jobTitle: json['job_title'] as String?,
        gender: json['gender'] as String?,
        partner: json['partner'] as String?,
      );
}
