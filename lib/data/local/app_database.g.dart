// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $UsersTable extends Users with TableInfo<$UsersTable, UserRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _displayNameMeta =
      const VerificationMeta('displayName');
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
      'display_name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _phoneNumberMeta =
      const VerificationMeta('phoneNumber');
  @override
  late final GeneratedColumn<String> phoneNumber = GeneratedColumn<String>(
      'phone_number', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
      'role', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('staff'));
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _photoUrlMeta =
      const VerificationMeta('photoUrl');
  @override
  late final GeneratedColumn<String> photoUrl = GeneratedColumn<String>(
      'photo_url', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        email,
        displayName,
        phoneNumber,
        role,
        isActive,
        photoUrl,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(Insertable<UserRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
          _displayNameMeta,
          displayName.isAcceptableOrUnknown(
              data['display_name']!, _displayNameMeta));
    }
    if (data.containsKey('phone_number')) {
      context.handle(
          _phoneNumberMeta,
          phoneNumber.isAcceptableOrUnknown(
              data['phone_number']!, _phoneNumberMeta));
    }
    if (data.containsKey('role')) {
      context.handle(
          _roleMeta, role.isAcceptableOrUnknown(data['role']!, _roleMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('photo_url')) {
      context.handle(_photoUrlMeta,
          photoUrl.isAcceptableOrUnknown(data['photo_url']!, _photoUrlMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email'])!,
      displayName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}display_name'])!,
      phoneNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone_number'])!,
      role: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}role'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      photoUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}photo_url'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class UserRow extends DataClass implements Insertable<UserRow> {
  final String id;
  final String email;
  final String displayName;
  final String phoneNumber;
  final String role;
  final bool isActive;
  final String photoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  const UserRow(
      {required this.id,
      required this.email,
      required this.displayName,
      required this.phoneNumber,
      required this.role,
      required this.isActive,
      required this.photoUrl,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['email'] = Variable<String>(email);
    map['display_name'] = Variable<String>(displayName);
    map['phone_number'] = Variable<String>(phoneNumber);
    map['role'] = Variable<String>(role);
    map['is_active'] = Variable<bool>(isActive);
    map['photo_url'] = Variable<String>(photoUrl);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      email: Value(email),
      displayName: Value(displayName),
      phoneNumber: Value(phoneNumber),
      role: Value(role),
      isActive: Value(isActive),
      photoUrl: Value(photoUrl),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory UserRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserRow(
      id: serializer.fromJson<String>(json['id']),
      email: serializer.fromJson<String>(json['email']),
      displayName: serializer.fromJson<String>(json['displayName']),
      phoneNumber: serializer.fromJson<String>(json['phoneNumber']),
      role: serializer.fromJson<String>(json['role']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      photoUrl: serializer.fromJson<String>(json['photoUrl']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'email': serializer.toJson<String>(email),
      'displayName': serializer.toJson<String>(displayName),
      'phoneNumber': serializer.toJson<String>(phoneNumber),
      'role': serializer.toJson<String>(role),
      'isActive': serializer.toJson<bool>(isActive),
      'photoUrl': serializer.toJson<String>(photoUrl),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  UserRow copyWith(
          {String? id,
          String? email,
          String? displayName,
          String? phoneNumber,
          String? role,
          bool? isActive,
          String? photoUrl,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      UserRow(
        id: id ?? this.id,
        email: email ?? this.email,
        displayName: displayName ?? this.displayName,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        role: role ?? this.role,
        isActive: isActive ?? this.isActive,
        photoUrl: photoUrl ?? this.photoUrl,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  UserRow copyWithCompanion(UsersCompanion data) {
    return UserRow(
      id: data.id.present ? data.id.value : this.id,
      email: data.email.present ? data.email.value : this.email,
      displayName:
          data.displayName.present ? data.displayName.value : this.displayName,
      phoneNumber:
          data.phoneNumber.present ? data.phoneNumber.value : this.phoneNumber,
      role: data.role.present ? data.role.value : this.role,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      photoUrl: data.photoUrl.present ? data.photoUrl.value : this.photoUrl,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserRow(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('displayName: $displayName, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('role: $role, ')
          ..write('isActive: $isActive, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, email, displayName, phoneNumber, role,
      isActive, photoUrl, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserRow &&
          other.id == this.id &&
          other.email == this.email &&
          other.displayName == this.displayName &&
          other.phoneNumber == this.phoneNumber &&
          other.role == this.role &&
          other.isActive == this.isActive &&
          other.photoUrl == this.photoUrl &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class UsersCompanion extends UpdateCompanion<UserRow> {
  final Value<String> id;
  final Value<String> email;
  final Value<String> displayName;
  final Value<String> phoneNumber;
  final Value<String> role;
  final Value<bool> isActive;
  final Value<String> photoUrl;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.email = const Value.absent(),
    this.displayName = const Value.absent(),
    this.phoneNumber = const Value.absent(),
    this.role = const Value.absent(),
    this.isActive = const Value.absent(),
    this.photoUrl = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersCompanion.insert({
    required String id,
    required String email,
    this.displayName = const Value.absent(),
    this.phoneNumber = const Value.absent(),
    this.role = const Value.absent(),
    this.isActive = const Value.absent(),
    this.photoUrl = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        email = Value(email),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<UserRow> custom({
    Expression<String>? id,
    Expression<String>? email,
    Expression<String>? displayName,
    Expression<String>? phoneNumber,
    Expression<String>? role,
    Expression<bool>? isActive,
    Expression<String>? photoUrl,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (email != null) 'email': email,
      if (displayName != null) 'display_name': displayName,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (role != null) 'role': role,
      if (isActive != null) 'is_active': isActive,
      if (photoUrl != null) 'photo_url': photoUrl,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersCompanion copyWith(
      {Value<String>? id,
      Value<String>? email,
      Value<String>? displayName,
      Value<String>? phoneNumber,
      Value<String>? role,
      Value<bool>? isActive,
      Value<String>? photoUrl,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return UsersCompanion(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (phoneNumber.present) {
      map['phone_number'] = Variable<String>(phoneNumber.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (photoUrl.present) {
      map['photo_url'] = Variable<String>(photoUrl.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('displayName: $displayName, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('role: $role, ')
          ..write('isActive: $isActive, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, CategoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _parentIdMeta =
      const VerificationMeta('parentId');
  @override
  late final GeneratedColumn<String> parentId = GeneratedColumn<String>(
      'parent_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _photoUrlMeta =
      const VerificationMeta('photoUrl');
  @override
  late final GeneratedColumn<String> photoUrl = GeneratedColumn<String>(
      'photo_url', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        parentId,
        description,
        isActive,
        photoUrl,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(Insertable<CategoryRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('parent_id')) {
      context.handle(_parentIdMeta,
          parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta));
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('photo_url')) {
      context.handle(_photoUrlMeta,
          photoUrl.isAcceptableOrUnknown(data['photo_url']!, _photoUrlMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CategoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      parentId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}parent_id'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      photoUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}photo_url'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class CategoryRow extends DataClass implements Insertable<CategoryRow> {
  final String id;
  final String name;
  final String parentId;
  final String description;
  final bool isActive;
  final String photoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  const CategoryRow(
      {required this.id,
      required this.name,
      required this.parentId,
      required this.description,
      required this.isActive,
      required this.photoUrl,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['parent_id'] = Variable<String>(parentId);
    map['description'] = Variable<String>(description);
    map['is_active'] = Variable<bool>(isActive);
    map['photo_url'] = Variable<String>(photoUrl);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      parentId: Value(parentId),
      description: Value(description),
      isActive: Value(isActive),
      photoUrl: Value(photoUrl),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory CategoryRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      parentId: serializer.fromJson<String>(json['parentId']),
      description: serializer.fromJson<String>(json['description']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      photoUrl: serializer.fromJson<String>(json['photoUrl']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'parentId': serializer.toJson<String>(parentId),
      'description': serializer.toJson<String>(description),
      'isActive': serializer.toJson<bool>(isActive),
      'photoUrl': serializer.toJson<String>(photoUrl),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CategoryRow copyWith(
          {String? id,
          String? name,
          String? parentId,
          String? description,
          bool? isActive,
          String? photoUrl,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      CategoryRow(
        id: id ?? this.id,
        name: name ?? this.name,
        parentId: parentId ?? this.parentId,
        description: description ?? this.description,
        isActive: isActive ?? this.isActive,
        photoUrl: photoUrl ?? this.photoUrl,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  CategoryRow copyWithCompanion(CategoriesCompanion data) {
    return CategoryRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      description:
          data.description.present ? data.description.value : this.description,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      photoUrl: data.photoUrl.present ? data.photoUrl.value : this.photoUrl,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoryRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('parentId: $parentId, ')
          ..write('description: $description, ')
          ..write('isActive: $isActive, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, parentId, description, isActive,
      photoUrl, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.parentId == this.parentId &&
          other.description == this.description &&
          other.isActive == this.isActive &&
          other.photoUrl == this.photoUrl &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CategoriesCompanion extends UpdateCompanion<CategoryRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> parentId;
  final Value<String> description;
  final Value<bool> isActive;
  final Value<String> photoUrl;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.parentId = const Value.absent(),
    this.description = const Value.absent(),
    this.isActive = const Value.absent(),
    this.photoUrl = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesCompanion.insert({
    required String id,
    required String name,
    this.parentId = const Value.absent(),
    this.description = const Value.absent(),
    this.isActive = const Value.absent(),
    this.photoUrl = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<CategoryRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? parentId,
    Expression<String>? description,
    Expression<bool>? isActive,
    Expression<String>? photoUrl,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (parentId != null) 'parent_id': parentId,
      if (description != null) 'description': description,
      if (isActive != null) 'is_active': isActive,
      if (photoUrl != null) 'photo_url': photoUrl,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? parentId,
      Value<String>? description,
      Value<bool>? isActive,
      Value<String>? photoUrl,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<String>(parentId.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (photoUrl.present) {
      map['photo_url'] = Variable<String>(photoUrl.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('parentId: $parentId, ')
          ..write('description: $description, ')
          ..write('isActive: $isActive, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProductsTable extends Products
    with TableInfo<$ProductsTable, ProductRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
      'category_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _brandMeta = const VerificationMeta('brand');
  @override
  late final GeneratedColumn<String> brand = GeneratedColumn<String>(
      'brand', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _imagesJsonMeta =
      const VerificationMeta('imagesJson');
  @override
  late final GeneratedColumn<String> imagesJson = GeneratedColumn<String>(
      'images_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        categoryId,
        brand,
        description,
        isActive,
        imagesJson,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'products';
  @override
  VerificationContext validateIntegrity(Insertable<ProductRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('brand')) {
      context.handle(
          _brandMeta, brand.isAcceptableOrUnknown(data['brand']!, _brandMeta));
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('images_json')) {
      context.handle(
          _imagesJsonMeta,
          imagesJson.isAcceptableOrUnknown(
              data['images_json']!, _imagesJsonMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProductRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProductRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category_id'])!,
      brand: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}brand'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      imagesJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}images_json'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $ProductsTable createAlias(String alias) {
    return $ProductsTable(attachedDatabase, alias);
  }
}

class ProductRow extends DataClass implements Insertable<ProductRow> {
  final String id;
  final String name;
  final String categoryId;
  final String brand;
  final String description;
  final bool isActive;

  /// The photos as a JSON list (see ProductImage).
  final String imagesJson;
  final DateTime createdAt;
  final DateTime updatedAt;
  const ProductRow(
      {required this.id,
      required this.name,
      required this.categoryId,
      required this.brand,
      required this.description,
      required this.isActive,
      required this.imagesJson,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['category_id'] = Variable<String>(categoryId);
    map['brand'] = Variable<String>(brand);
    map['description'] = Variable<String>(description);
    map['is_active'] = Variable<bool>(isActive);
    map['images_json'] = Variable<String>(imagesJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ProductsCompanion toCompanion(bool nullToAbsent) {
    return ProductsCompanion(
      id: Value(id),
      name: Value(name),
      categoryId: Value(categoryId),
      brand: Value(brand),
      description: Value(description),
      isActive: Value(isActive),
      imagesJson: Value(imagesJson),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ProductRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProductRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      brand: serializer.fromJson<String>(json['brand']),
      description: serializer.fromJson<String>(json['description']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      imagesJson: serializer.fromJson<String>(json['imagesJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'categoryId': serializer.toJson<String>(categoryId),
      'brand': serializer.toJson<String>(brand),
      'description': serializer.toJson<String>(description),
      'isActive': serializer.toJson<bool>(isActive),
      'imagesJson': serializer.toJson<String>(imagesJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ProductRow copyWith(
          {String? id,
          String? name,
          String? categoryId,
          String? brand,
          String? description,
          bool? isActive,
          String? imagesJson,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      ProductRow(
        id: id ?? this.id,
        name: name ?? this.name,
        categoryId: categoryId ?? this.categoryId,
        brand: brand ?? this.brand,
        description: description ?? this.description,
        isActive: isActive ?? this.isActive,
        imagesJson: imagesJson ?? this.imagesJson,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  ProductRow copyWithCompanion(ProductsCompanion data) {
    return ProductRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      brand: data.brand.present ? data.brand.value : this.brand,
      description:
          data.description.present ? data.description.value : this.description,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      imagesJson:
          data.imagesJson.present ? data.imagesJson.value : this.imagesJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProductRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('categoryId: $categoryId, ')
          ..write('brand: $brand, ')
          ..write('description: $description, ')
          ..write('isActive: $isActive, ')
          ..write('imagesJson: $imagesJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, categoryId, brand, description,
      isActive, imagesJson, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProductRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.categoryId == this.categoryId &&
          other.brand == this.brand &&
          other.description == this.description &&
          other.isActive == this.isActive &&
          other.imagesJson == this.imagesJson &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ProductsCompanion extends UpdateCompanion<ProductRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> categoryId;
  final Value<String> brand;
  final Value<String> description;
  final Value<bool> isActive;
  final Value<String> imagesJson;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ProductsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.brand = const Value.absent(),
    this.description = const Value.absent(),
    this.isActive = const Value.absent(),
    this.imagesJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProductsCompanion.insert({
    required String id,
    required String name,
    required String categoryId,
    this.brand = const Value.absent(),
    this.description = const Value.absent(),
    this.isActive = const Value.absent(),
    this.imagesJson = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        categoryId = Value(categoryId),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<ProductRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? categoryId,
    Expression<String>? brand,
    Expression<String>? description,
    Expression<bool>? isActive,
    Expression<String>? imagesJson,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (categoryId != null) 'category_id': categoryId,
      if (brand != null) 'brand': brand,
      if (description != null) 'description': description,
      if (isActive != null) 'is_active': isActive,
      if (imagesJson != null) 'images_json': imagesJson,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProductsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? categoryId,
      Value<String>? brand,
      Value<String>? description,
      Value<bool>? isActive,
      Value<String>? imagesJson,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return ProductsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      brand: brand ?? this.brand,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      imagesJson: imagesJson ?? this.imagesJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (brand.present) {
      map['brand'] = Variable<String>(brand.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (imagesJson.present) {
      map['images_json'] = Variable<String>(imagesJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('categoryId: $categoryId, ')
          ..write('brand: $brand, ')
          ..write('description: $description, ')
          ..write('isActive: $isActive, ')
          ..write('imagesJson: $imagesJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProductVariantsTable extends ProductVariants
    with TableInfo<$ProductVariantsTable, VariantRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductVariantsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _productIdMeta =
      const VerificationMeta('productId');
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
      'product_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _skuMeta = const VerificationMeta('sku');
  @override
  late final GeneratedColumn<String> sku = GeneratedColumn<String>(
      'sku', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _barcodeMeta =
      const VerificationMeta('barcode');
  @override
  late final GeneratedColumn<String> barcode = GeneratedColumn<String>(
      'barcode', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _attributesJsonMeta =
      const VerificationMeta('attributesJson');
  @override
  late final GeneratedColumn<String> attributesJson = GeneratedColumn<String>(
      'attributes_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('{}'));
  static const VerificationMeta _costPriceMeta =
      const VerificationMeta('costPrice');
  @override
  late final GeneratedColumn<double> costPrice = GeneratedColumn<double>(
      'cost_price', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _salePriceMeta =
      const VerificationMeta('salePrice');
  @override
  late final GeneratedColumn<double> salePrice = GeneratedColumn<double>(
      'sale_price', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _isWholesaleMeta =
      const VerificationMeta('isWholesale');
  @override
  late final GeneratedColumn<bool> isWholesale = GeneratedColumn<bool>(
      'is_wholesale', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_wholesale" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _wholesalePriceMeta =
      const VerificationMeta('wholesalePrice');
  @override
  late final GeneratedColumn<double> wholesalePrice = GeneratedColumn<double>(
      'wholesale_price', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _alertThresholdMeta =
      const VerificationMeta('alertThreshold');
  @override
  late final GeneratedColumn<int> alertThreshold = GeneratedColumn<int>(
      'alert_threshold', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _positionMeta =
      const VerificationMeta('position');
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
      'position', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        productId,
        sku,
        name,
        barcode,
        attributesJson,
        costPrice,
        salePrice,
        isWholesale,
        wholesalePrice,
        alertThreshold,
        isActive,
        position
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'product_variants';
  @override
  VerificationContext validateIntegrity(Insertable<VariantRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(_productIdMeta,
          productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta));
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('sku')) {
      context.handle(
          _skuMeta, sku.isAcceptableOrUnknown(data['sku']!, _skuMeta));
    } else if (isInserting) {
      context.missing(_skuMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    }
    if (data.containsKey('barcode')) {
      context.handle(_barcodeMeta,
          barcode.isAcceptableOrUnknown(data['barcode']!, _barcodeMeta));
    }
    if (data.containsKey('attributes_json')) {
      context.handle(
          _attributesJsonMeta,
          attributesJson.isAcceptableOrUnknown(
              data['attributes_json']!, _attributesJsonMeta));
    }
    if (data.containsKey('cost_price')) {
      context.handle(_costPriceMeta,
          costPrice.isAcceptableOrUnknown(data['cost_price']!, _costPriceMeta));
    }
    if (data.containsKey('sale_price')) {
      context.handle(_salePriceMeta,
          salePrice.isAcceptableOrUnknown(data['sale_price']!, _salePriceMeta));
    }
    if (data.containsKey('is_wholesale')) {
      context.handle(
          _isWholesaleMeta,
          isWholesale.isAcceptableOrUnknown(
              data['is_wholesale']!, _isWholesaleMeta));
    }
    if (data.containsKey('wholesale_price')) {
      context.handle(
          _wholesalePriceMeta,
          wholesalePrice.isAcceptableOrUnknown(
              data['wholesale_price']!, _wholesalePriceMeta));
    }
    if (data.containsKey('alert_threshold')) {
      context.handle(
          _alertThresholdMeta,
          alertThreshold.isAcceptableOrUnknown(
              data['alert_threshold']!, _alertThresholdMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('position')) {
      context.handle(_positionMeta,
          position.isAcceptableOrUnknown(data['position']!, _positionMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VariantRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VariantRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      productId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}product_id'])!,
      sku: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sku'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      barcode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}barcode'])!,
      attributesJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}attributes_json'])!,
      costPrice: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}cost_price'])!,
      salePrice: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}sale_price'])!,
      isWholesale: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_wholesale'])!,
      wholesalePrice: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}wholesale_price'])!,
      alertThreshold: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}alert_threshold'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      position: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}position'])!,
    );
  }

  @override
  $ProductVariantsTable createAlias(String alias) {
    return $ProductVariantsTable(attachedDatabase, alias);
  }
}

class VariantRow extends DataClass implements Insertable<VariantRow> {
  final String id;
  final String productId;
  final String sku;
  final String name;
  final String barcode;
  final String attributesJson;
  final double costPrice;
  final double salePrice;
  final bool isWholesale;
  final double wholesalePrice;
  final int alertThreshold;
  final bool isActive;
  final int position;
  const VariantRow(
      {required this.id,
      required this.productId,
      required this.sku,
      required this.name,
      required this.barcode,
      required this.attributesJson,
      required this.costPrice,
      required this.salePrice,
      required this.isWholesale,
      required this.wholesalePrice,
      required this.alertThreshold,
      required this.isActive,
      required this.position});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['product_id'] = Variable<String>(productId);
    map['sku'] = Variable<String>(sku);
    map['name'] = Variable<String>(name);
    map['barcode'] = Variable<String>(barcode);
    map['attributes_json'] = Variable<String>(attributesJson);
    map['cost_price'] = Variable<double>(costPrice);
    map['sale_price'] = Variable<double>(salePrice);
    map['is_wholesale'] = Variable<bool>(isWholesale);
    map['wholesale_price'] = Variable<double>(wholesalePrice);
    map['alert_threshold'] = Variable<int>(alertThreshold);
    map['is_active'] = Variable<bool>(isActive);
    map['position'] = Variable<int>(position);
    return map;
  }

  ProductVariantsCompanion toCompanion(bool nullToAbsent) {
    return ProductVariantsCompanion(
      id: Value(id),
      productId: Value(productId),
      sku: Value(sku),
      name: Value(name),
      barcode: Value(barcode),
      attributesJson: Value(attributesJson),
      costPrice: Value(costPrice),
      salePrice: Value(salePrice),
      isWholesale: Value(isWholesale),
      wholesalePrice: Value(wholesalePrice),
      alertThreshold: Value(alertThreshold),
      isActive: Value(isActive),
      position: Value(position),
    );
  }

  factory VariantRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VariantRow(
      id: serializer.fromJson<String>(json['id']),
      productId: serializer.fromJson<String>(json['productId']),
      sku: serializer.fromJson<String>(json['sku']),
      name: serializer.fromJson<String>(json['name']),
      barcode: serializer.fromJson<String>(json['barcode']),
      attributesJson: serializer.fromJson<String>(json['attributesJson']),
      costPrice: serializer.fromJson<double>(json['costPrice']),
      salePrice: serializer.fromJson<double>(json['salePrice']),
      isWholesale: serializer.fromJson<bool>(json['isWholesale']),
      wholesalePrice: serializer.fromJson<double>(json['wholesalePrice']),
      alertThreshold: serializer.fromJson<int>(json['alertThreshold']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'productId': serializer.toJson<String>(productId),
      'sku': serializer.toJson<String>(sku),
      'name': serializer.toJson<String>(name),
      'barcode': serializer.toJson<String>(barcode),
      'attributesJson': serializer.toJson<String>(attributesJson),
      'costPrice': serializer.toJson<double>(costPrice),
      'salePrice': serializer.toJson<double>(salePrice),
      'isWholesale': serializer.toJson<bool>(isWholesale),
      'wholesalePrice': serializer.toJson<double>(wholesalePrice),
      'alertThreshold': serializer.toJson<int>(alertThreshold),
      'isActive': serializer.toJson<bool>(isActive),
      'position': serializer.toJson<int>(position),
    };
  }

  VariantRow copyWith(
          {String? id,
          String? productId,
          String? sku,
          String? name,
          String? barcode,
          String? attributesJson,
          double? costPrice,
          double? salePrice,
          bool? isWholesale,
          double? wholesalePrice,
          int? alertThreshold,
          bool? isActive,
          int? position}) =>
      VariantRow(
        id: id ?? this.id,
        productId: productId ?? this.productId,
        sku: sku ?? this.sku,
        name: name ?? this.name,
        barcode: barcode ?? this.barcode,
        attributesJson: attributesJson ?? this.attributesJson,
        costPrice: costPrice ?? this.costPrice,
        salePrice: salePrice ?? this.salePrice,
        isWholesale: isWholesale ?? this.isWholesale,
        wholesalePrice: wholesalePrice ?? this.wholesalePrice,
        alertThreshold: alertThreshold ?? this.alertThreshold,
        isActive: isActive ?? this.isActive,
        position: position ?? this.position,
      );
  VariantRow copyWithCompanion(ProductVariantsCompanion data) {
    return VariantRow(
      id: data.id.present ? data.id.value : this.id,
      productId: data.productId.present ? data.productId.value : this.productId,
      sku: data.sku.present ? data.sku.value : this.sku,
      name: data.name.present ? data.name.value : this.name,
      barcode: data.barcode.present ? data.barcode.value : this.barcode,
      attributesJson: data.attributesJson.present
          ? data.attributesJson.value
          : this.attributesJson,
      costPrice: data.costPrice.present ? data.costPrice.value : this.costPrice,
      salePrice: data.salePrice.present ? data.salePrice.value : this.salePrice,
      isWholesale:
          data.isWholesale.present ? data.isWholesale.value : this.isWholesale,
      wholesalePrice: data.wholesalePrice.present
          ? data.wholesalePrice.value
          : this.wholesalePrice,
      alertThreshold: data.alertThreshold.present
          ? data.alertThreshold.value
          : this.alertThreshold,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VariantRow(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('sku: $sku, ')
          ..write('name: $name, ')
          ..write('barcode: $barcode, ')
          ..write('attributesJson: $attributesJson, ')
          ..write('costPrice: $costPrice, ')
          ..write('salePrice: $salePrice, ')
          ..write('isWholesale: $isWholesale, ')
          ..write('wholesalePrice: $wholesalePrice, ')
          ..write('alertThreshold: $alertThreshold, ')
          ..write('isActive: $isActive, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      productId,
      sku,
      name,
      barcode,
      attributesJson,
      costPrice,
      salePrice,
      isWholesale,
      wholesalePrice,
      alertThreshold,
      isActive,
      position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VariantRow &&
          other.id == this.id &&
          other.productId == this.productId &&
          other.sku == this.sku &&
          other.name == this.name &&
          other.barcode == this.barcode &&
          other.attributesJson == this.attributesJson &&
          other.costPrice == this.costPrice &&
          other.salePrice == this.salePrice &&
          other.isWholesale == this.isWholesale &&
          other.wholesalePrice == this.wholesalePrice &&
          other.alertThreshold == this.alertThreshold &&
          other.isActive == this.isActive &&
          other.position == this.position);
}

class ProductVariantsCompanion extends UpdateCompanion<VariantRow> {
  final Value<String> id;
  final Value<String> productId;
  final Value<String> sku;
  final Value<String> name;
  final Value<String> barcode;
  final Value<String> attributesJson;
  final Value<double> costPrice;
  final Value<double> salePrice;
  final Value<bool> isWholesale;
  final Value<double> wholesalePrice;
  final Value<int> alertThreshold;
  final Value<bool> isActive;
  final Value<int> position;
  final Value<int> rowid;
  const ProductVariantsCompanion({
    this.id = const Value.absent(),
    this.productId = const Value.absent(),
    this.sku = const Value.absent(),
    this.name = const Value.absent(),
    this.barcode = const Value.absent(),
    this.attributesJson = const Value.absent(),
    this.costPrice = const Value.absent(),
    this.salePrice = const Value.absent(),
    this.isWholesale = const Value.absent(),
    this.wholesalePrice = const Value.absent(),
    this.alertThreshold = const Value.absent(),
    this.isActive = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProductVariantsCompanion.insert({
    required String id,
    required String productId,
    required String sku,
    this.name = const Value.absent(),
    this.barcode = const Value.absent(),
    this.attributesJson = const Value.absent(),
    this.costPrice = const Value.absent(),
    this.salePrice = const Value.absent(),
    this.isWholesale = const Value.absent(),
    this.wholesalePrice = const Value.absent(),
    this.alertThreshold = const Value.absent(),
    this.isActive = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        productId = Value(productId),
        sku = Value(sku);
  static Insertable<VariantRow> custom({
    Expression<String>? id,
    Expression<String>? productId,
    Expression<String>? sku,
    Expression<String>? name,
    Expression<String>? barcode,
    Expression<String>? attributesJson,
    Expression<double>? costPrice,
    Expression<double>? salePrice,
    Expression<bool>? isWholesale,
    Expression<double>? wholesalePrice,
    Expression<int>? alertThreshold,
    Expression<bool>? isActive,
    Expression<int>? position,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (productId != null) 'product_id': productId,
      if (sku != null) 'sku': sku,
      if (name != null) 'name': name,
      if (barcode != null) 'barcode': barcode,
      if (attributesJson != null) 'attributes_json': attributesJson,
      if (costPrice != null) 'cost_price': costPrice,
      if (salePrice != null) 'sale_price': salePrice,
      if (isWholesale != null) 'is_wholesale': isWholesale,
      if (wholesalePrice != null) 'wholesale_price': wholesalePrice,
      if (alertThreshold != null) 'alert_threshold': alertThreshold,
      if (isActive != null) 'is_active': isActive,
      if (position != null) 'position': position,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProductVariantsCompanion copyWith(
      {Value<String>? id,
      Value<String>? productId,
      Value<String>? sku,
      Value<String>? name,
      Value<String>? barcode,
      Value<String>? attributesJson,
      Value<double>? costPrice,
      Value<double>? salePrice,
      Value<bool>? isWholesale,
      Value<double>? wholesalePrice,
      Value<int>? alertThreshold,
      Value<bool>? isActive,
      Value<int>? position,
      Value<int>? rowid}) {
    return ProductVariantsCompanion(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      sku: sku ?? this.sku,
      name: name ?? this.name,
      barcode: barcode ?? this.barcode,
      attributesJson: attributesJson ?? this.attributesJson,
      costPrice: costPrice ?? this.costPrice,
      salePrice: salePrice ?? this.salePrice,
      isWholesale: isWholesale ?? this.isWholesale,
      wholesalePrice: wholesalePrice ?? this.wholesalePrice,
      alertThreshold: alertThreshold ?? this.alertThreshold,
      isActive: isActive ?? this.isActive,
      position: position ?? this.position,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (sku.present) {
      map['sku'] = Variable<String>(sku.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
    }
    if (attributesJson.present) {
      map['attributes_json'] = Variable<String>(attributesJson.value);
    }
    if (costPrice.present) {
      map['cost_price'] = Variable<double>(costPrice.value);
    }
    if (salePrice.present) {
      map['sale_price'] = Variable<double>(salePrice.value);
    }
    if (isWholesale.present) {
      map['is_wholesale'] = Variable<bool>(isWholesale.value);
    }
    if (wholesalePrice.present) {
      map['wholesale_price'] = Variable<double>(wholesalePrice.value);
    }
    if (alertThreshold.present) {
      map['alert_threshold'] = Variable<int>(alertThreshold.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductVariantsCompanion(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('sku: $sku, ')
          ..write('name: $name, ')
          ..write('barcode: $barcode, ')
          ..write('attributesJson: $attributesJson, ')
          ..write('costPrice: $costPrice, ')
          ..write('salePrice: $salePrice, ')
          ..write('isWholesale: $isWholesale, ')
          ..write('wholesalePrice: $wholesalePrice, ')
          ..write('alertThreshold: $alertThreshold, ')
          ..write('isActive: $isActive, ')
          ..write('position: $position, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VendorsTable extends Vendors with TableInfo<$VendorsTable, VendorRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VendorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('other'));
  static const VerificationMeta _contactPersonMeta =
      const VerificationMeta('contactPerson');
  @override
  late final GeneratedColumn<String> contactPerson = GeneratedColumn<String>(
      'contact_person', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _addressMeta =
      const VerificationMeta('address');
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
      'address', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _cityMeta = const VerificationMeta('city');
  @override
  late final GeneratedColumn<String> city = GeneratedColumn<String>(
      'city', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _openingBalanceMeta =
      const VerificationMeta('openingBalance');
  @override
  late final GeneratedColumn<double> openingBalance = GeneratedColumn<double>(
      'opening_balance', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _photoUrlMeta =
      const VerificationMeta('photoUrl');
  @override
  late final GeneratedColumn<String> photoUrl = GeneratedColumn<String>(
      'photo_url', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        type,
        contactPerson,
        phone,
        email,
        address,
        city,
        notes,
        openingBalance,
        isActive,
        photoUrl,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vendors';
  @override
  VerificationContext validateIntegrity(Insertable<VendorRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    }
    if (data.containsKey('contact_person')) {
      context.handle(
          _contactPersonMeta,
          contactPerson.isAcceptableOrUnknown(
              data['contact_person']!, _contactPersonMeta));
    }
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    }
    if (data.containsKey('address')) {
      context.handle(_addressMeta,
          address.isAcceptableOrUnknown(data['address']!, _addressMeta));
    }
    if (data.containsKey('city')) {
      context.handle(
          _cityMeta, city.isAcceptableOrUnknown(data['city']!, _cityMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('opening_balance')) {
      context.handle(
          _openingBalanceMeta,
          openingBalance.isAcceptableOrUnknown(
              data['opening_balance']!, _openingBalanceMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('photo_url')) {
      context.handle(_photoUrlMeta,
          photoUrl.isAcceptableOrUnknown(data['photo_url']!, _photoUrlMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VendorRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VendorRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      contactPerson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}contact_person'])!,
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone'])!,
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email'])!,
      address: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}address'])!,
      city: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}city'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes'])!,
      openingBalance: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}opening_balance'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      photoUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}photo_url'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $VendorsTable createAlias(String alias) {
    return $VendorsTable(attachedDatabase, alias);
  }
}

class VendorRow extends DataClass implements Insertable<VendorRow> {
  final String id;
  final String name;
  final String type;
  final String contactPerson;
  final String phone;
  final String email;
  final String address;
  final String city;
  final String notes;
  final double openingBalance;
  final bool isActive;
  final String photoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  const VendorRow(
      {required this.id,
      required this.name,
      required this.type,
      required this.contactPerson,
      required this.phone,
      required this.email,
      required this.address,
      required this.city,
      required this.notes,
      required this.openingBalance,
      required this.isActive,
      required this.photoUrl,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    map['contact_person'] = Variable<String>(contactPerson);
    map['phone'] = Variable<String>(phone);
    map['email'] = Variable<String>(email);
    map['address'] = Variable<String>(address);
    map['city'] = Variable<String>(city);
    map['notes'] = Variable<String>(notes);
    map['opening_balance'] = Variable<double>(openingBalance);
    map['is_active'] = Variable<bool>(isActive);
    map['photo_url'] = Variable<String>(photoUrl);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  VendorsCompanion toCompanion(bool nullToAbsent) {
    return VendorsCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      contactPerson: Value(contactPerson),
      phone: Value(phone),
      email: Value(email),
      address: Value(address),
      city: Value(city),
      notes: Value(notes),
      openingBalance: Value(openingBalance),
      isActive: Value(isActive),
      photoUrl: Value(photoUrl),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory VendorRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VendorRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      contactPerson: serializer.fromJson<String>(json['contactPerson']),
      phone: serializer.fromJson<String>(json['phone']),
      email: serializer.fromJson<String>(json['email']),
      address: serializer.fromJson<String>(json['address']),
      city: serializer.fromJson<String>(json['city']),
      notes: serializer.fromJson<String>(json['notes']),
      openingBalance: serializer.fromJson<double>(json['openingBalance']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      photoUrl: serializer.fromJson<String>(json['photoUrl']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'contactPerson': serializer.toJson<String>(contactPerson),
      'phone': serializer.toJson<String>(phone),
      'email': serializer.toJson<String>(email),
      'address': serializer.toJson<String>(address),
      'city': serializer.toJson<String>(city),
      'notes': serializer.toJson<String>(notes),
      'openingBalance': serializer.toJson<double>(openingBalance),
      'isActive': serializer.toJson<bool>(isActive),
      'photoUrl': serializer.toJson<String>(photoUrl),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  VendorRow copyWith(
          {String? id,
          String? name,
          String? type,
          String? contactPerson,
          String? phone,
          String? email,
          String? address,
          String? city,
          String? notes,
          double? openingBalance,
          bool? isActive,
          String? photoUrl,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      VendorRow(
        id: id ?? this.id,
        name: name ?? this.name,
        type: type ?? this.type,
        contactPerson: contactPerson ?? this.contactPerson,
        phone: phone ?? this.phone,
        email: email ?? this.email,
        address: address ?? this.address,
        city: city ?? this.city,
        notes: notes ?? this.notes,
        openingBalance: openingBalance ?? this.openingBalance,
        isActive: isActive ?? this.isActive,
        photoUrl: photoUrl ?? this.photoUrl,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  VendorRow copyWithCompanion(VendorsCompanion data) {
    return VendorRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      contactPerson: data.contactPerson.present
          ? data.contactPerson.value
          : this.contactPerson,
      phone: data.phone.present ? data.phone.value : this.phone,
      email: data.email.present ? data.email.value : this.email,
      address: data.address.present ? data.address.value : this.address,
      city: data.city.present ? data.city.value : this.city,
      notes: data.notes.present ? data.notes.value : this.notes,
      openingBalance: data.openingBalance.present
          ? data.openingBalance.value
          : this.openingBalance,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      photoUrl: data.photoUrl.present ? data.photoUrl.value : this.photoUrl,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VendorRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('contactPerson: $contactPerson, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('address: $address, ')
          ..write('city: $city, ')
          ..write('notes: $notes, ')
          ..write('openingBalance: $openingBalance, ')
          ..write('isActive: $isActive, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      name,
      type,
      contactPerson,
      phone,
      email,
      address,
      city,
      notes,
      openingBalance,
      isActive,
      photoUrl,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VendorRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.contactPerson == this.contactPerson &&
          other.phone == this.phone &&
          other.email == this.email &&
          other.address == this.address &&
          other.city == this.city &&
          other.notes == this.notes &&
          other.openingBalance == this.openingBalance &&
          other.isActive == this.isActive &&
          other.photoUrl == this.photoUrl &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class VendorsCompanion extends UpdateCompanion<VendorRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> type;
  final Value<String> contactPerson;
  final Value<String> phone;
  final Value<String> email;
  final Value<String> address;
  final Value<String> city;
  final Value<String> notes;
  final Value<double> openingBalance;
  final Value<bool> isActive;
  final Value<String> photoUrl;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const VendorsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.contactPerson = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.address = const Value.absent(),
    this.city = const Value.absent(),
    this.notes = const Value.absent(),
    this.openingBalance = const Value.absent(),
    this.isActive = const Value.absent(),
    this.photoUrl = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VendorsCompanion.insert({
    required String id,
    required String name,
    this.type = const Value.absent(),
    this.contactPerson = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.address = const Value.absent(),
    this.city = const Value.absent(),
    this.notes = const Value.absent(),
    this.openingBalance = const Value.absent(),
    this.isActive = const Value.absent(),
    this.photoUrl = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<VendorRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? contactPerson,
    Expression<String>? phone,
    Expression<String>? email,
    Expression<String>? address,
    Expression<String>? city,
    Expression<String>? notes,
    Expression<double>? openingBalance,
    Expression<bool>? isActive,
    Expression<String>? photoUrl,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (contactPerson != null) 'contact_person': contactPerson,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (address != null) 'address': address,
      if (city != null) 'city': city,
      if (notes != null) 'notes': notes,
      if (openingBalance != null) 'opening_balance': openingBalance,
      if (isActive != null) 'is_active': isActive,
      if (photoUrl != null) 'photo_url': photoUrl,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VendorsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? type,
      Value<String>? contactPerson,
      Value<String>? phone,
      Value<String>? email,
      Value<String>? address,
      Value<String>? city,
      Value<String>? notes,
      Value<double>? openingBalance,
      Value<bool>? isActive,
      Value<String>? photoUrl,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return VendorsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      contactPerson: contactPerson ?? this.contactPerson,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      city: city ?? this.city,
      notes: notes ?? this.notes,
      openingBalance: openingBalance ?? this.openingBalance,
      isActive: isActive ?? this.isActive,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (contactPerson.present) {
      map['contact_person'] = Variable<String>(contactPerson.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (city.present) {
      map['city'] = Variable<String>(city.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (openingBalance.present) {
      map['opening_balance'] = Variable<double>(openingBalance.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (photoUrl.present) {
      map['photo_url'] = Variable<String>(photoUrl.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VendorsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('contactPerson: $contactPerson, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('address: $address, ')
          ..write('city: $city, ')
          ..write('notes: $notes, ')
          ..write('openingBalance: $openingBalance, ')
          ..write('isActive: $isActive, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CustomersTable extends Customers
    with TableInfo<$CustomersTable, CustomerRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('retail'));
  static const VerificationMeta _contactPersonMeta =
      const VerificationMeta('contactPerson');
  @override
  late final GeneratedColumn<String> contactPerson = GeneratedColumn<String>(
      'contact_person', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _addressMeta =
      const VerificationMeta('address');
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
      'address', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _cityMeta = const VerificationMeta('city');
  @override
  late final GeneratedColumn<String> city = GeneratedColumn<String>(
      'city', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _creditLimitMeta =
      const VerificationMeta('creditLimit');
  @override
  late final GeneratedColumn<double> creditLimit = GeneratedColumn<double>(
      'credit_limit', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _openingBalanceMeta =
      const VerificationMeta('openingBalance');
  @override
  late final GeneratedColumn<double> openingBalance = GeneratedColumn<double>(
      'opening_balance', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _photoUrlMeta =
      const VerificationMeta('photoUrl');
  @override
  late final GeneratedColumn<String> photoUrl = GeneratedColumn<String>(
      'photo_url', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        type,
        contactPerson,
        phone,
        email,
        address,
        city,
        notes,
        creditLimit,
        openingBalance,
        isActive,
        photoUrl,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'customers';
  @override
  VerificationContext validateIntegrity(Insertable<CustomerRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    }
    if (data.containsKey('contact_person')) {
      context.handle(
          _contactPersonMeta,
          contactPerson.isAcceptableOrUnknown(
              data['contact_person']!, _contactPersonMeta));
    }
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    }
    if (data.containsKey('address')) {
      context.handle(_addressMeta,
          address.isAcceptableOrUnknown(data['address']!, _addressMeta));
    }
    if (data.containsKey('city')) {
      context.handle(
          _cityMeta, city.isAcceptableOrUnknown(data['city']!, _cityMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('credit_limit')) {
      context.handle(
          _creditLimitMeta,
          creditLimit.isAcceptableOrUnknown(
              data['credit_limit']!, _creditLimitMeta));
    }
    if (data.containsKey('opening_balance')) {
      context.handle(
          _openingBalanceMeta,
          openingBalance.isAcceptableOrUnknown(
              data['opening_balance']!, _openingBalanceMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('photo_url')) {
      context.handle(_photoUrlMeta,
          photoUrl.isAcceptableOrUnknown(data['photo_url']!, _photoUrlMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CustomerRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomerRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      contactPerson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}contact_person'])!,
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone'])!,
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email'])!,
      address: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}address'])!,
      city: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}city'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes'])!,
      creditLimit: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}credit_limit'])!,
      openingBalance: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}opening_balance'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      photoUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}photo_url'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $CustomersTable createAlias(String alias) {
    return $CustomersTable(attachedDatabase, alias);
  }
}

class CustomerRow extends DataClass implements Insertable<CustomerRow> {
  final String id;
  final String name;
  final String type;
  final String contactPerson;
  final String phone;
  final String email;
  final String address;
  final String city;
  final String notes;
  final double creditLimit;
  final double openingBalance;
  final bool isActive;
  final String photoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  const CustomerRow(
      {required this.id,
      required this.name,
      required this.type,
      required this.contactPerson,
      required this.phone,
      required this.email,
      required this.address,
      required this.city,
      required this.notes,
      required this.creditLimit,
      required this.openingBalance,
      required this.isActive,
      required this.photoUrl,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    map['contact_person'] = Variable<String>(contactPerson);
    map['phone'] = Variable<String>(phone);
    map['email'] = Variable<String>(email);
    map['address'] = Variable<String>(address);
    map['city'] = Variable<String>(city);
    map['notes'] = Variable<String>(notes);
    map['credit_limit'] = Variable<double>(creditLimit);
    map['opening_balance'] = Variable<double>(openingBalance);
    map['is_active'] = Variable<bool>(isActive);
    map['photo_url'] = Variable<String>(photoUrl);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CustomersCompanion toCompanion(bool nullToAbsent) {
    return CustomersCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      contactPerson: Value(contactPerson),
      phone: Value(phone),
      email: Value(email),
      address: Value(address),
      city: Value(city),
      notes: Value(notes),
      creditLimit: Value(creditLimit),
      openingBalance: Value(openingBalance),
      isActive: Value(isActive),
      photoUrl: Value(photoUrl),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory CustomerRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomerRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      contactPerson: serializer.fromJson<String>(json['contactPerson']),
      phone: serializer.fromJson<String>(json['phone']),
      email: serializer.fromJson<String>(json['email']),
      address: serializer.fromJson<String>(json['address']),
      city: serializer.fromJson<String>(json['city']),
      notes: serializer.fromJson<String>(json['notes']),
      creditLimit: serializer.fromJson<double>(json['creditLimit']),
      openingBalance: serializer.fromJson<double>(json['openingBalance']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      photoUrl: serializer.fromJson<String>(json['photoUrl']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'contactPerson': serializer.toJson<String>(contactPerson),
      'phone': serializer.toJson<String>(phone),
      'email': serializer.toJson<String>(email),
      'address': serializer.toJson<String>(address),
      'city': serializer.toJson<String>(city),
      'notes': serializer.toJson<String>(notes),
      'creditLimit': serializer.toJson<double>(creditLimit),
      'openingBalance': serializer.toJson<double>(openingBalance),
      'isActive': serializer.toJson<bool>(isActive),
      'photoUrl': serializer.toJson<String>(photoUrl),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CustomerRow copyWith(
          {String? id,
          String? name,
          String? type,
          String? contactPerson,
          String? phone,
          String? email,
          String? address,
          String? city,
          String? notes,
          double? creditLimit,
          double? openingBalance,
          bool? isActive,
          String? photoUrl,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      CustomerRow(
        id: id ?? this.id,
        name: name ?? this.name,
        type: type ?? this.type,
        contactPerson: contactPerson ?? this.contactPerson,
        phone: phone ?? this.phone,
        email: email ?? this.email,
        address: address ?? this.address,
        city: city ?? this.city,
        notes: notes ?? this.notes,
        creditLimit: creditLimit ?? this.creditLimit,
        openingBalance: openingBalance ?? this.openingBalance,
        isActive: isActive ?? this.isActive,
        photoUrl: photoUrl ?? this.photoUrl,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  CustomerRow copyWithCompanion(CustomersCompanion data) {
    return CustomerRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      contactPerson: data.contactPerson.present
          ? data.contactPerson.value
          : this.contactPerson,
      phone: data.phone.present ? data.phone.value : this.phone,
      email: data.email.present ? data.email.value : this.email,
      address: data.address.present ? data.address.value : this.address,
      city: data.city.present ? data.city.value : this.city,
      notes: data.notes.present ? data.notes.value : this.notes,
      creditLimit:
          data.creditLimit.present ? data.creditLimit.value : this.creditLimit,
      openingBalance: data.openingBalance.present
          ? data.openingBalance.value
          : this.openingBalance,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      photoUrl: data.photoUrl.present ? data.photoUrl.value : this.photoUrl,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomerRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('contactPerson: $contactPerson, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('address: $address, ')
          ..write('city: $city, ')
          ..write('notes: $notes, ')
          ..write('creditLimit: $creditLimit, ')
          ..write('openingBalance: $openingBalance, ')
          ..write('isActive: $isActive, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      name,
      type,
      contactPerson,
      phone,
      email,
      address,
      city,
      notes,
      creditLimit,
      openingBalance,
      isActive,
      photoUrl,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomerRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.contactPerson == this.contactPerson &&
          other.phone == this.phone &&
          other.email == this.email &&
          other.address == this.address &&
          other.city == this.city &&
          other.notes == this.notes &&
          other.creditLimit == this.creditLimit &&
          other.openingBalance == this.openingBalance &&
          other.isActive == this.isActive &&
          other.photoUrl == this.photoUrl &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CustomersCompanion extends UpdateCompanion<CustomerRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> type;
  final Value<String> contactPerson;
  final Value<String> phone;
  final Value<String> email;
  final Value<String> address;
  final Value<String> city;
  final Value<String> notes;
  final Value<double> creditLimit;
  final Value<double> openingBalance;
  final Value<bool> isActive;
  final Value<String> photoUrl;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CustomersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.contactPerson = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.address = const Value.absent(),
    this.city = const Value.absent(),
    this.notes = const Value.absent(),
    this.creditLimit = const Value.absent(),
    this.openingBalance = const Value.absent(),
    this.isActive = const Value.absent(),
    this.photoUrl = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomersCompanion.insert({
    required String id,
    required String name,
    this.type = const Value.absent(),
    this.contactPerson = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.address = const Value.absent(),
    this.city = const Value.absent(),
    this.notes = const Value.absent(),
    this.creditLimit = const Value.absent(),
    this.openingBalance = const Value.absent(),
    this.isActive = const Value.absent(),
    this.photoUrl = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<CustomerRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? contactPerson,
    Expression<String>? phone,
    Expression<String>? email,
    Expression<String>? address,
    Expression<String>? city,
    Expression<String>? notes,
    Expression<double>? creditLimit,
    Expression<double>? openingBalance,
    Expression<bool>? isActive,
    Expression<String>? photoUrl,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (contactPerson != null) 'contact_person': contactPerson,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (address != null) 'address': address,
      if (city != null) 'city': city,
      if (notes != null) 'notes': notes,
      if (creditLimit != null) 'credit_limit': creditLimit,
      if (openingBalance != null) 'opening_balance': openingBalance,
      if (isActive != null) 'is_active': isActive,
      if (photoUrl != null) 'photo_url': photoUrl,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomersCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? type,
      Value<String>? contactPerson,
      Value<String>? phone,
      Value<String>? email,
      Value<String>? address,
      Value<String>? city,
      Value<String>? notes,
      Value<double>? creditLimit,
      Value<double>? openingBalance,
      Value<bool>? isActive,
      Value<String>? photoUrl,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return CustomersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      contactPerson: contactPerson ?? this.contactPerson,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      city: city ?? this.city,
      notes: notes ?? this.notes,
      creditLimit: creditLimit ?? this.creditLimit,
      openingBalance: openingBalance ?? this.openingBalance,
      isActive: isActive ?? this.isActive,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (contactPerson.present) {
      map['contact_person'] = Variable<String>(contactPerson.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (city.present) {
      map['city'] = Variable<String>(city.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (creditLimit.present) {
      map['credit_limit'] = Variable<double>(creditLimit.value);
    }
    if (openingBalance.present) {
      map['opening_balance'] = Variable<double>(openingBalance.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (photoUrl.present) {
      map['photo_url'] = Variable<String>(photoUrl.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('contactPerson: $contactPerson, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('address: $address, ')
          ..write('city: $city, ')
          ..write('notes: $notes, ')
          ..write('creditLimit: $creditLimit, ')
          ..write('openingBalance: $openingBalance, ')
          ..write('isActive: $isActive, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LedgerEntriesTable extends LedgerEntries
    with TableInfo<$LedgerEntriesTable, LedgerRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LedgerEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _partyTypeMeta =
      const VerificationMeta('partyType');
  @override
  late final GeneratedColumn<String> partyType = GeneratedColumn<String>(
      'party_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _partyIdMeta =
      const VerificationMeta('partyId');
  @override
  late final GeneratedColumn<String> partyId = GeneratedColumn<String>(
      'party_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entryTypeMeta =
      const VerificationMeta('entryType');
  @override
  late final GeneratedColumn<String> entryType = GeneratedColumn<String>(
      'entry_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _entryDateMeta =
      const VerificationMeta('entryDate');
  @override
  late final GeneratedColumn<DateTime> entryDate = GeneratedColumn<DateTime>(
      'entry_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _referenceMeta =
      const VerificationMeta('reference');
  @override
  late final GeneratedColumn<String> reference = GeneratedColumn<String>(
      'reference', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _paymentMethodMeta =
      const VerificationMeta('paymentMethod');
  @override
  late final GeneratedColumn<String> paymentMethod = GeneratedColumn<String>(
      'payment_method', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _paymentRefMeta =
      const VerificationMeta('paymentRef');
  @override
  late final GeneratedColumn<String> paymentRef = GeneratedColumn<String>(
      'payment_ref', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _purchaseIdMeta =
      const VerificationMeta('purchaseId');
  @override
  late final GeneratedColumn<String> purchaseId = GeneratedColumn<String>(
      'purchase_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _orderIdMeta =
      const VerificationMeta('orderId');
  @override
  late final GeneratedColumn<String> orderId = GeneratedColumn<String>(
      'order_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        partyType,
        partyId,
        entryType,
        amount,
        entryDate,
        description,
        reference,
        paymentMethod,
        paymentRef,
        purchaseId,
        orderId,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ledger_entries';
  @override
  VerificationContext validateIntegrity(Insertable<LedgerRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('party_type')) {
      context.handle(_partyTypeMeta,
          partyType.isAcceptableOrUnknown(data['party_type']!, _partyTypeMeta));
    } else if (isInserting) {
      context.missing(_partyTypeMeta);
    }
    if (data.containsKey('party_id')) {
      context.handle(_partyIdMeta,
          partyId.isAcceptableOrUnknown(data['party_id']!, _partyIdMeta));
    } else if (isInserting) {
      context.missing(_partyIdMeta);
    }
    if (data.containsKey('entry_type')) {
      context.handle(_entryTypeMeta,
          entryType.isAcceptableOrUnknown(data['entry_type']!, _entryTypeMeta));
    } else if (isInserting) {
      context.missing(_entryTypeMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('entry_date')) {
      context.handle(_entryDateMeta,
          entryDate.isAcceptableOrUnknown(data['entry_date']!, _entryDateMeta));
    } else if (isInserting) {
      context.missing(_entryDateMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('reference')) {
      context.handle(_referenceMeta,
          reference.isAcceptableOrUnknown(data['reference']!, _referenceMeta));
    }
    if (data.containsKey('payment_method')) {
      context.handle(
          _paymentMethodMeta,
          paymentMethod.isAcceptableOrUnknown(
              data['payment_method']!, _paymentMethodMeta));
    }
    if (data.containsKey('payment_ref')) {
      context.handle(
          _paymentRefMeta,
          paymentRef.isAcceptableOrUnknown(
              data['payment_ref']!, _paymentRefMeta));
    }
    if (data.containsKey('purchase_id')) {
      context.handle(
          _purchaseIdMeta,
          purchaseId.isAcceptableOrUnknown(
              data['purchase_id']!, _purchaseIdMeta));
    }
    if (data.containsKey('order_id')) {
      context.handle(_orderIdMeta,
          orderId.isAcceptableOrUnknown(data['order_id']!, _orderIdMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LedgerRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LedgerRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      partyType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}party_type'])!,
      partyId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}party_id'])!,
      entryType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entry_type'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      entryDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}entry_date'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      reference: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reference'])!,
      paymentMethod: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payment_method'])!,
      paymentRef: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payment_ref'])!,
      purchaseId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}purchase_id'])!,
      orderId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}order_id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $LedgerEntriesTable createAlias(String alias) {
    return $LedgerEntriesTable(attachedDatabase, alias);
  }
}

class LedgerRow extends DataClass implements Insertable<LedgerRow> {
  final String id;
  final String partyType;
  final String partyId;
  final String entryType;
  final double amount;
  final DateTime entryDate;
  final String description;
  final String reference;
  final String paymentMethod;
  final String paymentRef;
  final String purchaseId;
  final String orderId;
  final DateTime createdAt;
  final DateTime updatedAt;
  const LedgerRow(
      {required this.id,
      required this.partyType,
      required this.partyId,
      required this.entryType,
      required this.amount,
      required this.entryDate,
      required this.description,
      required this.reference,
      required this.paymentMethod,
      required this.paymentRef,
      required this.purchaseId,
      required this.orderId,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['party_type'] = Variable<String>(partyType);
    map['party_id'] = Variable<String>(partyId);
    map['entry_type'] = Variable<String>(entryType);
    map['amount'] = Variable<double>(amount);
    map['entry_date'] = Variable<DateTime>(entryDate);
    map['description'] = Variable<String>(description);
    map['reference'] = Variable<String>(reference);
    map['payment_method'] = Variable<String>(paymentMethod);
    map['payment_ref'] = Variable<String>(paymentRef);
    map['purchase_id'] = Variable<String>(purchaseId);
    map['order_id'] = Variable<String>(orderId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LedgerEntriesCompanion toCompanion(bool nullToAbsent) {
    return LedgerEntriesCompanion(
      id: Value(id),
      partyType: Value(partyType),
      partyId: Value(partyId),
      entryType: Value(entryType),
      amount: Value(amount),
      entryDate: Value(entryDate),
      description: Value(description),
      reference: Value(reference),
      paymentMethod: Value(paymentMethod),
      paymentRef: Value(paymentRef),
      purchaseId: Value(purchaseId),
      orderId: Value(orderId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory LedgerRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LedgerRow(
      id: serializer.fromJson<String>(json['id']),
      partyType: serializer.fromJson<String>(json['partyType']),
      partyId: serializer.fromJson<String>(json['partyId']),
      entryType: serializer.fromJson<String>(json['entryType']),
      amount: serializer.fromJson<double>(json['amount']),
      entryDate: serializer.fromJson<DateTime>(json['entryDate']),
      description: serializer.fromJson<String>(json['description']),
      reference: serializer.fromJson<String>(json['reference']),
      paymentMethod: serializer.fromJson<String>(json['paymentMethod']),
      paymentRef: serializer.fromJson<String>(json['paymentRef']),
      purchaseId: serializer.fromJson<String>(json['purchaseId']),
      orderId: serializer.fromJson<String>(json['orderId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'partyType': serializer.toJson<String>(partyType),
      'partyId': serializer.toJson<String>(partyId),
      'entryType': serializer.toJson<String>(entryType),
      'amount': serializer.toJson<double>(amount),
      'entryDate': serializer.toJson<DateTime>(entryDate),
      'description': serializer.toJson<String>(description),
      'reference': serializer.toJson<String>(reference),
      'paymentMethod': serializer.toJson<String>(paymentMethod),
      'paymentRef': serializer.toJson<String>(paymentRef),
      'purchaseId': serializer.toJson<String>(purchaseId),
      'orderId': serializer.toJson<String>(orderId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LedgerRow copyWith(
          {String? id,
          String? partyType,
          String? partyId,
          String? entryType,
          double? amount,
          DateTime? entryDate,
          String? description,
          String? reference,
          String? paymentMethod,
          String? paymentRef,
          String? purchaseId,
          String? orderId,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      LedgerRow(
        id: id ?? this.id,
        partyType: partyType ?? this.partyType,
        partyId: partyId ?? this.partyId,
        entryType: entryType ?? this.entryType,
        amount: amount ?? this.amount,
        entryDate: entryDate ?? this.entryDate,
        description: description ?? this.description,
        reference: reference ?? this.reference,
        paymentMethod: paymentMethod ?? this.paymentMethod,
        paymentRef: paymentRef ?? this.paymentRef,
        purchaseId: purchaseId ?? this.purchaseId,
        orderId: orderId ?? this.orderId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  LedgerRow copyWithCompanion(LedgerEntriesCompanion data) {
    return LedgerRow(
      id: data.id.present ? data.id.value : this.id,
      partyType: data.partyType.present ? data.partyType.value : this.partyType,
      partyId: data.partyId.present ? data.partyId.value : this.partyId,
      entryType: data.entryType.present ? data.entryType.value : this.entryType,
      amount: data.amount.present ? data.amount.value : this.amount,
      entryDate: data.entryDate.present ? data.entryDate.value : this.entryDate,
      description:
          data.description.present ? data.description.value : this.description,
      reference: data.reference.present ? data.reference.value : this.reference,
      paymentMethod: data.paymentMethod.present
          ? data.paymentMethod.value
          : this.paymentMethod,
      paymentRef:
          data.paymentRef.present ? data.paymentRef.value : this.paymentRef,
      purchaseId:
          data.purchaseId.present ? data.purchaseId.value : this.purchaseId,
      orderId: data.orderId.present ? data.orderId.value : this.orderId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LedgerRow(')
          ..write('id: $id, ')
          ..write('partyType: $partyType, ')
          ..write('partyId: $partyId, ')
          ..write('entryType: $entryType, ')
          ..write('amount: $amount, ')
          ..write('entryDate: $entryDate, ')
          ..write('description: $description, ')
          ..write('reference: $reference, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('paymentRef: $paymentRef, ')
          ..write('purchaseId: $purchaseId, ')
          ..write('orderId: $orderId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      partyType,
      partyId,
      entryType,
      amount,
      entryDate,
      description,
      reference,
      paymentMethod,
      paymentRef,
      purchaseId,
      orderId,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LedgerRow &&
          other.id == this.id &&
          other.partyType == this.partyType &&
          other.partyId == this.partyId &&
          other.entryType == this.entryType &&
          other.amount == this.amount &&
          other.entryDate == this.entryDate &&
          other.description == this.description &&
          other.reference == this.reference &&
          other.paymentMethod == this.paymentMethod &&
          other.paymentRef == this.paymentRef &&
          other.purchaseId == this.purchaseId &&
          other.orderId == this.orderId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class LedgerEntriesCompanion extends UpdateCompanion<LedgerRow> {
  final Value<String> id;
  final Value<String> partyType;
  final Value<String> partyId;
  final Value<String> entryType;
  final Value<double> amount;
  final Value<DateTime> entryDate;
  final Value<String> description;
  final Value<String> reference;
  final Value<String> paymentMethod;
  final Value<String> paymentRef;
  final Value<String> purchaseId;
  final Value<String> orderId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LedgerEntriesCompanion({
    this.id = const Value.absent(),
    this.partyType = const Value.absent(),
    this.partyId = const Value.absent(),
    this.entryType = const Value.absent(),
    this.amount = const Value.absent(),
    this.entryDate = const Value.absent(),
    this.description = const Value.absent(),
    this.reference = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.paymentRef = const Value.absent(),
    this.purchaseId = const Value.absent(),
    this.orderId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LedgerEntriesCompanion.insert({
    required String id,
    required String partyType,
    required String partyId,
    required String entryType,
    required double amount,
    required DateTime entryDate,
    this.description = const Value.absent(),
    this.reference = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.paymentRef = const Value.absent(),
    this.purchaseId = const Value.absent(),
    this.orderId = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        partyType = Value(partyType),
        partyId = Value(partyId),
        entryType = Value(entryType),
        amount = Value(amount),
        entryDate = Value(entryDate),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<LedgerRow> custom({
    Expression<String>? id,
    Expression<String>? partyType,
    Expression<String>? partyId,
    Expression<String>? entryType,
    Expression<double>? amount,
    Expression<DateTime>? entryDate,
    Expression<String>? description,
    Expression<String>? reference,
    Expression<String>? paymentMethod,
    Expression<String>? paymentRef,
    Expression<String>? purchaseId,
    Expression<String>? orderId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (partyType != null) 'party_type': partyType,
      if (partyId != null) 'party_id': partyId,
      if (entryType != null) 'entry_type': entryType,
      if (amount != null) 'amount': amount,
      if (entryDate != null) 'entry_date': entryDate,
      if (description != null) 'description': description,
      if (reference != null) 'reference': reference,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (paymentRef != null) 'payment_ref': paymentRef,
      if (purchaseId != null) 'purchase_id': purchaseId,
      if (orderId != null) 'order_id': orderId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LedgerEntriesCompanion copyWith(
      {Value<String>? id,
      Value<String>? partyType,
      Value<String>? partyId,
      Value<String>? entryType,
      Value<double>? amount,
      Value<DateTime>? entryDate,
      Value<String>? description,
      Value<String>? reference,
      Value<String>? paymentMethod,
      Value<String>? paymentRef,
      Value<String>? purchaseId,
      Value<String>? orderId,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return LedgerEntriesCompanion(
      id: id ?? this.id,
      partyType: partyType ?? this.partyType,
      partyId: partyId ?? this.partyId,
      entryType: entryType ?? this.entryType,
      amount: amount ?? this.amount,
      entryDate: entryDate ?? this.entryDate,
      description: description ?? this.description,
      reference: reference ?? this.reference,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentRef: paymentRef ?? this.paymentRef,
      purchaseId: purchaseId ?? this.purchaseId,
      orderId: orderId ?? this.orderId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (partyType.present) {
      map['party_type'] = Variable<String>(partyType.value);
    }
    if (partyId.present) {
      map['party_id'] = Variable<String>(partyId.value);
    }
    if (entryType.present) {
      map['entry_type'] = Variable<String>(entryType.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (entryDate.present) {
      map['entry_date'] = Variable<DateTime>(entryDate.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (reference.present) {
      map['reference'] = Variable<String>(reference.value);
    }
    if (paymentMethod.present) {
      map['payment_method'] = Variable<String>(paymentMethod.value);
    }
    if (paymentRef.present) {
      map['payment_ref'] = Variable<String>(paymentRef.value);
    }
    if (purchaseId.present) {
      map['purchase_id'] = Variable<String>(purchaseId.value);
    }
    if (orderId.present) {
      map['order_id'] = Variable<String>(orderId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LedgerEntriesCompanion(')
          ..write('id: $id, ')
          ..write('partyType: $partyType, ')
          ..write('partyId: $partyId, ')
          ..write('entryType: $entryType, ')
          ..write('amount: $amount, ')
          ..write('entryDate: $entryDate, ')
          ..write('description: $description, ')
          ..write('reference: $reference, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('paymentRef: $paymentRef, ')
          ..write('purchaseId: $purchaseId, ')
          ..write('orderId: $orderId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PurchasesTable extends Purchases
    with TableInfo<$PurchasesTable, PurchaseRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PurchasesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _purchaseNoMeta =
      const VerificationMeta('purchaseNo');
  @override
  late final GeneratedColumn<String> purchaseNo = GeneratedColumn<String>(
      'purchase_no', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _vendorIdMeta =
      const VerificationMeta('vendorId');
  @override
  late final GeneratedColumn<String> vendorId = GeneratedColumn<String>(
      'vendor_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _vendorNameMeta =
      const VerificationMeta('vendorName');
  @override
  late final GeneratedColumn<String> vendorName = GeneratedColumn<String>(
      'vendor_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _invoiceNoMeta =
      const VerificationMeta('invoiceNo');
  @override
  late final GeneratedColumn<String> invoiceNo = GeneratedColumn<String>(
      'invoice_no', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _purchaseDateMeta =
      const VerificationMeta('purchaseDate');
  @override
  late final GeneratedColumn<DateTime> purchaseDate = GeneratedColumn<DateTime>(
      'purchase_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _totalAmountMeta =
      const VerificationMeta('totalAmount');
  @override
  late final GeneratedColumn<double> totalAmount = GeneratedColumn<double>(
      'total_amount', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        purchaseNo,
        vendorId,
        vendorName,
        invoiceNo,
        purchaseDate,
        notes,
        totalAmount,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'purchases';
  @override
  VerificationContext validateIntegrity(Insertable<PurchaseRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('purchase_no')) {
      context.handle(
          _purchaseNoMeta,
          purchaseNo.isAcceptableOrUnknown(
              data['purchase_no']!, _purchaseNoMeta));
    } else if (isInserting) {
      context.missing(_purchaseNoMeta);
    }
    if (data.containsKey('vendor_id')) {
      context.handle(_vendorIdMeta,
          vendorId.isAcceptableOrUnknown(data['vendor_id']!, _vendorIdMeta));
    } else if (isInserting) {
      context.missing(_vendorIdMeta);
    }
    if (data.containsKey('vendor_name')) {
      context.handle(
          _vendorNameMeta,
          vendorName.isAcceptableOrUnknown(
              data['vendor_name']!, _vendorNameMeta));
    } else if (isInserting) {
      context.missing(_vendorNameMeta);
    }
    if (data.containsKey('invoice_no')) {
      context.handle(_invoiceNoMeta,
          invoiceNo.isAcceptableOrUnknown(data['invoice_no']!, _invoiceNoMeta));
    }
    if (data.containsKey('purchase_date')) {
      context.handle(
          _purchaseDateMeta,
          purchaseDate.isAcceptableOrUnknown(
              data['purchase_date']!, _purchaseDateMeta));
    } else if (isInserting) {
      context.missing(_purchaseDateMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('total_amount')) {
      context.handle(
          _totalAmountMeta,
          totalAmount.isAcceptableOrUnknown(
              data['total_amount']!, _totalAmountMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PurchaseRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PurchaseRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      purchaseNo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}purchase_no'])!,
      vendorId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}vendor_id'])!,
      vendorName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}vendor_name'])!,
      invoiceNo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}invoice_no'])!,
      purchaseDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}purchase_date'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes'])!,
      totalAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}total_amount'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $PurchasesTable createAlias(String alias) {
    return $PurchasesTable(attachedDatabase, alias);
  }
}

class PurchaseRow extends DataClass implements Insertable<PurchaseRow> {
  final String id;
  final String purchaseNo;
  final String vendorId;
  final String vendorName;
  final String invoiceNo;
  final DateTime purchaseDate;
  final String notes;
  final double totalAmount;
  final DateTime createdAt;
  final DateTime updatedAt;
  const PurchaseRow(
      {required this.id,
      required this.purchaseNo,
      required this.vendorId,
      required this.vendorName,
      required this.invoiceNo,
      required this.purchaseDate,
      required this.notes,
      required this.totalAmount,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['purchase_no'] = Variable<String>(purchaseNo);
    map['vendor_id'] = Variable<String>(vendorId);
    map['vendor_name'] = Variable<String>(vendorName);
    map['invoice_no'] = Variable<String>(invoiceNo);
    map['purchase_date'] = Variable<DateTime>(purchaseDate);
    map['notes'] = Variable<String>(notes);
    map['total_amount'] = Variable<double>(totalAmount);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PurchasesCompanion toCompanion(bool nullToAbsent) {
    return PurchasesCompanion(
      id: Value(id),
      purchaseNo: Value(purchaseNo),
      vendorId: Value(vendorId),
      vendorName: Value(vendorName),
      invoiceNo: Value(invoiceNo),
      purchaseDate: Value(purchaseDate),
      notes: Value(notes),
      totalAmount: Value(totalAmount),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory PurchaseRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PurchaseRow(
      id: serializer.fromJson<String>(json['id']),
      purchaseNo: serializer.fromJson<String>(json['purchaseNo']),
      vendorId: serializer.fromJson<String>(json['vendorId']),
      vendorName: serializer.fromJson<String>(json['vendorName']),
      invoiceNo: serializer.fromJson<String>(json['invoiceNo']),
      purchaseDate: serializer.fromJson<DateTime>(json['purchaseDate']),
      notes: serializer.fromJson<String>(json['notes']),
      totalAmount: serializer.fromJson<double>(json['totalAmount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'purchaseNo': serializer.toJson<String>(purchaseNo),
      'vendorId': serializer.toJson<String>(vendorId),
      'vendorName': serializer.toJson<String>(vendorName),
      'invoiceNo': serializer.toJson<String>(invoiceNo),
      'purchaseDate': serializer.toJson<DateTime>(purchaseDate),
      'notes': serializer.toJson<String>(notes),
      'totalAmount': serializer.toJson<double>(totalAmount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PurchaseRow copyWith(
          {String? id,
          String? purchaseNo,
          String? vendorId,
          String? vendorName,
          String? invoiceNo,
          DateTime? purchaseDate,
          String? notes,
          double? totalAmount,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      PurchaseRow(
        id: id ?? this.id,
        purchaseNo: purchaseNo ?? this.purchaseNo,
        vendorId: vendorId ?? this.vendorId,
        vendorName: vendorName ?? this.vendorName,
        invoiceNo: invoiceNo ?? this.invoiceNo,
        purchaseDate: purchaseDate ?? this.purchaseDate,
        notes: notes ?? this.notes,
        totalAmount: totalAmount ?? this.totalAmount,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  PurchaseRow copyWithCompanion(PurchasesCompanion data) {
    return PurchaseRow(
      id: data.id.present ? data.id.value : this.id,
      purchaseNo:
          data.purchaseNo.present ? data.purchaseNo.value : this.purchaseNo,
      vendorId: data.vendorId.present ? data.vendorId.value : this.vendorId,
      vendorName:
          data.vendorName.present ? data.vendorName.value : this.vendorName,
      invoiceNo: data.invoiceNo.present ? data.invoiceNo.value : this.invoiceNo,
      purchaseDate: data.purchaseDate.present
          ? data.purchaseDate.value
          : this.purchaseDate,
      notes: data.notes.present ? data.notes.value : this.notes,
      totalAmount:
          data.totalAmount.present ? data.totalAmount.value : this.totalAmount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PurchaseRow(')
          ..write('id: $id, ')
          ..write('purchaseNo: $purchaseNo, ')
          ..write('vendorId: $vendorId, ')
          ..write('vendorName: $vendorName, ')
          ..write('invoiceNo: $invoiceNo, ')
          ..write('purchaseDate: $purchaseDate, ')
          ..write('notes: $notes, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, purchaseNo, vendorId, vendorName,
      invoiceNo, purchaseDate, notes, totalAmount, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PurchaseRow &&
          other.id == this.id &&
          other.purchaseNo == this.purchaseNo &&
          other.vendorId == this.vendorId &&
          other.vendorName == this.vendorName &&
          other.invoiceNo == this.invoiceNo &&
          other.purchaseDate == this.purchaseDate &&
          other.notes == this.notes &&
          other.totalAmount == this.totalAmount &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PurchasesCompanion extends UpdateCompanion<PurchaseRow> {
  final Value<String> id;
  final Value<String> purchaseNo;
  final Value<String> vendorId;
  final Value<String> vendorName;
  final Value<String> invoiceNo;
  final Value<DateTime> purchaseDate;
  final Value<String> notes;
  final Value<double> totalAmount;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const PurchasesCompanion({
    this.id = const Value.absent(),
    this.purchaseNo = const Value.absent(),
    this.vendorId = const Value.absent(),
    this.vendorName = const Value.absent(),
    this.invoiceNo = const Value.absent(),
    this.purchaseDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.totalAmount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PurchasesCompanion.insert({
    required String id,
    required String purchaseNo,
    required String vendorId,
    required String vendorName,
    this.invoiceNo = const Value.absent(),
    required DateTime purchaseDate,
    this.notes = const Value.absent(),
    this.totalAmount = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        purchaseNo = Value(purchaseNo),
        vendorId = Value(vendorId),
        vendorName = Value(vendorName),
        purchaseDate = Value(purchaseDate),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<PurchaseRow> custom({
    Expression<String>? id,
    Expression<String>? purchaseNo,
    Expression<String>? vendorId,
    Expression<String>? vendorName,
    Expression<String>? invoiceNo,
    Expression<DateTime>? purchaseDate,
    Expression<String>? notes,
    Expression<double>? totalAmount,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (purchaseNo != null) 'purchase_no': purchaseNo,
      if (vendorId != null) 'vendor_id': vendorId,
      if (vendorName != null) 'vendor_name': vendorName,
      if (invoiceNo != null) 'invoice_no': invoiceNo,
      if (purchaseDate != null) 'purchase_date': purchaseDate,
      if (notes != null) 'notes': notes,
      if (totalAmount != null) 'total_amount': totalAmount,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PurchasesCompanion copyWith(
      {Value<String>? id,
      Value<String>? purchaseNo,
      Value<String>? vendorId,
      Value<String>? vendorName,
      Value<String>? invoiceNo,
      Value<DateTime>? purchaseDate,
      Value<String>? notes,
      Value<double>? totalAmount,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return PurchasesCompanion(
      id: id ?? this.id,
      purchaseNo: purchaseNo ?? this.purchaseNo,
      vendorId: vendorId ?? this.vendorId,
      vendorName: vendorName ?? this.vendorName,
      invoiceNo: invoiceNo ?? this.invoiceNo,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      notes: notes ?? this.notes,
      totalAmount: totalAmount ?? this.totalAmount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (purchaseNo.present) {
      map['purchase_no'] = Variable<String>(purchaseNo.value);
    }
    if (vendorId.present) {
      map['vendor_id'] = Variable<String>(vendorId.value);
    }
    if (vendorName.present) {
      map['vendor_name'] = Variable<String>(vendorName.value);
    }
    if (invoiceNo.present) {
      map['invoice_no'] = Variable<String>(invoiceNo.value);
    }
    if (purchaseDate.present) {
      map['purchase_date'] = Variable<DateTime>(purchaseDate.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (totalAmount.present) {
      map['total_amount'] = Variable<double>(totalAmount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PurchasesCompanion(')
          ..write('id: $id, ')
          ..write('purchaseNo: $purchaseNo, ')
          ..write('vendorId: $vendorId, ')
          ..write('vendorName: $vendorName, ')
          ..write('invoiceNo: $invoiceNo, ')
          ..write('purchaseDate: $purchaseDate, ')
          ..write('notes: $notes, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PurchaseItemsTable extends PurchaseItems
    with TableInfo<$PurchaseItemsTable, PurchaseItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PurchaseItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _purchaseIdMeta =
      const VerificationMeta('purchaseId');
  @override
  late final GeneratedColumn<String> purchaseId = GeneratedColumn<String>(
      'purchase_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _productIdMeta =
      const VerificationMeta('productId');
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
      'product_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _variantIdMeta =
      const VerificationMeta('variantId');
  @override
  late final GeneratedColumn<String> variantId = GeneratedColumn<String>(
      'variant_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _productNameMeta =
      const VerificationMeta('productName');
  @override
  late final GeneratedColumn<String> productName = GeneratedColumn<String>(
      'product_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _variantLabelMeta =
      const VerificationMeta('variantLabel');
  @override
  late final GeneratedColumn<String> variantLabel = GeneratedColumn<String>(
      'variant_label', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _skuMeta = const VerificationMeta('sku');
  @override
  late final GeneratedColumn<String> sku = GeneratedColumn<String>(
      'sku', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
      'quantity', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _unitCostMeta =
      const VerificationMeta('unitCost');
  @override
  late final GeneratedColumn<double> unitCost = GeneratedColumn<double>(
      'unit_cost', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _positionMeta =
      const VerificationMeta('position');
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
      'position', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        purchaseId,
        productId,
        variantId,
        productName,
        variantLabel,
        sku,
        quantity,
        unitCost,
        position
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'purchase_items';
  @override
  VerificationContext validateIntegrity(Insertable<PurchaseItemRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('purchase_id')) {
      context.handle(
          _purchaseIdMeta,
          purchaseId.isAcceptableOrUnknown(
              data['purchase_id']!, _purchaseIdMeta));
    } else if (isInserting) {
      context.missing(_purchaseIdMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(_productIdMeta,
          productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta));
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('variant_id')) {
      context.handle(_variantIdMeta,
          variantId.isAcceptableOrUnknown(data['variant_id']!, _variantIdMeta));
    } else if (isInserting) {
      context.missing(_variantIdMeta);
    }
    if (data.containsKey('product_name')) {
      context.handle(
          _productNameMeta,
          productName.isAcceptableOrUnknown(
              data['product_name']!, _productNameMeta));
    } else if (isInserting) {
      context.missing(_productNameMeta);
    }
    if (data.containsKey('variant_label')) {
      context.handle(
          _variantLabelMeta,
          variantLabel.isAcceptableOrUnknown(
              data['variant_label']!, _variantLabelMeta));
    } else if (isInserting) {
      context.missing(_variantLabelMeta);
    }
    if (data.containsKey('sku')) {
      context.handle(
          _skuMeta, sku.isAcceptableOrUnknown(data['sku']!, _skuMeta));
    } else if (isInserting) {
      context.missing(_skuMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('unit_cost')) {
      context.handle(_unitCostMeta,
          unitCost.isAcceptableOrUnknown(data['unit_cost']!, _unitCostMeta));
    } else if (isInserting) {
      context.missing(_unitCostMeta);
    }
    if (data.containsKey('position')) {
      context.handle(_positionMeta,
          position.isAcceptableOrUnknown(data['position']!, _positionMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PurchaseItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PurchaseItemRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      purchaseId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}purchase_id'])!,
      productId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}product_id'])!,
      variantId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}variant_id'])!,
      productName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}product_name'])!,
      variantLabel: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}variant_label'])!,
      sku: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sku'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quantity'])!,
      unitCost: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}unit_cost'])!,
      position: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}position'])!,
    );
  }

  @override
  $PurchaseItemsTable createAlias(String alias) {
    return $PurchaseItemsTable(attachedDatabase, alias);
  }
}

class PurchaseItemRow extends DataClass implements Insertable<PurchaseItemRow> {
  final String id;
  final String purchaseId;
  final String productId;
  final String variantId;
  final String productName;
  final String variantLabel;
  final String sku;
  final int quantity;
  final double unitCost;
  final int position;
  const PurchaseItemRow(
      {required this.id,
      required this.purchaseId,
      required this.productId,
      required this.variantId,
      required this.productName,
      required this.variantLabel,
      required this.sku,
      required this.quantity,
      required this.unitCost,
      required this.position});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['purchase_id'] = Variable<String>(purchaseId);
    map['product_id'] = Variable<String>(productId);
    map['variant_id'] = Variable<String>(variantId);
    map['product_name'] = Variable<String>(productName);
    map['variant_label'] = Variable<String>(variantLabel);
    map['sku'] = Variable<String>(sku);
    map['quantity'] = Variable<int>(quantity);
    map['unit_cost'] = Variable<double>(unitCost);
    map['position'] = Variable<int>(position);
    return map;
  }

  PurchaseItemsCompanion toCompanion(bool nullToAbsent) {
    return PurchaseItemsCompanion(
      id: Value(id),
      purchaseId: Value(purchaseId),
      productId: Value(productId),
      variantId: Value(variantId),
      productName: Value(productName),
      variantLabel: Value(variantLabel),
      sku: Value(sku),
      quantity: Value(quantity),
      unitCost: Value(unitCost),
      position: Value(position),
    );
  }

  factory PurchaseItemRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PurchaseItemRow(
      id: serializer.fromJson<String>(json['id']),
      purchaseId: serializer.fromJson<String>(json['purchaseId']),
      productId: serializer.fromJson<String>(json['productId']),
      variantId: serializer.fromJson<String>(json['variantId']),
      productName: serializer.fromJson<String>(json['productName']),
      variantLabel: serializer.fromJson<String>(json['variantLabel']),
      sku: serializer.fromJson<String>(json['sku']),
      quantity: serializer.fromJson<int>(json['quantity']),
      unitCost: serializer.fromJson<double>(json['unitCost']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'purchaseId': serializer.toJson<String>(purchaseId),
      'productId': serializer.toJson<String>(productId),
      'variantId': serializer.toJson<String>(variantId),
      'productName': serializer.toJson<String>(productName),
      'variantLabel': serializer.toJson<String>(variantLabel),
      'sku': serializer.toJson<String>(sku),
      'quantity': serializer.toJson<int>(quantity),
      'unitCost': serializer.toJson<double>(unitCost),
      'position': serializer.toJson<int>(position),
    };
  }

  PurchaseItemRow copyWith(
          {String? id,
          String? purchaseId,
          String? productId,
          String? variantId,
          String? productName,
          String? variantLabel,
          String? sku,
          int? quantity,
          double? unitCost,
          int? position}) =>
      PurchaseItemRow(
        id: id ?? this.id,
        purchaseId: purchaseId ?? this.purchaseId,
        productId: productId ?? this.productId,
        variantId: variantId ?? this.variantId,
        productName: productName ?? this.productName,
        variantLabel: variantLabel ?? this.variantLabel,
        sku: sku ?? this.sku,
        quantity: quantity ?? this.quantity,
        unitCost: unitCost ?? this.unitCost,
        position: position ?? this.position,
      );
  PurchaseItemRow copyWithCompanion(PurchaseItemsCompanion data) {
    return PurchaseItemRow(
      id: data.id.present ? data.id.value : this.id,
      purchaseId:
          data.purchaseId.present ? data.purchaseId.value : this.purchaseId,
      productId: data.productId.present ? data.productId.value : this.productId,
      variantId: data.variantId.present ? data.variantId.value : this.variantId,
      productName:
          data.productName.present ? data.productName.value : this.productName,
      variantLabel: data.variantLabel.present
          ? data.variantLabel.value
          : this.variantLabel,
      sku: data.sku.present ? data.sku.value : this.sku,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unitCost: data.unitCost.present ? data.unitCost.value : this.unitCost,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PurchaseItemRow(')
          ..write('id: $id, ')
          ..write('purchaseId: $purchaseId, ')
          ..write('productId: $productId, ')
          ..write('variantId: $variantId, ')
          ..write('productName: $productName, ')
          ..write('variantLabel: $variantLabel, ')
          ..write('sku: $sku, ')
          ..write('quantity: $quantity, ')
          ..write('unitCost: $unitCost, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, purchaseId, productId, variantId,
      productName, variantLabel, sku, quantity, unitCost, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PurchaseItemRow &&
          other.id == this.id &&
          other.purchaseId == this.purchaseId &&
          other.productId == this.productId &&
          other.variantId == this.variantId &&
          other.productName == this.productName &&
          other.variantLabel == this.variantLabel &&
          other.sku == this.sku &&
          other.quantity == this.quantity &&
          other.unitCost == this.unitCost &&
          other.position == this.position);
}

class PurchaseItemsCompanion extends UpdateCompanion<PurchaseItemRow> {
  final Value<String> id;
  final Value<String> purchaseId;
  final Value<String> productId;
  final Value<String> variantId;
  final Value<String> productName;
  final Value<String> variantLabel;
  final Value<String> sku;
  final Value<int> quantity;
  final Value<double> unitCost;
  final Value<int> position;
  final Value<int> rowid;
  const PurchaseItemsCompanion({
    this.id = const Value.absent(),
    this.purchaseId = const Value.absent(),
    this.productId = const Value.absent(),
    this.variantId = const Value.absent(),
    this.productName = const Value.absent(),
    this.variantLabel = const Value.absent(),
    this.sku = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unitCost = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PurchaseItemsCompanion.insert({
    required String id,
    required String purchaseId,
    required String productId,
    required String variantId,
    required String productName,
    required String variantLabel,
    required String sku,
    required int quantity,
    required double unitCost,
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        purchaseId = Value(purchaseId),
        productId = Value(productId),
        variantId = Value(variantId),
        productName = Value(productName),
        variantLabel = Value(variantLabel),
        sku = Value(sku),
        quantity = Value(quantity),
        unitCost = Value(unitCost);
  static Insertable<PurchaseItemRow> custom({
    Expression<String>? id,
    Expression<String>? purchaseId,
    Expression<String>? productId,
    Expression<String>? variantId,
    Expression<String>? productName,
    Expression<String>? variantLabel,
    Expression<String>? sku,
    Expression<int>? quantity,
    Expression<double>? unitCost,
    Expression<int>? position,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (purchaseId != null) 'purchase_id': purchaseId,
      if (productId != null) 'product_id': productId,
      if (variantId != null) 'variant_id': variantId,
      if (productName != null) 'product_name': productName,
      if (variantLabel != null) 'variant_label': variantLabel,
      if (sku != null) 'sku': sku,
      if (quantity != null) 'quantity': quantity,
      if (unitCost != null) 'unit_cost': unitCost,
      if (position != null) 'position': position,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PurchaseItemsCompanion copyWith(
      {Value<String>? id,
      Value<String>? purchaseId,
      Value<String>? productId,
      Value<String>? variantId,
      Value<String>? productName,
      Value<String>? variantLabel,
      Value<String>? sku,
      Value<int>? quantity,
      Value<double>? unitCost,
      Value<int>? position,
      Value<int>? rowid}) {
    return PurchaseItemsCompanion(
      id: id ?? this.id,
      purchaseId: purchaseId ?? this.purchaseId,
      productId: productId ?? this.productId,
      variantId: variantId ?? this.variantId,
      productName: productName ?? this.productName,
      variantLabel: variantLabel ?? this.variantLabel,
      sku: sku ?? this.sku,
      quantity: quantity ?? this.quantity,
      unitCost: unitCost ?? this.unitCost,
      position: position ?? this.position,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (purchaseId.present) {
      map['purchase_id'] = Variable<String>(purchaseId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (variantId.present) {
      map['variant_id'] = Variable<String>(variantId.value);
    }
    if (productName.present) {
      map['product_name'] = Variable<String>(productName.value);
    }
    if (variantLabel.present) {
      map['variant_label'] = Variable<String>(variantLabel.value);
    }
    if (sku.present) {
      map['sku'] = Variable<String>(sku.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (unitCost.present) {
      map['unit_cost'] = Variable<double>(unitCost.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PurchaseItemsCompanion(')
          ..write('id: $id, ')
          ..write('purchaseId: $purchaseId, ')
          ..write('productId: $productId, ')
          ..write('variantId: $variantId, ')
          ..write('productName: $productName, ')
          ..write('variantLabel: $variantLabel, ')
          ..write('sku: $sku, ')
          ..write('quantity: $quantity, ')
          ..write('unitCost: $unitCost, ')
          ..write('position: $position, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StockMovementsTable extends StockMovements
    with TableInfo<$StockMovementsTable, StockMovementRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StockMovementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _productIdMeta =
      const VerificationMeta('productId');
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
      'product_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _variantIdMeta =
      const VerificationMeta('variantId');
  @override
  late final GeneratedColumn<String> variantId = GeneratedColumn<String>(
      'variant_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _skuMeta = const VerificationMeta('sku');
  @override
  late final GeneratedColumn<String> sku = GeneratedColumn<String>(
      'sku', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
      'quantity', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _movementTypeMeta =
      const VerificationMeta('movementType');
  @override
  late final GeneratedColumn<String> movementType = GeneratedColumn<String>(
      'movement_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sourceIdMeta =
      const VerificationMeta('sourceId');
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
      'source_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _unitCostMeta =
      const VerificationMeta('unitCost');
  @override
  late final GeneratedColumn<double> unitCost = GeneratedColumn<double>(
      'unit_cost', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _movementDateMeta =
      const VerificationMeta('movementDate');
  @override
  late final GeneratedColumn<DateTime> movementDate = GeneratedColumn<DateTime>(
      'movement_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        productId,
        variantId,
        sku,
        quantity,
        movementType,
        sourceId,
        unitCost,
        movementDate,
        note,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stock_movements';
  @override
  VerificationContext validateIntegrity(Insertable<StockMovementRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(_productIdMeta,
          productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta));
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('variant_id')) {
      context.handle(_variantIdMeta,
          variantId.isAcceptableOrUnknown(data['variant_id']!, _variantIdMeta));
    } else if (isInserting) {
      context.missing(_variantIdMeta);
    }
    if (data.containsKey('sku')) {
      context.handle(
          _skuMeta, sku.isAcceptableOrUnknown(data['sku']!, _skuMeta));
    } else if (isInserting) {
      context.missing(_skuMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('movement_type')) {
      context.handle(
          _movementTypeMeta,
          movementType.isAcceptableOrUnknown(
              data['movement_type']!, _movementTypeMeta));
    } else if (isInserting) {
      context.missing(_movementTypeMeta);
    }
    if (data.containsKey('source_id')) {
      context.handle(_sourceIdMeta,
          sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta));
    }
    if (data.containsKey('unit_cost')) {
      context.handle(_unitCostMeta,
          unitCost.isAcceptableOrUnknown(data['unit_cost']!, _unitCostMeta));
    }
    if (data.containsKey('movement_date')) {
      context.handle(
          _movementDateMeta,
          movementDate.isAcceptableOrUnknown(
              data['movement_date']!, _movementDateMeta));
    } else if (isInserting) {
      context.missing(_movementDateMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StockMovementRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StockMovementRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      productId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}product_id'])!,
      variantId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}variant_id'])!,
      sku: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sku'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quantity'])!,
      movementType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}movement_type'])!,
      sourceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_id'])!,
      unitCost: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}unit_cost'])!,
      movementDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}movement_date'])!,
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $StockMovementsTable createAlias(String alias) {
    return $StockMovementsTable(attachedDatabase, alias);
  }
}

class StockMovementRow extends DataClass
    implements Insertable<StockMovementRow> {
  final String id;
  final String productId;
  final String variantId;
  final String sku;
  final int quantity;
  final String movementType;
  final String sourceId;
  final double unitCost;
  final DateTime movementDate;
  final String note;
  final DateTime createdAt;
  final DateTime updatedAt;
  const StockMovementRow(
      {required this.id,
      required this.productId,
      required this.variantId,
      required this.sku,
      required this.quantity,
      required this.movementType,
      required this.sourceId,
      required this.unitCost,
      required this.movementDate,
      required this.note,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['product_id'] = Variable<String>(productId);
    map['variant_id'] = Variable<String>(variantId);
    map['sku'] = Variable<String>(sku);
    map['quantity'] = Variable<int>(quantity);
    map['movement_type'] = Variable<String>(movementType);
    map['source_id'] = Variable<String>(sourceId);
    map['unit_cost'] = Variable<double>(unitCost);
    map['movement_date'] = Variable<DateTime>(movementDate);
    map['note'] = Variable<String>(note);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  StockMovementsCompanion toCompanion(bool nullToAbsent) {
    return StockMovementsCompanion(
      id: Value(id),
      productId: Value(productId),
      variantId: Value(variantId),
      sku: Value(sku),
      quantity: Value(quantity),
      movementType: Value(movementType),
      sourceId: Value(sourceId),
      unitCost: Value(unitCost),
      movementDate: Value(movementDate),
      note: Value(note),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory StockMovementRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StockMovementRow(
      id: serializer.fromJson<String>(json['id']),
      productId: serializer.fromJson<String>(json['productId']),
      variantId: serializer.fromJson<String>(json['variantId']),
      sku: serializer.fromJson<String>(json['sku']),
      quantity: serializer.fromJson<int>(json['quantity']),
      movementType: serializer.fromJson<String>(json['movementType']),
      sourceId: serializer.fromJson<String>(json['sourceId']),
      unitCost: serializer.fromJson<double>(json['unitCost']),
      movementDate: serializer.fromJson<DateTime>(json['movementDate']),
      note: serializer.fromJson<String>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'productId': serializer.toJson<String>(productId),
      'variantId': serializer.toJson<String>(variantId),
      'sku': serializer.toJson<String>(sku),
      'quantity': serializer.toJson<int>(quantity),
      'movementType': serializer.toJson<String>(movementType),
      'sourceId': serializer.toJson<String>(sourceId),
      'unitCost': serializer.toJson<double>(unitCost),
      'movementDate': serializer.toJson<DateTime>(movementDate),
      'note': serializer.toJson<String>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  StockMovementRow copyWith(
          {String? id,
          String? productId,
          String? variantId,
          String? sku,
          int? quantity,
          String? movementType,
          String? sourceId,
          double? unitCost,
          DateTime? movementDate,
          String? note,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      StockMovementRow(
        id: id ?? this.id,
        productId: productId ?? this.productId,
        variantId: variantId ?? this.variantId,
        sku: sku ?? this.sku,
        quantity: quantity ?? this.quantity,
        movementType: movementType ?? this.movementType,
        sourceId: sourceId ?? this.sourceId,
        unitCost: unitCost ?? this.unitCost,
        movementDate: movementDate ?? this.movementDate,
        note: note ?? this.note,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  StockMovementRow copyWithCompanion(StockMovementsCompanion data) {
    return StockMovementRow(
      id: data.id.present ? data.id.value : this.id,
      productId: data.productId.present ? data.productId.value : this.productId,
      variantId: data.variantId.present ? data.variantId.value : this.variantId,
      sku: data.sku.present ? data.sku.value : this.sku,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      movementType: data.movementType.present
          ? data.movementType.value
          : this.movementType,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      unitCost: data.unitCost.present ? data.unitCost.value : this.unitCost,
      movementDate: data.movementDate.present
          ? data.movementDate.value
          : this.movementDate,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StockMovementRow(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('variantId: $variantId, ')
          ..write('sku: $sku, ')
          ..write('quantity: $quantity, ')
          ..write('movementType: $movementType, ')
          ..write('sourceId: $sourceId, ')
          ..write('unitCost: $unitCost, ')
          ..write('movementDate: $movementDate, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      productId,
      variantId,
      sku,
      quantity,
      movementType,
      sourceId,
      unitCost,
      movementDate,
      note,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StockMovementRow &&
          other.id == this.id &&
          other.productId == this.productId &&
          other.variantId == this.variantId &&
          other.sku == this.sku &&
          other.quantity == this.quantity &&
          other.movementType == this.movementType &&
          other.sourceId == this.sourceId &&
          other.unitCost == this.unitCost &&
          other.movementDate == this.movementDate &&
          other.note == this.note &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class StockMovementsCompanion extends UpdateCompanion<StockMovementRow> {
  final Value<String> id;
  final Value<String> productId;
  final Value<String> variantId;
  final Value<String> sku;
  final Value<int> quantity;
  final Value<String> movementType;
  final Value<String> sourceId;
  final Value<double> unitCost;
  final Value<DateTime> movementDate;
  final Value<String> note;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const StockMovementsCompanion({
    this.id = const Value.absent(),
    this.productId = const Value.absent(),
    this.variantId = const Value.absent(),
    this.sku = const Value.absent(),
    this.quantity = const Value.absent(),
    this.movementType = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.unitCost = const Value.absent(),
    this.movementDate = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StockMovementsCompanion.insert({
    required String id,
    required String productId,
    required String variantId,
    required String sku,
    required int quantity,
    required String movementType,
    this.sourceId = const Value.absent(),
    this.unitCost = const Value.absent(),
    required DateTime movementDate,
    this.note = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        productId = Value(productId),
        variantId = Value(variantId),
        sku = Value(sku),
        quantity = Value(quantity),
        movementType = Value(movementType),
        movementDate = Value(movementDate),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<StockMovementRow> custom({
    Expression<String>? id,
    Expression<String>? productId,
    Expression<String>? variantId,
    Expression<String>? sku,
    Expression<int>? quantity,
    Expression<String>? movementType,
    Expression<String>? sourceId,
    Expression<double>? unitCost,
    Expression<DateTime>? movementDate,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (productId != null) 'product_id': productId,
      if (variantId != null) 'variant_id': variantId,
      if (sku != null) 'sku': sku,
      if (quantity != null) 'quantity': quantity,
      if (movementType != null) 'movement_type': movementType,
      if (sourceId != null) 'source_id': sourceId,
      if (unitCost != null) 'unit_cost': unitCost,
      if (movementDate != null) 'movement_date': movementDate,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StockMovementsCompanion copyWith(
      {Value<String>? id,
      Value<String>? productId,
      Value<String>? variantId,
      Value<String>? sku,
      Value<int>? quantity,
      Value<String>? movementType,
      Value<String>? sourceId,
      Value<double>? unitCost,
      Value<DateTime>? movementDate,
      Value<String>? note,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return StockMovementsCompanion(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      variantId: variantId ?? this.variantId,
      sku: sku ?? this.sku,
      quantity: quantity ?? this.quantity,
      movementType: movementType ?? this.movementType,
      sourceId: sourceId ?? this.sourceId,
      unitCost: unitCost ?? this.unitCost,
      movementDate: movementDate ?? this.movementDate,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (variantId.present) {
      map['variant_id'] = Variable<String>(variantId.value);
    }
    if (sku.present) {
      map['sku'] = Variable<String>(sku.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (movementType.present) {
      map['movement_type'] = Variable<String>(movementType.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (unitCost.present) {
      map['unit_cost'] = Variable<double>(unitCost.value);
    }
    if (movementDate.present) {
      map['movement_date'] = Variable<DateTime>(movementDate.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StockMovementsCompanion(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('variantId: $variantId, ')
          ..write('sku: $sku, ')
          ..write('quantity: $quantity, ')
          ..write('movementType: $movementType, ')
          ..write('sourceId: $sourceId, ')
          ..write('unitCost: $unitCost, ')
          ..write('movementDate: $movementDate, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StockAuditsTable extends StockAudits
    with TableInfo<$StockAuditsTable, StockAuditRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StockAuditsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _auditNoMeta =
      const VerificationMeta('auditNo');
  @override
  late final GeneratedColumn<String> auditNo = GeneratedColumn<String>(
      'audit_no', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _auditDateMeta =
      const VerificationMeta('auditDate');
  @override
  late final GeneratedColumn<DateTime> auditDate = GeneratedColumn<DateTime>(
      'audit_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _countedByIdMeta =
      const VerificationMeta('countedById');
  @override
  late final GeneratedColumn<String> countedById = GeneratedColumn<String>(
      'counted_by_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _countedByNameMeta =
      const VerificationMeta('countedByName');
  @override
  late final GeneratedColumn<String> countedByName = GeneratedColumn<String>(
      'counted_by_name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        auditNo,
        auditDate,
        note,
        countedById,
        countedByName,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stock_audits';
  @override
  VerificationContext validateIntegrity(Insertable<StockAuditRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('audit_no')) {
      context.handle(_auditNoMeta,
          auditNo.isAcceptableOrUnknown(data['audit_no']!, _auditNoMeta));
    } else if (isInserting) {
      context.missing(_auditNoMeta);
    }
    if (data.containsKey('audit_date')) {
      context.handle(_auditDateMeta,
          auditDate.isAcceptableOrUnknown(data['audit_date']!, _auditDateMeta));
    } else if (isInserting) {
      context.missing(_auditDateMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('counted_by_id')) {
      context.handle(
          _countedByIdMeta,
          countedById.isAcceptableOrUnknown(
              data['counted_by_id']!, _countedByIdMeta));
    }
    if (data.containsKey('counted_by_name')) {
      context.handle(
          _countedByNameMeta,
          countedByName.isAcceptableOrUnknown(
              data['counted_by_name']!, _countedByNameMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StockAuditRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StockAuditRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      auditNo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}audit_no'])!,
      auditDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}audit_date'])!,
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note'])!,
      countedById: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}counted_by_id'])!,
      countedByName: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}counted_by_name'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $StockAuditsTable createAlias(String alias) {
    return $StockAuditsTable(attachedDatabase, alias);
  }
}

class StockAuditRow extends DataClass implements Insertable<StockAuditRow> {
  final String id;
  final String auditNo;
  final DateTime auditDate;
  final String note;
  final String countedById;
  final String countedByName;
  final DateTime createdAt;
  final DateTime updatedAt;
  const StockAuditRow(
      {required this.id,
      required this.auditNo,
      required this.auditDate,
      required this.note,
      required this.countedById,
      required this.countedByName,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['audit_no'] = Variable<String>(auditNo);
    map['audit_date'] = Variable<DateTime>(auditDate);
    map['note'] = Variable<String>(note);
    map['counted_by_id'] = Variable<String>(countedById);
    map['counted_by_name'] = Variable<String>(countedByName);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  StockAuditsCompanion toCompanion(bool nullToAbsent) {
    return StockAuditsCompanion(
      id: Value(id),
      auditNo: Value(auditNo),
      auditDate: Value(auditDate),
      note: Value(note),
      countedById: Value(countedById),
      countedByName: Value(countedByName),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory StockAuditRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StockAuditRow(
      id: serializer.fromJson<String>(json['id']),
      auditNo: serializer.fromJson<String>(json['auditNo']),
      auditDate: serializer.fromJson<DateTime>(json['auditDate']),
      note: serializer.fromJson<String>(json['note']),
      countedById: serializer.fromJson<String>(json['countedById']),
      countedByName: serializer.fromJson<String>(json['countedByName']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'auditNo': serializer.toJson<String>(auditNo),
      'auditDate': serializer.toJson<DateTime>(auditDate),
      'note': serializer.toJson<String>(note),
      'countedById': serializer.toJson<String>(countedById),
      'countedByName': serializer.toJson<String>(countedByName),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  StockAuditRow copyWith(
          {String? id,
          String? auditNo,
          DateTime? auditDate,
          String? note,
          String? countedById,
          String? countedByName,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      StockAuditRow(
        id: id ?? this.id,
        auditNo: auditNo ?? this.auditNo,
        auditDate: auditDate ?? this.auditDate,
        note: note ?? this.note,
        countedById: countedById ?? this.countedById,
        countedByName: countedByName ?? this.countedByName,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  StockAuditRow copyWithCompanion(StockAuditsCompanion data) {
    return StockAuditRow(
      id: data.id.present ? data.id.value : this.id,
      auditNo: data.auditNo.present ? data.auditNo.value : this.auditNo,
      auditDate: data.auditDate.present ? data.auditDate.value : this.auditDate,
      note: data.note.present ? data.note.value : this.note,
      countedById:
          data.countedById.present ? data.countedById.value : this.countedById,
      countedByName: data.countedByName.present
          ? data.countedByName.value
          : this.countedByName,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StockAuditRow(')
          ..write('id: $id, ')
          ..write('auditNo: $auditNo, ')
          ..write('auditDate: $auditDate, ')
          ..write('note: $note, ')
          ..write('countedById: $countedById, ')
          ..write('countedByName: $countedByName, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, auditNo, auditDate, note, countedById,
      countedByName, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StockAuditRow &&
          other.id == this.id &&
          other.auditNo == this.auditNo &&
          other.auditDate == this.auditDate &&
          other.note == this.note &&
          other.countedById == this.countedById &&
          other.countedByName == this.countedByName &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class StockAuditsCompanion extends UpdateCompanion<StockAuditRow> {
  final Value<String> id;
  final Value<String> auditNo;
  final Value<DateTime> auditDate;
  final Value<String> note;
  final Value<String> countedById;
  final Value<String> countedByName;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const StockAuditsCompanion({
    this.id = const Value.absent(),
    this.auditNo = const Value.absent(),
    this.auditDate = const Value.absent(),
    this.note = const Value.absent(),
    this.countedById = const Value.absent(),
    this.countedByName = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StockAuditsCompanion.insert({
    required String id,
    required String auditNo,
    required DateTime auditDate,
    this.note = const Value.absent(),
    this.countedById = const Value.absent(),
    this.countedByName = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        auditNo = Value(auditNo),
        auditDate = Value(auditDate),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<StockAuditRow> custom({
    Expression<String>? id,
    Expression<String>? auditNo,
    Expression<DateTime>? auditDate,
    Expression<String>? note,
    Expression<String>? countedById,
    Expression<String>? countedByName,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (auditNo != null) 'audit_no': auditNo,
      if (auditDate != null) 'audit_date': auditDate,
      if (note != null) 'note': note,
      if (countedById != null) 'counted_by_id': countedById,
      if (countedByName != null) 'counted_by_name': countedByName,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StockAuditsCompanion copyWith(
      {Value<String>? id,
      Value<String>? auditNo,
      Value<DateTime>? auditDate,
      Value<String>? note,
      Value<String>? countedById,
      Value<String>? countedByName,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return StockAuditsCompanion(
      id: id ?? this.id,
      auditNo: auditNo ?? this.auditNo,
      auditDate: auditDate ?? this.auditDate,
      note: note ?? this.note,
      countedById: countedById ?? this.countedById,
      countedByName: countedByName ?? this.countedByName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (auditNo.present) {
      map['audit_no'] = Variable<String>(auditNo.value);
    }
    if (auditDate.present) {
      map['audit_date'] = Variable<DateTime>(auditDate.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (countedById.present) {
      map['counted_by_id'] = Variable<String>(countedById.value);
    }
    if (countedByName.present) {
      map['counted_by_name'] = Variable<String>(countedByName.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StockAuditsCompanion(')
          ..write('id: $id, ')
          ..write('auditNo: $auditNo, ')
          ..write('auditDate: $auditDate, ')
          ..write('note: $note, ')
          ..write('countedById: $countedById, ')
          ..write('countedByName: $countedByName, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StockAuditItemsTable extends StockAuditItems
    with TableInfo<$StockAuditItemsTable, StockAuditItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StockAuditItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _auditIdMeta =
      const VerificationMeta('auditId');
  @override
  late final GeneratedColumn<String> auditId = GeneratedColumn<String>(
      'audit_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _positionMeta =
      const VerificationMeta('position');
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
      'position', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _productIdMeta =
      const VerificationMeta('productId');
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
      'product_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _variantIdMeta =
      const VerificationMeta('variantId');
  @override
  late final GeneratedColumn<String> variantId = GeneratedColumn<String>(
      'variant_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _productNameMeta =
      const VerificationMeta('productName');
  @override
  late final GeneratedColumn<String> productName = GeneratedColumn<String>(
      'product_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _variantLabelMeta =
      const VerificationMeta('variantLabel');
  @override
  late final GeneratedColumn<String> variantLabel = GeneratedColumn<String>(
      'variant_label', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _skuMeta = const VerificationMeta('sku');
  @override
  late final GeneratedColumn<String> sku = GeneratedColumn<String>(
      'sku', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _systemQuantityMeta =
      const VerificationMeta('systemQuantity');
  @override
  late final GeneratedColumn<int> systemQuantity = GeneratedColumn<int>(
      'system_quantity', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _countedQuantityMeta =
      const VerificationMeta('countedQuantity');
  @override
  late final GeneratedColumn<int> countedQuantity = GeneratedColumn<int>(
      'counted_quantity', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        auditId,
        position,
        productId,
        variantId,
        productName,
        variantLabel,
        sku,
        systemQuantity,
        countedQuantity
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stock_audit_items';
  @override
  VerificationContext validateIntegrity(Insertable<StockAuditItemRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('audit_id')) {
      context.handle(_auditIdMeta,
          auditId.isAcceptableOrUnknown(data['audit_id']!, _auditIdMeta));
    } else if (isInserting) {
      context.missing(_auditIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(_positionMeta,
          position.isAcceptableOrUnknown(data['position']!, _positionMeta));
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(_productIdMeta,
          productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta));
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('variant_id')) {
      context.handle(_variantIdMeta,
          variantId.isAcceptableOrUnknown(data['variant_id']!, _variantIdMeta));
    } else if (isInserting) {
      context.missing(_variantIdMeta);
    }
    if (data.containsKey('product_name')) {
      context.handle(
          _productNameMeta,
          productName.isAcceptableOrUnknown(
              data['product_name']!, _productNameMeta));
    } else if (isInserting) {
      context.missing(_productNameMeta);
    }
    if (data.containsKey('variant_label')) {
      context.handle(
          _variantLabelMeta,
          variantLabel.isAcceptableOrUnknown(
              data['variant_label']!, _variantLabelMeta));
    } else if (isInserting) {
      context.missing(_variantLabelMeta);
    }
    if (data.containsKey('sku')) {
      context.handle(
          _skuMeta, sku.isAcceptableOrUnknown(data['sku']!, _skuMeta));
    } else if (isInserting) {
      context.missing(_skuMeta);
    }
    if (data.containsKey('system_quantity')) {
      context.handle(
          _systemQuantityMeta,
          systemQuantity.isAcceptableOrUnknown(
              data['system_quantity']!, _systemQuantityMeta));
    } else if (isInserting) {
      context.missing(_systemQuantityMeta);
    }
    if (data.containsKey('counted_quantity')) {
      context.handle(
          _countedQuantityMeta,
          countedQuantity.isAcceptableOrUnknown(
              data['counted_quantity']!, _countedQuantityMeta));
    } else if (isInserting) {
      context.missing(_countedQuantityMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {auditId, position};
  @override
  StockAuditItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StockAuditItemRow(
      auditId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}audit_id'])!,
      position: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}position'])!,
      productId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}product_id'])!,
      variantId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}variant_id'])!,
      productName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}product_name'])!,
      variantLabel: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}variant_label'])!,
      sku: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sku'])!,
      systemQuantity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}system_quantity'])!,
      countedQuantity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}counted_quantity'])!,
    );
  }

  @override
  $StockAuditItemsTable createAlias(String alias) {
    return $StockAuditItemsTable(attachedDatabase, alias);
  }
}

class StockAuditItemRow extends DataClass
    implements Insertable<StockAuditItemRow> {
  final String auditId;
  final int position;
  final String productId;
  final String variantId;
  final String productName;
  final String variantLabel;
  final String sku;
  final int systemQuantity;
  final int countedQuantity;
  const StockAuditItemRow(
      {required this.auditId,
      required this.position,
      required this.productId,
      required this.variantId,
      required this.productName,
      required this.variantLabel,
      required this.sku,
      required this.systemQuantity,
      required this.countedQuantity});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['audit_id'] = Variable<String>(auditId);
    map['position'] = Variable<int>(position);
    map['product_id'] = Variable<String>(productId);
    map['variant_id'] = Variable<String>(variantId);
    map['product_name'] = Variable<String>(productName);
    map['variant_label'] = Variable<String>(variantLabel);
    map['sku'] = Variable<String>(sku);
    map['system_quantity'] = Variable<int>(systemQuantity);
    map['counted_quantity'] = Variable<int>(countedQuantity);
    return map;
  }

  StockAuditItemsCompanion toCompanion(bool nullToAbsent) {
    return StockAuditItemsCompanion(
      auditId: Value(auditId),
      position: Value(position),
      productId: Value(productId),
      variantId: Value(variantId),
      productName: Value(productName),
      variantLabel: Value(variantLabel),
      sku: Value(sku),
      systemQuantity: Value(systemQuantity),
      countedQuantity: Value(countedQuantity),
    );
  }

  factory StockAuditItemRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StockAuditItemRow(
      auditId: serializer.fromJson<String>(json['auditId']),
      position: serializer.fromJson<int>(json['position']),
      productId: serializer.fromJson<String>(json['productId']),
      variantId: serializer.fromJson<String>(json['variantId']),
      productName: serializer.fromJson<String>(json['productName']),
      variantLabel: serializer.fromJson<String>(json['variantLabel']),
      sku: serializer.fromJson<String>(json['sku']),
      systemQuantity: serializer.fromJson<int>(json['systemQuantity']),
      countedQuantity: serializer.fromJson<int>(json['countedQuantity']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'auditId': serializer.toJson<String>(auditId),
      'position': serializer.toJson<int>(position),
      'productId': serializer.toJson<String>(productId),
      'variantId': serializer.toJson<String>(variantId),
      'productName': serializer.toJson<String>(productName),
      'variantLabel': serializer.toJson<String>(variantLabel),
      'sku': serializer.toJson<String>(sku),
      'systemQuantity': serializer.toJson<int>(systemQuantity),
      'countedQuantity': serializer.toJson<int>(countedQuantity),
    };
  }

  StockAuditItemRow copyWith(
          {String? auditId,
          int? position,
          String? productId,
          String? variantId,
          String? productName,
          String? variantLabel,
          String? sku,
          int? systemQuantity,
          int? countedQuantity}) =>
      StockAuditItemRow(
        auditId: auditId ?? this.auditId,
        position: position ?? this.position,
        productId: productId ?? this.productId,
        variantId: variantId ?? this.variantId,
        productName: productName ?? this.productName,
        variantLabel: variantLabel ?? this.variantLabel,
        sku: sku ?? this.sku,
        systemQuantity: systemQuantity ?? this.systemQuantity,
        countedQuantity: countedQuantity ?? this.countedQuantity,
      );
  StockAuditItemRow copyWithCompanion(StockAuditItemsCompanion data) {
    return StockAuditItemRow(
      auditId: data.auditId.present ? data.auditId.value : this.auditId,
      position: data.position.present ? data.position.value : this.position,
      productId: data.productId.present ? data.productId.value : this.productId,
      variantId: data.variantId.present ? data.variantId.value : this.variantId,
      productName:
          data.productName.present ? data.productName.value : this.productName,
      variantLabel: data.variantLabel.present
          ? data.variantLabel.value
          : this.variantLabel,
      sku: data.sku.present ? data.sku.value : this.sku,
      systemQuantity: data.systemQuantity.present
          ? data.systemQuantity.value
          : this.systemQuantity,
      countedQuantity: data.countedQuantity.present
          ? data.countedQuantity.value
          : this.countedQuantity,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StockAuditItemRow(')
          ..write('auditId: $auditId, ')
          ..write('position: $position, ')
          ..write('productId: $productId, ')
          ..write('variantId: $variantId, ')
          ..write('productName: $productName, ')
          ..write('variantLabel: $variantLabel, ')
          ..write('sku: $sku, ')
          ..write('systemQuantity: $systemQuantity, ')
          ..write('countedQuantity: $countedQuantity')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(auditId, position, productId, variantId,
      productName, variantLabel, sku, systemQuantity, countedQuantity);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StockAuditItemRow &&
          other.auditId == this.auditId &&
          other.position == this.position &&
          other.productId == this.productId &&
          other.variantId == this.variantId &&
          other.productName == this.productName &&
          other.variantLabel == this.variantLabel &&
          other.sku == this.sku &&
          other.systemQuantity == this.systemQuantity &&
          other.countedQuantity == this.countedQuantity);
}

class StockAuditItemsCompanion extends UpdateCompanion<StockAuditItemRow> {
  final Value<String> auditId;
  final Value<int> position;
  final Value<String> productId;
  final Value<String> variantId;
  final Value<String> productName;
  final Value<String> variantLabel;
  final Value<String> sku;
  final Value<int> systemQuantity;
  final Value<int> countedQuantity;
  final Value<int> rowid;
  const StockAuditItemsCompanion({
    this.auditId = const Value.absent(),
    this.position = const Value.absent(),
    this.productId = const Value.absent(),
    this.variantId = const Value.absent(),
    this.productName = const Value.absent(),
    this.variantLabel = const Value.absent(),
    this.sku = const Value.absent(),
    this.systemQuantity = const Value.absent(),
    this.countedQuantity = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StockAuditItemsCompanion.insert({
    required String auditId,
    required int position,
    required String productId,
    required String variantId,
    required String productName,
    required String variantLabel,
    required String sku,
    required int systemQuantity,
    required int countedQuantity,
    this.rowid = const Value.absent(),
  })  : auditId = Value(auditId),
        position = Value(position),
        productId = Value(productId),
        variantId = Value(variantId),
        productName = Value(productName),
        variantLabel = Value(variantLabel),
        sku = Value(sku),
        systemQuantity = Value(systemQuantity),
        countedQuantity = Value(countedQuantity);
  static Insertable<StockAuditItemRow> custom({
    Expression<String>? auditId,
    Expression<int>? position,
    Expression<String>? productId,
    Expression<String>? variantId,
    Expression<String>? productName,
    Expression<String>? variantLabel,
    Expression<String>? sku,
    Expression<int>? systemQuantity,
    Expression<int>? countedQuantity,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (auditId != null) 'audit_id': auditId,
      if (position != null) 'position': position,
      if (productId != null) 'product_id': productId,
      if (variantId != null) 'variant_id': variantId,
      if (productName != null) 'product_name': productName,
      if (variantLabel != null) 'variant_label': variantLabel,
      if (sku != null) 'sku': sku,
      if (systemQuantity != null) 'system_quantity': systemQuantity,
      if (countedQuantity != null) 'counted_quantity': countedQuantity,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StockAuditItemsCompanion copyWith(
      {Value<String>? auditId,
      Value<int>? position,
      Value<String>? productId,
      Value<String>? variantId,
      Value<String>? productName,
      Value<String>? variantLabel,
      Value<String>? sku,
      Value<int>? systemQuantity,
      Value<int>? countedQuantity,
      Value<int>? rowid}) {
    return StockAuditItemsCompanion(
      auditId: auditId ?? this.auditId,
      position: position ?? this.position,
      productId: productId ?? this.productId,
      variantId: variantId ?? this.variantId,
      productName: productName ?? this.productName,
      variantLabel: variantLabel ?? this.variantLabel,
      sku: sku ?? this.sku,
      systemQuantity: systemQuantity ?? this.systemQuantity,
      countedQuantity: countedQuantity ?? this.countedQuantity,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (auditId.present) {
      map['audit_id'] = Variable<String>(auditId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (variantId.present) {
      map['variant_id'] = Variable<String>(variantId.value);
    }
    if (productName.present) {
      map['product_name'] = Variable<String>(productName.value);
    }
    if (variantLabel.present) {
      map['variant_label'] = Variable<String>(variantLabel.value);
    }
    if (sku.present) {
      map['sku'] = Variable<String>(sku.value);
    }
    if (systemQuantity.present) {
      map['system_quantity'] = Variable<int>(systemQuantity.value);
    }
    if (countedQuantity.present) {
      map['counted_quantity'] = Variable<int>(countedQuantity.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StockAuditItemsCompanion(')
          ..write('auditId: $auditId, ')
          ..write('position: $position, ')
          ..write('productId: $productId, ')
          ..write('variantId: $variantId, ')
          ..write('productName: $productName, ')
          ..write('variantLabel: $variantLabel, ')
          ..write('sku: $sku, ')
          ..write('systemQuantity: $systemQuantity, ')
          ..write('countedQuantity: $countedQuantity, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OrdersTable extends Orders with TableInfo<$OrdersTable, OrderRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OrdersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _orderNoMeta =
      const VerificationMeta('orderNo');
  @override
  late final GeneratedColumn<String> orderNo = GeneratedColumn<String>(
      'order_no', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _customerIdMeta =
      const VerificationMeta('customerId');
  @override
  late final GeneratedColumn<String> customerId = GeneratedColumn<String>(
      'customer_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _customerNameMeta =
      const VerificationMeta('customerName');
  @override
  late final GeneratedColumn<String> customerName = GeneratedColumn<String>(
      'customer_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _orderDateMeta =
      const VerificationMeta('orderDate');
  @override
  late final GeneratedColumn<DateTime> orderDate = GeneratedColumn<DateTime>(
      'order_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _saleTypeMeta =
      const VerificationMeta('saleType');
  @override
  late final GeneratedColumn<String> saleType = GeneratedColumn<String>(
      'sale_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('retail'));
  static const VerificationMeta _discountMeta =
      const VerificationMeta('discount');
  @override
  late final GeneratedColumn<double> discount = GeneratedColumn<double>(
      'discount', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _shippingFeeMeta =
      const VerificationMeta('shippingFee');
  @override
  late final GeneratedColumn<double> shippingFee = GeneratedColumn<double>(
      'shipping_fee', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _shippingAddressMeta =
      const VerificationMeta('shippingAddress');
  @override
  late final GeneratedColumn<String> shippingAddress = GeneratedColumn<String>(
      'shipping_address', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _channelMeta =
      const VerificationMeta('channel');
  @override
  late final GeneratedColumn<String> channel = GeneratedColumn<String>(
      'channel', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('admin'));
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        orderNo,
        customerId,
        customerName,
        orderDate,
        status,
        saleType,
        discount,
        shippingFee,
        shippingAddress,
        channel,
        notes,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'orders';
  @override
  VerificationContext validateIntegrity(Insertable<OrderRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('order_no')) {
      context.handle(_orderNoMeta,
          orderNo.isAcceptableOrUnknown(data['order_no']!, _orderNoMeta));
    } else if (isInserting) {
      context.missing(_orderNoMeta);
    }
    if (data.containsKey('customer_id')) {
      context.handle(
          _customerIdMeta,
          customerId.isAcceptableOrUnknown(
              data['customer_id']!, _customerIdMeta));
    } else if (isInserting) {
      context.missing(_customerIdMeta);
    }
    if (data.containsKey('customer_name')) {
      context.handle(
          _customerNameMeta,
          customerName.isAcceptableOrUnknown(
              data['customer_name']!, _customerNameMeta));
    } else if (isInserting) {
      context.missing(_customerNameMeta);
    }
    if (data.containsKey('order_date')) {
      context.handle(_orderDateMeta,
          orderDate.isAcceptableOrUnknown(data['order_date']!, _orderDateMeta));
    } else if (isInserting) {
      context.missing(_orderDateMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('sale_type')) {
      context.handle(_saleTypeMeta,
          saleType.isAcceptableOrUnknown(data['sale_type']!, _saleTypeMeta));
    }
    if (data.containsKey('discount')) {
      context.handle(_discountMeta,
          discount.isAcceptableOrUnknown(data['discount']!, _discountMeta));
    }
    if (data.containsKey('shipping_fee')) {
      context.handle(
          _shippingFeeMeta,
          shippingFee.isAcceptableOrUnknown(
              data['shipping_fee']!, _shippingFeeMeta));
    }
    if (data.containsKey('shipping_address')) {
      context.handle(
          _shippingAddressMeta,
          shippingAddress.isAcceptableOrUnknown(
              data['shipping_address']!, _shippingAddressMeta));
    }
    if (data.containsKey('channel')) {
      context.handle(_channelMeta,
          channel.isAcceptableOrUnknown(data['channel']!, _channelMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OrderRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OrderRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      orderNo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}order_no'])!,
      customerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}customer_id'])!,
      customerName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}customer_name'])!,
      orderDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}order_date'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      saleType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sale_type'])!,
      discount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}discount'])!,
      shippingFee: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}shipping_fee'])!,
      shippingAddress: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}shipping_address'])!,
      channel: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}channel'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $OrdersTable createAlias(String alias) {
    return $OrdersTable(attachedDatabase, alias);
  }
}

class OrderRow extends DataClass implements Insertable<OrderRow> {
  final String id;
  final String orderNo;
  final String customerId;
  final String customerName;
  final DateTime orderDate;
  final String status;
  final String saleType;
  final double discount;
  final double shippingFee;
  final String shippingAddress;
  final String channel;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  const OrderRow(
      {required this.id,
      required this.orderNo,
      required this.customerId,
      required this.customerName,
      required this.orderDate,
      required this.status,
      required this.saleType,
      required this.discount,
      required this.shippingFee,
      required this.shippingAddress,
      required this.channel,
      required this.notes,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['order_no'] = Variable<String>(orderNo);
    map['customer_id'] = Variable<String>(customerId);
    map['customer_name'] = Variable<String>(customerName);
    map['order_date'] = Variable<DateTime>(orderDate);
    map['status'] = Variable<String>(status);
    map['sale_type'] = Variable<String>(saleType);
    map['discount'] = Variable<double>(discount);
    map['shipping_fee'] = Variable<double>(shippingFee);
    map['shipping_address'] = Variable<String>(shippingAddress);
    map['channel'] = Variable<String>(channel);
    map['notes'] = Variable<String>(notes);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  OrdersCompanion toCompanion(bool nullToAbsent) {
    return OrdersCompanion(
      id: Value(id),
      orderNo: Value(orderNo),
      customerId: Value(customerId),
      customerName: Value(customerName),
      orderDate: Value(orderDate),
      status: Value(status),
      saleType: Value(saleType),
      discount: Value(discount),
      shippingFee: Value(shippingFee),
      shippingAddress: Value(shippingAddress),
      channel: Value(channel),
      notes: Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory OrderRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OrderRow(
      id: serializer.fromJson<String>(json['id']),
      orderNo: serializer.fromJson<String>(json['orderNo']),
      customerId: serializer.fromJson<String>(json['customerId']),
      customerName: serializer.fromJson<String>(json['customerName']),
      orderDate: serializer.fromJson<DateTime>(json['orderDate']),
      status: serializer.fromJson<String>(json['status']),
      saleType: serializer.fromJson<String>(json['saleType']),
      discount: serializer.fromJson<double>(json['discount']),
      shippingFee: serializer.fromJson<double>(json['shippingFee']),
      shippingAddress: serializer.fromJson<String>(json['shippingAddress']),
      channel: serializer.fromJson<String>(json['channel']),
      notes: serializer.fromJson<String>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'orderNo': serializer.toJson<String>(orderNo),
      'customerId': serializer.toJson<String>(customerId),
      'customerName': serializer.toJson<String>(customerName),
      'orderDate': serializer.toJson<DateTime>(orderDate),
      'status': serializer.toJson<String>(status),
      'saleType': serializer.toJson<String>(saleType),
      'discount': serializer.toJson<double>(discount),
      'shippingFee': serializer.toJson<double>(shippingFee),
      'shippingAddress': serializer.toJson<String>(shippingAddress),
      'channel': serializer.toJson<String>(channel),
      'notes': serializer.toJson<String>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  OrderRow copyWith(
          {String? id,
          String? orderNo,
          String? customerId,
          String? customerName,
          DateTime? orderDate,
          String? status,
          String? saleType,
          double? discount,
          double? shippingFee,
          String? shippingAddress,
          String? channel,
          String? notes,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      OrderRow(
        id: id ?? this.id,
        orderNo: orderNo ?? this.orderNo,
        customerId: customerId ?? this.customerId,
        customerName: customerName ?? this.customerName,
        orderDate: orderDate ?? this.orderDate,
        status: status ?? this.status,
        saleType: saleType ?? this.saleType,
        discount: discount ?? this.discount,
        shippingFee: shippingFee ?? this.shippingFee,
        shippingAddress: shippingAddress ?? this.shippingAddress,
        channel: channel ?? this.channel,
        notes: notes ?? this.notes,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  OrderRow copyWithCompanion(OrdersCompanion data) {
    return OrderRow(
      id: data.id.present ? data.id.value : this.id,
      orderNo: data.orderNo.present ? data.orderNo.value : this.orderNo,
      customerId:
          data.customerId.present ? data.customerId.value : this.customerId,
      customerName: data.customerName.present
          ? data.customerName.value
          : this.customerName,
      orderDate: data.orderDate.present ? data.orderDate.value : this.orderDate,
      status: data.status.present ? data.status.value : this.status,
      saleType: data.saleType.present ? data.saleType.value : this.saleType,
      discount: data.discount.present ? data.discount.value : this.discount,
      shippingFee:
          data.shippingFee.present ? data.shippingFee.value : this.shippingFee,
      shippingAddress: data.shippingAddress.present
          ? data.shippingAddress.value
          : this.shippingAddress,
      channel: data.channel.present ? data.channel.value : this.channel,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OrderRow(')
          ..write('id: $id, ')
          ..write('orderNo: $orderNo, ')
          ..write('customerId: $customerId, ')
          ..write('customerName: $customerName, ')
          ..write('orderDate: $orderDate, ')
          ..write('status: $status, ')
          ..write('saleType: $saleType, ')
          ..write('discount: $discount, ')
          ..write('shippingFee: $shippingFee, ')
          ..write('shippingAddress: $shippingAddress, ')
          ..write('channel: $channel, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      orderNo,
      customerId,
      customerName,
      orderDate,
      status,
      saleType,
      discount,
      shippingFee,
      shippingAddress,
      channel,
      notes,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OrderRow &&
          other.id == this.id &&
          other.orderNo == this.orderNo &&
          other.customerId == this.customerId &&
          other.customerName == this.customerName &&
          other.orderDate == this.orderDate &&
          other.status == this.status &&
          other.saleType == this.saleType &&
          other.discount == this.discount &&
          other.shippingFee == this.shippingFee &&
          other.shippingAddress == this.shippingAddress &&
          other.channel == this.channel &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class OrdersCompanion extends UpdateCompanion<OrderRow> {
  final Value<String> id;
  final Value<String> orderNo;
  final Value<String> customerId;
  final Value<String> customerName;
  final Value<DateTime> orderDate;
  final Value<String> status;
  final Value<String> saleType;
  final Value<double> discount;
  final Value<double> shippingFee;
  final Value<String> shippingAddress;
  final Value<String> channel;
  final Value<String> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const OrdersCompanion({
    this.id = const Value.absent(),
    this.orderNo = const Value.absent(),
    this.customerId = const Value.absent(),
    this.customerName = const Value.absent(),
    this.orderDate = const Value.absent(),
    this.status = const Value.absent(),
    this.saleType = const Value.absent(),
    this.discount = const Value.absent(),
    this.shippingFee = const Value.absent(),
    this.shippingAddress = const Value.absent(),
    this.channel = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OrdersCompanion.insert({
    required String id,
    required String orderNo,
    required String customerId,
    required String customerName,
    required DateTime orderDate,
    this.status = const Value.absent(),
    this.saleType = const Value.absent(),
    this.discount = const Value.absent(),
    this.shippingFee = const Value.absent(),
    this.shippingAddress = const Value.absent(),
    this.channel = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        orderNo = Value(orderNo),
        customerId = Value(customerId),
        customerName = Value(customerName),
        orderDate = Value(orderDate),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<OrderRow> custom({
    Expression<String>? id,
    Expression<String>? orderNo,
    Expression<String>? customerId,
    Expression<String>? customerName,
    Expression<DateTime>? orderDate,
    Expression<String>? status,
    Expression<String>? saleType,
    Expression<double>? discount,
    Expression<double>? shippingFee,
    Expression<String>? shippingAddress,
    Expression<String>? channel,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (orderNo != null) 'order_no': orderNo,
      if (customerId != null) 'customer_id': customerId,
      if (customerName != null) 'customer_name': customerName,
      if (orderDate != null) 'order_date': orderDate,
      if (status != null) 'status': status,
      if (saleType != null) 'sale_type': saleType,
      if (discount != null) 'discount': discount,
      if (shippingFee != null) 'shipping_fee': shippingFee,
      if (shippingAddress != null) 'shipping_address': shippingAddress,
      if (channel != null) 'channel': channel,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OrdersCompanion copyWith(
      {Value<String>? id,
      Value<String>? orderNo,
      Value<String>? customerId,
      Value<String>? customerName,
      Value<DateTime>? orderDate,
      Value<String>? status,
      Value<String>? saleType,
      Value<double>? discount,
      Value<double>? shippingFee,
      Value<String>? shippingAddress,
      Value<String>? channel,
      Value<String>? notes,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return OrdersCompanion(
      id: id ?? this.id,
      orderNo: orderNo ?? this.orderNo,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      orderDate: orderDate ?? this.orderDate,
      status: status ?? this.status,
      saleType: saleType ?? this.saleType,
      discount: discount ?? this.discount,
      shippingFee: shippingFee ?? this.shippingFee,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      channel: channel ?? this.channel,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (orderNo.present) {
      map['order_no'] = Variable<String>(orderNo.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<String>(customerId.value);
    }
    if (customerName.present) {
      map['customer_name'] = Variable<String>(customerName.value);
    }
    if (orderDate.present) {
      map['order_date'] = Variable<DateTime>(orderDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (saleType.present) {
      map['sale_type'] = Variable<String>(saleType.value);
    }
    if (discount.present) {
      map['discount'] = Variable<double>(discount.value);
    }
    if (shippingFee.present) {
      map['shipping_fee'] = Variable<double>(shippingFee.value);
    }
    if (shippingAddress.present) {
      map['shipping_address'] = Variable<String>(shippingAddress.value);
    }
    if (channel.present) {
      map['channel'] = Variable<String>(channel.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OrdersCompanion(')
          ..write('id: $id, ')
          ..write('orderNo: $orderNo, ')
          ..write('customerId: $customerId, ')
          ..write('customerName: $customerName, ')
          ..write('orderDate: $orderDate, ')
          ..write('status: $status, ')
          ..write('saleType: $saleType, ')
          ..write('discount: $discount, ')
          ..write('shippingFee: $shippingFee, ')
          ..write('shippingAddress: $shippingAddress, ')
          ..write('channel: $channel, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OrderItemsTable extends OrderItems
    with TableInfo<$OrderItemsTable, OrderItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OrderItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _orderIdMeta =
      const VerificationMeta('orderId');
  @override
  late final GeneratedColumn<String> orderId = GeneratedColumn<String>(
      'order_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _productIdMeta =
      const VerificationMeta('productId');
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
      'product_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _variantIdMeta =
      const VerificationMeta('variantId');
  @override
  late final GeneratedColumn<String> variantId = GeneratedColumn<String>(
      'variant_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _productNameMeta =
      const VerificationMeta('productName');
  @override
  late final GeneratedColumn<String> productName = GeneratedColumn<String>(
      'product_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _variantLabelMeta =
      const VerificationMeta('variantLabel');
  @override
  late final GeneratedColumn<String> variantLabel = GeneratedColumn<String>(
      'variant_label', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _skuMeta = const VerificationMeta('sku');
  @override
  late final GeneratedColumn<String> sku = GeneratedColumn<String>(
      'sku', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
      'quantity', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _unitPriceMeta =
      const VerificationMeta('unitPrice');
  @override
  late final GeneratedColumn<double> unitPrice = GeneratedColumn<double>(
      'unit_price', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _discountMeta =
      const VerificationMeta('discount');
  @override
  late final GeneratedColumn<double> discount = GeneratedColumn<double>(
      'discount', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _positionMeta =
      const VerificationMeta('position');
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
      'position', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        orderId,
        productId,
        variantId,
        productName,
        variantLabel,
        sku,
        quantity,
        unitPrice,
        discount,
        position
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'order_items';
  @override
  VerificationContext validateIntegrity(Insertable<OrderItemRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('order_id')) {
      context.handle(_orderIdMeta,
          orderId.isAcceptableOrUnknown(data['order_id']!, _orderIdMeta));
    } else if (isInserting) {
      context.missing(_orderIdMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(_productIdMeta,
          productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta));
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('variant_id')) {
      context.handle(_variantIdMeta,
          variantId.isAcceptableOrUnknown(data['variant_id']!, _variantIdMeta));
    } else if (isInserting) {
      context.missing(_variantIdMeta);
    }
    if (data.containsKey('product_name')) {
      context.handle(
          _productNameMeta,
          productName.isAcceptableOrUnknown(
              data['product_name']!, _productNameMeta));
    } else if (isInserting) {
      context.missing(_productNameMeta);
    }
    if (data.containsKey('variant_label')) {
      context.handle(
          _variantLabelMeta,
          variantLabel.isAcceptableOrUnknown(
              data['variant_label']!, _variantLabelMeta));
    } else if (isInserting) {
      context.missing(_variantLabelMeta);
    }
    if (data.containsKey('sku')) {
      context.handle(
          _skuMeta, sku.isAcceptableOrUnknown(data['sku']!, _skuMeta));
    } else if (isInserting) {
      context.missing(_skuMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('unit_price')) {
      context.handle(_unitPriceMeta,
          unitPrice.isAcceptableOrUnknown(data['unit_price']!, _unitPriceMeta));
    } else if (isInserting) {
      context.missing(_unitPriceMeta);
    }
    if (data.containsKey('discount')) {
      context.handle(_discountMeta,
          discount.isAcceptableOrUnknown(data['discount']!, _discountMeta));
    }
    if (data.containsKey('position')) {
      context.handle(_positionMeta,
          position.isAcceptableOrUnknown(data['position']!, _positionMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OrderItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OrderItemRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      orderId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}order_id'])!,
      productId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}product_id'])!,
      variantId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}variant_id'])!,
      productName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}product_name'])!,
      variantLabel: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}variant_label'])!,
      sku: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sku'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quantity'])!,
      unitPrice: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}unit_price'])!,
      discount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}discount'])!,
      position: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}position'])!,
    );
  }

  @override
  $OrderItemsTable createAlias(String alias) {
    return $OrderItemsTable(attachedDatabase, alias);
  }
}

class OrderItemRow extends DataClass implements Insertable<OrderItemRow> {
  final String id;
  final String orderId;
  final String productId;
  final String variantId;
  final String productName;
  final String variantLabel;
  final String sku;
  final int quantity;
  final double unitPrice;
  final double discount;
  final int position;
  const OrderItemRow(
      {required this.id,
      required this.orderId,
      required this.productId,
      required this.variantId,
      required this.productName,
      required this.variantLabel,
      required this.sku,
      required this.quantity,
      required this.unitPrice,
      required this.discount,
      required this.position});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['order_id'] = Variable<String>(orderId);
    map['product_id'] = Variable<String>(productId);
    map['variant_id'] = Variable<String>(variantId);
    map['product_name'] = Variable<String>(productName);
    map['variant_label'] = Variable<String>(variantLabel);
    map['sku'] = Variable<String>(sku);
    map['quantity'] = Variable<int>(quantity);
    map['unit_price'] = Variable<double>(unitPrice);
    map['discount'] = Variable<double>(discount);
    map['position'] = Variable<int>(position);
    return map;
  }

  OrderItemsCompanion toCompanion(bool nullToAbsent) {
    return OrderItemsCompanion(
      id: Value(id),
      orderId: Value(orderId),
      productId: Value(productId),
      variantId: Value(variantId),
      productName: Value(productName),
      variantLabel: Value(variantLabel),
      sku: Value(sku),
      quantity: Value(quantity),
      unitPrice: Value(unitPrice),
      discount: Value(discount),
      position: Value(position),
    );
  }

  factory OrderItemRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OrderItemRow(
      id: serializer.fromJson<String>(json['id']),
      orderId: serializer.fromJson<String>(json['orderId']),
      productId: serializer.fromJson<String>(json['productId']),
      variantId: serializer.fromJson<String>(json['variantId']),
      productName: serializer.fromJson<String>(json['productName']),
      variantLabel: serializer.fromJson<String>(json['variantLabel']),
      sku: serializer.fromJson<String>(json['sku']),
      quantity: serializer.fromJson<int>(json['quantity']),
      unitPrice: serializer.fromJson<double>(json['unitPrice']),
      discount: serializer.fromJson<double>(json['discount']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'orderId': serializer.toJson<String>(orderId),
      'productId': serializer.toJson<String>(productId),
      'variantId': serializer.toJson<String>(variantId),
      'productName': serializer.toJson<String>(productName),
      'variantLabel': serializer.toJson<String>(variantLabel),
      'sku': serializer.toJson<String>(sku),
      'quantity': serializer.toJson<int>(quantity),
      'unitPrice': serializer.toJson<double>(unitPrice),
      'discount': serializer.toJson<double>(discount),
      'position': serializer.toJson<int>(position),
    };
  }

  OrderItemRow copyWith(
          {String? id,
          String? orderId,
          String? productId,
          String? variantId,
          String? productName,
          String? variantLabel,
          String? sku,
          int? quantity,
          double? unitPrice,
          double? discount,
          int? position}) =>
      OrderItemRow(
        id: id ?? this.id,
        orderId: orderId ?? this.orderId,
        productId: productId ?? this.productId,
        variantId: variantId ?? this.variantId,
        productName: productName ?? this.productName,
        variantLabel: variantLabel ?? this.variantLabel,
        sku: sku ?? this.sku,
        quantity: quantity ?? this.quantity,
        unitPrice: unitPrice ?? this.unitPrice,
        discount: discount ?? this.discount,
        position: position ?? this.position,
      );
  OrderItemRow copyWithCompanion(OrderItemsCompanion data) {
    return OrderItemRow(
      id: data.id.present ? data.id.value : this.id,
      orderId: data.orderId.present ? data.orderId.value : this.orderId,
      productId: data.productId.present ? data.productId.value : this.productId,
      variantId: data.variantId.present ? data.variantId.value : this.variantId,
      productName:
          data.productName.present ? data.productName.value : this.productName,
      variantLabel: data.variantLabel.present
          ? data.variantLabel.value
          : this.variantLabel,
      sku: data.sku.present ? data.sku.value : this.sku,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unitPrice: data.unitPrice.present ? data.unitPrice.value : this.unitPrice,
      discount: data.discount.present ? data.discount.value : this.discount,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OrderItemRow(')
          ..write('id: $id, ')
          ..write('orderId: $orderId, ')
          ..write('productId: $productId, ')
          ..write('variantId: $variantId, ')
          ..write('productName: $productName, ')
          ..write('variantLabel: $variantLabel, ')
          ..write('sku: $sku, ')
          ..write('quantity: $quantity, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('discount: $discount, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, orderId, productId, variantId,
      productName, variantLabel, sku, quantity, unitPrice, discount, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OrderItemRow &&
          other.id == this.id &&
          other.orderId == this.orderId &&
          other.productId == this.productId &&
          other.variantId == this.variantId &&
          other.productName == this.productName &&
          other.variantLabel == this.variantLabel &&
          other.sku == this.sku &&
          other.quantity == this.quantity &&
          other.unitPrice == this.unitPrice &&
          other.discount == this.discount &&
          other.position == this.position);
}

class OrderItemsCompanion extends UpdateCompanion<OrderItemRow> {
  final Value<String> id;
  final Value<String> orderId;
  final Value<String> productId;
  final Value<String> variantId;
  final Value<String> productName;
  final Value<String> variantLabel;
  final Value<String> sku;
  final Value<int> quantity;
  final Value<double> unitPrice;
  final Value<double> discount;
  final Value<int> position;
  final Value<int> rowid;
  const OrderItemsCompanion({
    this.id = const Value.absent(),
    this.orderId = const Value.absent(),
    this.productId = const Value.absent(),
    this.variantId = const Value.absent(),
    this.productName = const Value.absent(),
    this.variantLabel = const Value.absent(),
    this.sku = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unitPrice = const Value.absent(),
    this.discount = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OrderItemsCompanion.insert({
    required String id,
    required String orderId,
    required String productId,
    required String variantId,
    required String productName,
    required String variantLabel,
    required String sku,
    required int quantity,
    required double unitPrice,
    this.discount = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        orderId = Value(orderId),
        productId = Value(productId),
        variantId = Value(variantId),
        productName = Value(productName),
        variantLabel = Value(variantLabel),
        sku = Value(sku),
        quantity = Value(quantity),
        unitPrice = Value(unitPrice);
  static Insertable<OrderItemRow> custom({
    Expression<String>? id,
    Expression<String>? orderId,
    Expression<String>? productId,
    Expression<String>? variantId,
    Expression<String>? productName,
    Expression<String>? variantLabel,
    Expression<String>? sku,
    Expression<int>? quantity,
    Expression<double>? unitPrice,
    Expression<double>? discount,
    Expression<int>? position,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (orderId != null) 'order_id': orderId,
      if (productId != null) 'product_id': productId,
      if (variantId != null) 'variant_id': variantId,
      if (productName != null) 'product_name': productName,
      if (variantLabel != null) 'variant_label': variantLabel,
      if (sku != null) 'sku': sku,
      if (quantity != null) 'quantity': quantity,
      if (unitPrice != null) 'unit_price': unitPrice,
      if (discount != null) 'discount': discount,
      if (position != null) 'position': position,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OrderItemsCompanion copyWith(
      {Value<String>? id,
      Value<String>? orderId,
      Value<String>? productId,
      Value<String>? variantId,
      Value<String>? productName,
      Value<String>? variantLabel,
      Value<String>? sku,
      Value<int>? quantity,
      Value<double>? unitPrice,
      Value<double>? discount,
      Value<int>? position,
      Value<int>? rowid}) {
    return OrderItemsCompanion(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      productId: productId ?? this.productId,
      variantId: variantId ?? this.variantId,
      productName: productName ?? this.productName,
      variantLabel: variantLabel ?? this.variantLabel,
      sku: sku ?? this.sku,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      discount: discount ?? this.discount,
      position: position ?? this.position,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (orderId.present) {
      map['order_id'] = Variable<String>(orderId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (variantId.present) {
      map['variant_id'] = Variable<String>(variantId.value);
    }
    if (productName.present) {
      map['product_name'] = Variable<String>(productName.value);
    }
    if (variantLabel.present) {
      map['variant_label'] = Variable<String>(variantLabel.value);
    }
    if (sku.present) {
      map['sku'] = Variable<String>(sku.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (unitPrice.present) {
      map['unit_price'] = Variable<double>(unitPrice.value);
    }
    if (discount.present) {
      map['discount'] = Variable<double>(discount.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OrderItemsCompanion(')
          ..write('id: $id, ')
          ..write('orderId: $orderId, ')
          ..write('productId: $productId, ')
          ..write('variantId: $variantId, ')
          ..write('productName: $productName, ')
          ..write('variantLabel: $variantLabel, ')
          ..write('sku: $sku, ')
          ..write('quantity: $quantity, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('discount: $discount, ')
          ..write('position: $position, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OrderStatusEntriesTable extends OrderStatusEntries
    with TableInfo<$OrderStatusEntriesTable, OrderStatusRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OrderStatusEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _orderIdMeta =
      const VerificationMeta('orderId');
  @override
  late final GeneratedColumn<String> orderId = GeneratedColumn<String>(
      'order_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _positionMeta =
      const VerificationMeta('position');
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
      'position', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _changedAtMeta =
      const VerificationMeta('changedAt');
  @override
  late final GeneratedColumn<DateTime> changedAt = GeneratedColumn<DateTime>(
      'changed_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _byUserIdMeta =
      const VerificationMeta('byUserId');
  @override
  late final GeneratedColumn<String> byUserId = GeneratedColumn<String>(
      'by_user_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _byNameMeta = const VerificationMeta('byName');
  @override
  late final GeneratedColumn<String> byName = GeneratedColumn<String>(
      'by_name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  @override
  List<GeneratedColumn> get $columns =>
      [orderId, position, status, changedAt, byUserId, byName];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'order_status_entries';
  @override
  VerificationContext validateIntegrity(Insertable<OrderStatusRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('order_id')) {
      context.handle(_orderIdMeta,
          orderId.isAcceptableOrUnknown(data['order_id']!, _orderIdMeta));
    } else if (isInserting) {
      context.missing(_orderIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(_positionMeta,
          position.isAcceptableOrUnknown(data['position']!, _positionMeta));
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('changed_at')) {
      context.handle(_changedAtMeta,
          changedAt.isAcceptableOrUnknown(data['changed_at']!, _changedAtMeta));
    } else if (isInserting) {
      context.missing(_changedAtMeta);
    }
    if (data.containsKey('by_user_id')) {
      context.handle(_byUserIdMeta,
          byUserId.isAcceptableOrUnknown(data['by_user_id']!, _byUserIdMeta));
    }
    if (data.containsKey('by_name')) {
      context.handle(_byNameMeta,
          byName.isAcceptableOrUnknown(data['by_name']!, _byNameMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {orderId, position};
  @override
  OrderStatusRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OrderStatusRow(
      orderId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}order_id'])!,
      position: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}position'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      changedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}changed_at'])!,
      byUserId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}by_user_id'])!,
      byName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}by_name'])!,
    );
  }

  @override
  $OrderStatusEntriesTable createAlias(String alias) {
    return $OrderStatusEntriesTable(attachedDatabase, alias);
  }
}

class OrderStatusRow extends DataClass implements Insertable<OrderStatusRow> {
  final String orderId;
  final int position;
  final String status;
  final DateTime changedAt;
  final String byUserId;
  final String byName;
  const OrderStatusRow(
      {required this.orderId,
      required this.position,
      required this.status,
      required this.changedAt,
      required this.byUserId,
      required this.byName});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['order_id'] = Variable<String>(orderId);
    map['position'] = Variable<int>(position);
    map['status'] = Variable<String>(status);
    map['changed_at'] = Variable<DateTime>(changedAt);
    map['by_user_id'] = Variable<String>(byUserId);
    map['by_name'] = Variable<String>(byName);
    return map;
  }

  OrderStatusEntriesCompanion toCompanion(bool nullToAbsent) {
    return OrderStatusEntriesCompanion(
      orderId: Value(orderId),
      position: Value(position),
      status: Value(status),
      changedAt: Value(changedAt),
      byUserId: Value(byUserId),
      byName: Value(byName),
    );
  }

  factory OrderStatusRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OrderStatusRow(
      orderId: serializer.fromJson<String>(json['orderId']),
      position: serializer.fromJson<int>(json['position']),
      status: serializer.fromJson<String>(json['status']),
      changedAt: serializer.fromJson<DateTime>(json['changedAt']),
      byUserId: serializer.fromJson<String>(json['byUserId']),
      byName: serializer.fromJson<String>(json['byName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'orderId': serializer.toJson<String>(orderId),
      'position': serializer.toJson<int>(position),
      'status': serializer.toJson<String>(status),
      'changedAt': serializer.toJson<DateTime>(changedAt),
      'byUserId': serializer.toJson<String>(byUserId),
      'byName': serializer.toJson<String>(byName),
    };
  }

  OrderStatusRow copyWith(
          {String? orderId,
          int? position,
          String? status,
          DateTime? changedAt,
          String? byUserId,
          String? byName}) =>
      OrderStatusRow(
        orderId: orderId ?? this.orderId,
        position: position ?? this.position,
        status: status ?? this.status,
        changedAt: changedAt ?? this.changedAt,
        byUserId: byUserId ?? this.byUserId,
        byName: byName ?? this.byName,
      );
  OrderStatusRow copyWithCompanion(OrderStatusEntriesCompanion data) {
    return OrderStatusRow(
      orderId: data.orderId.present ? data.orderId.value : this.orderId,
      position: data.position.present ? data.position.value : this.position,
      status: data.status.present ? data.status.value : this.status,
      changedAt: data.changedAt.present ? data.changedAt.value : this.changedAt,
      byUserId: data.byUserId.present ? data.byUserId.value : this.byUserId,
      byName: data.byName.present ? data.byName.value : this.byName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OrderStatusRow(')
          ..write('orderId: $orderId, ')
          ..write('position: $position, ')
          ..write('status: $status, ')
          ..write('changedAt: $changedAt, ')
          ..write('byUserId: $byUserId, ')
          ..write('byName: $byName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(orderId, position, status, changedAt, byUserId, byName);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OrderStatusRow &&
          other.orderId == this.orderId &&
          other.position == this.position &&
          other.status == this.status &&
          other.changedAt == this.changedAt &&
          other.byUserId == this.byUserId &&
          other.byName == this.byName);
}

class OrderStatusEntriesCompanion extends UpdateCompanion<OrderStatusRow> {
  final Value<String> orderId;
  final Value<int> position;
  final Value<String> status;
  final Value<DateTime> changedAt;
  final Value<String> byUserId;
  final Value<String> byName;
  final Value<int> rowid;
  const OrderStatusEntriesCompanion({
    this.orderId = const Value.absent(),
    this.position = const Value.absent(),
    this.status = const Value.absent(),
    this.changedAt = const Value.absent(),
    this.byUserId = const Value.absent(),
    this.byName = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OrderStatusEntriesCompanion.insert({
    required String orderId,
    required int position,
    required String status,
    required DateTime changedAt,
    this.byUserId = const Value.absent(),
    this.byName = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : orderId = Value(orderId),
        position = Value(position),
        status = Value(status),
        changedAt = Value(changedAt);
  static Insertable<OrderStatusRow> custom({
    Expression<String>? orderId,
    Expression<int>? position,
    Expression<String>? status,
    Expression<DateTime>? changedAt,
    Expression<String>? byUserId,
    Expression<String>? byName,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (orderId != null) 'order_id': orderId,
      if (position != null) 'position': position,
      if (status != null) 'status': status,
      if (changedAt != null) 'changed_at': changedAt,
      if (byUserId != null) 'by_user_id': byUserId,
      if (byName != null) 'by_name': byName,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OrderStatusEntriesCompanion copyWith(
      {Value<String>? orderId,
      Value<int>? position,
      Value<String>? status,
      Value<DateTime>? changedAt,
      Value<String>? byUserId,
      Value<String>? byName,
      Value<int>? rowid}) {
    return OrderStatusEntriesCompanion(
      orderId: orderId ?? this.orderId,
      position: position ?? this.position,
      status: status ?? this.status,
      changedAt: changedAt ?? this.changedAt,
      byUserId: byUserId ?? this.byUserId,
      byName: byName ?? this.byName,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (orderId.present) {
      map['order_id'] = Variable<String>(orderId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (changedAt.present) {
      map['changed_at'] = Variable<DateTime>(changedAt.value);
    }
    if (byUserId.present) {
      map['by_user_id'] = Variable<String>(byUserId.value);
    }
    if (byName.present) {
      map['by_name'] = Variable<String>(byName.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OrderStatusEntriesCompanion(')
          ..write('orderId: $orderId, ')
          ..write('position: $position, ')
          ..write('status: $status, ')
          ..write('changedAt: $changedAt, ')
          ..write('byUserId: $byUserId, ')
          ..write('byName: $byName, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OutboxTable extends Outbox with TableInfo<$OutboxTable, OutboxRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutboxTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _seqMeta = const VerificationMeta('seq');
  @override
  late final GeneratedColumn<int> seq = GeneratedColumn<int>(
      'seq', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _opIdMeta = const VerificationMeta('opId');
  @override
  late final GeneratedColumn<String> opId = GeneratedColumn<String>(
      'op_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
      'kind', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _collectionMeta =
      const VerificationMeta('collection');
  @override
  late final GeneratedColumn<String> collection = GeneratedColumn<String>(
      'collection', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityIdMeta =
      const VerificationMeta('entityId');
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
      'entity_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
      'label', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isNewMeta = const VerificationMeta('isNew');
  @override
  late final GeneratedColumn<bool> isNew = GeneratedColumn<bool>(
      'is_new', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_new" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _payloadMeta =
      const VerificationMeta('payload');
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
      'payload', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
      'state', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _errorMeta = const VerificationMeta('error');
  @override
  late final GeneratedColumn<String> error = GeneratedColumn<String>(
      'error', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _attemptsMeta =
      const VerificationMeta('attempts');
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
      'attempts', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        seq,
        opId,
        kind,
        collection,
        entityId,
        label,
        isNew,
        payload,
        state,
        error,
        attempts,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outbox';
  @override
  VerificationContext validateIntegrity(Insertable<OutboxRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('seq')) {
      context.handle(
          _seqMeta, seq.isAcceptableOrUnknown(data['seq']!, _seqMeta));
    }
    if (data.containsKey('op_id')) {
      context.handle(
          _opIdMeta, opId.isAcceptableOrUnknown(data['op_id']!, _opIdMeta));
    } else if (isInserting) {
      context.missing(_opIdMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
          _kindMeta, kind.isAcceptableOrUnknown(data['kind']!, _kindMeta));
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('collection')) {
      context.handle(
          _collectionMeta,
          collection.isAcceptableOrUnknown(
              data['collection']!, _collectionMeta));
    } else if (isInserting) {
      context.missing(_collectionMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(_entityIdMeta,
          entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta));
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
          _labelMeta, label.isAcceptableOrUnknown(data['label']!, _labelMeta));
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('is_new')) {
      context.handle(
          _isNewMeta, isNew.isAcceptableOrUnknown(data['is_new']!, _isNewMeta));
    }
    if (data.containsKey('payload')) {
      context.handle(_payloadMeta,
          payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta));
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
          _stateMeta, state.isAcceptableOrUnknown(data['state']!, _stateMeta));
    }
    if (data.containsKey('error')) {
      context.handle(
          _errorMeta, error.isAcceptableOrUnknown(data['error']!, _errorMeta));
    }
    if (data.containsKey('attempts')) {
      context.handle(_attemptsMeta,
          attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {seq};
  @override
  OutboxRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboxRow(
      seq: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}seq'])!,
      opId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}op_id'])!,
      kind: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}kind'])!,
      collection: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}collection'])!,
      entityId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_id'])!,
      label: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}label'])!,
      isNew: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_new'])!,
      payload: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload'])!,
      state: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}state'])!,
      error: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}error'])!,
      attempts: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}attempts'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $OutboxTable createAlias(String alias) {
    return $OutboxTable(attachedDatabase, alias);
  }
}

class OutboxRow extends DataClass implements Insertable<OutboxRow> {
  /// Upload order. Entries are sent oldest first because later ones can depend
  /// on earlier ones (an order for a customer created a moment before).
  final int seq;

  /// Sent as the Idempotency-Key, so a retry after a dropped connection cannot
  /// do the action twice.
  final String opId;

  /// upsert, delete, order_confirm, order_status, order_cancel, order_payment,
  /// purchase_confirm, purchase_payment, ledger_entry, audit_confirm.
  final String kind;
  final String collection;
  final String entityId;

  /// Short readable text for the sync screen, such as "Order ORD-20261114-AB12".
  final String label;

  /// For upserts: true when the record did not exist on the server yet.
  final bool isNew;
  final String payload;

  /// pending: waiting to be uploaded. failed: the server refused it (see [error]).
  final String state;
  final String error;
  final int attempts;
  final DateTime createdAt;
  const OutboxRow(
      {required this.seq,
      required this.opId,
      required this.kind,
      required this.collection,
      required this.entityId,
      required this.label,
      required this.isNew,
      required this.payload,
      required this.state,
      required this.error,
      required this.attempts,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['seq'] = Variable<int>(seq);
    map['op_id'] = Variable<String>(opId);
    map['kind'] = Variable<String>(kind);
    map['collection'] = Variable<String>(collection);
    map['entity_id'] = Variable<String>(entityId);
    map['label'] = Variable<String>(label);
    map['is_new'] = Variable<bool>(isNew);
    map['payload'] = Variable<String>(payload);
    map['state'] = Variable<String>(state);
    map['error'] = Variable<String>(error);
    map['attempts'] = Variable<int>(attempts);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  OutboxCompanion toCompanion(bool nullToAbsent) {
    return OutboxCompanion(
      seq: Value(seq),
      opId: Value(opId),
      kind: Value(kind),
      collection: Value(collection),
      entityId: Value(entityId),
      label: Value(label),
      isNew: Value(isNew),
      payload: Value(payload),
      state: Value(state),
      error: Value(error),
      attempts: Value(attempts),
      createdAt: Value(createdAt),
    );
  }

  factory OutboxRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboxRow(
      seq: serializer.fromJson<int>(json['seq']),
      opId: serializer.fromJson<String>(json['opId']),
      kind: serializer.fromJson<String>(json['kind']),
      collection: serializer.fromJson<String>(json['collection']),
      entityId: serializer.fromJson<String>(json['entityId']),
      label: serializer.fromJson<String>(json['label']),
      isNew: serializer.fromJson<bool>(json['isNew']),
      payload: serializer.fromJson<String>(json['payload']),
      state: serializer.fromJson<String>(json['state']),
      error: serializer.fromJson<String>(json['error']),
      attempts: serializer.fromJson<int>(json['attempts']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'seq': serializer.toJson<int>(seq),
      'opId': serializer.toJson<String>(opId),
      'kind': serializer.toJson<String>(kind),
      'collection': serializer.toJson<String>(collection),
      'entityId': serializer.toJson<String>(entityId),
      'label': serializer.toJson<String>(label),
      'isNew': serializer.toJson<bool>(isNew),
      'payload': serializer.toJson<String>(payload),
      'state': serializer.toJson<String>(state),
      'error': serializer.toJson<String>(error),
      'attempts': serializer.toJson<int>(attempts),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  OutboxRow copyWith(
          {int? seq,
          String? opId,
          String? kind,
          String? collection,
          String? entityId,
          String? label,
          bool? isNew,
          String? payload,
          String? state,
          String? error,
          int? attempts,
          DateTime? createdAt}) =>
      OutboxRow(
        seq: seq ?? this.seq,
        opId: opId ?? this.opId,
        kind: kind ?? this.kind,
        collection: collection ?? this.collection,
        entityId: entityId ?? this.entityId,
        label: label ?? this.label,
        isNew: isNew ?? this.isNew,
        payload: payload ?? this.payload,
        state: state ?? this.state,
        error: error ?? this.error,
        attempts: attempts ?? this.attempts,
        createdAt: createdAt ?? this.createdAt,
      );
  OutboxRow copyWithCompanion(OutboxCompanion data) {
    return OutboxRow(
      seq: data.seq.present ? data.seq.value : this.seq,
      opId: data.opId.present ? data.opId.value : this.opId,
      kind: data.kind.present ? data.kind.value : this.kind,
      collection:
          data.collection.present ? data.collection.value : this.collection,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      label: data.label.present ? data.label.value : this.label,
      isNew: data.isNew.present ? data.isNew.value : this.isNew,
      payload: data.payload.present ? data.payload.value : this.payload,
      state: data.state.present ? data.state.value : this.state,
      error: data.error.present ? data.error.value : this.error,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboxRow(')
          ..write('seq: $seq, ')
          ..write('opId: $opId, ')
          ..write('kind: $kind, ')
          ..write('collection: $collection, ')
          ..write('entityId: $entityId, ')
          ..write('label: $label, ')
          ..write('isNew: $isNew, ')
          ..write('payload: $payload, ')
          ..write('state: $state, ')
          ..write('error: $error, ')
          ..write('attempts: $attempts, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(seq, opId, kind, collection, entityId, label,
      isNew, payload, state, error, attempts, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboxRow &&
          other.seq == this.seq &&
          other.opId == this.opId &&
          other.kind == this.kind &&
          other.collection == this.collection &&
          other.entityId == this.entityId &&
          other.label == this.label &&
          other.isNew == this.isNew &&
          other.payload == this.payload &&
          other.state == this.state &&
          other.error == this.error &&
          other.attempts == this.attempts &&
          other.createdAt == this.createdAt);
}

class OutboxCompanion extends UpdateCompanion<OutboxRow> {
  final Value<int> seq;
  final Value<String> opId;
  final Value<String> kind;
  final Value<String> collection;
  final Value<String> entityId;
  final Value<String> label;
  final Value<bool> isNew;
  final Value<String> payload;
  final Value<String> state;
  final Value<String> error;
  final Value<int> attempts;
  final Value<DateTime> createdAt;
  const OutboxCompanion({
    this.seq = const Value.absent(),
    this.opId = const Value.absent(),
    this.kind = const Value.absent(),
    this.collection = const Value.absent(),
    this.entityId = const Value.absent(),
    this.label = const Value.absent(),
    this.isNew = const Value.absent(),
    this.payload = const Value.absent(),
    this.state = const Value.absent(),
    this.error = const Value.absent(),
    this.attempts = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  OutboxCompanion.insert({
    this.seq = const Value.absent(),
    required String opId,
    required String kind,
    required String collection,
    required String entityId,
    required String label,
    this.isNew = const Value.absent(),
    required String payload,
    this.state = const Value.absent(),
    this.error = const Value.absent(),
    this.attempts = const Value.absent(),
    required DateTime createdAt,
  })  : opId = Value(opId),
        kind = Value(kind),
        collection = Value(collection),
        entityId = Value(entityId),
        label = Value(label),
        payload = Value(payload),
        createdAt = Value(createdAt);
  static Insertable<OutboxRow> custom({
    Expression<int>? seq,
    Expression<String>? opId,
    Expression<String>? kind,
    Expression<String>? collection,
    Expression<String>? entityId,
    Expression<String>? label,
    Expression<bool>? isNew,
    Expression<String>? payload,
    Expression<String>? state,
    Expression<String>? error,
    Expression<int>? attempts,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (seq != null) 'seq': seq,
      if (opId != null) 'op_id': opId,
      if (kind != null) 'kind': kind,
      if (collection != null) 'collection': collection,
      if (entityId != null) 'entity_id': entityId,
      if (label != null) 'label': label,
      if (isNew != null) 'is_new': isNew,
      if (payload != null) 'payload': payload,
      if (state != null) 'state': state,
      if (error != null) 'error': error,
      if (attempts != null) 'attempts': attempts,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  OutboxCompanion copyWith(
      {Value<int>? seq,
      Value<String>? opId,
      Value<String>? kind,
      Value<String>? collection,
      Value<String>? entityId,
      Value<String>? label,
      Value<bool>? isNew,
      Value<String>? payload,
      Value<String>? state,
      Value<String>? error,
      Value<int>? attempts,
      Value<DateTime>? createdAt}) {
    return OutboxCompanion(
      seq: seq ?? this.seq,
      opId: opId ?? this.opId,
      kind: kind ?? this.kind,
      collection: collection ?? this.collection,
      entityId: entityId ?? this.entityId,
      label: label ?? this.label,
      isNew: isNew ?? this.isNew,
      payload: payload ?? this.payload,
      state: state ?? this.state,
      error: error ?? this.error,
      attempts: attempts ?? this.attempts,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (seq.present) {
      map['seq'] = Variable<int>(seq.value);
    }
    if (opId.present) {
      map['op_id'] = Variable<String>(opId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (collection.present) {
      map['collection'] = Variable<String>(collection.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (isNew.present) {
      map['is_new'] = Variable<bool>(isNew.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (error.present) {
      map['error'] = Variable<String>(error.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutboxCompanion(')
          ..write('seq: $seq, ')
          ..write('opId: $opId, ')
          ..write('kind: $kind, ')
          ..write('collection: $collection, ')
          ..write('entityId: $entityId, ')
          ..write('label: $label, ')
          ..write('isNew: $isNew, ')
          ..write('payload: $payload, ')
          ..write('state: $state, ')
          ..write('error: $error, ')
          ..write('attempts: $attempts, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $SyncKvTable extends SyncKv with TableInfo<$SyncKvTable, SyncKvRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncKvTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_kv';
  @override
  VerificationContext validateIntegrity(Insertable<SyncKvRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SyncKvRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncKvRow(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
    );
  }

  @override
  $SyncKvTable createAlias(String alias) {
    return $SyncKvTable(attachedDatabase, alias);
  }
}

class SyncKvRow extends DataClass implements Insertable<SyncKvRow> {
  final String key;
  final String value;
  const SyncKvRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SyncKvCompanion toCompanion(bool nullToAbsent) {
    return SyncKvCompanion(
      key: Value(key),
      value: Value(value),
    );
  }

  factory SyncKvRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncKvRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  SyncKvRow copyWith({String? key, String? value}) => SyncKvRow(
        key: key ?? this.key,
        value: value ?? this.value,
      );
  SyncKvRow copyWithCompanion(SyncKvCompanion data) {
    return SyncKvRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncKvRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncKvRow &&
          other.key == this.key &&
          other.value == this.value);
}

class SyncKvCompanion extends UpdateCompanion<SyncKvRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SyncKvCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncKvCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  })  : key = Value(key),
        value = Value(value);
  static Insertable<SyncKvRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncKvCompanion copyWith(
      {Value<String>? key, Value<String>? value, Value<int>? rowid}) {
    return SyncKvCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncKvCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UsersTable users = $UsersTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $ProductsTable products = $ProductsTable(this);
  late final $ProductVariantsTable productVariants =
      $ProductVariantsTable(this);
  late final $VendorsTable vendors = $VendorsTable(this);
  late final $CustomersTable customers = $CustomersTable(this);
  late final $LedgerEntriesTable ledgerEntries = $LedgerEntriesTable(this);
  late final $PurchasesTable purchases = $PurchasesTable(this);
  late final $PurchaseItemsTable purchaseItems = $PurchaseItemsTable(this);
  late final $StockMovementsTable stockMovements = $StockMovementsTable(this);
  late final $StockAuditsTable stockAudits = $StockAuditsTable(this);
  late final $StockAuditItemsTable stockAuditItems =
      $StockAuditItemsTable(this);
  late final $OrdersTable orders = $OrdersTable(this);
  late final $OrderItemsTable orderItems = $OrderItemsTable(this);
  late final $OrderStatusEntriesTable orderStatusEntries =
      $OrderStatusEntriesTable(this);
  late final $OutboxTable outbox = $OutboxTable(this);
  late final $SyncKvTable syncKv = $SyncKvTable(this);
  late final Index productsCategory = Index('products_category',
      'CREATE INDEX products_category ON products (category_id)');
  late final Index variantsProduct = Index('variants_product',
      'CREATE INDEX variants_product ON product_variants (product_id)');
  late final Index variantsSku = Index(
      'variants_sku', 'CREATE INDEX variants_sku ON product_variants (sku)');
  late final Index ledgerParty = Index(
      'ledger_party', 'CREATE INDEX ledger_party ON ledger_entries (party_id)');
  late final Index ledgerPurchase = Index('ledger_purchase',
      'CREATE INDEX ledger_purchase ON ledger_entries (purchase_id)');
  late final Index ledgerOrder = Index(
      'ledger_order', 'CREATE INDEX ledger_order ON ledger_entries (order_id)');
  late final Index purchasesVendor = Index('purchases_vendor',
      'CREATE INDEX purchases_vendor ON purchases (vendor_id)');
  late final Index purchaseItemsPurchase = Index('purchase_items_purchase',
      'CREATE INDEX purchase_items_purchase ON purchase_items (purchase_id)');
  late final Index movementsVariant = Index('movements_variant',
      'CREATE INDEX movements_variant ON stock_movements (variant_id)');
  late final Index movementsSource = Index('movements_source',
      'CREATE INDEX movements_source ON stock_movements (source_id)');
  late final Index ordersCustomer = Index('orders_customer',
      'CREATE INDEX orders_customer ON orders (customer_id)');
  late final Index ordersDate =
      Index('orders_date', 'CREATE INDEX orders_date ON orders (order_date)');
  late final Index orderItemsOrder = Index('order_items_order',
      'CREATE INDEX order_items_order ON order_items (order_id)');
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        users,
        categories,
        products,
        productVariants,
        vendors,
        customers,
        ledgerEntries,
        purchases,
        purchaseItems,
        stockMovements,
        stockAudits,
        stockAuditItems,
        orders,
        orderItems,
        orderStatusEntries,
        outbox,
        syncKv,
        productsCategory,
        variantsProduct,
        variantsSku,
        ledgerParty,
        ledgerPurchase,
        ledgerOrder,
        purchasesVendor,
        purchaseItemsPurchase,
        movementsVariant,
        movementsSource,
        ordersCustomer,
        ordersDate,
        orderItemsOrder
      ];
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$UsersTableCreateCompanionBuilder = UsersCompanion Function({
  required String id,
  required String email,
  Value<String> displayName,
  Value<String> phoneNumber,
  Value<String> role,
  Value<bool> isActive,
  Value<String> photoUrl,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$UsersTableUpdateCompanionBuilder = UsersCompanion Function({
  Value<String> id,
  Value<String> email,
  Value<String> displayName,
  Value<String> phoneNumber,
  Value<String> role,
  Value<bool> isActive,
  Value<String> photoUrl,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phoneNumber => $composableBuilder(
      column: $table.phoneNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get photoUrl => $composableBuilder(
      column: $table.photoUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$UsersTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phoneNumber => $composableBuilder(
      column: $table.phoneNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get photoUrl => $composableBuilder(
      column: $table.photoUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$UsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => column);

  GeneratedColumn<String> get phoneNumber => $composableBuilder(
      column: $table.phoneNumber, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get photoUrl =>
      $composableBuilder(column: $table.photoUrl, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$UsersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UsersTable,
    UserRow,
    $$UsersTableFilterComposer,
    $$UsersTableOrderingComposer,
    $$UsersTableAnnotationComposer,
    $$UsersTableCreateCompanionBuilder,
    $$UsersTableUpdateCompanionBuilder,
    (UserRow, BaseReferences<_$AppDatabase, $UsersTable, UserRow>),
    UserRow,
    PrefetchHooks Function()> {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> email = const Value.absent(),
            Value<String> displayName = const Value.absent(),
            Value<String> phoneNumber = const Value.absent(),
            Value<String> role = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<String> photoUrl = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UsersCompanion(
            id: id,
            email: email,
            displayName: displayName,
            phoneNumber: phoneNumber,
            role: role,
            isActive: isActive,
            photoUrl: photoUrl,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String email,
            Value<String> displayName = const Value.absent(),
            Value<String> phoneNumber = const Value.absent(),
            Value<String> role = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<String> photoUrl = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              UsersCompanion.insert(
            id: id,
            email: email,
            displayName: displayName,
            phoneNumber: phoneNumber,
            role: role,
            isActive: isActive,
            photoUrl: photoUrl,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$UsersTable, UserRow>(table),
                    BaseReferences<_$AppDatabase, $UsersTable, UserRow>(
                        db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$UsersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UsersTable,
    UserRow,
    $$UsersTableFilterComposer,
    $$UsersTableOrderingComposer,
    $$UsersTableAnnotationComposer,
    $$UsersTableCreateCompanionBuilder,
    $$UsersTableUpdateCompanionBuilder,
    (UserRow, BaseReferences<_$AppDatabase, $UsersTable, UserRow>),
    UserRow,
    PrefetchHooks Function()>;
typedef $$CategoriesTableCreateCompanionBuilder = CategoriesCompanion Function({
  required String id,
  required String name,
  Value<String> parentId,
  Value<String> description,
  Value<bool> isActive,
  Value<String> photoUrl,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$CategoriesTableUpdateCompanionBuilder = CategoriesCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> parentId,
  Value<String> description,
  Value<bool> isActive,
  Value<String> photoUrl,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get parentId => $composableBuilder(
      column: $table.parentId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get photoUrl => $composableBuilder(
      column: $table.photoUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get parentId => $composableBuilder(
      column: $table.parentId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get photoUrl => $composableBuilder(
      column: $table.photoUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get parentId =>
      $composableBuilder(column: $table.parentId, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get photoUrl =>
      $composableBuilder(column: $table.photoUrl, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CategoriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CategoriesTable,
    CategoryRow,
    $$CategoriesTableFilterComposer,
    $$CategoriesTableOrderingComposer,
    $$CategoriesTableAnnotationComposer,
    $$CategoriesTableCreateCompanionBuilder,
    $$CategoriesTableUpdateCompanionBuilder,
    (CategoryRow, BaseReferences<_$AppDatabase, $CategoriesTable, CategoryRow>),
    CategoryRow,
    PrefetchHooks Function()> {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> parentId = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<String> photoUrl = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CategoriesCompanion(
            id: id,
            name: name,
            parentId: parentId,
            description: description,
            isActive: isActive,
            photoUrl: photoUrl,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String> parentId = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<String> photoUrl = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              CategoriesCompanion.insert(
            id: id,
            name: name,
            parentId: parentId,
            description: description,
            isActive: isActive,
            photoUrl: photoUrl,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$CategoriesTable, CategoryRow>(table),
                    BaseReferences<_$AppDatabase, $CategoriesTable,
                        CategoryRow>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CategoriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CategoriesTable,
    CategoryRow,
    $$CategoriesTableFilterComposer,
    $$CategoriesTableOrderingComposer,
    $$CategoriesTableAnnotationComposer,
    $$CategoriesTableCreateCompanionBuilder,
    $$CategoriesTableUpdateCompanionBuilder,
    (CategoryRow, BaseReferences<_$AppDatabase, $CategoriesTable, CategoryRow>),
    CategoryRow,
    PrefetchHooks Function()>;
typedef $$ProductsTableCreateCompanionBuilder = ProductsCompanion Function({
  required String id,
  required String name,
  required String categoryId,
  Value<String> brand,
  Value<String> description,
  Value<bool> isActive,
  Value<String> imagesJson,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$ProductsTableUpdateCompanionBuilder = ProductsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> categoryId,
  Value<String> brand,
  Value<String> description,
  Value<bool> isActive,
  Value<String> imagesJson,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$ProductsTableFilterComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get brand => $composableBuilder(
      column: $table.brand, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imagesJson => $composableBuilder(
      column: $table.imagesJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$ProductsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get brand => $composableBuilder(
      column: $table.brand, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imagesJson => $composableBuilder(
      column: $table.imagesJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$ProductsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => column);

  GeneratedColumn<String> get brand =>
      $composableBuilder(column: $table.brand, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get imagesJson => $composableBuilder(
      column: $table.imagesJson, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ProductsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ProductsTable,
    ProductRow,
    $$ProductsTableFilterComposer,
    $$ProductsTableOrderingComposer,
    $$ProductsTableAnnotationComposer,
    $$ProductsTableCreateCompanionBuilder,
    $$ProductsTableUpdateCompanionBuilder,
    (ProductRow, BaseReferences<_$AppDatabase, $ProductsTable, ProductRow>),
    ProductRow,
    PrefetchHooks Function()> {
  $$ProductsTableTableManager(_$AppDatabase db, $ProductsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> categoryId = const Value.absent(),
            Value<String> brand = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<String> imagesJson = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProductsCompanion(
            id: id,
            name: name,
            categoryId: categoryId,
            brand: brand,
            description: description,
            isActive: isActive,
            imagesJson: imagesJson,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required String categoryId,
            Value<String> brand = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<String> imagesJson = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              ProductsCompanion.insert(
            id: id,
            name: name,
            categoryId: categoryId,
            brand: brand,
            description: description,
            isActive: isActive,
            imagesJson: imagesJson,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$ProductsTable, ProductRow>(table),
                    BaseReferences<_$AppDatabase, $ProductsTable, ProductRow>(
                        db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ProductsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ProductsTable,
    ProductRow,
    $$ProductsTableFilterComposer,
    $$ProductsTableOrderingComposer,
    $$ProductsTableAnnotationComposer,
    $$ProductsTableCreateCompanionBuilder,
    $$ProductsTableUpdateCompanionBuilder,
    (ProductRow, BaseReferences<_$AppDatabase, $ProductsTable, ProductRow>),
    ProductRow,
    PrefetchHooks Function()>;
typedef $$ProductVariantsTableCreateCompanionBuilder = ProductVariantsCompanion
    Function({
  required String id,
  required String productId,
  required String sku,
  Value<String> name,
  Value<String> barcode,
  Value<String> attributesJson,
  Value<double> costPrice,
  Value<double> salePrice,
  Value<bool> isWholesale,
  Value<double> wholesalePrice,
  Value<int> alertThreshold,
  Value<bool> isActive,
  Value<int> position,
  Value<int> rowid,
});
typedef $$ProductVariantsTableUpdateCompanionBuilder = ProductVariantsCompanion
    Function({
  Value<String> id,
  Value<String> productId,
  Value<String> sku,
  Value<String> name,
  Value<String> barcode,
  Value<String> attributesJson,
  Value<double> costPrice,
  Value<double> salePrice,
  Value<bool> isWholesale,
  Value<double> wholesalePrice,
  Value<int> alertThreshold,
  Value<bool> isActive,
  Value<int> position,
  Value<int> rowid,
});

class $$ProductVariantsTableFilterComposer
    extends Composer<_$AppDatabase, $ProductVariantsTable> {
  $$ProductVariantsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get productId => $composableBuilder(
      column: $table.productId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sku => $composableBuilder(
      column: $table.sku, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get barcode => $composableBuilder(
      column: $table.barcode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get attributesJson => $composableBuilder(
      column: $table.attributesJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get costPrice => $composableBuilder(
      column: $table.costPrice, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get salePrice => $composableBuilder(
      column: $table.salePrice, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isWholesale => $composableBuilder(
      column: $table.isWholesale, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get wholesalePrice => $composableBuilder(
      column: $table.wholesalePrice,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get alertThreshold => $composableBuilder(
      column: $table.alertThreshold,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get position => $composableBuilder(
      column: $table.position, builder: (column) => ColumnFilters(column));
}

class $$ProductVariantsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductVariantsTable> {
  $$ProductVariantsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get productId => $composableBuilder(
      column: $table.productId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sku => $composableBuilder(
      column: $table.sku, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get barcode => $composableBuilder(
      column: $table.barcode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get attributesJson => $composableBuilder(
      column: $table.attributesJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get costPrice => $composableBuilder(
      column: $table.costPrice, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get salePrice => $composableBuilder(
      column: $table.salePrice, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isWholesale => $composableBuilder(
      column: $table.isWholesale, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get wholesalePrice => $composableBuilder(
      column: $table.wholesalePrice,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get alertThreshold => $composableBuilder(
      column: $table.alertThreshold,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get position => $composableBuilder(
      column: $table.position, builder: (column) => ColumnOrderings(column));
}

class $$ProductVariantsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductVariantsTable> {
  $$ProductVariantsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<String> get sku =>
      $composableBuilder(column: $table.sku, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get barcode =>
      $composableBuilder(column: $table.barcode, builder: (column) => column);

  GeneratedColumn<String> get attributesJson => $composableBuilder(
      column: $table.attributesJson, builder: (column) => column);

  GeneratedColumn<double> get costPrice =>
      $composableBuilder(column: $table.costPrice, builder: (column) => column);

  GeneratedColumn<double> get salePrice =>
      $composableBuilder(column: $table.salePrice, builder: (column) => column);

  GeneratedColumn<bool> get isWholesale => $composableBuilder(
      column: $table.isWholesale, builder: (column) => column);

  GeneratedColumn<double> get wholesalePrice => $composableBuilder(
      column: $table.wholesalePrice, builder: (column) => column);

  GeneratedColumn<int> get alertThreshold => $composableBuilder(
      column: $table.alertThreshold, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);
}

class $$ProductVariantsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ProductVariantsTable,
    VariantRow,
    $$ProductVariantsTableFilterComposer,
    $$ProductVariantsTableOrderingComposer,
    $$ProductVariantsTableAnnotationComposer,
    $$ProductVariantsTableCreateCompanionBuilder,
    $$ProductVariantsTableUpdateCompanionBuilder,
    (
      VariantRow,
      BaseReferences<_$AppDatabase, $ProductVariantsTable, VariantRow>
    ),
    VariantRow,
    PrefetchHooks Function()> {
  $$ProductVariantsTableTableManager(
      _$AppDatabase db, $ProductVariantsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductVariantsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductVariantsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductVariantsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> productId = const Value.absent(),
            Value<String> sku = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> barcode = const Value.absent(),
            Value<String> attributesJson = const Value.absent(),
            Value<double> costPrice = const Value.absent(),
            Value<double> salePrice = const Value.absent(),
            Value<bool> isWholesale = const Value.absent(),
            Value<double> wholesalePrice = const Value.absent(),
            Value<int> alertThreshold = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<int> position = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProductVariantsCompanion(
            id: id,
            productId: productId,
            sku: sku,
            name: name,
            barcode: barcode,
            attributesJson: attributesJson,
            costPrice: costPrice,
            salePrice: salePrice,
            isWholesale: isWholesale,
            wholesalePrice: wholesalePrice,
            alertThreshold: alertThreshold,
            isActive: isActive,
            position: position,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String productId,
            required String sku,
            Value<String> name = const Value.absent(),
            Value<String> barcode = const Value.absent(),
            Value<String> attributesJson = const Value.absent(),
            Value<double> costPrice = const Value.absent(),
            Value<double> salePrice = const Value.absent(),
            Value<bool> isWholesale = const Value.absent(),
            Value<double> wholesalePrice = const Value.absent(),
            Value<int> alertThreshold = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<int> position = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProductVariantsCompanion.insert(
            id: id,
            productId: productId,
            sku: sku,
            name: name,
            barcode: barcode,
            attributesJson: attributesJson,
            costPrice: costPrice,
            salePrice: salePrice,
            isWholesale: isWholesale,
            wholesalePrice: wholesalePrice,
            alertThreshold: alertThreshold,
            isActive: isActive,
            position: position,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$ProductVariantsTable, VariantRow>(table),
                    BaseReferences<_$AppDatabase, $ProductVariantsTable,
                        VariantRow>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ProductVariantsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ProductVariantsTable,
    VariantRow,
    $$ProductVariantsTableFilterComposer,
    $$ProductVariantsTableOrderingComposer,
    $$ProductVariantsTableAnnotationComposer,
    $$ProductVariantsTableCreateCompanionBuilder,
    $$ProductVariantsTableUpdateCompanionBuilder,
    (
      VariantRow,
      BaseReferences<_$AppDatabase, $ProductVariantsTable, VariantRow>
    ),
    VariantRow,
    PrefetchHooks Function()>;
typedef $$VendorsTableCreateCompanionBuilder = VendorsCompanion Function({
  required String id,
  required String name,
  Value<String> type,
  Value<String> contactPerson,
  Value<String> phone,
  Value<String> email,
  Value<String> address,
  Value<String> city,
  Value<String> notes,
  Value<double> openingBalance,
  Value<bool> isActive,
  Value<String> photoUrl,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$VendorsTableUpdateCompanionBuilder = VendorsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> type,
  Value<String> contactPerson,
  Value<String> phone,
  Value<String> email,
  Value<String> address,
  Value<String> city,
  Value<String> notes,
  Value<double> openingBalance,
  Value<bool> isActive,
  Value<String> photoUrl,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$VendorsTableFilterComposer
    extends Composer<_$AppDatabase, $VendorsTable> {
  $$VendorsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get contactPerson => $composableBuilder(
      column: $table.contactPerson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get city => $composableBuilder(
      column: $table.city, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get openingBalance => $composableBuilder(
      column: $table.openingBalance,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get photoUrl => $composableBuilder(
      column: $table.photoUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$VendorsTableOrderingComposer
    extends Composer<_$AppDatabase, $VendorsTable> {
  $$VendorsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get contactPerson => $composableBuilder(
      column: $table.contactPerson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get city => $composableBuilder(
      column: $table.city, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get openingBalance => $composableBuilder(
      column: $table.openingBalance,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get photoUrl => $composableBuilder(
      column: $table.photoUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$VendorsTableAnnotationComposer
    extends Composer<_$AppDatabase, $VendorsTable> {
  $$VendorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get contactPerson => $composableBuilder(
      column: $table.contactPerson, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get city =>
      $composableBuilder(column: $table.city, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<double> get openingBalance => $composableBuilder(
      column: $table.openingBalance, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get photoUrl =>
      $composableBuilder(column: $table.photoUrl, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$VendorsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $VendorsTable,
    VendorRow,
    $$VendorsTableFilterComposer,
    $$VendorsTableOrderingComposer,
    $$VendorsTableAnnotationComposer,
    $$VendorsTableCreateCompanionBuilder,
    $$VendorsTableUpdateCompanionBuilder,
    (VendorRow, BaseReferences<_$AppDatabase, $VendorsTable, VendorRow>),
    VendorRow,
    PrefetchHooks Function()> {
  $$VendorsTableTableManager(_$AppDatabase db, $VendorsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VendorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VendorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VendorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> contactPerson = const Value.absent(),
            Value<String> phone = const Value.absent(),
            Value<String> email = const Value.absent(),
            Value<String> address = const Value.absent(),
            Value<String> city = const Value.absent(),
            Value<String> notes = const Value.absent(),
            Value<double> openingBalance = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<String> photoUrl = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              VendorsCompanion(
            id: id,
            name: name,
            type: type,
            contactPerson: contactPerson,
            phone: phone,
            email: email,
            address: address,
            city: city,
            notes: notes,
            openingBalance: openingBalance,
            isActive: isActive,
            photoUrl: photoUrl,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String> type = const Value.absent(),
            Value<String> contactPerson = const Value.absent(),
            Value<String> phone = const Value.absent(),
            Value<String> email = const Value.absent(),
            Value<String> address = const Value.absent(),
            Value<String> city = const Value.absent(),
            Value<String> notes = const Value.absent(),
            Value<double> openingBalance = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<String> photoUrl = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              VendorsCompanion.insert(
            id: id,
            name: name,
            type: type,
            contactPerson: contactPerson,
            phone: phone,
            email: email,
            address: address,
            city: city,
            notes: notes,
            openingBalance: openingBalance,
            isActive: isActive,
            photoUrl: photoUrl,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$VendorsTable, VendorRow>(table),
                    BaseReferences<_$AppDatabase, $VendorsTable, VendorRow>(
                        db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$VendorsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $VendorsTable,
    VendorRow,
    $$VendorsTableFilterComposer,
    $$VendorsTableOrderingComposer,
    $$VendorsTableAnnotationComposer,
    $$VendorsTableCreateCompanionBuilder,
    $$VendorsTableUpdateCompanionBuilder,
    (VendorRow, BaseReferences<_$AppDatabase, $VendorsTable, VendorRow>),
    VendorRow,
    PrefetchHooks Function()>;
typedef $$CustomersTableCreateCompanionBuilder = CustomersCompanion Function({
  required String id,
  required String name,
  Value<String> type,
  Value<String> contactPerson,
  Value<String> phone,
  Value<String> email,
  Value<String> address,
  Value<String> city,
  Value<String> notes,
  Value<double> creditLimit,
  Value<double> openingBalance,
  Value<bool> isActive,
  Value<String> photoUrl,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$CustomersTableUpdateCompanionBuilder = CustomersCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> type,
  Value<String> contactPerson,
  Value<String> phone,
  Value<String> email,
  Value<String> address,
  Value<String> city,
  Value<String> notes,
  Value<double> creditLimit,
  Value<double> openingBalance,
  Value<bool> isActive,
  Value<String> photoUrl,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$CustomersTableFilterComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get contactPerson => $composableBuilder(
      column: $table.contactPerson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get city => $composableBuilder(
      column: $table.city, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get creditLimit => $composableBuilder(
      column: $table.creditLimit, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get openingBalance => $composableBuilder(
      column: $table.openingBalance,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get photoUrl => $composableBuilder(
      column: $table.photoUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$CustomersTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get contactPerson => $composableBuilder(
      column: $table.contactPerson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get city => $composableBuilder(
      column: $table.city, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get creditLimit => $composableBuilder(
      column: $table.creditLimit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get openingBalance => $composableBuilder(
      column: $table.openingBalance,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get photoUrl => $composableBuilder(
      column: $table.photoUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$CustomersTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get contactPerson => $composableBuilder(
      column: $table.contactPerson, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get city =>
      $composableBuilder(column: $table.city, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<double> get creditLimit => $composableBuilder(
      column: $table.creditLimit, builder: (column) => column);

  GeneratedColumn<double> get openingBalance => $composableBuilder(
      column: $table.openingBalance, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get photoUrl =>
      $composableBuilder(column: $table.photoUrl, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CustomersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CustomersTable,
    CustomerRow,
    $$CustomersTableFilterComposer,
    $$CustomersTableOrderingComposer,
    $$CustomersTableAnnotationComposer,
    $$CustomersTableCreateCompanionBuilder,
    $$CustomersTableUpdateCompanionBuilder,
    (CustomerRow, BaseReferences<_$AppDatabase, $CustomersTable, CustomerRow>),
    CustomerRow,
    PrefetchHooks Function()> {
  $$CustomersTableTableManager(_$AppDatabase db, $CustomersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> contactPerson = const Value.absent(),
            Value<String> phone = const Value.absent(),
            Value<String> email = const Value.absent(),
            Value<String> address = const Value.absent(),
            Value<String> city = const Value.absent(),
            Value<String> notes = const Value.absent(),
            Value<double> creditLimit = const Value.absent(),
            Value<double> openingBalance = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<String> photoUrl = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CustomersCompanion(
            id: id,
            name: name,
            type: type,
            contactPerson: contactPerson,
            phone: phone,
            email: email,
            address: address,
            city: city,
            notes: notes,
            creditLimit: creditLimit,
            openingBalance: openingBalance,
            isActive: isActive,
            photoUrl: photoUrl,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String> type = const Value.absent(),
            Value<String> contactPerson = const Value.absent(),
            Value<String> phone = const Value.absent(),
            Value<String> email = const Value.absent(),
            Value<String> address = const Value.absent(),
            Value<String> city = const Value.absent(),
            Value<String> notes = const Value.absent(),
            Value<double> creditLimit = const Value.absent(),
            Value<double> openingBalance = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<String> photoUrl = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              CustomersCompanion.insert(
            id: id,
            name: name,
            type: type,
            contactPerson: contactPerson,
            phone: phone,
            email: email,
            address: address,
            city: city,
            notes: notes,
            creditLimit: creditLimit,
            openingBalance: openingBalance,
            isActive: isActive,
            photoUrl: photoUrl,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$CustomersTable, CustomerRow>(table),
                    BaseReferences<_$AppDatabase, $CustomersTable, CustomerRow>(
                        db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CustomersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CustomersTable,
    CustomerRow,
    $$CustomersTableFilterComposer,
    $$CustomersTableOrderingComposer,
    $$CustomersTableAnnotationComposer,
    $$CustomersTableCreateCompanionBuilder,
    $$CustomersTableUpdateCompanionBuilder,
    (CustomerRow, BaseReferences<_$AppDatabase, $CustomersTable, CustomerRow>),
    CustomerRow,
    PrefetchHooks Function()>;
typedef $$LedgerEntriesTableCreateCompanionBuilder = LedgerEntriesCompanion
    Function({
  required String id,
  required String partyType,
  required String partyId,
  required String entryType,
  required double amount,
  required DateTime entryDate,
  Value<String> description,
  Value<String> reference,
  Value<String> paymentMethod,
  Value<String> paymentRef,
  Value<String> purchaseId,
  Value<String> orderId,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$LedgerEntriesTableUpdateCompanionBuilder = LedgerEntriesCompanion
    Function({
  Value<String> id,
  Value<String> partyType,
  Value<String> partyId,
  Value<String> entryType,
  Value<double> amount,
  Value<DateTime> entryDate,
  Value<String> description,
  Value<String> reference,
  Value<String> paymentMethod,
  Value<String> paymentRef,
  Value<String> purchaseId,
  Value<String> orderId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$LedgerEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $LedgerEntriesTable> {
  $$LedgerEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get partyType => $composableBuilder(
      column: $table.partyType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get partyId => $composableBuilder(
      column: $table.partyId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entryType => $composableBuilder(
      column: $table.entryType, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get entryDate => $composableBuilder(
      column: $table.entryDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reference => $composableBuilder(
      column: $table.reference, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get paymentMethod => $composableBuilder(
      column: $table.paymentMethod, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get paymentRef => $composableBuilder(
      column: $table.paymentRef, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get purchaseId => $composableBuilder(
      column: $table.purchaseId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get orderId => $composableBuilder(
      column: $table.orderId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$LedgerEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $LedgerEntriesTable> {
  $$LedgerEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get partyType => $composableBuilder(
      column: $table.partyType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get partyId => $composableBuilder(
      column: $table.partyId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entryType => $composableBuilder(
      column: $table.entryType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get entryDate => $composableBuilder(
      column: $table.entryDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reference => $composableBuilder(
      column: $table.reference, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get paymentMethod => $composableBuilder(
      column: $table.paymentMethod,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get paymentRef => $composableBuilder(
      column: $table.paymentRef, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get purchaseId => $composableBuilder(
      column: $table.purchaseId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get orderId => $composableBuilder(
      column: $table.orderId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$LedgerEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LedgerEntriesTable> {
  $$LedgerEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get partyType =>
      $composableBuilder(column: $table.partyType, builder: (column) => column);

  GeneratedColumn<String> get partyId =>
      $composableBuilder(column: $table.partyId, builder: (column) => column);

  GeneratedColumn<String> get entryType =>
      $composableBuilder(column: $table.entryType, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<DateTime> get entryDate =>
      $composableBuilder(column: $table.entryDate, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get reference =>
      $composableBuilder(column: $table.reference, builder: (column) => column);

  GeneratedColumn<String> get paymentMethod => $composableBuilder(
      column: $table.paymentMethod, builder: (column) => column);

  GeneratedColumn<String> get paymentRef => $composableBuilder(
      column: $table.paymentRef, builder: (column) => column);

  GeneratedColumn<String> get purchaseId => $composableBuilder(
      column: $table.purchaseId, builder: (column) => column);

  GeneratedColumn<String> get orderId =>
      $composableBuilder(column: $table.orderId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LedgerEntriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LedgerEntriesTable,
    LedgerRow,
    $$LedgerEntriesTableFilterComposer,
    $$LedgerEntriesTableOrderingComposer,
    $$LedgerEntriesTableAnnotationComposer,
    $$LedgerEntriesTableCreateCompanionBuilder,
    $$LedgerEntriesTableUpdateCompanionBuilder,
    (LedgerRow, BaseReferences<_$AppDatabase, $LedgerEntriesTable, LedgerRow>),
    LedgerRow,
    PrefetchHooks Function()> {
  $$LedgerEntriesTableTableManager(_$AppDatabase db, $LedgerEntriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LedgerEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LedgerEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LedgerEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> partyType = const Value.absent(),
            Value<String> partyId = const Value.absent(),
            Value<String> entryType = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<DateTime> entryDate = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<String> reference = const Value.absent(),
            Value<String> paymentMethod = const Value.absent(),
            Value<String> paymentRef = const Value.absent(),
            Value<String> purchaseId = const Value.absent(),
            Value<String> orderId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LedgerEntriesCompanion(
            id: id,
            partyType: partyType,
            partyId: partyId,
            entryType: entryType,
            amount: amount,
            entryDate: entryDate,
            description: description,
            reference: reference,
            paymentMethod: paymentMethod,
            paymentRef: paymentRef,
            purchaseId: purchaseId,
            orderId: orderId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String partyType,
            required String partyId,
            required String entryType,
            required double amount,
            required DateTime entryDate,
            Value<String> description = const Value.absent(),
            Value<String> reference = const Value.absent(),
            Value<String> paymentMethod = const Value.absent(),
            Value<String> paymentRef = const Value.absent(),
            Value<String> purchaseId = const Value.absent(),
            Value<String> orderId = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              LedgerEntriesCompanion.insert(
            id: id,
            partyType: partyType,
            partyId: partyId,
            entryType: entryType,
            amount: amount,
            entryDate: entryDate,
            description: description,
            reference: reference,
            paymentMethod: paymentMethod,
            paymentRef: paymentRef,
            purchaseId: purchaseId,
            orderId: orderId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$LedgerEntriesTable, LedgerRow>(table),
                    BaseReferences<_$AppDatabase, $LedgerEntriesTable,
                        LedgerRow>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LedgerEntriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LedgerEntriesTable,
    LedgerRow,
    $$LedgerEntriesTableFilterComposer,
    $$LedgerEntriesTableOrderingComposer,
    $$LedgerEntriesTableAnnotationComposer,
    $$LedgerEntriesTableCreateCompanionBuilder,
    $$LedgerEntriesTableUpdateCompanionBuilder,
    (LedgerRow, BaseReferences<_$AppDatabase, $LedgerEntriesTable, LedgerRow>),
    LedgerRow,
    PrefetchHooks Function()>;
typedef $$PurchasesTableCreateCompanionBuilder = PurchasesCompanion Function({
  required String id,
  required String purchaseNo,
  required String vendorId,
  required String vendorName,
  Value<String> invoiceNo,
  required DateTime purchaseDate,
  Value<String> notes,
  Value<double> totalAmount,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$PurchasesTableUpdateCompanionBuilder = PurchasesCompanion Function({
  Value<String> id,
  Value<String> purchaseNo,
  Value<String> vendorId,
  Value<String> vendorName,
  Value<String> invoiceNo,
  Value<DateTime> purchaseDate,
  Value<String> notes,
  Value<double> totalAmount,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$PurchasesTableFilterComposer
    extends Composer<_$AppDatabase, $PurchasesTable> {
  $$PurchasesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get purchaseNo => $composableBuilder(
      column: $table.purchaseNo, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get vendorId => $composableBuilder(
      column: $table.vendorId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get vendorName => $composableBuilder(
      column: $table.vendorName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get invoiceNo => $composableBuilder(
      column: $table.invoiceNo, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get purchaseDate => $composableBuilder(
      column: $table.purchaseDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get totalAmount => $composableBuilder(
      column: $table.totalAmount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$PurchasesTableOrderingComposer
    extends Composer<_$AppDatabase, $PurchasesTable> {
  $$PurchasesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get purchaseNo => $composableBuilder(
      column: $table.purchaseNo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get vendorId => $composableBuilder(
      column: $table.vendorId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get vendorName => $composableBuilder(
      column: $table.vendorName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get invoiceNo => $composableBuilder(
      column: $table.invoiceNo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get purchaseDate => $composableBuilder(
      column: $table.purchaseDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get totalAmount => $composableBuilder(
      column: $table.totalAmount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$PurchasesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PurchasesTable> {
  $$PurchasesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get purchaseNo => $composableBuilder(
      column: $table.purchaseNo, builder: (column) => column);

  GeneratedColumn<String> get vendorId =>
      $composableBuilder(column: $table.vendorId, builder: (column) => column);

  GeneratedColumn<String> get vendorName => $composableBuilder(
      column: $table.vendorName, builder: (column) => column);

  GeneratedColumn<String> get invoiceNo =>
      $composableBuilder(column: $table.invoiceNo, builder: (column) => column);

  GeneratedColumn<DateTime> get purchaseDate => $composableBuilder(
      column: $table.purchaseDate, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<double> get totalAmount => $composableBuilder(
      column: $table.totalAmount, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$PurchasesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PurchasesTable,
    PurchaseRow,
    $$PurchasesTableFilterComposer,
    $$PurchasesTableOrderingComposer,
    $$PurchasesTableAnnotationComposer,
    $$PurchasesTableCreateCompanionBuilder,
    $$PurchasesTableUpdateCompanionBuilder,
    (PurchaseRow, BaseReferences<_$AppDatabase, $PurchasesTable, PurchaseRow>),
    PurchaseRow,
    PrefetchHooks Function()> {
  $$PurchasesTableTableManager(_$AppDatabase db, $PurchasesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PurchasesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PurchasesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PurchasesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> purchaseNo = const Value.absent(),
            Value<String> vendorId = const Value.absent(),
            Value<String> vendorName = const Value.absent(),
            Value<String> invoiceNo = const Value.absent(),
            Value<DateTime> purchaseDate = const Value.absent(),
            Value<String> notes = const Value.absent(),
            Value<double> totalAmount = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PurchasesCompanion(
            id: id,
            purchaseNo: purchaseNo,
            vendorId: vendorId,
            vendorName: vendorName,
            invoiceNo: invoiceNo,
            purchaseDate: purchaseDate,
            notes: notes,
            totalAmount: totalAmount,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String purchaseNo,
            required String vendorId,
            required String vendorName,
            Value<String> invoiceNo = const Value.absent(),
            required DateTime purchaseDate,
            Value<String> notes = const Value.absent(),
            Value<double> totalAmount = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              PurchasesCompanion.insert(
            id: id,
            purchaseNo: purchaseNo,
            vendorId: vendorId,
            vendorName: vendorName,
            invoiceNo: invoiceNo,
            purchaseDate: purchaseDate,
            notes: notes,
            totalAmount: totalAmount,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$PurchasesTable, PurchaseRow>(table),
                    BaseReferences<_$AppDatabase, $PurchasesTable, PurchaseRow>(
                        db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PurchasesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PurchasesTable,
    PurchaseRow,
    $$PurchasesTableFilterComposer,
    $$PurchasesTableOrderingComposer,
    $$PurchasesTableAnnotationComposer,
    $$PurchasesTableCreateCompanionBuilder,
    $$PurchasesTableUpdateCompanionBuilder,
    (PurchaseRow, BaseReferences<_$AppDatabase, $PurchasesTable, PurchaseRow>),
    PurchaseRow,
    PrefetchHooks Function()>;
typedef $$PurchaseItemsTableCreateCompanionBuilder = PurchaseItemsCompanion
    Function({
  required String id,
  required String purchaseId,
  required String productId,
  required String variantId,
  required String productName,
  required String variantLabel,
  required String sku,
  required int quantity,
  required double unitCost,
  Value<int> position,
  Value<int> rowid,
});
typedef $$PurchaseItemsTableUpdateCompanionBuilder = PurchaseItemsCompanion
    Function({
  Value<String> id,
  Value<String> purchaseId,
  Value<String> productId,
  Value<String> variantId,
  Value<String> productName,
  Value<String> variantLabel,
  Value<String> sku,
  Value<int> quantity,
  Value<double> unitCost,
  Value<int> position,
  Value<int> rowid,
});

class $$PurchaseItemsTableFilterComposer
    extends Composer<_$AppDatabase, $PurchaseItemsTable> {
  $$PurchaseItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get purchaseId => $composableBuilder(
      column: $table.purchaseId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get productId => $composableBuilder(
      column: $table.productId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get variantId => $composableBuilder(
      column: $table.variantId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get productName => $composableBuilder(
      column: $table.productName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get variantLabel => $composableBuilder(
      column: $table.variantLabel, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sku => $composableBuilder(
      column: $table.sku, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get unitCost => $composableBuilder(
      column: $table.unitCost, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get position => $composableBuilder(
      column: $table.position, builder: (column) => ColumnFilters(column));
}

class $$PurchaseItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $PurchaseItemsTable> {
  $$PurchaseItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get purchaseId => $composableBuilder(
      column: $table.purchaseId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get productId => $composableBuilder(
      column: $table.productId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get variantId => $composableBuilder(
      column: $table.variantId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get productName => $composableBuilder(
      column: $table.productName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get variantLabel => $composableBuilder(
      column: $table.variantLabel,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sku => $composableBuilder(
      column: $table.sku, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get unitCost => $composableBuilder(
      column: $table.unitCost, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get position => $composableBuilder(
      column: $table.position, builder: (column) => ColumnOrderings(column));
}

class $$PurchaseItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PurchaseItemsTable> {
  $$PurchaseItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get purchaseId => $composableBuilder(
      column: $table.purchaseId, builder: (column) => column);

  GeneratedColumn<String> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<String> get variantId =>
      $composableBuilder(column: $table.variantId, builder: (column) => column);

  GeneratedColumn<String> get productName => $composableBuilder(
      column: $table.productName, builder: (column) => column);

  GeneratedColumn<String> get variantLabel => $composableBuilder(
      column: $table.variantLabel, builder: (column) => column);

  GeneratedColumn<String> get sku =>
      $composableBuilder(column: $table.sku, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<double> get unitCost =>
      $composableBuilder(column: $table.unitCost, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);
}

class $$PurchaseItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PurchaseItemsTable,
    PurchaseItemRow,
    $$PurchaseItemsTableFilterComposer,
    $$PurchaseItemsTableOrderingComposer,
    $$PurchaseItemsTableAnnotationComposer,
    $$PurchaseItemsTableCreateCompanionBuilder,
    $$PurchaseItemsTableUpdateCompanionBuilder,
    (
      PurchaseItemRow,
      BaseReferences<_$AppDatabase, $PurchaseItemsTable, PurchaseItemRow>
    ),
    PurchaseItemRow,
    PrefetchHooks Function()> {
  $$PurchaseItemsTableTableManager(_$AppDatabase db, $PurchaseItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PurchaseItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PurchaseItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PurchaseItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> purchaseId = const Value.absent(),
            Value<String> productId = const Value.absent(),
            Value<String> variantId = const Value.absent(),
            Value<String> productName = const Value.absent(),
            Value<String> variantLabel = const Value.absent(),
            Value<String> sku = const Value.absent(),
            Value<int> quantity = const Value.absent(),
            Value<double> unitCost = const Value.absent(),
            Value<int> position = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PurchaseItemsCompanion(
            id: id,
            purchaseId: purchaseId,
            productId: productId,
            variantId: variantId,
            productName: productName,
            variantLabel: variantLabel,
            sku: sku,
            quantity: quantity,
            unitCost: unitCost,
            position: position,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String purchaseId,
            required String productId,
            required String variantId,
            required String productName,
            required String variantLabel,
            required String sku,
            required int quantity,
            required double unitCost,
            Value<int> position = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PurchaseItemsCompanion.insert(
            id: id,
            purchaseId: purchaseId,
            productId: productId,
            variantId: variantId,
            productName: productName,
            variantLabel: variantLabel,
            sku: sku,
            quantity: quantity,
            unitCost: unitCost,
            position: position,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$PurchaseItemsTable, PurchaseItemRow>(table),
                    BaseReferences<_$AppDatabase, $PurchaseItemsTable,
                        PurchaseItemRow>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PurchaseItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PurchaseItemsTable,
    PurchaseItemRow,
    $$PurchaseItemsTableFilterComposer,
    $$PurchaseItemsTableOrderingComposer,
    $$PurchaseItemsTableAnnotationComposer,
    $$PurchaseItemsTableCreateCompanionBuilder,
    $$PurchaseItemsTableUpdateCompanionBuilder,
    (
      PurchaseItemRow,
      BaseReferences<_$AppDatabase, $PurchaseItemsTable, PurchaseItemRow>
    ),
    PurchaseItemRow,
    PrefetchHooks Function()>;
typedef $$StockMovementsTableCreateCompanionBuilder = StockMovementsCompanion
    Function({
  required String id,
  required String productId,
  required String variantId,
  required String sku,
  required int quantity,
  required String movementType,
  Value<String> sourceId,
  Value<double> unitCost,
  required DateTime movementDate,
  Value<String> note,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$StockMovementsTableUpdateCompanionBuilder = StockMovementsCompanion
    Function({
  Value<String> id,
  Value<String> productId,
  Value<String> variantId,
  Value<String> sku,
  Value<int> quantity,
  Value<String> movementType,
  Value<String> sourceId,
  Value<double> unitCost,
  Value<DateTime> movementDate,
  Value<String> note,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$StockMovementsTableFilterComposer
    extends Composer<_$AppDatabase, $StockMovementsTable> {
  $$StockMovementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get productId => $composableBuilder(
      column: $table.productId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get variantId => $composableBuilder(
      column: $table.variantId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sku => $composableBuilder(
      column: $table.sku, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get movementType => $composableBuilder(
      column: $table.movementType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourceId => $composableBuilder(
      column: $table.sourceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get unitCost => $composableBuilder(
      column: $table.unitCost, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get movementDate => $composableBuilder(
      column: $table.movementDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$StockMovementsTableOrderingComposer
    extends Composer<_$AppDatabase, $StockMovementsTable> {
  $$StockMovementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get productId => $composableBuilder(
      column: $table.productId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get variantId => $composableBuilder(
      column: $table.variantId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sku => $composableBuilder(
      column: $table.sku, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get movementType => $composableBuilder(
      column: $table.movementType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceId => $composableBuilder(
      column: $table.sourceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get unitCost => $composableBuilder(
      column: $table.unitCost, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get movementDate => $composableBuilder(
      column: $table.movementDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$StockMovementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StockMovementsTable> {
  $$StockMovementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<String> get variantId =>
      $composableBuilder(column: $table.variantId, builder: (column) => column);

  GeneratedColumn<String> get sku =>
      $composableBuilder(column: $table.sku, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get movementType => $composableBuilder(
      column: $table.movementType, builder: (column) => column);

  GeneratedColumn<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<double> get unitCost =>
      $composableBuilder(column: $table.unitCost, builder: (column) => column);

  GeneratedColumn<DateTime> get movementDate => $composableBuilder(
      column: $table.movementDate, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$StockMovementsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $StockMovementsTable,
    StockMovementRow,
    $$StockMovementsTableFilterComposer,
    $$StockMovementsTableOrderingComposer,
    $$StockMovementsTableAnnotationComposer,
    $$StockMovementsTableCreateCompanionBuilder,
    $$StockMovementsTableUpdateCompanionBuilder,
    (
      StockMovementRow,
      BaseReferences<_$AppDatabase, $StockMovementsTable, StockMovementRow>
    ),
    StockMovementRow,
    PrefetchHooks Function()> {
  $$StockMovementsTableTableManager(
      _$AppDatabase db, $StockMovementsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StockMovementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StockMovementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StockMovementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> productId = const Value.absent(),
            Value<String> variantId = const Value.absent(),
            Value<String> sku = const Value.absent(),
            Value<int> quantity = const Value.absent(),
            Value<String> movementType = const Value.absent(),
            Value<String> sourceId = const Value.absent(),
            Value<double> unitCost = const Value.absent(),
            Value<DateTime> movementDate = const Value.absent(),
            Value<String> note = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              StockMovementsCompanion(
            id: id,
            productId: productId,
            variantId: variantId,
            sku: sku,
            quantity: quantity,
            movementType: movementType,
            sourceId: sourceId,
            unitCost: unitCost,
            movementDate: movementDate,
            note: note,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String productId,
            required String variantId,
            required String sku,
            required int quantity,
            required String movementType,
            Value<String> sourceId = const Value.absent(),
            Value<double> unitCost = const Value.absent(),
            required DateTime movementDate,
            Value<String> note = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              StockMovementsCompanion.insert(
            id: id,
            productId: productId,
            variantId: variantId,
            sku: sku,
            quantity: quantity,
            movementType: movementType,
            sourceId: sourceId,
            unitCost: unitCost,
            movementDate: movementDate,
            note: note,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$StockMovementsTable, StockMovementRow>(table),
                    BaseReferences<_$AppDatabase, $StockMovementsTable,
                        StockMovementRow>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$StockMovementsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $StockMovementsTable,
    StockMovementRow,
    $$StockMovementsTableFilterComposer,
    $$StockMovementsTableOrderingComposer,
    $$StockMovementsTableAnnotationComposer,
    $$StockMovementsTableCreateCompanionBuilder,
    $$StockMovementsTableUpdateCompanionBuilder,
    (
      StockMovementRow,
      BaseReferences<_$AppDatabase, $StockMovementsTable, StockMovementRow>
    ),
    StockMovementRow,
    PrefetchHooks Function()>;
typedef $$StockAuditsTableCreateCompanionBuilder = StockAuditsCompanion
    Function({
  required String id,
  required String auditNo,
  required DateTime auditDate,
  Value<String> note,
  Value<String> countedById,
  Value<String> countedByName,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$StockAuditsTableUpdateCompanionBuilder = StockAuditsCompanion
    Function({
  Value<String> id,
  Value<String> auditNo,
  Value<DateTime> auditDate,
  Value<String> note,
  Value<String> countedById,
  Value<String> countedByName,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$StockAuditsTableFilterComposer
    extends Composer<_$AppDatabase, $StockAuditsTable> {
  $$StockAuditsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get auditNo => $composableBuilder(
      column: $table.auditNo, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get auditDate => $composableBuilder(
      column: $table.auditDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get countedById => $composableBuilder(
      column: $table.countedById, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get countedByName => $composableBuilder(
      column: $table.countedByName, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$StockAuditsTableOrderingComposer
    extends Composer<_$AppDatabase, $StockAuditsTable> {
  $$StockAuditsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get auditNo => $composableBuilder(
      column: $table.auditNo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get auditDate => $composableBuilder(
      column: $table.auditDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get countedById => $composableBuilder(
      column: $table.countedById, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get countedByName => $composableBuilder(
      column: $table.countedByName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$StockAuditsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StockAuditsTable> {
  $$StockAuditsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get auditNo =>
      $composableBuilder(column: $table.auditNo, builder: (column) => column);

  GeneratedColumn<DateTime> get auditDate =>
      $composableBuilder(column: $table.auditDate, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get countedById => $composableBuilder(
      column: $table.countedById, builder: (column) => column);

  GeneratedColumn<String> get countedByName => $composableBuilder(
      column: $table.countedByName, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$StockAuditsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $StockAuditsTable,
    StockAuditRow,
    $$StockAuditsTableFilterComposer,
    $$StockAuditsTableOrderingComposer,
    $$StockAuditsTableAnnotationComposer,
    $$StockAuditsTableCreateCompanionBuilder,
    $$StockAuditsTableUpdateCompanionBuilder,
    (
      StockAuditRow,
      BaseReferences<_$AppDatabase, $StockAuditsTable, StockAuditRow>
    ),
    StockAuditRow,
    PrefetchHooks Function()> {
  $$StockAuditsTableTableManager(_$AppDatabase db, $StockAuditsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StockAuditsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StockAuditsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StockAuditsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> auditNo = const Value.absent(),
            Value<DateTime> auditDate = const Value.absent(),
            Value<String> note = const Value.absent(),
            Value<String> countedById = const Value.absent(),
            Value<String> countedByName = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              StockAuditsCompanion(
            id: id,
            auditNo: auditNo,
            auditDate: auditDate,
            note: note,
            countedById: countedById,
            countedByName: countedByName,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String auditNo,
            required DateTime auditDate,
            Value<String> note = const Value.absent(),
            Value<String> countedById = const Value.absent(),
            Value<String> countedByName = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              StockAuditsCompanion.insert(
            id: id,
            auditNo: auditNo,
            auditDate: auditDate,
            note: note,
            countedById: countedById,
            countedByName: countedByName,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$StockAuditsTable, StockAuditRow>(table),
                    BaseReferences<_$AppDatabase, $StockAuditsTable,
                        StockAuditRow>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$StockAuditsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $StockAuditsTable,
    StockAuditRow,
    $$StockAuditsTableFilterComposer,
    $$StockAuditsTableOrderingComposer,
    $$StockAuditsTableAnnotationComposer,
    $$StockAuditsTableCreateCompanionBuilder,
    $$StockAuditsTableUpdateCompanionBuilder,
    (
      StockAuditRow,
      BaseReferences<_$AppDatabase, $StockAuditsTable, StockAuditRow>
    ),
    StockAuditRow,
    PrefetchHooks Function()>;
typedef $$StockAuditItemsTableCreateCompanionBuilder = StockAuditItemsCompanion
    Function({
  required String auditId,
  required int position,
  required String productId,
  required String variantId,
  required String productName,
  required String variantLabel,
  required String sku,
  required int systemQuantity,
  required int countedQuantity,
  Value<int> rowid,
});
typedef $$StockAuditItemsTableUpdateCompanionBuilder = StockAuditItemsCompanion
    Function({
  Value<String> auditId,
  Value<int> position,
  Value<String> productId,
  Value<String> variantId,
  Value<String> productName,
  Value<String> variantLabel,
  Value<String> sku,
  Value<int> systemQuantity,
  Value<int> countedQuantity,
  Value<int> rowid,
});

class $$StockAuditItemsTableFilterComposer
    extends Composer<_$AppDatabase, $StockAuditItemsTable> {
  $$StockAuditItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get auditId => $composableBuilder(
      column: $table.auditId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get position => $composableBuilder(
      column: $table.position, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get productId => $composableBuilder(
      column: $table.productId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get variantId => $composableBuilder(
      column: $table.variantId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get productName => $composableBuilder(
      column: $table.productName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get variantLabel => $composableBuilder(
      column: $table.variantLabel, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sku => $composableBuilder(
      column: $table.sku, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get systemQuantity => $composableBuilder(
      column: $table.systemQuantity,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get countedQuantity => $composableBuilder(
      column: $table.countedQuantity,
      builder: (column) => ColumnFilters(column));
}

class $$StockAuditItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $StockAuditItemsTable> {
  $$StockAuditItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get auditId => $composableBuilder(
      column: $table.auditId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get position => $composableBuilder(
      column: $table.position, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get productId => $composableBuilder(
      column: $table.productId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get variantId => $composableBuilder(
      column: $table.variantId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get productName => $composableBuilder(
      column: $table.productName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get variantLabel => $composableBuilder(
      column: $table.variantLabel,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sku => $composableBuilder(
      column: $table.sku, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get systemQuantity => $composableBuilder(
      column: $table.systemQuantity,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get countedQuantity => $composableBuilder(
      column: $table.countedQuantity,
      builder: (column) => ColumnOrderings(column));
}

class $$StockAuditItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StockAuditItemsTable> {
  $$StockAuditItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get auditId =>
      $composableBuilder(column: $table.auditId, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<String> get variantId =>
      $composableBuilder(column: $table.variantId, builder: (column) => column);

  GeneratedColumn<String> get productName => $composableBuilder(
      column: $table.productName, builder: (column) => column);

  GeneratedColumn<String> get variantLabel => $composableBuilder(
      column: $table.variantLabel, builder: (column) => column);

  GeneratedColumn<String> get sku =>
      $composableBuilder(column: $table.sku, builder: (column) => column);

  GeneratedColumn<int> get systemQuantity => $composableBuilder(
      column: $table.systemQuantity, builder: (column) => column);

  GeneratedColumn<int> get countedQuantity => $composableBuilder(
      column: $table.countedQuantity, builder: (column) => column);
}

class $$StockAuditItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $StockAuditItemsTable,
    StockAuditItemRow,
    $$StockAuditItemsTableFilterComposer,
    $$StockAuditItemsTableOrderingComposer,
    $$StockAuditItemsTableAnnotationComposer,
    $$StockAuditItemsTableCreateCompanionBuilder,
    $$StockAuditItemsTableUpdateCompanionBuilder,
    (
      StockAuditItemRow,
      BaseReferences<_$AppDatabase, $StockAuditItemsTable, StockAuditItemRow>
    ),
    StockAuditItemRow,
    PrefetchHooks Function()> {
  $$StockAuditItemsTableTableManager(
      _$AppDatabase db, $StockAuditItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StockAuditItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StockAuditItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StockAuditItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> auditId = const Value.absent(),
            Value<int> position = const Value.absent(),
            Value<String> productId = const Value.absent(),
            Value<String> variantId = const Value.absent(),
            Value<String> productName = const Value.absent(),
            Value<String> variantLabel = const Value.absent(),
            Value<String> sku = const Value.absent(),
            Value<int> systemQuantity = const Value.absent(),
            Value<int> countedQuantity = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              StockAuditItemsCompanion(
            auditId: auditId,
            position: position,
            productId: productId,
            variantId: variantId,
            productName: productName,
            variantLabel: variantLabel,
            sku: sku,
            systemQuantity: systemQuantity,
            countedQuantity: countedQuantity,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String auditId,
            required int position,
            required String productId,
            required String variantId,
            required String productName,
            required String variantLabel,
            required String sku,
            required int systemQuantity,
            required int countedQuantity,
            Value<int> rowid = const Value.absent(),
          }) =>
              StockAuditItemsCompanion.insert(
            auditId: auditId,
            position: position,
            productId: productId,
            variantId: variantId,
            productName: productName,
            variantLabel: variantLabel,
            sku: sku,
            systemQuantity: systemQuantity,
            countedQuantity: countedQuantity,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$StockAuditItemsTable, StockAuditItemRow>(
                        table),
                    BaseReferences<_$AppDatabase, $StockAuditItemsTable,
                        StockAuditItemRow>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$StockAuditItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $StockAuditItemsTable,
    StockAuditItemRow,
    $$StockAuditItemsTableFilterComposer,
    $$StockAuditItemsTableOrderingComposer,
    $$StockAuditItemsTableAnnotationComposer,
    $$StockAuditItemsTableCreateCompanionBuilder,
    $$StockAuditItemsTableUpdateCompanionBuilder,
    (
      StockAuditItemRow,
      BaseReferences<_$AppDatabase, $StockAuditItemsTable, StockAuditItemRow>
    ),
    StockAuditItemRow,
    PrefetchHooks Function()>;
typedef $$OrdersTableCreateCompanionBuilder = OrdersCompanion Function({
  required String id,
  required String orderNo,
  required String customerId,
  required String customerName,
  required DateTime orderDate,
  Value<String> status,
  Value<String> saleType,
  Value<double> discount,
  Value<double> shippingFee,
  Value<String> shippingAddress,
  Value<String> channel,
  Value<String> notes,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$OrdersTableUpdateCompanionBuilder = OrdersCompanion Function({
  Value<String> id,
  Value<String> orderNo,
  Value<String> customerId,
  Value<String> customerName,
  Value<DateTime> orderDate,
  Value<String> status,
  Value<String> saleType,
  Value<double> discount,
  Value<double> shippingFee,
  Value<String> shippingAddress,
  Value<String> channel,
  Value<String> notes,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$OrdersTableFilterComposer
    extends Composer<_$AppDatabase, $OrdersTable> {
  $$OrdersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get orderNo => $composableBuilder(
      column: $table.orderNo, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get customerId => $composableBuilder(
      column: $table.customerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get customerName => $composableBuilder(
      column: $table.customerName, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get orderDate => $composableBuilder(
      column: $table.orderDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get saleType => $composableBuilder(
      column: $table.saleType, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get discount => $composableBuilder(
      column: $table.discount, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get shippingFee => $composableBuilder(
      column: $table.shippingFee, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get shippingAddress => $composableBuilder(
      column: $table.shippingAddress,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get channel => $composableBuilder(
      column: $table.channel, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$OrdersTableOrderingComposer
    extends Composer<_$AppDatabase, $OrdersTable> {
  $$OrdersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get orderNo => $composableBuilder(
      column: $table.orderNo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get customerId => $composableBuilder(
      column: $table.customerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get customerName => $composableBuilder(
      column: $table.customerName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get orderDate => $composableBuilder(
      column: $table.orderDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get saleType => $composableBuilder(
      column: $table.saleType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get discount => $composableBuilder(
      column: $table.discount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get shippingFee => $composableBuilder(
      column: $table.shippingFee, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get shippingAddress => $composableBuilder(
      column: $table.shippingAddress,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get channel => $composableBuilder(
      column: $table.channel, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$OrdersTableAnnotationComposer
    extends Composer<_$AppDatabase, $OrdersTable> {
  $$OrdersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get orderNo =>
      $composableBuilder(column: $table.orderNo, builder: (column) => column);

  GeneratedColumn<String> get customerId => $composableBuilder(
      column: $table.customerId, builder: (column) => column);

  GeneratedColumn<String> get customerName => $composableBuilder(
      column: $table.customerName, builder: (column) => column);

  GeneratedColumn<DateTime> get orderDate =>
      $composableBuilder(column: $table.orderDate, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get saleType =>
      $composableBuilder(column: $table.saleType, builder: (column) => column);

  GeneratedColumn<double> get discount =>
      $composableBuilder(column: $table.discount, builder: (column) => column);

  GeneratedColumn<double> get shippingFee => $composableBuilder(
      column: $table.shippingFee, builder: (column) => column);

  GeneratedColumn<String> get shippingAddress => $composableBuilder(
      column: $table.shippingAddress, builder: (column) => column);

  GeneratedColumn<String> get channel =>
      $composableBuilder(column: $table.channel, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$OrdersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $OrdersTable,
    OrderRow,
    $$OrdersTableFilterComposer,
    $$OrdersTableOrderingComposer,
    $$OrdersTableAnnotationComposer,
    $$OrdersTableCreateCompanionBuilder,
    $$OrdersTableUpdateCompanionBuilder,
    (OrderRow, BaseReferences<_$AppDatabase, $OrdersTable, OrderRow>),
    OrderRow,
    PrefetchHooks Function()> {
  $$OrdersTableTableManager(_$AppDatabase db, $OrdersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OrdersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OrdersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OrdersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> orderNo = const Value.absent(),
            Value<String> customerId = const Value.absent(),
            Value<String> customerName = const Value.absent(),
            Value<DateTime> orderDate = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String> saleType = const Value.absent(),
            Value<double> discount = const Value.absent(),
            Value<double> shippingFee = const Value.absent(),
            Value<String> shippingAddress = const Value.absent(),
            Value<String> channel = const Value.absent(),
            Value<String> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              OrdersCompanion(
            id: id,
            orderNo: orderNo,
            customerId: customerId,
            customerName: customerName,
            orderDate: orderDate,
            status: status,
            saleType: saleType,
            discount: discount,
            shippingFee: shippingFee,
            shippingAddress: shippingAddress,
            channel: channel,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String orderNo,
            required String customerId,
            required String customerName,
            required DateTime orderDate,
            Value<String> status = const Value.absent(),
            Value<String> saleType = const Value.absent(),
            Value<double> discount = const Value.absent(),
            Value<double> shippingFee = const Value.absent(),
            Value<String> shippingAddress = const Value.absent(),
            Value<String> channel = const Value.absent(),
            Value<String> notes = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              OrdersCompanion.insert(
            id: id,
            orderNo: orderNo,
            customerId: customerId,
            customerName: customerName,
            orderDate: orderDate,
            status: status,
            saleType: saleType,
            discount: discount,
            shippingFee: shippingFee,
            shippingAddress: shippingAddress,
            channel: channel,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$OrdersTable, OrderRow>(table),
                    BaseReferences<_$AppDatabase, $OrdersTable, OrderRow>(
                        db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$OrdersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $OrdersTable,
    OrderRow,
    $$OrdersTableFilterComposer,
    $$OrdersTableOrderingComposer,
    $$OrdersTableAnnotationComposer,
    $$OrdersTableCreateCompanionBuilder,
    $$OrdersTableUpdateCompanionBuilder,
    (OrderRow, BaseReferences<_$AppDatabase, $OrdersTable, OrderRow>),
    OrderRow,
    PrefetchHooks Function()>;
typedef $$OrderItemsTableCreateCompanionBuilder = OrderItemsCompanion Function({
  required String id,
  required String orderId,
  required String productId,
  required String variantId,
  required String productName,
  required String variantLabel,
  required String sku,
  required int quantity,
  required double unitPrice,
  Value<double> discount,
  Value<int> position,
  Value<int> rowid,
});
typedef $$OrderItemsTableUpdateCompanionBuilder = OrderItemsCompanion Function({
  Value<String> id,
  Value<String> orderId,
  Value<String> productId,
  Value<String> variantId,
  Value<String> productName,
  Value<String> variantLabel,
  Value<String> sku,
  Value<int> quantity,
  Value<double> unitPrice,
  Value<double> discount,
  Value<int> position,
  Value<int> rowid,
});

class $$OrderItemsTableFilterComposer
    extends Composer<_$AppDatabase, $OrderItemsTable> {
  $$OrderItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get orderId => $composableBuilder(
      column: $table.orderId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get productId => $composableBuilder(
      column: $table.productId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get variantId => $composableBuilder(
      column: $table.variantId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get productName => $composableBuilder(
      column: $table.productName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get variantLabel => $composableBuilder(
      column: $table.variantLabel, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sku => $composableBuilder(
      column: $table.sku, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get unitPrice => $composableBuilder(
      column: $table.unitPrice, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get discount => $composableBuilder(
      column: $table.discount, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get position => $composableBuilder(
      column: $table.position, builder: (column) => ColumnFilters(column));
}

class $$OrderItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $OrderItemsTable> {
  $$OrderItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get orderId => $composableBuilder(
      column: $table.orderId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get productId => $composableBuilder(
      column: $table.productId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get variantId => $composableBuilder(
      column: $table.variantId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get productName => $composableBuilder(
      column: $table.productName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get variantLabel => $composableBuilder(
      column: $table.variantLabel,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sku => $composableBuilder(
      column: $table.sku, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get unitPrice => $composableBuilder(
      column: $table.unitPrice, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get discount => $composableBuilder(
      column: $table.discount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get position => $composableBuilder(
      column: $table.position, builder: (column) => ColumnOrderings(column));
}

class $$OrderItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $OrderItemsTable> {
  $$OrderItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get orderId =>
      $composableBuilder(column: $table.orderId, builder: (column) => column);

  GeneratedColumn<String> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<String> get variantId =>
      $composableBuilder(column: $table.variantId, builder: (column) => column);

  GeneratedColumn<String> get productName => $composableBuilder(
      column: $table.productName, builder: (column) => column);

  GeneratedColumn<String> get variantLabel => $composableBuilder(
      column: $table.variantLabel, builder: (column) => column);

  GeneratedColumn<String> get sku =>
      $composableBuilder(column: $table.sku, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<double> get unitPrice =>
      $composableBuilder(column: $table.unitPrice, builder: (column) => column);

  GeneratedColumn<double> get discount =>
      $composableBuilder(column: $table.discount, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);
}

class $$OrderItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $OrderItemsTable,
    OrderItemRow,
    $$OrderItemsTableFilterComposer,
    $$OrderItemsTableOrderingComposer,
    $$OrderItemsTableAnnotationComposer,
    $$OrderItemsTableCreateCompanionBuilder,
    $$OrderItemsTableUpdateCompanionBuilder,
    (
      OrderItemRow,
      BaseReferences<_$AppDatabase, $OrderItemsTable, OrderItemRow>
    ),
    OrderItemRow,
    PrefetchHooks Function()> {
  $$OrderItemsTableTableManager(_$AppDatabase db, $OrderItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OrderItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OrderItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OrderItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> orderId = const Value.absent(),
            Value<String> productId = const Value.absent(),
            Value<String> variantId = const Value.absent(),
            Value<String> productName = const Value.absent(),
            Value<String> variantLabel = const Value.absent(),
            Value<String> sku = const Value.absent(),
            Value<int> quantity = const Value.absent(),
            Value<double> unitPrice = const Value.absent(),
            Value<double> discount = const Value.absent(),
            Value<int> position = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              OrderItemsCompanion(
            id: id,
            orderId: orderId,
            productId: productId,
            variantId: variantId,
            productName: productName,
            variantLabel: variantLabel,
            sku: sku,
            quantity: quantity,
            unitPrice: unitPrice,
            discount: discount,
            position: position,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String orderId,
            required String productId,
            required String variantId,
            required String productName,
            required String variantLabel,
            required String sku,
            required int quantity,
            required double unitPrice,
            Value<double> discount = const Value.absent(),
            Value<int> position = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              OrderItemsCompanion.insert(
            id: id,
            orderId: orderId,
            productId: productId,
            variantId: variantId,
            productName: productName,
            variantLabel: variantLabel,
            sku: sku,
            quantity: quantity,
            unitPrice: unitPrice,
            discount: discount,
            position: position,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$OrderItemsTable, OrderItemRow>(table),
                    BaseReferences<_$AppDatabase, $OrderItemsTable,
                        OrderItemRow>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$OrderItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $OrderItemsTable,
    OrderItemRow,
    $$OrderItemsTableFilterComposer,
    $$OrderItemsTableOrderingComposer,
    $$OrderItemsTableAnnotationComposer,
    $$OrderItemsTableCreateCompanionBuilder,
    $$OrderItemsTableUpdateCompanionBuilder,
    (
      OrderItemRow,
      BaseReferences<_$AppDatabase, $OrderItemsTable, OrderItemRow>
    ),
    OrderItemRow,
    PrefetchHooks Function()>;
typedef $$OrderStatusEntriesTableCreateCompanionBuilder
    = OrderStatusEntriesCompanion Function({
  required String orderId,
  required int position,
  required String status,
  required DateTime changedAt,
  Value<String> byUserId,
  Value<String> byName,
  Value<int> rowid,
});
typedef $$OrderStatusEntriesTableUpdateCompanionBuilder
    = OrderStatusEntriesCompanion Function({
  Value<String> orderId,
  Value<int> position,
  Value<String> status,
  Value<DateTime> changedAt,
  Value<String> byUserId,
  Value<String> byName,
  Value<int> rowid,
});

class $$OrderStatusEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $OrderStatusEntriesTable> {
  $$OrderStatusEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get orderId => $composableBuilder(
      column: $table.orderId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get position => $composableBuilder(
      column: $table.position, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get changedAt => $composableBuilder(
      column: $table.changedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get byUserId => $composableBuilder(
      column: $table.byUserId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get byName => $composableBuilder(
      column: $table.byName, builder: (column) => ColumnFilters(column));
}

class $$OrderStatusEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $OrderStatusEntriesTable> {
  $$OrderStatusEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get orderId => $composableBuilder(
      column: $table.orderId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get position => $composableBuilder(
      column: $table.position, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get changedAt => $composableBuilder(
      column: $table.changedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get byUserId => $composableBuilder(
      column: $table.byUserId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get byName => $composableBuilder(
      column: $table.byName, builder: (column) => ColumnOrderings(column));
}

class $$OrderStatusEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $OrderStatusEntriesTable> {
  $$OrderStatusEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get orderId =>
      $composableBuilder(column: $table.orderId, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get changedAt =>
      $composableBuilder(column: $table.changedAt, builder: (column) => column);

  GeneratedColumn<String> get byUserId =>
      $composableBuilder(column: $table.byUserId, builder: (column) => column);

  GeneratedColumn<String> get byName =>
      $composableBuilder(column: $table.byName, builder: (column) => column);
}

class $$OrderStatusEntriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $OrderStatusEntriesTable,
    OrderStatusRow,
    $$OrderStatusEntriesTableFilterComposer,
    $$OrderStatusEntriesTableOrderingComposer,
    $$OrderStatusEntriesTableAnnotationComposer,
    $$OrderStatusEntriesTableCreateCompanionBuilder,
    $$OrderStatusEntriesTableUpdateCompanionBuilder,
    (
      OrderStatusRow,
      BaseReferences<_$AppDatabase, $OrderStatusEntriesTable, OrderStatusRow>
    ),
    OrderStatusRow,
    PrefetchHooks Function()> {
  $$OrderStatusEntriesTableTableManager(
      _$AppDatabase db, $OrderStatusEntriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OrderStatusEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OrderStatusEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OrderStatusEntriesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> orderId = const Value.absent(),
            Value<int> position = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime> changedAt = const Value.absent(),
            Value<String> byUserId = const Value.absent(),
            Value<String> byName = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              OrderStatusEntriesCompanion(
            orderId: orderId,
            position: position,
            status: status,
            changedAt: changedAt,
            byUserId: byUserId,
            byName: byName,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String orderId,
            required int position,
            required String status,
            required DateTime changedAt,
            Value<String> byUserId = const Value.absent(),
            Value<String> byName = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              OrderStatusEntriesCompanion.insert(
            orderId: orderId,
            position: position,
            status: status,
            changedAt: changedAt,
            byUserId: byUserId,
            byName: byName,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$OrderStatusEntriesTable, OrderStatusRow>(
                        table),
                    BaseReferences<_$AppDatabase, $OrderStatusEntriesTable,
                        OrderStatusRow>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$OrderStatusEntriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $OrderStatusEntriesTable,
    OrderStatusRow,
    $$OrderStatusEntriesTableFilterComposer,
    $$OrderStatusEntriesTableOrderingComposer,
    $$OrderStatusEntriesTableAnnotationComposer,
    $$OrderStatusEntriesTableCreateCompanionBuilder,
    $$OrderStatusEntriesTableUpdateCompanionBuilder,
    (
      OrderStatusRow,
      BaseReferences<_$AppDatabase, $OrderStatusEntriesTable, OrderStatusRow>
    ),
    OrderStatusRow,
    PrefetchHooks Function()>;
typedef $$OutboxTableCreateCompanionBuilder = OutboxCompanion Function({
  Value<int> seq,
  required String opId,
  required String kind,
  required String collection,
  required String entityId,
  required String label,
  Value<bool> isNew,
  required String payload,
  Value<String> state,
  Value<String> error,
  Value<int> attempts,
  required DateTime createdAt,
});
typedef $$OutboxTableUpdateCompanionBuilder = OutboxCompanion Function({
  Value<int> seq,
  Value<String> opId,
  Value<String> kind,
  Value<String> collection,
  Value<String> entityId,
  Value<String> label,
  Value<bool> isNew,
  Value<String> payload,
  Value<String> state,
  Value<String> error,
  Value<int> attempts,
  Value<DateTime> createdAt,
});

class $$OutboxTableFilterComposer
    extends Composer<_$AppDatabase, $OutboxTable> {
  $$OutboxTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get seq => $composableBuilder(
      column: $table.seq, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get opId => $composableBuilder(
      column: $table.opId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get collection => $composableBuilder(
      column: $table.collection, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isNew => $composableBuilder(
      column: $table.isNew, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get state => $composableBuilder(
      column: $table.state, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get error => $composableBuilder(
      column: $table.error, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get attempts => $composableBuilder(
      column: $table.attempts, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$OutboxTableOrderingComposer
    extends Composer<_$AppDatabase, $OutboxTable> {
  $$OutboxTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get seq => $composableBuilder(
      column: $table.seq, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get opId => $composableBuilder(
      column: $table.opId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get collection => $composableBuilder(
      column: $table.collection, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isNew => $composableBuilder(
      column: $table.isNew, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get state => $composableBuilder(
      column: $table.state, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get error => $composableBuilder(
      column: $table.error, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get attempts => $composableBuilder(
      column: $table.attempts, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$OutboxTableAnnotationComposer
    extends Composer<_$AppDatabase, $OutboxTable> {
  $$OutboxTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => column);

  GeneratedColumn<String> get opId =>
      $composableBuilder(column: $table.opId, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get collection => $composableBuilder(
      column: $table.collection, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<bool> get isNew =>
      $composableBuilder(column: $table.isNew, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<String> get error =>
      $composableBuilder(column: $table.error, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$OutboxTableTableManager extends RootTableManager<
    _$AppDatabase,
    $OutboxTable,
    OutboxRow,
    $$OutboxTableFilterComposer,
    $$OutboxTableOrderingComposer,
    $$OutboxTableAnnotationComposer,
    $$OutboxTableCreateCompanionBuilder,
    $$OutboxTableUpdateCompanionBuilder,
    (OutboxRow, BaseReferences<_$AppDatabase, $OutboxTable, OutboxRow>),
    OutboxRow,
    PrefetchHooks Function()> {
  $$OutboxTableTableManager(_$AppDatabase db, $OutboxTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OutboxTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OutboxTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OutboxTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> seq = const Value.absent(),
            Value<String> opId = const Value.absent(),
            Value<String> kind = const Value.absent(),
            Value<String> collection = const Value.absent(),
            Value<String> entityId = const Value.absent(),
            Value<String> label = const Value.absent(),
            Value<bool> isNew = const Value.absent(),
            Value<String> payload = const Value.absent(),
            Value<String> state = const Value.absent(),
            Value<String> error = const Value.absent(),
            Value<int> attempts = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              OutboxCompanion(
            seq: seq,
            opId: opId,
            kind: kind,
            collection: collection,
            entityId: entityId,
            label: label,
            isNew: isNew,
            payload: payload,
            state: state,
            error: error,
            attempts: attempts,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> seq = const Value.absent(),
            required String opId,
            required String kind,
            required String collection,
            required String entityId,
            required String label,
            Value<bool> isNew = const Value.absent(),
            required String payload,
            Value<String> state = const Value.absent(),
            Value<String> error = const Value.absent(),
            Value<int> attempts = const Value.absent(),
            required DateTime createdAt,
          }) =>
              OutboxCompanion.insert(
            seq: seq,
            opId: opId,
            kind: kind,
            collection: collection,
            entityId: entityId,
            label: label,
            isNew: isNew,
            payload: payload,
            state: state,
            error: error,
            attempts: attempts,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$OutboxTable, OutboxRow>(table),
                    BaseReferences<_$AppDatabase, $OutboxTable, OutboxRow>(
                        db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$OutboxTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $OutboxTable,
    OutboxRow,
    $$OutboxTableFilterComposer,
    $$OutboxTableOrderingComposer,
    $$OutboxTableAnnotationComposer,
    $$OutboxTableCreateCompanionBuilder,
    $$OutboxTableUpdateCompanionBuilder,
    (OutboxRow, BaseReferences<_$AppDatabase, $OutboxTable, OutboxRow>),
    OutboxRow,
    PrefetchHooks Function()>;
typedef $$SyncKvTableCreateCompanionBuilder = SyncKvCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$SyncKvTableUpdateCompanionBuilder = SyncKvCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$SyncKvTableFilterComposer
    extends Composer<_$AppDatabase, $SyncKvTable> {
  $$SyncKvTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));
}

class $$SyncKvTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncKvTable> {
  $$SyncKvTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));
}

class $$SyncKvTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncKvTable> {
  $$SyncKvTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SyncKvTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SyncKvTable,
    SyncKvRow,
    $$SyncKvTableFilterComposer,
    $$SyncKvTableOrderingComposer,
    $$SyncKvTableAnnotationComposer,
    $$SyncKvTableCreateCompanionBuilder,
    $$SyncKvTableUpdateCompanionBuilder,
    (SyncKvRow, BaseReferences<_$AppDatabase, $SyncKvTable, SyncKvRow>),
    SyncKvRow,
    PrefetchHooks Function()> {
  $$SyncKvTableTableManager(_$AppDatabase db, $SyncKvTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncKvTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncKvTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncKvTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncKvCompanion(
            key: key,
            value: value,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncKvCompanion.insert(
            key: key,
            value: value,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$SyncKvTable, SyncKvRow>(table),
                    BaseReferences<_$AppDatabase, $SyncKvTable, SyncKvRow>(
                        db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncKvTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SyncKvTable,
    SyncKvRow,
    $$SyncKvTableFilterComposer,
    $$SyncKvTableOrderingComposer,
    $$SyncKvTableAnnotationComposer,
    $$SyncKvTableCreateCompanionBuilder,
    $$SyncKvTableUpdateCompanionBuilder,
    (SyncKvRow, BaseReferences<_$AppDatabase, $SyncKvTable, SyncKvRow>),
    SyncKvRow,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$ProductsTableTableManager get products =>
      $$ProductsTableTableManager(_db, _db.products);
  $$ProductVariantsTableTableManager get productVariants =>
      $$ProductVariantsTableTableManager(_db, _db.productVariants);
  $$VendorsTableTableManager get vendors =>
      $$VendorsTableTableManager(_db, _db.vendors);
  $$CustomersTableTableManager get customers =>
      $$CustomersTableTableManager(_db, _db.customers);
  $$LedgerEntriesTableTableManager get ledgerEntries =>
      $$LedgerEntriesTableTableManager(_db, _db.ledgerEntries);
  $$PurchasesTableTableManager get purchases =>
      $$PurchasesTableTableManager(_db, _db.purchases);
  $$PurchaseItemsTableTableManager get purchaseItems =>
      $$PurchaseItemsTableTableManager(_db, _db.purchaseItems);
  $$StockMovementsTableTableManager get stockMovements =>
      $$StockMovementsTableTableManager(_db, _db.stockMovements);
  $$StockAuditsTableTableManager get stockAudits =>
      $$StockAuditsTableTableManager(_db, _db.stockAudits);
  $$StockAuditItemsTableTableManager get stockAuditItems =>
      $$StockAuditItemsTableTableManager(_db, _db.stockAuditItems);
  $$OrdersTableTableManager get orders =>
      $$OrdersTableTableManager(_db, _db.orders);
  $$OrderItemsTableTableManager get orderItems =>
      $$OrderItemsTableTableManager(_db, _db.orderItems);
  $$OrderStatusEntriesTableTableManager get orderStatusEntries =>
      $$OrderStatusEntriesTableTableManager(_db, _db.orderStatusEntries);
  $$OutboxTableTableManager get outbox =>
      $$OutboxTableTableManager(_db, _db.outbox);
  $$SyncKvTableTableManager get syncKv =>
      $$SyncKvTableTableManager(_db, _db.syncKv);
}
