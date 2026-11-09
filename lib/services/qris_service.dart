import 'dart:developer' as dev;

/// Service to parse, validate, and dynamically construct EMVCo Bank Indonesia QRIS payloads.
class QrisService {
  /// Default demo static QRIS payload (Bank Indonesia Standard format)
  static const String defaultStaticQris =
      '00020101021126660014ID.LINKAJA.WWW011893600911002230303002150000000000000010303UMI51440014ID.CO.QRIS.WWW02150000000000000010303UMI5204581253033605802ID5911WARUNG MAJU6007JAKARTA61051234062200116CU10000000000010703A016304';

  /// Standard CRC-16 / CCITT-FALSE (Polynomial: 0x1021, Init: 0xFFFF)
  /// Used by EMVCo and Bank Indonesia ASPI standards.
  static int crc16Ccitt(String data) {
    int crc = 0xFFFF;
    for (int i = 0; i < data.length; i++) {
      crc ^= (data.codeUnitAt(i) << 8);
      for (int j = 0; j < 8; j++) {
        if ((crc & 0x8000) != 0) {
          crc = ((crc << 1) ^ 0x1021) & 0xFFFF;
        } else {
          crc = (crc << 1) & 0xFFFF;
        }
      }
    }
    return crc & 0xFFFF;
  }

  /// Calculates the 4-character hex CRC string for the payload up to '6304'
  static String calculateChecksum(String payloadWith6304) {
    final crc = crc16Ccitt(payloadWith6304);
    return crc.toRadixString(16).toUpperCase().padLeft(4, '0');
  }

  /// Sanitizes and extracts the pure EMVCo QRIS string from user input
  static String sanitizePayload(String raw) {
    // Strip carriage returns, newlines, tabs, and quotes (preserve valid spaces in merchant names)
    String clean = raw.replaceAll(RegExp(r'[\r\n\t"\x27]'), '').trim();

    // If copied with prefix like 'QRIS: 000201...'
    final startIdx = clean.indexOf('000201');
    if (startIdx != -1) {
      clean = clean.substring(startIdx);
    }
    return clean;
  }

  /// Parses TLV (Tag-Length-Value) entries from an EMVCo QRIS string.
  static Map<String, String> parseTlv(String qris) {
    final Map<String, String> tags = {};
    int i = 0;
    final clean = sanitizePayload(qris);

    while (i + 4 <= clean.length) {
      final tag = clean.substring(i, i + 2);
      final len = int.tryParse(clean.substring(i + 2, i + 4));
      if (len == null || len < 0) break;
      if (i + 4 + len > clean.length) {
        // Tag length exceeds remaining string
        break;
      }
      final val = clean.substring(i + 4, i + 4 + len);
      tags[tag] = val;
      i += 4 + len;
    }
    return tags;
  }

  /// Robust extractor for a specific tag ID with fallback to regex scan
  static String? extractTag(String qris, String tagId) {
    final clean = sanitizePayload(qris);
    final tags = parseTlv(clean);
    if (tags.containsKey(tagId)) return tags[tagId];

    final pattern = RegExp('$tagId([0-9]{2})');
    for (final match in pattern.allMatches(clean)) {
      final len = int.tryParse(match.group(1) ?? '');
      if (len != null && len > 0) {
        final start = match.end;
        if (start + len <= clean.length) {
          return clean.substring(start, start + len);
        }
      }
    }
    return null;
  }

