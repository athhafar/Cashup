import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'tlv_parser.dart';

enum CardReaderAvailability { available, disabled, unsupported }

enum CardReadError {
  cancelled,
  tagLost,
  unsupportedCard,
  timeout,
  nfcDisabled,
  parseFailed,
}

class CardReadException implements Exception {
  const CardReadException(this.error, [this.message]);
  final CardReadError error;
  final String? message;

  @override
  String toString() => 'CardReadException: $error ($message)';
}

class CardData {
  const CardData({
    required this.brand,
    required this.last4,
    required this.maskedPan,
    this.balance,
  });

  final String brand; // Visa, Mastercard, BCA, Permata, GPN, e-Money, dst.
  final String last4;
  final String maskedPan; // "•••• 4821"
  final int? balance; // Saldo kartu jika e-Money / Flazz (prepaid)
}

abstract class CardReader {
  Future<CardReaderAvailability> checkAvailability();
  Future<void> openSettings();

  /// Menunggu kartu, membaca data, lalu mengembalikannya.
  /// Melempar [CardReadException] dengan kode yang jelas.
  Future<CardData> readCard();

  Future<void> cancel();
}

/// Simulated Card Reader for demo / tests
class SimulatedCardReader implements CardReader {
  bool _isCancelled = false;
  bool simulateFailure = false;
  int? simulatedBalance;
  String simulatedBrand = 'Visa';
  String simulatedLast4 = '4821';

  @override
  Future<CardReaderAvailability> checkAvailability() async {
    return CardReaderAvailability.available;
  }

  @override
  Future<void> openSettings() async {}

  @override
  Future<CardData> readCard() async {
    _isCancelled = false;
    await Future.delayed(const Duration(milliseconds: 1400));
    if (_isCancelled) {
      throw const CardReadException(CardReadError.cancelled);
    }

    if (simulateFailure) {
      simulateFailure = false;
      throw const CardReadException(
        CardReadError.tagLost,
        'Kartu terlepas. Tempelkan ulang kartu dan jangan digeser.',
      );
    }

    final brand = simulatedBrand;
    final last4 = simulatedLast4;
    final bal = simulatedBalance;

    return CardData(
      brand: brand,
      last4: last4,
      maskedPan: '•••• $last4',
      balance: bal,
    );
  }

  @override
  Future<void> cancel() async {
    _isCancelled = true;
  }
}

/// Native Card Reader via Android NFC Hardware
class NativeCardReader implements CardReader {
  static const MethodChannel _channel = MethodChannel('mini_cashupay/nfc');
  static const EventChannel _eventChannel = EventChannel('mini_cashupay/nfc_events');

  StreamSubscription? _eventSubscription;
  Completer<CardData>? _readCompleter;

  @override
  Future<CardReaderAvailability> checkAvailability() async {
    try {
      final isAvail = await _channel.invokeMethod<bool>('isAvailable');
      if (isAvail != true) return CardReaderAvailability.unsupported;

      final isEnabled = await _channel.invokeMethod<bool>('isEnabled');
      if (isEnabled != true) return CardReaderAvailability.disabled;

      return CardReaderAvailability.available;
    } on MissingPluginException {
      return CardReaderAvailability.unsupported;
    } catch (_) {
      return CardReaderAvailability.unsupported;
    }
  }

  @override
  Future<void> openSettings() async {
    try {
      await _channel.invokeMethod('openSettings');
    } catch (_) {}
  }

