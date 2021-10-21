import 'dart:math';

extension CustomList<E> on List<E> {
  E? randomElement() {
    if (isEmpty) return null;
    return this[Random().nextInt(length)];
  }
}
