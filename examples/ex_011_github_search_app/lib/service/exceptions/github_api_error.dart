class GitHubAPIError implements Exception {
  final String message;

  GitHubAPIError.parseError() : message = 'Error reading data from the API';
  GitHubAPIError.rateLimitExceeded() : message = 'Rate limit exceeded';
  GitHubAPIError.unknownError() : message = 'Unknown error';

  @override
  String toString() {
    return message;
  }
}
