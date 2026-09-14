import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class OnboardingPreferences {
  const OnboardingPreferences();

  Future<File> _file() async {
    final directory = await getApplicationDocumentsDirectory();
    return File(p.join(directory.path, 'onboarding_complete.txt'));
  }

  Future<bool> isComplete() async {
    final file = await _file();
    return await file.exists() && (await file.readAsString()).trim() == '1';
  }

  Future<void> markComplete() async {
    await (await _file()).writeAsString('1', flush: true);
  }
}