  @override
  Future<CardData> readCard() async {
    final avail = await checkAvailability();
    if (avail == CardReaderAvailability.disabled) {
      throw const CardReadException(CardReadError.nfcDisabled);
    }
    if (avail == CardReaderAvailability.unsupported) {
      throw const CardReadException(CardReadError.unsupportedCard);
    }

    _readCompleter = Completer<CardData>();

    try {
      _eventSubscription = _eventChannel.receiveBroadcastStream().listen(
        (event) async {
          if (event is Map) {
            final type = event['type'];
            if (type == 'tagDiscovered') {
              final uid = event['uid'] as String? ?? '';
              final hasIsoDep = event['hasIsoDep'] == true;
              debugPrint('[NFC HARDWARE] Tag Discovered! UID: $uid, IsoDep: $hasIsoDep');
              _processTag(uid: uid, hasIsoDep: hasIsoDep);
            } else if (type == 'tagLost') {
              if (!(_readCompleter?.isCompleted ?? true)) {
                _readCompleter?.completeError(
                  const CardReadException(CardReadError.tagLost),
                );
              }
            } else if (type == 'error') {
              final code = event['code'];
              if (!(_readCompleter?.isCompleted ?? true)) {
                if (code == 'UNSUPPORTED_CARD') {
                  _readCompleter?.completeError(
                    const CardReadException(CardReadError.unsupportedCard),
                  );
                } else if (code == 'NFC_DISABLED') {
                  _readCompleter?.completeError(
                    const CardReadException(CardReadError.nfcDisabled),
                  );
                } else {
                  _readCompleter?.completeError(
                    const CardReadException(CardReadError.parseFailed),
                  );
                }
              }
            }
          }
        },
        onError: (err) {
          if (!(_readCompleter?.isCompleted ?? true)) {
            _readCompleter?.completeError(
              const CardReadException(CardReadError.parseFailed),
            );
          }
        },
      );

      await _channel.invokeMethod('startSession');
    } catch (e) {
      await cancel();
      throw CardReadException(CardReadError.parseFailed, e.toString());
    }

    return _readCompleter!.future.timeout(
      const Duration(seconds: 25),
      onTimeout: () {
        cancel();
        throw const CardReadException(CardReadError.timeout);
      },
    );
  }

