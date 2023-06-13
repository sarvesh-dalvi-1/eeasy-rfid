class APIResponse<T> {
  final T data;
  final int statusCode;
  final bool error;
  final String reasonPhrase;

  APIResponse({required this.data, this.statusCode = 200, this.error = false, this.reasonPhrase = ''});

}