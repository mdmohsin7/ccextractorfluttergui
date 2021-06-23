import 'dart:convert';
import 'dart:io';

// Package imports:
import 'package:localstorage/localstorage.dart';
import 'package:path_provider/path_provider.dart';

// Project imports:
import 'package:ccxgui/models/settings_model.dart';
import 'package:ccxgui/utils/constants.dart';

class SettingsRepository {
  // final SettingsModel settingsModel;

  // SettingsRepository(this.settingsModel);

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/config.json');
  }

  // Remember to check if json is valid before storage.ready.
  Future<bool> checkValidJSON() async {
    final file = await _localFile;
    try {
      final String settings = await file.readAsString();
      // This checks if the file is in a valid json format
      Map<String, dynamic> data = jsonDecode(settings);
      for (var item in settingsList) {
        // This checks if all the keys from settings mode (put in a seperate list in contants file), exists or not.
        // If not, exception is thrown and default settings are written.
        if (!data.containsKey(item)) {
          throw Exception('Setting key not found');
        }
      }
      // This checks if all the values are of the intended datatype.
      if (outputFormats.contains(data['outputformat']) &&
          data['outputfilename'] is String &&
          data['append'] is bool &&
          data['autoprogram'] is bool) {
      } else {
        throw Exception('Settings value has mismatched datatype');
      }
      return true;
    } catch (e) {
      print('Rewriting config.json file');
      await file.writeAsString(jsonEncode(SettingsModel()));
      return false;
    }
  }

  Future<SettingsModel> getSettings() async {
    final SettingsModel _settings = SettingsModel();
    try {
      LocalStorage storage = LocalStorage('config.json');
      await storage.ready;
      _settings.outputformat = await storage.getItem('outputformat');
      _settings.outputfilename = await storage.getItem('outputfilename');
      _settings.autoprogram = await storage.getItem('autoprogram');
      _settings.append = await storage.getItem('append');
    } catch (e) {
      print('GetSettings Error $e');
    }
    return _settings;
  }

  Future clearSettings() async {
    print('deleting');
    LocalStorage storage = LocalStorage('config.json');
    await storage.ready;
    await storage.clear();
  }

  Future saveSettings(SettingsModel settingsModel) async {
    try {
      LocalStorage storage = LocalStorage('config.json');
      await storage.ready;
      await storage.setItem('outputformat', settingsModel.outputformat);
      await storage.setItem('outputfilename', settingsModel.outputfilename);
      await storage.setItem('append', settingsModel.append);
      await storage.setItem('autoprogram', settingsModel.autoprogram);
    } catch (e) {
      print('Error saving settings $e');
    }
  }
}
