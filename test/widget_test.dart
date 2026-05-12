import 'package:flutter_test/flutter_test.dart';
import 'package:jood/core/routing/routes.dart';

void main() {
  test('login route is defined', () {
    expect(Routes.loginScreen, '/login');
  });
}
