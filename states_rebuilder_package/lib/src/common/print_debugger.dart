extension PrintConsoleX on Object {
  T printConsole<T>([String pre = '', String post = '']) {
    pre = pre.isNotEmpty ? '[$pre] ' : '';
    post = post.isNotEmpty ? '[$post] ' : '';
    print('$pre${this}$post');
    return this as T;
  }

  T printConsoleWhen<T>(bool when, {String pre = '', String post = ''}) {
    if (when) {
      pre = pre.isNotEmpty ? '[$pre] ' : '';
      post = post.isNotEmpty ? '[$post] ' : '';
      print('$pre${this}$post');
    }
    return this as T;
  }
}
