import 'package:gesture_recorder/gesture_recorder.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _recordedDataKey = 'recorded_gesture_data';

/// Saves recorded gesture data to SharedPreferences.
///
/// Returns `true` if the save was successful, `false` otherwise.
Future<bool> saveRecordedData(RecordedGestureData data) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(_recordedDataKey, data.toJson());
  } catch (e) {
    return false;
  }
}

/// Fetches recorded gesture data from SharedPreferences.
///
/// Returns the [RecordedGestureData] if found, `null` otherwise.
Future<RecordedGestureData?> fetchRecordedData() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final serialized = prefs.getString(_recordedDataKey);
    if (serialized == null) {
      return null;
    }
    return serialized.toData();
  } catch (e) {
    return null;
  }
}
