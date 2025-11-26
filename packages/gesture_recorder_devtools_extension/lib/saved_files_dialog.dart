import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gesture_recorder_devtools_extension/device_communicator.dart';
import 'package:gesture_recorder_devtools_extension/ide_communicator.dart';

class SavedFilesDialog extends StatefulWidget {
  const SavedFilesDialog({
    super.key,
    required this.deviceCommunicator,
    required this.onFileLoaded,
  });

  final DeviceCommunicator deviceCommunicator;
  final ValueChanged<Map<String, dynamic>> onFileLoaded;

  @override
  State<SavedFilesDialog> createState() => _SavedFilesDialogState();
}

class _SavedFilesDialogState extends State<SavedFilesDialog> {
  final _ideCommunicator = IdeCommunicator();
  List<Uri> _files = [];
  bool _isLoading = true;
  String? _error;
  String? _replayingFile;
  String? _loadingFile;

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final files = await _ideCommunicator.getAssetsFiles();
      // Filter to show only .json files
      final jsonFiles = files
          .where((uri) => uri.path.endsWith('.json'))
          .toList();
      // Sort by filename (descending to show newest first)
      jsonFiles.sort((a, b) {
        final aName = a.pathSegments.last;
        final bName = b.pathSegments.last;
        return bName.compareTo(aName);
      });

      setState(() {
        _files = jsonFiles;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      setState(() {
        _error = '${e.toString()}\n$stackTrace';
        _isLoading = false;
      });
    }
  }

  Future<void> _onReplay(Uri fileUri) async {
    setState(() {
      _replayingFile = fileUri.pathSegments.last;
    });

    try {
      final fileContent = await _ideCommunicator.readFile(fileUri);
      if (fileContent.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to read file'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      await widget.deviceCommunicator.replayGestureOnDevice(fileContent);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Replaying ${fileUri.pathSegments.last}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error replaying file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _replayingFile = null;
        });
      }
    }
  }

  Future<void> _onLoad(Uri fileUri) async {
    setState(() {
      _loadingFile = fileUri.pathSegments.last;
    });

    try {
      final fileContent = await _ideCommunicator.readFile(fileUri);
      if (fileContent.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to read file'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final data = jsonDecode(fileContent) as Map<String, dynamic>;
      widget.onFileLoaded(data);

      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Loaded ${fileUri.pathSegments.last}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loadingFile = null;
        });
      }
    }
  }

  String _getFileName(Uri uri) {
    return uri.pathSegments.last;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 600,
        height: 500,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  'Saved Gesture Files',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _isLoading ? null : _loadFiles,
                  tooltip: 'Refresh',
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              'Error loading files',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadFiles, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_files.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No saved files',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Save gesture recordings to see them here.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _files.length,
      itemBuilder: (context, index) {
        final fileUri = _files[index];
        final fileName = _getFileName(fileUri);
        final isReplaying = _replayingFile == fileName;
        final isLoading = _loadingFile == fileName;

        return ListTile(
          title: Text(fileName),
          subtitle: Text(
            'Tap to load, or use buttons to replay',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isReplaying)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                IconButton(
                  icon: const Icon(Icons.play_arrow),
                  onPressed: widget.deviceCommunicator.isConnected
                      ? () => _onReplay(fileUri)
                      : null,
                  tooltip: 'Quick replay on device',
                ),
              if (isLoading)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                IconButton(
                  icon: const Icon(Icons.open_in_new),
                  onPressed: () => _onLoad(fileUri),
                  tooltip: 'Load in inspector',
                ),
            ],
          ),
          onTap: () => _onLoad(fileUri),
        );
      },
    );
  }
}
