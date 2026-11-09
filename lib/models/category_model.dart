import 'package:mq_sports_erp/models/syncable_model.dart';
import 'package:uuid/uuid.dart';

/// A product category. Categories form a tree of any depth: an empty
/// [parentId] marks a top-level category, otherwise it is the id of the
/// parent category.
class CategoryModel implements SyncableModel {
  CategoryModel({
    String? id,
    required this.name,
    this.parentId = '',
    this.description = '',
    this.isActive = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  @override
  final String id;
  final String name;
  final String parentId;
  final String description;
  final bool isActive;
  final DateTime createdAt;

  @override
  final DateTime updatedAt;

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'parentId': parentId,
      'description': description,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      parentId: map['parentId'] as String? ?? '',
      description: map['description'] as String? ?? '',
      isActive: map['isActive'] as bool? ?? true,
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? ''),
      updatedAt: DateTime.tryParse(map['updatedAt'] as String? ?? ''),
    );
  }

  /// Returns a modified copy. `updatedAt` is bumped to now unless given.
  CategoryModel copyWith({
    String? name,
    String? parentId,
    String? description,
    bool? isActive,
    DateTime? updatedAt,
  }) {
    return CategoryModel(
      id: id,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
