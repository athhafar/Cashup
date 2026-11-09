import 'dart:convert';
import 'dart:typed_data';

class Tlv {
  Tlv(this.tag, this.value, this.children);
  final int tag;
  final Uint8List value;
  final List<Tlv> children; // terisi jika tag constructed
}

Uint8List hexToBytes(String hex) {
  final clean = hex.replaceAll(RegExp(r'\s+'), '');
  final len = clean.length;
  final result = Uint8List(len ~/ 2);
  for (var i = 0; i < len; i += 2) {
    result[i ~/ 2] = int.parse(clean.substring(i, i + 2), radix: 16);
  }
  return result;
}

String bytesToHex(Uint8List bytes) {
  return bytes.map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase()).join('');
}

/// Convert ASCII byte array to String (e.g. Tag 50 Application Label)
String parseAscii(Uint8List bytes) {
  try {
    final chars = bytes.where((b) => b >= 32 && b <= 126).toList();
    return ascii.decode(chars).trim();
  } catch (_) {
    return '';
  }
}

/// TLV Parser according to EMV standard & AGENT_BRIEF.md 6.6
List<Tlv> parseTlv(Uint8List data) {
  final out = <Tlv>[];
  var i = 0;
  while (i < data.length) {
    if (data[i] == 0x00 || data[i] == 0xFF) {
      i++;
      continue;
    } // padding
    var tag = data[i++];
    final constructed = (tag & 0x20) != 0;
    if ((tag & 0x1F) == 0x1F) {
      do {
        tag = (tag << 8) | data[i++];
      } while ((data[i - 1] & 0x80) != 0);
    }
    if (i >= data.length) break;
    var len = data[i++];
    if ((len & 0x80) != 0) {
      final n = len & 0x7F;
      len = 0;
      for (var k = 0; k < n; k++) {
        if (i >= data.length) break;
        len = (len << 8) | data[i++];
      }
    }
    if (i + len > data.length) {
      // Soft break instead of crash for irregular contactless responses
      break;
    }
    final value = Uint8List.sublistView(data, i, i + len);
    out.add(Tlv(tag, value, constructed ? parseTlv(value) : const []));
    i += len;
  }
  return out;
}

Tlv? findTag(List<Tlv> list, int tag) {
  for (final t in list) {
    if (t.tag == tag) return t;
    final deep = findTag(t.children, tag);
    if (deep != null) return deep;
  }
  return null;
}

/// Helper to mask PAN: only keep last 4 digits e.g. "4111111111114821" -> "•••• 4821"
String maskPan(String pan) {
  final clean = pan.replaceAll(RegExp(r'\s+'), '').replaceAll('F', '').replaceAll('f', '');
  if (clean.length < 4) return '••••';
  final last4 = clean.substring(clean.length - 4);
  return '•••• $last4';
}

/// Extract clean PAN from raw PAN BCD or clean string
String cleanPan(String raw) {
  var s = raw.replaceAll(RegExp(r'[^0-9A-Fa-f]'), '').toUpperCase();
  // Strip trailing 'F' padding common in EMV BCD
  if (s.endsWith('F')) {
    s = s.substring(0, s.length - 1);
  }
  return s;
}

/// Helper to identify Card Brand from BIN, AID, or Application Label
String detectBrand({
  String? pan,
  String? aidHex,
  String? appLabel,
}) {
  if (appLabel != null && appLabel.isNotEmpty) {
    final l = appLabel.toUpperCase();
    if (l.contains('BCA')) return 'BCA';
    if (l.contains('PERMATA')) return 'Permata';
    if (l.contains('MANDIRI')) return 'Mandiri';
    if (l.contains('BRI')) return 'BRI';
    if (l.contains('BNI')) return 'BNI';
    if (l.contains('VISA')) return 'Visa';
    if (l.contains('MASTER')) return 'Mastercard';
    if (l.contains('GPN')) return 'GPN';
    if (l.contains('JCB')) return 'JCB';
  }

  if (aidHex != null && aidHex.isNotEmpty) {
    final upper = aidHex.toUpperCase();
    if (upper.startsWith('A000000152')) return 'BCA';
    if (upper.startsWith('A000000602') || upper.contains('GPN')) return 'GPN';
    if (upper.startsWith('A000000003')) return 'Visa';
    if (upper.startsWith('A000000004')) return 'Mastercard';
    if (upper.startsWith('A000000065')) return 'JCB';
    if (upper.startsWith('A000000333')) return 'UnionPay';
    if (upper.startsWith('A000000025')) return 'Amex';
  }

  if (pan != null && pan.isNotEmpty) {
    final clean = pan.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.startsWith('4')) return 'Visa';
    if (clean.startsWith(RegExp(r'^(5[1-5]|2[2-7])'))) return 'Mastercard';
    if (clean.startsWith(RegExp(r'^3[47]'))) return 'Amex';
    if (clean.startsWith(RegExp(r'^(6011|65|64[4-9])'))) return 'Discover';
    if (clean.startsWith(RegExp(r'^35(2[89]|[3-8][0-9])'))) return 'JCB';
    if (clean.startsWith('62')) return 'UnionPay';
    if (clean.startsWith(RegExp(r'^(1946|6032|6013|6014)'))) return 'GPN / Debit';
  }

  return 'Kartu Contactless';
}

/// Helper to identify Card Brand from AID RID (Backward Compatibility)
String brandFromAid(String aidHex) {
  return detectBrand(aidHex: aidHex);
}

/// Parse Track 2 Equivalent data (Tag 57): PAN before 'D' or '='
String? parseTrack2Pan(String track2Hex) {
  final clean = track2Hex.toUpperCase();
  final dIndex = clean.indexOf('D');
  if (dIndex != -1) {
    return clean.substring(0, dIndex);
  }
  final eqIndex = clean.indexOf('=');
  if (eqIndex != -1) {
    return clean.substring(0, eqIndex);
  }
  return null;
}

/// Search for PAN in arbitrary hex string using regex
String? findPanInHex(String hex) {
  final upper = hex.toUpperCase();

  // Pattern 1: Tag 57 (Track 2) header "57<len><pan>D"
  final tag57Match = RegExp(r'57[0-9A-F]{2}([3-6][0-9]{11,18})[D=]').firstMatch(upper);
  if (tag57Match != null) {
    return tag57Match.group(1);
  }

  // Pattern 2: Standard PAN with delimiter D or =
  final track2Match = RegExp(r'(4[0-9]{15}|5[1-5][0-9]{14}|2[2-7][0-9]{14}|3[47][0-9]{13}|35[0-9]{14}|6[0-9]{15})[D=]').firstMatch(upper);
  if (track2Match != null) {
    return track2Match.group(1);
  }

  // Pattern 3: Standalone 16-19 digit card PAN with valid IIN prefix
  final panMatch = RegExp(r'\b(4[0-9]{15}|5[1-5][0-9]{14}|2[2-7][0-9]{14}|3[47][0-9]{13}|35[0-9]{14}|6[0-9]{15})\b').firstMatch(upper);
  if (panMatch != null) {
    return panMatch.group(1);
  }

  return null;
}
