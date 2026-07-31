import 'dart:io';

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

  Future<void> deleteImage(String imagePath) async {
    final imageDirectory = await _imageDirectory();
    final normalizedDirectory = p.normalize(imageDirectory.absolute.path);
    final file = File(imagePath);
    final normalizedFile = p.normalize(file.absolute.path);

    if (!p.isWithin(normalizedDirectory, normalizedFile)) {
      return;
    }

    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<Directory> _imageDirectory() async {
    final documentsDirectory = await _documentsDirectoryProvider();
    return Directory(p.join(documentsDirectory.path, 'analysis_images'));
  }
}
