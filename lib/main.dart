import 'package:flutter/widgets.dart';
import 'package:media_kit/media_kit.dart' show MediaKit;

import 'app/app.dart';

void main() {
  MediaKit.ensureInitialized();
  runApp(const TvOverlayRefactorApp());
}
