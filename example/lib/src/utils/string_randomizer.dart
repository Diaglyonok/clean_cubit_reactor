import 'dart:math';

String generateRandomString(int length) {
  const String chars =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final Random random = Random.secure();

  return List.generate(length, (index) => chars[random.nextInt(chars.length)])
      .join();
}
