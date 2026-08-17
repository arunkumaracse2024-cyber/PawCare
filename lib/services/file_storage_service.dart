import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class FileStorageService {
  /// Copies a file from a temporary location to the persistent app directory.
  /// Generates a unique timestamped filename.
  static Future<String?> saveHealthAttachment(String originalPath) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final healthDir = Directory(p.join(appDir.path, 'health_attachments'));
      
      if (!await healthDir.exists()) {
        await healthDir.create(recursive: true);
      }
      
      final extension = p.extension(originalPath);
      final fileName = 'health_${DateTime.now().millisecondsSinceEpoch}$extension';
      final newPath = p.join(healthDir.path, fileName);
      
      final file = File(originalPath);
      await file.copy(newPath);
      
      debugPrint('[FileStorageService] Saved attachment to $newPath');
      return newPath;
    } catch (e) {
      debugPrint('[FileStorageService] Error saving attachment: $e');
      return null;
    }
  }
  
  /// Deletes a file, ensuring it belongs to the app's document directory
  /// to prevent accidental deletion of files elsewhere on the device.
  static Future<void> deleteAttachment(String? path) async {
    if (path == null || path.isEmpty) return;
    
    try {
      final file = File(path);
      if (await file.exists()) {
        final appDir = await getApplicationDocumentsDirectory();
        
        // Safety check: only delete if it's inside our app directory
        if (p.isWithin(appDir.path, path)) {
          await file.delete();
          debugPrint('[FileStorageService] Deleted attachment at $path');
        } else {
          debugPrint('[FileStorageService] Refused to delete file outside app directory: $path');
        }
      }
    } catch (e) {
      debugPrint('[FileStorageService] Error deleting attachment: $e');
    }
  }
}
