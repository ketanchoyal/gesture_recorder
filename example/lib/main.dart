import 'package:flutter/material.dart';
import 'package:gesture_recorder/gesture_recorder.dart';

void main() {
  runApp(GestureRecorder(child: const MyApp()));

  // for more detailed example
  // runApp(GestureRecorder(child: const DrawingCanvasExample()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  List<CapturedPointerData>? _pointerHistory;

  Future<void> _toggleRecordState(RecordState recordState) async {
    switch (recordState) {
      case RecordState.none:
        if (_pointerHistory != null) {
          await GestureRecorder.replay(context, _pointerHistory!);
        } else {
          GestureRecorder.start(context);
        }
      case RecordState.recording:
        final history = await GestureRecorder.stop(context);
        setState(() {
          _pointerHistory = history;
        });
      case RecordState.playing:
        // do nothing
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final recordState = GestureRecorder.stateOf(context);
    final hasHistory = _pointerHistory != null;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 48),
            Text(
              recordState.recordStatusText(hasHistory),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: recordState.recordColor(hasHistory),
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: recordState == RecordState.playing
                  ? null
                  : () => _toggleRecordState(recordState),
              icon: Icon(recordState.recordIcon(hasHistory)),
              label: Text(
                recordState == RecordState.recording
                    ? 'Stop Recording'
                    : hasHistory
                        ? 'Replay'
                        : 'Start Recording',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: recordState.recordColor(hasHistory),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() => _counter++),
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

extension on RecordState {
  IconData recordIcon(bool hasHistory) => switch (this) {
        RecordState.none =>
          hasHistory ? Icons.play_arrow : Icons.fiber_manual_record,
        RecordState.recording => Icons.stop,
        RecordState.playing => Icons.play_arrow,
      };

  Color recordColor(bool hasHistory) => switch (this) {
        RecordState.none => hasHistory ? Colors.green : Colors.red,
        RecordState.recording => Colors.grey,
        RecordState.playing => Colors.blue,
      };

  String recordStatusText(bool hasHistory) => switch (this) {
        RecordState.none => hasHistory ? 'Ready to replay' : 'Ready to record',
        RecordState.recording => 'Recording...',
        RecordState.playing => 'Playing...',
      };
}
