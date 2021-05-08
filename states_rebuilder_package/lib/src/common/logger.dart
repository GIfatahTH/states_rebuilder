///States_Rebuilder logger
class StatesRebuilerLogger {
  ///Set to true to avoid printing in test mode
  static bool isTestMode = false;

  ///The current printed message
  static String message = '';

  ///Console log the error
  static void log(String m, [dynamic e, StackTrace? s]) {
    String? errorMessage;
    try {
      errorMessage = e?.message as String?;
      errorMessage ??= '$e';
    } catch (_) {
      errorMessage = '$e';
    }
    // errorMessage ??= '';

    message = '[states_rebuilder]: $m' +
        (errorMessage != 'null' ? ': $errorMessage' : '');
    if (!isTestMode) {
      print(message);
      if (s != null) {
        print(s);
      }
    }
  }
}
