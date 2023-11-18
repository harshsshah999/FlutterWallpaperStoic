import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

class ExtStorage {
  static const MethodChannel _channel = MethodChannel('ext_storage');

  static const String DIRECTORY_MUSIC = "Music";

  static const String DIRECTORY_PODCASTS = "Podcasts";

  static const String DIRECTORY_RINGTONES = "Ringtones";

  static const String DIRECTORY_ALARMS = "Alarms";

  static const String DIRECTORY_NOTIFICATIONS = "Notifications";

  static const String DIRECTORY_PICTURES = "Pictures";

  static const String DIRECTORY_MOVIES = "Movies";

  static const String DIRECTORY_DOWNLOADS = "Download";

  static const String DIRECTORY_DCIM = "DCIM";

  static const String DIRECTORY_DOCUMENTS = "Documents";

  static const String DIRECTORY_SCREENSHOTS = "Screenshots";

  static const String DIRECTORY_AUDIOBOOKS = "Audiobooks";

  static Future<String> getExternalStorageDirectory() async {
    if (!Platform.isAndroid) {
      throw UnsupportedError("Only android supported");
    }
    return await _channel.invokeMethod('getExternalStorageDirectory');
  }

  static Future<String> getExternalStoragePublicDirectory(String type) async {
    if (!Platform.isAndroid) {
      throw UnsupportedError("Only android supported");
    }
    return await _channel
        .invokeMethod('getExternalStoragePublicDirectory', {"type": type});
  }
}
