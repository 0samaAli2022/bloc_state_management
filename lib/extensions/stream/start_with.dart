// ignore: depend_on_referenced_packages
import 'package:async/async.dart';

extension StartWith<T> on Stream<T> {
  Stream<T> startWith(T value) => StreamGroup.merge(
        [
          this,
          Stream<T>.value(value),
        ],
      );
}
