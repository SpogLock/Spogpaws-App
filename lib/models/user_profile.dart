enum AccountStatus { pending, active, suspended, banned, unknown }

AccountStatus accountStatusFromString(String? value) {
  switch (value) {
    case 'pending':
      return AccountStatus.pending;
    case 'active':
      return AccountStatus.active;
    case 'suspended':
      return AccountStatus.suspended;
    case 'banned':
      return AccountStatus.banned;
    default:
      return AccountStatus.unknown;
  }
}

String accountStatusToString(AccountStatus value) {
  switch (value) {
    case AccountStatus.pending:
      return 'pending';
    case AccountStatus.active:
      return 'active';
    case AccountStatus.suspended:
      return 'suspended';
    case AccountStatus.banned:
      return 'banned';
    case AccountStatus.unknown:
      return 'unknown';
  }
}

class UserProfile {
  const UserProfile({
    required this.id,
    required this.email,
    required this.fullName,
    required this.username,
    required this.accountStatus,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String email;
  final String? fullName;
  final String? username;
  final AccountStatus accountStatus;
  final String role;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: (map['id'] ?? '').toString(),
      email: (map['email'] ?? '').toString(),
      fullName: map['full_name']?.toString(),
      username: map['username']?.toString(),
      accountStatus: accountStatusFromString(map['account_status']?.toString()),
      role: (map['role'] ?? 'user').toString(),
      createdAt: DateTime.tryParse((map['created_at'] ?? '').toString()),
      updatedAt: DateTime.tryParse((map['updated_at'] ?? '').toString()),
    );
  }
}
