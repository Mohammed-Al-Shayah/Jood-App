class BookingException implements Exception {
  BookingException(this.message);

  final String message;

  @override
  String toString() => message;
}
