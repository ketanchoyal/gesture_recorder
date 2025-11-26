
# gesture_recorder

**gesture_recorder** enables you to "record" all the gesture event happening during recording.

The recorded data can be replayed, which means you can duplicate exactly the same behavior again and again.

## Features

- [x] record / replay
- [x] persist recorded data
- [ ] edit / mimic gesture event on DevTools

## Getting started

First, place `GestureRecorder` at the top of the entire widget tree.

```dart
GestureRecorder(
  child: MaterialApp(),
),
```

You can access the controller by calling static methods provided by `GestureRecorder` like below.

```dart
/// start recording
GestureRecorder.start(context);

/// stop recording and obtain recorded event data
final data = await GestureRecorder.stop(context);

/// replay recorded event data
await GestureDetector.replay(context, data);
```

Also, you can observe `RecordState` from `GestureRecorder`.

```dart
/// observe [RecordState]. Once the state changes, observing widget is rebuilt.
final recordState = GestureRecorder.stateOf(context);
```

## Serialize/Deserialize

The serialize/deserialize feature makes it easy to persist (save) or share your recorded gesture data.

You can serialize (`RecordedGestureData` → JSON String) and deserialize (JSON String → `RecordedGestureData`) using the following:

### Serialize (to save or share):

```dart
final data = await GestureRecorder.stop(context);
final jsonString = data.toJson(); // Convert to JSON string
```

You can now store `jsonString` anywhere (file, cloud, preferences, etc).

### Deserialize (to replay or load):

Now you can replay loaded data:

```dart
final data = jsonString.toData();
await GestureRecorder.replay(context, data);
```

This enables you to persist gesture sessions between app launches or share them between devices.

# Contact

If you have anything you want to inform me ([@chooyan-eng](https://github.com/chooyan-eng)), such as suggestions to enhance this package or functionalities you want etc, feel free to make [issues on GitHub](https://github.com/chooyan-eng/gesture_recorder/issues) or send messages on X [@tsuyoshi_chujo](https://x.com/tsuyoshi_chujo) (Japanese [@chooyan_i18n](https://x.com/chooyan_i18n)).