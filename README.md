# cashUPay Mini — SoftPOS Contactless Prototype

Aplikasi mini SoftPOS (penerimaan pembayaran kartu contactless lewat NFC) berbasis **Flutter + GetX**. Prototipe ini dikembangkan untuk keperluan portofolio/interview dan menggunakan **mock API in-memory & repository** (bukan produk pembayaran acquirer sungguhan).

---

## 1. Arsitektur & Alur Pembayaran

### Arsitektur Singkat
- **Pattern**: GetX State Management (Separation of UI, Controller, Repository, and Service layers).
- **Security**: Token session tersimpan di local secure storage (`GetStorage`), PAN lengkap tidak pernah disimpan/di-log/dikirim, hanya brand dan masked last-4 yang digunakan.
- **NFC Engine**:
  - `CardReader` Interface di Dart (`NativeCardReader` via Android MethodChannel & EventChannel, serta `SimulatedCardReader` untuk demo).
  - Parser TLV murni di Dart (`tlv_parser.dart`) untuk membaca template EMV PPSE & AID.
  - Native Kotlin Reader bridge (`NfcBridge.kt`) mengaktifkan `enableReaderMode` (IsoDep).

### Diagram Alur Pembayaran

```
[Splash] ─── Cek Token ───► [Login (Masuk)]
                                 │ (warung-maju / 123456)
                                 ▼
                          [Beranda Utama]
                                 │
                   Tekan "Terima pembayaran"
                                 ▼
                        [Nominal Pembayaran]
                       (Keypad 3×4 + Rupiah)
                                 │
                                 ▼
                           [Tap Kartu]
                 (Radar Wave NFC / Simulasi Tap)
                                 │
                          Kartu Terdeteksi
                                 ▼
                       [Proses Pembayaran]
           1. Baca Kartu ➔ 2. Kirim Server ➔ 3. Otorisasi
                                 │
                ┌────────────────┴────────────────┐
                ▼                                 ▼
      [Hasil Sukses (Struk)]            [Hasil Ditolak]
      - Nominal & Struk                 - Batas limit (> 5 jt)
      - Bagikan Struk                   - Tombol Coba Lagi
```

---

## 2. Cara Menjalankan

### Persyaratan
- Flutter SDK (≥ 3.11)
- Android SDK (untuk pengujian NFC fisik di perangkat Android)

### Menjalankan Aplikasi
```bash
# Ambil dependencies
flutter pub get

# Jalankan analyzer
flutter analyze

# Jalankan unit & widget test
flutter test

# Jalankan aplikasi di emulator atau device
flutter run
```

### Kredensial Login Demo
- **ID merchant**: `warung-maju`
- **PIN**: `123456`

### Penggunaan Mode Simulasi
1. Masuk ke tab **Akun** ➔ **Preferensi**.
2. Aktifkan **Mode simulasi tap** (aktif secara default).
3. Pada saat berada di layar **Tap kartu**, gunakan tombol:
   - **Simulasikan kartu**: Menghasilkan tap kartu Visa 4821 yang valid.
   - **Simulasi kartu lepas**: Mensimulasikan kegagalan kartu terlepas saat tap.
4. Input nominal **> Rp 5.000.000** akan otomatis disimulasikan sebagai transaksi **Ditolak** (`LIMIT_EXCEEDED`).

---

## 3. Keterbatasan Prototipe

- **Bukan Pembayaran Riil**: Aplikasi ini adalah prototipe portofolio, tidak terhubung ke acquirer atau payment gateway nyata.
- **EMV Kernel**: Tidak menggunakan kernel EMV Level 2 tersertifikasi (PCI CPoC/MPoC).
- **Platform NFC**: Implementasi hardware NFC native saat ini dioptimalkan untuk Android (iOS memerlukan sertifikasi Apple Tap to Pay / entitlement khusus).

---

## 4. Rencana Menuju Produk Produksi

Jika prototipe ini akan dikembangkan menjadi produk SoftPOS komersial:
1. **Sertifikasi Keamanan & Standar**:
   - Sertifikasi PCI CPoC / MPoC (Contactless Payments on COTS).
   - Integrasi EMVCo Level 2 Contactless Kernel yang tersertifikasi.
2. **Device Attestation & Proteksi Runtime**:
   - Google Play Integrity API / SafetyNet untuk deteksi root, hook (Frida, Xposed), emulator, dan debugging.
   - Hardware-backed Keystore untuk manajemen enkripsi.
3. **Komunikasi Jaringan**:
   - SSL Pinning / Certificate Pinning untuk pencegahan Man-in-the-Middle (MitM).
   - Transaksi end-to-end encryption (E2EE) langsung ke Hardware Security Module (HSM) acquirer.
4. **Dukungan iOS**:
   - Pendaftaran Apple Tap to Pay on iPhone SDK melalui program entitlement resmi Apple.