  Future<void> _processTag({required String uid, required bool hasIsoDep}) async {
    try {
      final cleanUid = uid.replaceAll(RegExp(r'[^0-9A-Fa-f]'), '');
      final uidLast4 = cleanUid.length >= 4
          ? cleanUid.substring(cleanUid.length - 4).toUpperCase()
          : (cleanUid.isNotEmpty ? cleanUid.padLeft(4, '0').toUpperCase() : '0000');

      if (!hasIsoDep) {
        // Tag without IsoDep: use real hardware UID
        debugPrint('[NFC HARDWARE] Tag without IsoDep. Reading hardware UID: $cleanUid');
        _readCompleter?.complete(
          CardData(
            brand: 'Kartu Contactless',
            last4: uidLast4,
            maskedPan: '•••• $uidLast4',
          ),
        );
        return;
      }

      String chosenAid = '';
      String? rawPan;
      String? appLabel;
      int? readBalance;

      // 0. Check if card is Indonesian Prepaid E-Money / TapCash / Brizzi / Flazz
      try {
        // A. Mandiri e-Money (Spesifikasi Standar Nasional APDU Mandiri)
        const emoneySelect = '00A40400080000000000000001';
        final emResp = await _transceive(emoneySelect);
        debugPrint('[NFC HARDWARE] e-Money Select Response: $emResp');
        if (emResp.endsWith('9000')) {
          // Baca nomor kartu e-Money
          final numResp = await _transceive('00B300003F');
          debugPrint('[NFC HARDWARE] e-Money Number Response: $numResp');
          if (numResp.endsWith('9000') && numResp.length >= 20) {
            rawPan = numResp.substring(0, 16);
          }

          // Baca Saldo e-Money (Command 00B500000A)
          final balResp = await _transceive('00B500000A');
          debugPrint('[NFC HARDWARE] e-Money Balance Response: $balResp');
          if (balResp.endsWith('9000') && balResp.length >= 12) {
            final balBytes = hexToBytes(balResp.substring(0, balResp.length - 4));
            if (balBytes.length >= 4) {
              // Little-endian 4-byte unsigned integer
              var parsedBal = 0;
              for (var i = 0; i < 4; i++) {
                parsedBal += (balBytes[i] & 0xFF) << (i * 8);
              }
              if (parsedBal >= 0 && parsedBal <= 20000000) {
                readBalance = parsedBal;
                appLabel = 'Mandiri e-Money';
                debugPrint('[NFC HARDWARE] SUCCESS READ MANDIRI E-MONEY SALDO: Rp $readBalance');
              }
            }
          }
        }

        // B. BNI TapCash
        if (readBalance == null) {
          const tapcashSelect = '00A4040008A000424E49999999';
          final tcResp = await _transceive(tapcashSelect);
          if (tcResp.endsWith('9000')) {
            final tcBalResp = await _transceive('9032030000');
            if (tcBalResp.length >= 14) {
              final tcBytes = hexToBytes(tcBalResp);
              if (tcBytes.length >= 5) {
                final bal = ((tcBytes[2] & 0xFF) << 16) | ((tcBytes[3] & 0xFF) << 8) | (tcBytes[4] & 0xFF);
                readBalance = bal;
                appLabel = 'BNI TapCash';
                debugPrint('[NFC HARDWARE] SUCCESS READ BNI TAPCASH SALDO: Rp $readBalance');
              }
            }
          }
        }

        // C. BRI Brizzi
        if (readBalance == null) {
          const brizziSelect = '905A00000301000000';
          final brizziResp = await _transceive(brizziSelect);
          if (brizziResp.endsWith('9100') || brizziResp.endsWith('9000')) {
            final brizziBalResp = await _transceive('906C0000010000');
            if (brizziBalResp.length >= 12) {
              final brizziBytes = hexToBytes(brizziBalResp);
              if (brizziBytes.length >= 4) {
                final bal = ((brizziBytes[0] & 0xFF) << 24) | ((brizziBytes[1] & 0xFF) << 16) | ((brizziBytes[2] & 0xFF) << 8) | (brizziBytes[3] & 0xFF);
                if (bal >= 0 && bal <= 20000000) {
                  readBalance = bal;
                  appLabel = 'BRI Brizzi';
                  debugPrint('[NFC HARDWARE] SUCCESS READ BRI BRIZZI SALDO: Rp $readBalance');
                }
              }
            }
          }
        }
      } catch (e) {
        debugPrint('[NFC HARDWARE] Error probing prepaid card: $e');
      }

      // 1. SELECT PPSE (2PAY.SYS.DDF01)
      const ppseApdu = '00A404000E325041592E5359532E444446303100';
      final ppseResp = await _transceive(ppseApdu);
      debugPrint('[NFC HARDWARE] PPSE Response: $ppseResp');

      if (ppseResp.endsWith('9000')) {
        try {
          final tlvList = parseTlv(hexToBytes(ppseResp.substring(0, ppseResp.length - 4)));
          final aidTlv = findTag(tlvList, 0x4F);
          if (aidTlv != null) {
            chosenAid = bytesToHex(aidTlv.value);
            debugPrint('[NFC HARDWARE] Found AID from PPSE: $chosenAid');
          }
          final labelTlv = findTag(tlvList, 0x50);
          if (labelTlv != null) {
            appLabel = parseAscii(labelTlv.value);
          }
        } catch (_) {}
      }

      // 2. Candidate AIDs (Standard Visa, Mastercard, BCA, GPN, Permata, JCB)
      final candidateAids = [
        if (chosenAid.isNotEmpty) chosenAid,
        'A0000000031010', // Visa Credit/Debit (BCA/Permata Visa)
        'A0000000041010', // Mastercard (BCA Mastercard)
        'A0000001523010', // BCA Paspor Debit
        'A0000006020001', // GPN Chip Contactless
        'A0000000651010', // JCB
        'A0000000032010', // Visa Electron
        'A0000000042203', // Maestro
      ];

      for (final aid in candidateAids) {
        final aidLenHex = (aid.length ~/ 2).toRadixString(16).padLeft(2, '0').toUpperCase();
        final selectAidApdu = '00A40400$aidLenHex${aid}00';
        final aidResp = await _transceive(selectAidApdu);

        if (aidResp.endsWith('9000')) {
          chosenAid = aid;
          debugPrint('[NFC HARDWARE] Selected AID: $aid, Response: $aidResp');

          try {
            final aidTlv = parseTlv(hexToBytes(aidResp.substring(0, aidResp.length - 4)));
            // Check Tag 50 (Application Label e.g. "BCA PASPOR")
            final labelTlv = findTag(aidTlv, 0x50);
            if (labelTlv != null) {
              appLabel = parseAscii(labelTlv.value);
              debugPrint('[NFC HARDWARE] Application Label: $appLabel');
            }
            // Check Tag 5A (PAN)
            final panTlv = findTag(aidTlv, 0x5A);
            if (panTlv != null) {
              rawPan = bytesToHex(panTlv.value);
              break;
            }
            // Check Tag 57 (Track 2)
            final track2Tlv = findTag(aidTlv, 0x57);
            if (track2Tlv != null) {
              rawPan = parseTrack2Pan(bytesToHex(track2Tlv.value));
              break;
            }
          } catch (_) {}

          // 3. GET PROCESSING OPTIONS (GPO)
          const gpoApdu = '80A8000002830000';
          final gpoResp = await _transceive(gpoApdu);
          debugPrint('[NFC HARDWARE] GPO Response: $gpoResp');

          if (gpoResp.endsWith('9000')) {
            try {
              final gpoTlv = parseTlv(hexToBytes(gpoResp.substring(0, gpoResp.length - 4)));
              final panTlv = findTag(gpoTlv, 0x5A);
              if (panTlv != null) {
                rawPan = bytesToHex(panTlv.value);
                break;
              }
              final track2Tlv = findTag(gpoTlv, 0x57);
              if (track2Tlv != null) {
                rawPan = parseTrack2Pan(bytesToHex(track2Tlv.value));
                break;
              }
            } catch (_) {}

            // Try regex search in GPO raw hex
            final gpoFound = findPanInHex(gpoResp);
            if (gpoFound != null) {
              rawPan = gpoFound;
              break;
            }
          }

          // 4. Scan Records: SFI 1 to 4, Records 1 to 4
          for (var sfi = 1; sfi <= 4; sfi++) {
            for (var rec = 1; rec <= 4; rec++) {
              final p2Hex = ((sfi << 3) | 4).toRadixString(16).padLeft(2, '0').toUpperCase();
              final recHex = rec.toRadixString(16).padLeft(2, '0').toUpperCase();
              final readRecApdu = '00B2$recHex${p2Hex}00';
              final recResp = await _transceive(readRecApdu);

              if (recResp.endsWith('9000')) {
                debugPrint('[NFC HARDWARE] Record SFI $sfi Rec $rec: $recResp');
                try {
                  final recTlv = parseTlv(hexToBytes(recResp.substring(0, recResp.length - 4)));
                  // Check Tag 50 (App label)
                  final labelTlv = findTag(recTlv, 0x50);
                  if (labelTlv != null && appLabel == null) {
                    appLabel = parseAscii(labelTlv.value);
                  }
                  // Check Tag 5A (PAN)
                  final panTlv = findTag(recTlv, 0x5A);
                  if (panTlv != null) {
                    rawPan = bytesToHex(panTlv.value);
                    break;
                  }
                  // Check Tag 57 (Track 2)
                  final track2Tlv = findTag(recTlv, 0x57);
                  if (track2Tlv != null) {
                    rawPan = parseTrack2Pan(bytesToHex(track2Tlv.value));
                    break;
                  }
                } catch (_) {}

                // Regex search in record
                final recFound = findPanInHex(recResp);
                if (recFound != null) {
                  rawPan = recFound;
                  break;
                }
              }
            }
            if (rawPan != null) break;
          }

          if (rawPan != null) break;
        }
      }

      String brand;
      String realLast4;
      String maskedPan;

      if (rawPan != null && rawPan.isNotEmpty) {
        // Real card number extracted from chip!
        final fullPan = cleanPan(rawPan);
        realLast4 = fullPan.length >= 4 ? fullPan.substring(fullPan.length - 4) : fullPan;
        maskedPan = maskPan(fullPan);
        brand = detectBrand(pan: fullPan, aidHex: chosenAid, appLabel: appLabel);
        debugPrint('[NFC HARDWARE] Extracted Real Card PAN: $maskedPan, Brand: $brand');
      } else {
        // Card chip did not expose PAN (offline tokenized): use real hardware UID
        realLast4 = uidLast4;
        maskedPan = '•••• $realLast4';
        brand = detectBrand(aidHex: chosenAid, appLabel: appLabel);
        debugPrint('[NFC HARDWARE] Using real card hardware UID: $realLast4, Brand: $brand');
      }

      _readCompleter?.complete(
        CardData(
          brand: brand,
          last4: realLast4,
          maskedPan: maskedPan,
          balance: readBalance,
        ),
      );
    } catch (e) {
      debugPrint('[NFC HARDWARE] Error reading card: $e');
      final cleanUid = uid.replaceAll(RegExp(r'[^0-9A-Fa-f]'), '');
      final realLast4 = cleanUid.length >= 4
          ? cleanUid.substring(cleanUid.length - 4).toUpperCase()
          : '0000';
      _readCompleter?.complete(
        CardData(
          brand: 'Kartu Contactless',
          last4: realLast4,
          maskedPan: '•••• $realLast4',
        ),
      );
    }
  }

  Future<String> _transceive(String apdu) async {
    try {
      final resp = await _channel.invokeMethod<String>('transceive', {'apdu': apdu});
      return resp ?? '';
    } catch (_) {
      return '';
    }
  }

  @override
  Future<void> cancel() async {
    try {
      await _channel.invokeMethod('stopSession');
    } catch (_) {}
    await _eventSubscription?.cancel();
    _eventSubscription = null;
    if (_readCompleter != null && !_readCompleter!.isCompleted) {
      _readCompleter!.completeError(const CardReadException(CardReadError.cancelled));
    }
  }
}
