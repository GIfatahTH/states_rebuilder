///States_Rebuilder logger
class StatesRebuilerLogger {
  ///Set to true to avoid printing in test mode
  static bool isTestMode = false;

  ///The current printed message
  static String message = '';

  ///Console log the error
  static void log(String m, [dynamic e, StackTrace? s]) {
    message = message = '[states_rebuilder]: $m';
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
      print(message);
      if (s != null) {
        print(s);
      }
    }
  }
}
