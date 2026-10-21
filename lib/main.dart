import 'dart:math';
import 'dart:typed_data';

import 'package:cash_up/controllers/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final rnd = Random();
  final x = Int32List.fromList(
    List.generate(1000000, (_) => rnd.nextInt(1000)),
  );
  for (var i = 0; i < x.length; i++) {
    x[i] = rnd.nextInt(1000) + 1;
  }
  final sw = Stopwatch()..start();
  final y = groupAndEncrtpy(x, 'secretKey');
  debugPrint(
    'groupAndEncrtpy took ${sw.elapsedMilliseconds} ms, y.length=${y.length}',
  );

  for (var i = 0; i < 3; i++) {
    final g = y[i];
    final preview = g.indices.take(3).join(', ');
    debugPrint('Y[$i] -> Warna : "${g.enencyptedColor}" id warna: ${g.id}');

    debugPrint(
      'Index asal: [$preview, ...] (total ${g.indices.length} indices)',
    );
  }
  await GetStorage.init();
  runApp(const App());
}
