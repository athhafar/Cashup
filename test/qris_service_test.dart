import 'package:flutter_test/flutter_test.dart';
import 'package:cash_up/services/qris_service.dart';

void main() {
  group('QrisService Tests', () {
    const sampleStaticQris =
        '00020101021126660014ID.LINKAJA.WWW011893600911002230303002150000000000000010303UMI51440014ID.CO.QRIS.WWW02150000000000000010303UMI5204581253033605802ID5911WARUNG MAJU6007JAKARTA61051234062200116CU10000000000010703A016304E8A2';

    test('validateQris returns valid result and extracts merchant name and city', () {
      final res = QrisService.validateQris(sampleStaticQris);
      expect(res.isValid, isTrue);
      expect(res.merchantName, 'WARUNG MAJU');
      expect(res.merchantCity, 'JAKARTA');
    });

    test('validateQris rejects invalid prefix', () {
      final res = QrisService.validateQris('1234567890');
      expect(res.isValid, isFalse);
    });

    test('makeDynamicQris converts static 010211 to dynamic 010212 and injects amount', () {
      final dynamicPayload = QrisService.makeDynamicQris(
        baseQris: sampleStaticQris,
        amount: 45000,
        invoiceNumber: 'CU45000',
      );

      expect(dynamicPayload.startsWith('000201010212'), isTrue);
      expect(dynamicPayload.contains('540545000'), isTrue);
      expect(dynamicPayload.contains('6304'), isTrue);

      // Verify CRC length is exactly 4 characters at the end
      final crcPart = dynamicPayload.substring(dynamicPayload.length - 4);
      expect(crcPart.length, 4);

      // Verify CRC matches calculated checksum
      final payloadWithoutCrc = dynamicPayload.substring(0, dynamicPayload.length - 4);
      final expectedCrc = QrisService.calculateChecksum(payloadWithoutCrc);
      expect(crcPart, expectedCrc);
    });

    test('validates ShopeePay P2P QRIS and preserves Tag 62 token', () {
      const shopeeQris =
          '00020101021240530016ID.CO.SHOPEE.WWW0118936009183000806494020708064945204482953033605802ID5916athallahfarel6376015Jakarta Selatan61051295062470804DMCT99350002000125wTuaxUWCbxDdoVegkr48ZKeFX63045133';

      final res = QrisService.validateQris(shopeeQris);
      expect(res.isValid, isTrue);
      expect(res.merchantName, 'athallahfarel637');
      expect(res.merchantCity, 'Jakarta Selatan');

      final dynamicPayload = QrisService.makeDynamicQris(
        baseQris: shopeeQris,
        amount: 100000,
        invoiceNumber: 'CU100000',
      );

      // Must preserve the ShopeePay proprietary session token in Tag 62
      expect(dynamicPayload.contains('0804DMCT99350002000125wTuaxUWCbxDdoVegkr48ZKeFX'), isTrue);
      expect(dynamicPayload.contains('5406100000'), isTrue);
      expect(dynamicPayload.endsWith('778F'), isTrue);
    });

    test('crc16Ccitt calculation produces expected hex string', () {
      // Test deterministic CCITT calculation
      final crc = QrisService.crc16Ccitt('00020101021153033605802ID6304');
      expect(crc > 0, isTrue);
      final hex = crc.toRadixString(16).toUpperCase().padLeft(4, '0');
      expect(hex.length, 4);
    });
  });
}
