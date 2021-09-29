///States_Rebuilder logger
class StatesRebuilerLogger {
  ///Set to true to avoid printing in test mode
  static bool isTestMode = false;

  ///The current printed message
  static String message = '';

  ///Console log the error
  static void log(String m, [dynamic e, StackTrace? s]) {
    final suffix = e == null ? 'INFO' : 'ERROR';
    message = message = '[states_rebuilder::$suffix]: $m';
    if (e != null) {
      String? errorMessage;
      try {
        errorMessage = e.message as String?;
      } catch (_) {
        errorMessage = '$e';
      }
      message = message + ' : $errorMessage';
    }
    if (!isTestMode) {
      // ignore: avoid_print
      print(message);
      if (s != null) {
        // ignore: avoid_print
        print(s);
      }
    }
  }
}
