/// Cloud-side state of one collection, read from the Firestore `metadata`
/// collection: an integer [version] that increases on every upload, and the
/// time of the last upload.
class RemoteCollectionMeta {
  const RemoteCollectionMeta({required this.version, this.updatedAt});

  final int version;
  final DateTime? updatedAt;
}
