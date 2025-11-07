import 'package:logging/logging.dart';

/// Simple logging wrapper used across the app.
/// Call `initLogging()` early in `main()` to enable console output.

void initLogging() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    // Keep output simple and readable during development.
    // ignore: avoid_print
    print(
      '${record.level.name}: ${record.time.toIso8601String()} ${record.loggerName}: ${record.message}',
    );
    if (record.error != null) {
      // ignore: avoid_print
      print('Error: ${record.error}');
    }
    if (record.stackTrace != null) {
      // ignore: avoid_print
      print('Stack: ${record.stackTrace}');
    }
  });
}

Logger getLogger(String name) => Logger(name);
