import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class AnalysisImageLocalDataSource {
  AnalysisImageLocalDataSource({
    Future<Directory> Function()? documentsDirectoryProvider,
  }) : _documentsDirectoryProvider =
           documentsDirectoryProvider ?? getApplicationDocumentsDirectory;

  final Future<Directory> Function() _documentsDirectoryProvider;

  Future<String> persistImage(String sourceImagePath) async {
    final sourceFile = File(sourceImagePath);
    if (!await sourceFile.exists()) {
      throw FileSystemException('The meal photo could not be found.');
    }

    final imageDirectory = await _imageDirectory();
    await imageDirectory.create(recursive: true);

    final extension = p.extension(sourceImagePath).toLowerCase();
    final safeExtension = extension.isEmpty ? '.jpg' : extension;
    final fileName =
        'analysis_${DateTime.now().microsecondsSinceEpoch}$safeExtension';
    final destination = File(p.join(imageDirectory.path, fileName));

    return (await sourceFile.copy(destination.path)).path;
  }

  Future<String> persistBytes(
    Uint8List bytes, {
    String extension = '.jpg',
  }) async {
    final imageDirectory = await _imageDirectory();
    await imageDirectory.create(recursive: true);
    final safeExtension = extension.startsWith('.') ? extension : '.$extension';
    final destination = File(
      p.join(
        imageDirectory.path,
        'analysis_${DateTime.now().microsecondsSinceEpoch}$safeExtension',
      ),
    );
    await destination.writeAsBytes(bytes, flush: true);
    return destination.path;
  }

  Future<void> deleteImage(String imagePath) async {
    final resolvedPath = await resolveImagePath(imagePath);
    final imageDirectory = await _imageDirectory();
    final normalizedDirectory = p.normalize(imageDirectory.absolute.path);
    final file = File(resolvedPath);
    final normalizedFile = p.normalize(file.absolute.path);

    if (!p.isWithin(normalizedDirectory, normalizedFile)) {
      return;
    }

    if (await file.exists()) {
      await file.delete();
    }
  }

  /// Resolves paths saved before an iOS application-container path change.
  Future<String> resolveImagePath(String storedPath) async {
    if (await File(storedPath).exists()) return storedPath;

    final fileName = p.basename(storedPath);
    if (fileName.isEmpty || fileName == '.') return storedPath;
    final currentPath = p.join((await _imageDirectory()).path, fileName);
    return await File(currentPath).exists() ? currentPath : storedPath;
  }

  Future<Directory> _imageDirectory() async {
    final documentsDirectory = await _documentsDirectoryProvider();
    return Directory(p.join(documentsDirectory.path, 'analysis_images'));
  }
}