  /// Validates a raw QRIS string.
  static QrisValidationResult validateQris(String rawQris) {
    final clean = sanitizePayload(rawQris);
    if (clean.isEmpty) {
      return const QrisValidationResult(
        isValid: false,
        message: 'Payload QRIS tidak boleh kosong',
      );
    }

    if (rawQris.trim().toLowerCase().startsWith('http://') ||
        rawQris.trim().toLowerCase().startsWith('https://')) {
      return const QrisValidationResult(
        isValid: false,
        message:
            'Teks berupa tautan Web/URL (https://...). QRIS resmi Bank Indonesia harus berupa string kode teks yang diawali "000201". Silakan scan gambar QRIS Anda menggunakan Google Lens untuk menyalin string teksnya.',
      );
    }

    if (!clean.startsWith('000201')) {
      return const QrisValidationResult(
        isValid: false,
        message:
            'Format QRIS tidak valid. Standar Bank Indonesia harus diawali dengan Tag "000201".',
      );
    }

    final upper = clean.toUpperCase();
    if (!upper.contains('5802ID')) {
      return const QrisValidationResult(
        isValid: false,
        message: 'Bukan QRIS Indonesia (Tag 58 negara harus bernilai "5802ID")',
      );
    }

    final tags = parseTlv(clean);
    final merchantName = tags['59'] ?? extractTag(clean, '59') ?? 'Merchant Terdaftar';
    final merchantCity = tags['60'] ?? extractTag(clean, '60') ?? 'Indonesia';

    // Check NMID or Acquirer in tag 51 or 26-45
    String? nmid;
    if (tags.containsKey('51')) {
      final subTags = parseTlv(tags['51']!);
      nmid = subTags['02'] ?? tags['51'];
    } else {
      nmid = extractTag(clean, '51');
    }

    if (nmid == null) {
      for (int t = 26; t <= 45; t++) {
        final tagStr = t.toString().padLeft(2, '0');
        if (tags.containsKey(tagStr)) {
          final sub = parseTlv(tags[tagStr]!);
          nmid = sub['01'] ?? sub['00'] ?? tags[tagStr];
          break;
        }
      }
    }

    return QrisValidationResult(
      isValid: true,
      message: 'Format QRIS Valid',
      merchantName: merchantName,
      merchantCity: merchantCity,
      nmid: nmid,
      parsedTags: tags,
    );
  }

  /// Converts a static QRIS into a dynamic QRIS with an injected nominal amount and valid CRC.
  /// This allows real banking apps (BCA, Mandiri, Permata, GoPay, etc.) to scan and route the funds!
  static String makeDynamicQris({
    required String baseQris,
    required int amount,
    String? invoiceNumber,
  }) {
    String clean = sanitizePayload(baseQris);

    // 1. Remove existing CRC Tag 63 if present
    final upper = clean.toUpperCase();
    final crcIdx = upper.indexOf('6304');
    if (crcIdx != -1) {
      clean = clean.substring(0, crcIdx);
    }

    // 2. Change QR Type: Tag 01 from '11' (Static) to '12' (Dynamic)
    if (clean.contains('010211')) {
      clean = clean.replaceFirst('010211', '010212');
    }

    // 3. Strip existing Tag 54 (Amount) if present
    final match54 = RegExp(r'54[0-9]{2}[0-9]+(\.[0-9]{2})?').firstMatch(clean);
    if (match54 != null) {
      clean = clean.replaceRange(match54.start, match54.end, '');
    }

    // 4. Construct new Tag 54: 54 + length (2 digits) + amount
    final amountStr = amount.toString();
    final tag54 = '54${amountStr.length.toString().padLeft(2, '0')}$amountStr';

    // 5. Insert Tag 54 before Tag 58 (Country Code '5802ID')
    final tag58Idx = clean.toUpperCase().indexOf('5802ID');
    if (tag58Idx != -1) {
      clean = clean.substring(0, tag58Idx) + tag54 + clean.substring(tag58Idx);
    } else {
      clean += tag54;
    }

    // 6. Handle Tag 62 (Additional Data) safely:
    // If the base QRIS already contains Tag 62 (such as ShopeePay P2P token, DMCT, or merchant reference),
    // we MUST preserve it so we do not break the acquirer's transaction verification!
    // Only inject our own invoice number if Tag 62 does not already exist.
    final tags = parseTlv(clean);
    if (!tags.containsKey('62') && invoiceNumber != null && invoiceNumber.isNotEmpty) {
      final invoiceTag = '01${invoiceNumber.length.toString().padLeft(2, '0')}$invoiceNumber';
      final tag62 = '62${invoiceTag.length.toString().padLeft(2, '0')}$invoiceTag';
      clean += tag62;
    }

    // 7. Append Tag 63 length 04
    clean += '6304';

    // 8. Calculate CRC16-CCITT and append
    final crc = calculateChecksum(clean);
    final finalPayload = clean + crc;

    dev.log('[QRIS Service] Generated dynamic payload: $finalPayload');
    return finalPayload;
  }
}

class QrisValidationResult {
  final bool isValid;
  final String message;
  final String? merchantName;
  final String? merchantCity;
  final String? nmid;
  final Map<String, String>? parsedTags;

  const QrisValidationResult({
    required this.isValid,
    required this.message,
    this.merchantName,
    this.merchantCity,
    this.nmid,
    this.parsedTags,
  });
}
