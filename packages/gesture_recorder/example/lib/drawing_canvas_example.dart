import 'package:flutter/material.dart';
import 'package:gesture_recorder/gesture_recorder.dart';
import 'package:scribble/scribble.dart';
import 'shared_preferences.dart' as persistence;

class DrawingCanvasExample extends StatelessWidget {
  const DrawingCanvasExample({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Drawing Canvas',
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const DrawingCanvasPage(),
    );
  }
}

class DrawingCanvasPage extends StatefulWidget {
  const DrawingCanvasPage({super.key});

  @override
  State<DrawingCanvasPage> createState() => _DrawingCanvasPageState();
}

class _DrawingCanvasPageState extends State<DrawingCanvasPage> {
  late ScribbleNotifier notifier;
  RecordedGestureData? _recordedData;

  @override
  void initState() {
    super.initState();
    notifier = ScribbleNotifier();
  }

  @override
  void dispose() {
    notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Drawing Canvas'),
        actions: [
          ValueListenableBuilder(
            valueListenable: notifier,
            builder: (context, value, child) => IconButton(
              icon: child as Icon,
              tooltip: "Undo",
              onPressed: notifier.canUndo ? notifier.undo : null,
            ),
            child: const Icon(Icons.undo),
          ),
          ValueListenableBuilder(
            valueListenable: notifier,
            builder: (context, value, child) => IconButton(
              icon: child as Icon,
              tooltip: "Redo",
              onPressed: notifier.canRedo ? notifier.redo : null,
            ),
            child: const Icon(Icons.redo),
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            tooltip: "Clear",
            onPressed: notifier.clear,
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Optimize for iPad landscape (wider screen)
          final isLandscape = constraints.maxWidth > constraints.maxHeight;

          if (isLandscape) {
            // Landscape layout: toolbar on left, canvas on right
            return Row(
              children: [
                // Toolbar panel
                Container(
                  width: 200,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    border: Border(
                      right: BorderSide(
                        color: Theme.of(context).dividerColor,
                        width: 1,
                      ),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Colors',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildColorToolbar(),
                        const SizedBox(height: 24),
                        const Text(
                          'Stroke Width',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildStrokeToolbar(),
                        const SizedBox(height: 24),
                        const Text(
                          'Persistence',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildPersistenceButtons(),
                      ],
                    ),
                  ),
                ),
                // Canvas area
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Scribble(notifier: notifier, drawPen: true),
                    ),
                  ),
                ),
              ],
            );
          } else {
            // Portrait layout: toolbar on top, canvas below
            return Column(
              children: [
                Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(context).dividerColor,
                        width: 1,
                      ),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildColorToolbar(),
                        const SizedBox(height: 12),
                        _buildStrokeToolbar(),
                        const SizedBox(height: 12),
                        _buildPersistenceButtons(),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Scribble(notifier: notifier, drawPen: true),
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  IconData _getRecordIcon(RecordState recordState) {
    switch (recordState) {
      case RecordState.none:
        return _recordedData != null
            ? Icons.play_arrow
            : Icons.fiber_manual_record;
      case RecordState.recording:
        return Icons.stop;
      case RecordState.playing:
        return Icons.play_arrow;
    }
  }

  Color _getRecordColor(RecordState recordState) {
    switch (recordState) {
      case RecordState.none:
        return _recordedData != null ? Colors.green : Colors.red;
      case RecordState.recording:
        return Colors.grey;
      case RecordState.playing:
        return Colors.blue;
    }
  }

  Future<void> _toggleRecordState(RecordState recordState) async {
    switch (recordState) {
      case RecordState.none:
        if (_recordedData != null) {
          await GestureRecorder.replay(context, _recordedData!);
        } else {
          GestureRecorder.start(context);
        }
      case RecordState.recording:
        final history = await GestureRecorder.stop(context);
        setState(() {
          _recordedData = history;
        });
      case RecordState.playing:
        // do nothing
        break;
    }
  }

  Future<void> _saveData() async {
    if (_recordedData == null) return;
    final success = await persistence.saveRecordedData(_recordedData!);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(success ? 'Data saved successfully' : 'Failed to save data'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _restoreData() async {
    final data = await persistence.fetchRecordedData();
    if (mounted && data != null) {
      setState(() {
        _recordedData = data;
      });
    }
  }

  Widget _buildFloatingActionButton() {
    final recordState = GestureRecorder.stateOf(context);
    return FloatingActionButton(
      onPressed: recordState == RecordState.playing
          ? null
          : () => _toggleRecordState(recordState),
      backgroundColor: _getRecordColor(recordState),
      child: Icon(_getRecordIcon(recordState), color: Colors.white),
    );
  }

  // Rich color palette organized by categories
  static final List<Color> _primaryColors = [
    Colors.black,
    Colors.white,
    Colors.grey.shade700,
    Colors.grey.shade400,
  ];

  static final List<Color> _warmColors = [
    Colors.red,
    Colors.redAccent,
    Colors.deepOrange,
    Colors.orange,
    Colors.orangeAccent,
    Colors.amber,
    Colors.yellow,
    Colors.pink,
    Colors.pinkAccent,
  ];

  static final List<Color> _coolColors = [
    Colors.blue,
    Colors.blueAccent,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.greenAccent,
    Colors.lightGreen,
    Colors.lime,
  ];

  static final List<Color> _purpleColors = [
    Colors.purple,
    Colors.purpleAccent,
    Colors.deepPurple,
    Colors.indigo,
    Colors.indigoAccent,
  ];

  static final List<Color> _brownColors = [
    Colors.brown,
    Colors.brown.shade300,
    const Color(0xFF8B4513), // SaddleBrown
    const Color(0xFFD2691E), // Chocolate
    const Color(0xFFCD853F), // Peru
  ];

  Widget _buildColorToolbar() {
    return ValueListenableBuilder<ScribbleState>(
      valueListenable: notifier,
      builder: (context, state, _) {
        final selectedColor = state.map(
          drawing: (s) => Color(s.selectedColor),
          erasing: (_) => null,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Primary colors (black, white, grays)
            _buildColorGroup('Primary', _primaryColors, selectedColor, state),
            const SizedBox(height: 12),
            // Warm colors
            _buildColorGroup('Warm', _warmColors, selectedColor, state),
            const SizedBox(height: 12),
            // Cool colors
            _buildColorGroup('Cool', _coolColors, selectedColor, state),
            const SizedBox(height: 12),
            // Purple/Indigo colors
            _buildColorGroup('Purple', _purpleColors, selectedColor, state),
            const SizedBox(height: 12),
            // Brown/Earth tones
            _buildColorGroup('Earth', _brownColors, selectedColor, state),
            const SizedBox(height: 12),
            // Eraser
            _buildEraserButton(),
          ],
        );
      },
    );
  }

  Widget _buildColorGroup(
    String label,
    List<Color> colors,
    Color? selectedColor,
    ScribbleState state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.7),
            ),
          ),
        ),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: colors.map((color) {
            final isActive = state.map(
              drawing: (s) => s.selectedColor == color.toARGB32(),
              erasing: (_) => false,
            );
            return _buildColorButton(
              color: color,
              isActive: isActive,
              onPressed: () => notifier.setColor(color),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStrokeToolbar() {
    return ValueListenableBuilder<ScribbleState>(
      valueListenable: notifier,
      builder: (context, state, _) => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final width in notifier.widths)
            _buildStrokeButton(strokeWidth: width, state: state),
        ],
      ),
    );
  }

