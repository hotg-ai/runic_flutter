# runic_mobile

An example app to deploy and run runes on iOS and Android

## Getting Started

### Add the RuneVM plugin to your pubspec.yaml file

```
dependencies:
  flutter:
    sdk: flutter
  runevm_fl:
    git:
      url: https://github.com/hotg-ai/runevm_fl.git 

```

### Load and run your rune file

```dart

import 'package:runevm_fl/runevm_fl.dart';
import 'dart:typed_data';
import 'dart:async';

class RunMyRune {

  RunMyRune() {
    initAndRunRune([5,128,12,39]);
  }

  initAndRunRune(List<int> input) async {
    try {
      bytes = await rootBundle.load('assets/microspeech.rune');
      bool loaded =
          await RunevmFl.load(bytes!.buffer.asUint8List()) ?? false;
      if (loaded) {
        String manifest = (await RunevmFl.manifest).toString();
        print("Manifest loaded: $manifest");
      }
    } on Exception {
      print('Failed to init rune');
    }
    String? output = await RunevmFl.runRune(Uint8List.fromList(input));
  }

}

```
