import 'dart:typed_data';
import 'package:cash_up/services/tlv_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TLV Parser Tests', () {
    test('parse simple TLV tag and value', () {
      // Tag 0x82 (2 bytes length 2), value: 0x12 0x34
      final data = Uint8List.fromList([0x82, 0x02, 0x12, 0x34]);
      final result = parseTlv(data);
      expect(result.length, 1);
      expect(result.first.tag, 0x82);
      expect(result.first.value, [0x12, 0x34]);
    });

    test('parse constructed TLV tag with children', () {
      // Tag 0x6F (FCI Template, constructed): contains tag 0x84 (length 3, 0x01 0x02 0x03)
      final data = Uint8List.fromList([
        0x6F, 0x05, // Tag 6F len 5
        0x84, 0x03, 0x01, 0x02, 0x03, // Tag 84 len 3
      ]);
      final result = parseTlv(data);
      expect(result.length, 1);
      expect(result.first.tag, 0x6F);
      expect(result.first.children.length, 1);
      expect(result.first.children.first.tag, 0x84);
      expect(result.first.children.first.value, [0x01, 0x02, 0x03]);
    });

    test('findTag searches recursively', () {
      final data = Uint8List.fromList([
        0x6F, 0x07,
        0xA5, 0x05,
        0x88, 0x03, 0xAA, 0xBB, 0xCC,
      ]);
      final result = parseTlv(data);
      final found = findTag(result, 0x88);
      expect(found, isNotNull);
      expect(found!.value, [0xAA, 0xBB, 0xCC]);
    });
  });

  group('EMV Helper Functions', () {
    test('maskPan masks all but last 4 digits', () {
      expect(maskPan('4111111111114821'), '•••• 4821');
      expect(maskPan('4821'), '•••• 4821');
      expect(maskPan(''), '••••');
    });

    test('brandFromAid identifies Visa, Mastercard, GPN, JCB, etc.', () {
      expect(brandFromAid('A0000000031010'), 'Visa');
      expect(brandFromAid('A0000000041010'), 'Mastercard');
      expect(brandFromAid('A0000000651010'), 'JCB');
      expect(brandFromAid('A0000003330101'), 'UnionPay');
      expect(brandFromAid('A0000006020001'), 'GPN');
    });

    test('parseTrack2Pan extracts PAN correctly', () {
      expect(
        parseTrack2Pan('5413330089020011D251220100000000'),
        '5413330089020011',
      );
      expect(
        parseTrack2Pan('4111222233334444=281200000000'),
        '4111222233334444',
      );
    });

    test('findPanInHex extracts real PAN from arbitrary APDU bytes', () {
      expect(
        findPanInHex('771E9F2701009F3602001057134111222233334444D2512201000000009000'),
        '4111222233334444',
      );
    });

    test('detectBrand identifies brand from PAN, AID, or Label', () {
      expect(detectBrand(pan: '4111222233334444'), 'Visa');
      expect(detectBrand(pan: '5412345678901234'), 'Mastercard');
      expect(detectBrand(appLabel: 'BCA PASPOR'), 'BCA');
      expect(detectBrand(appLabel: 'PERMATA DEBIT'), 'Permata');
      expect(detectBrand(aidHex: 'A0000006020001'), 'GPN');
    });
  });
}
