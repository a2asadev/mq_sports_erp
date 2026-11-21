import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';

/// Packs files (name -> text) into one ZIP, so "save everything" is one file to keep.
Uint8List zipTextFiles(Map<String, String> files) {
  final Archive archive = Archive();
  for (final MapEntry<String, String> f in files.entries) {
    archive.addFile(ArchiveFile.bytes(f.key, utf8.encode(f.value)));
  }
  return ZipEncoder().encodeBytes(archive);
}
