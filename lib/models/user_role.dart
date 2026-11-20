/// Roles available in A2 Stocks.
enum UserRole {
  admin,
  manager,
  staff;

  /// Parses a stored role name. Unknown values fall back to the least
  /// privileged role.
  static UserRole fromName(String? name) {
    for (final UserRole role in UserRole.values) {
      if (role.name == name) {
        return role;
      }
    }
    return UserRole.staff;
  }
}
