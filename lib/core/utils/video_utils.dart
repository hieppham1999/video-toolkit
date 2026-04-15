/// Computes a simplified aspect ratio string from [width] and [height].
///
/// Returns e.g. "16:9", "4:3", "1:1". Returns null if either dimension is null or zero.
String? computeAspectRatio(int? width, int? height) {
  if (width == null || height == null || width == 0 || height == 0) return null;
  final g = _gcd(width, height);
  return '${width ~/ g}:${height ~/ g}';
}

int _gcd(int a, int b) {
  a = a.abs();
  b = b.abs();
  while (b != 0) {
    final t = b;
    b = a % b;
    a = t;
  }
  return a;
}
