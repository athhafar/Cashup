import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

class ColorGroup {
  final int id;
  final String enencyptedColor;
  final Int32List indices;
  ColorGroup({
    required this.id,
    required this.enencyptedColor,
    required this.indices,
  });
}

List<ColorGroup> groupAndEncrtpy(Int32List x, String secretKey) {
  const maxId = 1000;

  final counts = Int32List(maxId + 2);
  for (var i = 0; i < x.length; i++) {
    counts[x[i] + 1]++;
  }

  for (var id = 1; id < counts.length; id++) {
    counts[id] += counts[id - 1];
  }

  final starts = Int32List.fromList(counts);

  final flat = Int32List(x.length);
  final pos = Int32List.fromList(counts);

  for (var i = 0; i < x.length; i++) {
    final id = x[i];
    flat[pos[id]++] = i;
  }

  final hmac = Hmac(sha256, utf8.encode(secretKey));
  final y = <ColorGroup>[];
  for (var id = 0; id < maxId + 1; id++) {
    final start = starts[id];
    final end = starts[id + 1];
    if (start == end) {
      continue;
    }
    final indices = flat.sublist(start, end);
    final colorBytes = utf8.encode(id.toString());
    final encryptedColor = hmac.convert(colorBytes).toString();
    y.add(
      ColorGroup(id: id, enencyptedColor: encryptedColor, indices: indices),
    );
  }
  return y;
}
