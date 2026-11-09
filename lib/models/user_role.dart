/// Roles available in MQ Sports ERP.
enum UserRole {
  admin('Admin'),
  manager('Manager'),
  staff('Staff');

  const UserRole(this.label);

  final String label;

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
