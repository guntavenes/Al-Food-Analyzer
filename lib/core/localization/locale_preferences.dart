import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

abstract interface class LocalePreferences {
  Future<String?> load();

  Future<void> save(String languageCode);
}

class FileLocalePreferences implements LocalePreferences {
  const FileLocalePreferences();

  Future<File> _file() async {
    final directory = await getApplicationDocumentsDirectory();
    return File(p.join(directory.path, 'app_locale.txt'));
  }

  @override
  Future<String?> load() async {
    final file = await _file();
    if (!await file.exists()) return null;
    final value = (await file.readAsString()).trim();
    return value == 'tr' || value == 'en' ? value : null;
  }

  @override
  Future<void> save(String languageCode) async {
    final file = await _file();
    await file.writeAsString(languageCode, flush: true);
  }
}
