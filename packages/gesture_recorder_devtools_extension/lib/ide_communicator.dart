import 'dart:io';

import 'package:devtools_app_shared/service.dart';
import 'package:devtools_extensions/devtools_extensions.dart';
import 'package:dtd/dtd.dart';

/// Helper class to communicate with the IDE.
class IdeCommunicator {
  /// Save the given [data] to `assets/gesture_recorder/` with the given [fileName].
  Future<void> saveToWorkspace({
    required String data,
    required String fileName,
  }) async {
    final fileUri = await dtdManager.buildAssetsPath(fileName);

    if (fileUri == null) {
      throw Exception('Workspace root not found. Unable to save file.');
    }

    // Write file using dtdManager extension method
    await dtdManager.writeFile(fileUri, data);
  }

  /// Get all file [Uri]s in `assets/gesture_recorder/`.
  Future<List<Uri>> getAssetsFiles() async {
    final assetsPath = await dtdManager.findAssets();
    if (assetsPath == null) return [];

    final entries = await dtdManager._dtd.listDirectoryContents(assetsPath);

    return entries.uris ?? [];
  }

  Future<String> readFile(Uri uri) async {
    return await dtdManager.readFile(uri);
  }
}

extension on DTDManager {
  DartToolingDaemon get _dtd => connection.value!;

  Future<String> readFile(Uri uri) async {
    if (!hasConnection) return '';
    try {
      final response = await _dtd.readFileAsString(uri);
      return response.content ?? '';
    } catch (_) {
      // Fail gracefully.
      return '';
    }
  }

  Future<void> writeFile(Uri uri, String contents) async {
    if (!hasConnection) return;
    try {
      await _dtd.writeFileAsString(uri, contents);
    } catch (_) {
      return;
    }
  }

  Future<Uri?> findAssets() async {
    final workspaceRoots =
        (await dtdManager.workspaceRoots())?.ideWorkspaceRoots ?? [];

    if (workspaceRoots.isEmpty) return null;

    return File('${workspaceRoots.first.path}/gesture_recorder').uri;
  }

  Future<Uri?> buildAssetsPath(String fileName) async {
    final assetsPath = await findAssets();

    if (assetsPath == null) return null;

    return File('${assetsPath.path}/$fileName').uri;
  }
}