  Widget _buildStrokeButton({
    required double strokeWidth,
    required ScribbleState state,
  }) {
    final selected = state.selectedWidth == strokeWidth;
    return Material(
      elevation: selected ? 4 : 0,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: () => notifier.setStrokeWidth(strokeWidth),
        customBorder: const CircleBorder(),
        child: AnimatedContainer(
          duration: kThemeAnimationDuration,
          width: strokeWidth * 2 + 8,
          height: strokeWidth * 2 + 8,
          decoration: BoxDecoration(
            color: state.map(
              drawing: (s) => Color(s.selectedColor),
              erasing: (_) => Colors.transparent,
            ),
            border: state.map(
              drawing: (_) => null,
              erasing: (_) => Border.all(color: Colors.black, width: 1),
            ),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Container(
              width: strokeWidth * 2,
              height: strokeWidth * 2,
              decoration: BoxDecoration(
                color: state.map(
                  drawing: (_) => Colors.white,
                  erasing: (_) => Colors.black,
                ),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEraserButton() {
    return ValueListenableBuilder<ScribbleState>(
      valueListenable: notifier,
      builder: (context, state, _) {
        final isEraser = state is Erasing;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                'Tools',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ),
            Material(
              elevation: isEraser ? 6 : 2,
              shadowColor: isEraser
                  ? Colors.blue.withValues(alpha: 0.5)
                  : Colors.black.withValues(alpha: 0.2),
              shape: const CircleBorder(),
              child: InkWell(
                onTap: () => notifier.setEraser(),
                customBorder: const CircleBorder(),
                borderRadius: BorderRadius.circular(24),
                child: AnimatedContainer(
                  duration: kThemeAnimationDuration,
                  curve: Curves.easeInOut,
                  width: isEraser ? 52 : 44,
                  height: isEraser ? 52 : 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isEraser
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey.shade300,
                      width: isEraser ? 3.5 : 1.5,
                    ),
                    boxShadow: isEraser
                        ? [
                            BoxShadow(
                              color: Colors.blue.withValues(alpha: 0.4),
                              blurRadius: 8,
                              spreadRadius: 2,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                  ),
                  child: Icon(
                    Icons.cleaning_services,
                    color: isEraser
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey.shade600,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildColorButton({
    required Color color,
    required bool isActive,
    required VoidCallback onPressed,
    Widget? child,
  }) {
    // Special handling for white color - needs a border to be visible
    final needsBorder = color == Colors.white || color == Colors.grey.shade400;

    return Material(
      elevation: isActive ? 6 : 2,
      shadowColor: isActive
          ? color.withValues(alpha: 0.5)
          : Colors.black.withValues(alpha: 0.2),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: kThemeAnimationDuration,
          curve: Curves.easeInOut,
          width: isActive ? 52 : 44,
          height: isActive ? 52 : 44,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive
                  ? Theme.of(context).colorScheme.primary
                  : (needsBorder ? Colors.grey.shade400 : Colors.grey.shade300),
              width: isActive ? 3.5 : (needsBorder ? 1.5 : 1),
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.4),
                      blurRadius: 8,
                      spreadRadius: 2,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
          ),
          child: child ??
              (isActive
                  ? Center(
                      child: Icon(
                        Icons.check,
                        size: 20,
                        color: _getContrastColor(color),
                      ),
                    )
                  : const SizedBox()),
        ),
      ),
    );
  }

  Color _getContrastColor(Color color) {
    // Calculate luminance to determine if we need light or dark text
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  Widget _buildPersistenceButtons() {
    final recordState = GestureRecorder.stateOf(context);
    final hasHistory = _recordedData != null;
    final isRecordingOrPlaying = recordState == RecordState.recording ||
        recordState == RecordState.playing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: (hasHistory && !isRecordingOrPlaying) ? _saveData : null,
          icon: const Icon(Icons.save),
          label: const Text('Save'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: !isRecordingOrPlaying ? _restoreData : null,
          icon: const Icon(Icons.restore),
          label: const Text('Restore'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ],
    );
  }
}
