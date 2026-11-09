# Mini CashUPay — Brief untuk AI Agent

Aplikasi mini SoftPOS (terima pembayaran kartu contactless lewat NFC) berbasis **Flutter + GetX**. Ini prototipe untuk keperluan portofolio/interview, **bukan produk pembayaran sungguhan**. Transaksi dikirim ke **mock API**, bukan ke acquirer.

Baca seluruh dokumen ini sebelum menulis kode.

---

## 0. Aturan utama (paling penting)

1. **Ikuti struktur dan kultur project yang sudah ada.** Jangan membuat arsitektur baru.
   - Sebelum menulis apa pun, pelajari: struktur folder, penamaan file/class, pola GetX yang dipakai (bindings, controllers, routes, middleware), cara project mengelola theme, HTTP client, storage, error handling, dan localization.
   - Semua kode baru harus terlihat seperti ditulis oleh orang yang sama dengan kode yang sudah ada.
   - Jika project sudah punya komponen setara (button, text field, dialog, snackbar, api client, theme), **pakai itu**, jangan duplikasi.
2. **Jangan menambah package** jika yang sudah ada bisa memenuhi kebutuhan. Setiap package baru harus kamu sebutkan alasannya di akhir pekerjaan.
3. **Jangan refactor kode di luar scope** brief ini.
4. Kerjakan **bertahap sesuai urutan di bagian 11**, dan pastikan `flutter analyze` bersih di setiap tahap.
5. Jika ada keputusan yang tidak tercakup di sini, pilih yang paling konsisten dengan kode yang sudah ada, lalu catat di bagian "Asumsi" pada laporan akhir.

> Contoh nama folder/class di dokumen ini hanya **ilustrasi**. Ganti dengan konvensi project yang sebenarnya.

---

## 1. Referensi desain

| Referensi | Isi | Link |
|---|---|---|
| Kanvas desain (statis) | 6 layar: Masuk, Beranda, Nominal, Tap kartu, Hasil sukses, Riwayat | https://claude.ai/artifact/CDTyCuMe15i8J9zDGxZu79 |
| Prototipe HTML (interaktif) | 11 layar lengkap dengan animasi, tapi **gaya visual lama** | https://claude.ai/artifact/PuS3cLUYbfQ9vEU8CJ19MG |

- Untuk **tampilan visual**, ikuti kanvas desain dan spesifikasi di bagian 4 dan 5.
- Untuk **perilaku dan animasi**, prototipe HTML boleh dipakai sebagai gambaran alur.
- Jika link tidak bisa dibuka, ikuti spesifikasi teks di dokumen ini. Itu sudah cukup.
- Logo asli cashUPay belum tersedia. Pakai **wordmark teks** "cashUPay" + badge "Mini" sebagai placeholder, dalam satu widget (`BrandWordmark`) supaya mudah diganti dengan aset logo.

---

## 2. Scope fitur

**Wajib**
1. Login merchant ke mock API, token disimpan di `flutter_secure_storage`.
2. Dashboard: total penjualan hari ini, jumlah transaksi, tombol "Terima pembayaran".
3. Input nominal dengan keypad custom dan format Rupiah.
4. Tap kartu NFC: baca kartu contactless, tampilkan brand dan PAN yang di-mask.
5. Proses transaksi ke mock API, lalu layar hasil (sukses/gagal) dengan struk.
6. Riwayat transaksi: list, pull-to-refresh, pagination, halaman/sheet detail.

**Bagus kalau ada waktu**
7. Void/batalkan transaksi.
8. Filter riwayat berdasarkan status.
9. Mode simulasi tap (untuk demo tanpa kartu).
10. Dark mode.
11. Ringkasan penjualan (grafik 7 hari + rincian per kartu).

**Di luar scope** (jangan dikerjakan kecuali diminta): biometrik, ekspor PDF, antrean offline dengan database lokal, multi-bahasa, dukungan NFC di iOS.

---

## 3. Alur aplikasi

```
Splash → Login → Beranda ─┬─ Terima pembayaran → Nominal → Tap kartu → Proses → Hasil → Beranda
                          ├─ Riwayat → Detail (sheet) → Void (konfirmasi)
                          ├─ Ringkasan
                          └─ Akun/Pengaturan → Keluar → Login
```

Bottom navigation (3 tab): **Beranda, Riwayat, Akun**. Hanya tampil di tiga layar tab tersebut.

State alur pembayaran (gunakan sealed class atau enum sesuai kebiasaan project, di dalam controller):

```
idle → waitingCard → reading → processing → success | failed(reason)
```

---

## 4. Design tokens

Petakan ke `ThemeData`/sistem theme yang sudah ada di project. Jangan hardcode warna di widget.

### Warna (mode terang)

| Token | Hex | Pemakaian |
|---|---|---|
| `ink` | `#0B1220` | teks utama, header gelap, layar Tap, kartu saldo |
| `ground` | `#F4F5F7` | latar layar |
| `surface` | `#FFFFFF` | kartu, input, bottom bar |
| `line` | `#E4E7EC` | border dan pemisah |
| `muted` | `#5B6577` | teks sekunder |
| `accent` | `#1F4DFF` | tombol utama, tab aktif, link |
| `accentSoft` | `#8FA8FF` | huruf "U" pada wordmark di latar gelap, garis grafik |
| `success` | `#00875A` (bg `#E3F6EE`, teks `#006B47`) | status berhasil |
| `danger` | `#B4132B` (bg `#FDE8EC`) | status ditolak, tombol batalkan |
| `warning` | teks `#8A5200` (bg `#FFF0D4`) | status dibatalkan |
| `onDarkMuted` | `#A9B4CC` | teks sekunder di atas latar `ink` |

### Warna (mode gelap)

`ground #070F1F`, `surface #0F1A30`, `line #1F2D49`, teks `#E9EEFB`, `muted #8E9BB5`, `accent #4B8BFF`, chip bg `#16284D`. Status mengikuti versi gelap yang kontrasnya tetap ≥ 4.5:1.

### Warna badge brand kartu

Visa `#1A3FC4`, Mastercard `#C2410C`, GPN `#9F1239`, lainnya `ink`. Badge berupa kotak 42×42 radius 12 dengan 2 huruf awal brand (putih, 12/800).

### Tipografi

Keluarga: **Manrope** (400/500/600/700/800). Pakai `google_fonts` jika sudah ada di project, jika tidak bundel sebagai asset. Gunakan angka tabular untuk nominal bila tersedia.

| Peran | Ukuran / berat | Letter spacing |
|---|---|---|
| Nominal besar (layar Nominal) | 52 / 800 | -0.04em |
| Nominal di layar Tap/Hasil | 46 / 800 dan 40 / 800 | -0.04em |
| Total di kartu saldo | 36 / 800 | -0.03em |
| Judul layar | 24–28 / 800 | -0.03em |
| Heading section | 17–18 / 800 | 0 |
| Body | 15 / 500–600 | 0 |
| Caption | 13 / 600 | 0 |
| Label tab | 12 / 700 | 0 |

### Bentuk dan jarak

- Radius: tombol/input/chip **12**, kartu dan baris list **14**, kartu saldo **20**, bottom sheet atas **24**, tag status **6**. Hindari radius lebih besar dari ini. Tampilan harus tegas, bukan "bulat-bulat".
- Grid 4pt. Padding layar horizontal **20**.
- Tinggi minimum target sentuh **48**. Tombol utama tinggi **56**.
- Border 1px `line` untuk kartu/input. Bayangan hanya dipakai sangat sedikit.
- Tidak ada emoji sebagai ikon. Pakai ikon stroke 2px (pakai set ikon yang sudah ada di project, atau Material Symbols rounded).

---

## 5. Spesifikasi layar

Semua layar harus punya state: **loading, kosong, error** (di mana relevan).

### 5.1 Splash
Latar `ink`. Tengah: wordmark putih ("cash" putih, "U" `accentSoft`, "Pay" putih) + badge "Mini". Indikator loading tipis 120×3 di bawahnya. Durasi ±1.5 s, lalu cek token: ada → Beranda, tidak ada → Login.

### 5.2 Login
- Latar `ink`, dekorasi lingkaran konsentris tipis di kanan atas (stroke `#2B3F7A`).
- Atas: wordmark; headline "Terima kartu langsung dari ponsel." (38/800, putih); sub "Ubah smartphone Android jadi mesin EDC. Tanpa perangkat tambahan." (15, `onDarkMuted`).
- Bawah: sheet putih, radius atas 24, padding 24. Judul "Masuk sebagai merchant", field **ID merchant** dan **PIN** (tinggi 54, radius 12, bg `ground`, label di atas), tombol "Masuk" (loading spinner saat proses). Catatan kecil: "Prototipe dengan mock API. Tidak ada transaksi sungguhan."
- Error login tampil inline di bawah field (bukan hanya snackbar).

### 5.3 Beranda
- Header: avatar kotak 44 radius 12 (inisial, bg `ink`), "Halo," + nama merchant, tombol notifikasi 48×48.
- **Kartu saldo** (bg `ink`, radius 20, padding 20): label "Penjualan hari ini", total (36/800 putih), "▲ 12% dari kemarin" (hijau muda), sparkline area (garis `accentSoft`, isi `accent` opacity 0.25), baris statistik dipisah garis: **Transaksi, Rata-rata, Berhasil (%)**.
- Tombol utama penuh lebar "Terima pembayaran" dengan ikon contactless. Efek kilau halus lewat di atas tombol secara berkala (opsional, hormati reduced motion).
- Section "Transaksi terbaru" + tautan "Lihat semua". 3 baris transaksi.
- Pull-to-refresh.

### 5.4 Nominal
- App bar: tombol kembali + "Nominal pembayaran".
- Tengah: label "Jumlah pembayaran", nominal 52/800 (format `Rp 125.000`), chip cepat **Rp 25 rb / 50 rb / 100 rb** (tinggi 44, radius 12).
- Keypad 3×4 tanpa border (tombol transparan, angka 28/600, tinggi 60): `1–9, 000, 0, ⌫`. Tekan: scale 0.95 + haptic ringan. Maksimum 9 digit.
- Tombol "Lanjut ke kartu", nonaktif jika nominal 0.
- Nominal berdenyut kecil (scale 1.04, ±110 ms) setiap input.

### 5.5 Tap kartu
- Latar penuh `ink`. App bar: tombol tutup (X) + "Tap kartu".
- Tengah: ikon contactless dalam kotak 100×100 radius 28 warna `accent`, dikelilingi **3 cincin** (stroke `#4D74FF`) yang memancar bergantian (scale 0.45→1.1, opacity 0.7→0, siklus 2.6 s, selisih 0.85 s).
- Di bawahnya: nominal 46/800 putih, "Dekatkan kartu ke bagian belakang ponsel" (`onDarkMuted`).
- Bawah: teks brand yang didukung ("Visa · Mastercard · GPN · JCB · UnionPay") dan tombol "Batalkan" (outline).
- Saat mode simulasi aktif, tampilkan tombol tambahan "Simulasikan tap kartu" dan "Simulasikan kartu gagal terbaca".
- Saat kartu terdeteksi: kartu ilustrasi (gradien oranye→merah, 140×88) meluncur dari bawah ke tengah (±600 ms), lalu pindah ke Proses.
- **State khusus:** NFC mati → panel dengan penjelasan + tombol "Buka pengaturan NFC"; perangkat tanpa NFC → pesan jelas + tawaran mode simulasi.

### 5.6 Proses
Spinner di dalam kotak `ink`, judul "Memproses pembayaran", 3 langkah yang tercentang berurutan (±750 ms per langkah): **Membaca kartu → Mengirim ke server → Menunggu otorisasi**. Sinkronkan dengan state sebenarnya (jangan hanya animasi palsu); durasi minimum agar terbaca.

### 5.7 Hasil
- **Sukses:** lingkaran 88 (`#E3F6EE`) dengan centang yang tergambar (stroke draw ±500 ms, ikon scale-in dengan sedikit overshoot), judul "Pembayaran berhasil", nominal 40/800.
- **Gagal:** lingkaran `danger-bg` dengan silang, judul "Pembayaran ditolak", alasan spesifik di bawahnya (lihat tabel error di 8.4). Tombol "Coba lagi" dan "Selesai".
- Kartu struk (radius 18, border `line`): Kartu (`Visa •••• 4821`), Waktu, garis putus-putus, No. referensi, Status.
- Tombol "Selesai" (primer) dan "Bagikan struk" (sekunder, bisa berupa share teks sederhana).
- Tombol back sistem diarahkan ke Beranda, bukan kembali ke layar Proses.

### 5.8 Riwayat
- Judul "Riwayat" (28/800), kolom pencarian (referensi/kartu), chip filter: **Semua, Berhasil, Ditolak, Dibatalkan** (chip aktif: bg `ink`, teks putih).
- Dikelompokkan per tanggal ("Hari ini, 9 Nov"). Baris: badge brand, `Brand •••• 1234`, jam, nominal, tag status.
- Pull-to-refresh, pagination (load lebih banyak saat mendekati akhir), empty state "Belum ada transaksi di kategori ini."
- Ketuk baris → sheet detail.

### 5.9 Detail transaksi (bottom sheet)
Radius atas 14–24, handle di atas. Isi sama dengan kartu struk. Jika status **Berhasil**, ada tombol "Batalkan transaksi" (merah). Ketuk → sheet konfirmasi: "Batalkan transaksi ini?" + penjelasan + "Ya, batalkan transaksi" / "Kembali". Setelah berhasil: sheet tertutup, status berubah menjadi Dibatalkan, tampil toast "Transaksi dibatalkan".

### 5.10 Ringkasan
App bar "Ringkasan penjualan". Total 7 hari (angka naik dari 0), grafik batang 7 hari (batang terakhir `accent`, lainnya `accentSoft` pucat; batang tumbuh dari bawah ±800 ms), lalu "Berdasarkan kartu" berupa progress bar per brand (warna brand) dengan nominal.

### 5.11 Akun / Pengaturan
Kartu profil merchant (nama, MID, kota). Grup toggle: **Mode gelap**, **Mode simulasi tap**. Grup info: Tentang aplikasi (versi), Bantuan. Tombol "Keluar" (bg `danger-bg`, teks `danger`) menghapus token lalu ke Login.

### 5.12 Aksesibilitas dan motion
- Kontras teks ≥ 4.5:1. Jangan mengandalkan warna saja untuk status (selalu ada label teks).
- Ikon tombol tanpa teks harus punya `Semantics`/tooltip.
- Hormati `MediaQuery.disableAnimations` (matikan animasi dekoratif).

---

## 6. Arsitektur NFC

### 6.1 Prinsip
- Logika bisnis ada di **Dart**; sisi native (Kotlin) dibuat **setipis mungkin**: hanya mengelola sesi reader dan meneruskan APDU mentah.
- Controller GetX **tidak boleh** bergantung langsung pada MethodChannel. Ia bergantung pada interface `CardReader` yang di-inject lewat binding.
- Tiga implementasi:
  - `NativeCardReader`: MethodChannel + EventChannel ke Android.
  - `SimulatedCardReader`: menghasilkan data kartu palsu, dipakai untuk demo dan unit test.
  - Di iOS atau perangkat tanpa NFC, `NativeCardReader` melaporkan `unsupported`, bukan crash.
- Pemilihan implementasi mengikuti flag mode simulasi (Pengaturan) dan ketersediaan NFC.

### 6.2 Kontrak channel

| Nama | Nilai |
|---|---|
| MethodChannel | `mini_cashupay/nfc` |
| EventChannel | `mini_cashupay/nfc_events` |

Method (Dart → native):

| Method | Argumen | Hasil |
|---|---|---|
| `isAvailable` | — | `bool` |
| `isEnabled` | — | `bool` |
| `openSettings` | — | `null` |
| `startSession` | — | `null` |
| `stopSession` | — | `null` |
| `transceive` | `{apdu: String}` (hex) | `String` (hex respons, termasuk SW1SW2) |

Event (native → Dart), map dengan kunci `type`: `tagDiscovered`, `tagLost`, `error` (`code`: `UNSUPPORTED_CARD`, `CONNECT_FAILED`, `NFC_DISABLED`).

Error dari `transceive` memakai `PlatformException` dengan kode `TAG_LOST`, `TIMEOUT`, atau `IO_ERROR`.

### 6.3 Android (Kotlin) — kerangka

Sesuaikan `package`, tempat registrasi (biasanya `MainActivity.configureFlutterEngine`), dan gaya kode dengan project.

**AndroidManifest.xml**
```xml
<uses-permission android:name="android.permission.NFC" />
<uses-feature android:name="android.hardware.nfc" android:required="false" />
```
(`required="false"` agar app tetap bisa dipasang di perangkat tanpa NFC; mode simulasi tetap jalan.)

**NfcBridge.kt**
```kotlin
class NfcBridge(
    private val activity: Activity,
    messenger: BinaryMessenger
) : MethodChannel.MethodCallHandler, EventChannel.StreamHandler {

    private val adapter: NfcAdapter? = NfcAdapter.getDefaultAdapter(activity)
    private val main = Handler(Looper.getMainLooper())
    private var sink: EventChannel.EventSink? = null
    @Volatile private var isoDep: IsoDep? = null

    init {
        MethodChannel(messenger, "mini_cashupay/nfc").setMethodCallHandler(this)
        EventChannel(messenger, "mini_cashupay/nfc_events").setStreamHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "isAvailable" -> result.success(adapter != null)
            "isEnabled" -> result.success(adapter?.isEnabled == true)
            "openSettings" -> {
                activity.startActivity(Intent(Settings.ACTION_NFC_SETTINGS))
                result.success(null)
            }
            "startSession" -> { startReader(); result.success(null) }
            "stopSession" -> { stopReader(); result.success(null) }
            "transceive" -> transceive(call.argument<String>("apdu"), result)
            else -> result.notImplemented()
        }
    }

    private fun startReader() {
        val a = adapter ?: return emit("error", "code" to "NFC_DISABLED")
        if (!a.isEnabled) return emit("error", "code" to "NFC_DISABLED")
        a.enableReaderMode(
            activity,
            { tag ->
                val iso = IsoDep.get(tag)
                    ?: return@enableReaderMode emit("error", "code" to "UNSUPPORTED_CARD")
                try {
                    iso.connect()
                    iso.timeout = 5000
                    isoDep = iso
                    emit("tagDiscovered")
                } catch (e: IOException) {
                    emit("error", "code" to "CONNECT_FAILED")
                }
            },
            NfcAdapter.FLAG_READER_NFC_A or NfcAdapter.FLAG_READER_NFC_B or
                NfcAdapter.FLAG_READER_SKIP_NDEF_CHECK,
            null
        )
    }

    private fun stopReader() {
        adapter?.disableReaderMode(activity)
        try { isoDep?.close() } catch (_: IOException) {}
        isoDep = null
    }

    private fun transceive(hex: String?, result: MethodChannel.Result) {
        val iso = isoDep
        if (hex == null || iso == null || !iso.isConnected) {
            return result.error("TAG_LOST", "Tidak ada kartu terhubung", null)
        }
        Thread {
            try {
                val resp = iso.transceive(hex.hexToBytes()).toHex()
                main.post { result.success(resp) }
            } catch (e: TagLostException) {
                main.post { emit("tagLost"); result.error("TAG_LOST", e.message, null) }
            } catch (e: IOException) {
                main.post { result.error("IO_ERROR", e.message, null) }
            }
        }.start()
    }

    private fun emit(type: String, vararg extra: Pair<String, Any>) {
        main.post { sink?.success(mapOf("type" to type) + extra) }
    }

    override fun onListen(args: Any?, events: EventChannel.EventSink?) { sink = events }
    override fun onCancel(args: Any?) { sink = null }
}

private fun String.hexToBytes() = chunked(2).map { it.toInt(16).toByte() }.toByteArray()
private fun ByteArray.toHex() = joinToString("") { "%02X".format(it) }
```

Tambahan wajib:
- Panggil `stopSession` saat `onPause` Activity, dan mulai ulang saat kembali jika layar Tap masih aktif.
- Layar yang menampilkan data kartu memakai `FLAG_SECURE`.

### 6.4 Dart — interface

```dart
enum CardReaderAvailability { available, disabled, unsupported }

class CardData {
  const CardData({required this.brand, required this.last4, required this.maskedPan});
  final String brand;      // Visa, Mastercard, GPN, dst.
  final String last4;
  final String maskedPan;  // "•••• •••• •••• 4821"
}

abstract class CardReader {
  Future<CardReaderAvailability> checkAvailability();
  Future<void> openSettings();

  /// Menunggu kartu, membaca data, lalu mengembalikannya.
  /// Melempar [CardReadException] dengan kode yang jelas.
  Future<CardData> readCard();

  Future<void> cancel();
}

enum CardReadError { cancelled, tagLost, unsupportedCard, timeout, nfcDisabled, parseFailed }

class CardReadException implements Exception {
  const CardReadException(this.error);
  final CardReadError error;
}
```

PAN lengkap **hanya hidup di memori selama proses parsing**, lalu langsung diubah menjadi `CardData` (yang hanya berisi versi masked). Jangan pernah mengembalikan, menyimpan, atau me-log PAN penuh.

### 6.5 Alur EMV di Dart (di dalam `NativeCardReader`)

Alur contactless standar, dijalankan lewat `transceive`:

1. **SELECT PPSE**: `00A404000E 325041592E5359532E4444463031 00`
   Parse FCI, ambil daftar AID (tag `4F`, bersarang di `6F > A5 > BF0C > 61`). Pilih AID prioritas pertama yang dikenali.
2. **SELECT AID**: `00A40400 <len> <aid> 00`. Ambil PDOL (tag `9F38`) bila ada.
3. **GET PROCESSING OPTIONS**: `80A80000 <len> 83 <len> <data> 00`.
   Jika PDOL kosong, kirim `80A80000 02 8300 00`. Jika ada PDOL, isi data dengan nol sesuai panjang tiap tag (cukup untuk prototipe).
4. Dari respons GPO (format `77` atau `80`) ambil **AFL** (tag `94`).
5. **READ RECORD** untuk setiap entri AFL: `00B2 <record> <(sfi << 3) | 4> 00`.
6. Cari PAN: tag `5A`, atau jika tidak ada, tag `57` (Track 2 equivalent: digit sebelum karakter `D`).
7. Tentukan brand dari RID pada AID: `A000000003` Visa, `A000000004` Mastercard, `A000000025` Amex, `A000000065` JCB, `A000000333` UnionPay. Untuk GPN, **verifikasi sendiri** AID yang dipakai kartu uji kamu; jika tidak dikenali, jatuh ke label "Kartu lain" (atau tentukan dari BIN bila project sudah punya aturannya).
8. Selalu cek status word di akhir respons (`9000` = sukses). Selain itu → `unsupportedCard` atau `parseFailed`.

Catatan: ada kartu yang tidak mengekspos PAN, atau memakai tokenisasi. Tangani dengan menampilkan "Kartu terbaca, data terbatas" dan tetap lanjut memakai brand saja.

### 6.6 Parser TLV (Dart murni, wajib diberi unit test)

```dart
import 'dart:typed_data';

class Tlv {
  Tlv(this.tag, this.value, this.children);
  final int tag;
  final Uint8List value;
  final List<Tlv> children; // terisi jika tag constructed
}

List<Tlv> parseTlv(Uint8List data) {
  final out = <Tlv>[];
  var i = 0;
  while (i < data.length) {
    if (data[i] == 0x00 || data[i] == 0xFF) { i++; continue; } // padding
    var tag = data[i++];
    final constructed = (tag & 0x20) != 0;
    if ((tag & 0x1F) == 0x1F) {
      do { tag = (tag << 8) | data[i++]; } while ((data[i - 1] & 0x80) != 0);
    }
    var len = data[i++];
    if (len & 0x80 != 0) {
      final n = len & 0x7F;
      len = 0;
      for (var k = 0; k < n; k++) { len = (len << 8) | data[i++]; }
    }
    if (i + len > data.length) throw const FormatException('TLV melebihi data');
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
```

Fungsi bantu yang juga perlu ada dan dites: `maskPan(String pan)` (hanya 4 digit terakhir), `brandFromAid(String aid)`, dan parser Track 2 (`5413330089020011D2512...` → PAN sebelum `D`).

### 6.7 Pemetaan error ke UI

| `CardReadError` | Pesan ke pengguna |
|---|---|
| `nfcDisabled` | "NFC belum aktif. Aktifkan NFC lalu coba lagi." + tombol buka pengaturan |
| `tagLost` | "Kartu terlepas. Tempelkan ulang kartu dan jangan digeser." |
| `unsupportedCard` | "Kartu ini belum didukung." |
| `timeout` | "Waktu habis. Coba tempelkan kartu lagi." |
| `parseFailed` | "Kartu tidak terbaca. Coba lagi atau gunakan kartu lain." |
| `cancelled` | kembali ke Nominal tanpa pesan error |

---

## 7. Mock API

Ikuti HTTP client dan pola repository yang sudah ada. Buat **interface repository** (`AuthRepository`, `TransactionRepository`) dengan dua implementasi: **remote** (memanggil mock server) dan **fake in-memory**. Pilihan lewat flag lingkungan/konfigurasi yang sudah ada di project.

Mock server boleh berupa server kecil terpisah (Node/Express atau `json-server`, taruh di folder `mock_server/`) **atau** interceptor/fake di dalam app, mana yang paling cocok dengan kultur project.

### Endpoint

| Method | Path | Fungsi |
|---|---|---|
| POST | `/auth/login` | Login merchant |
| GET | `/merchant/profile` | Profil merchant |
| POST | `/transactions` | Buat transaksi |
| GET | `/transactions?status=&page=&limit=` | Riwayat (paginated) |
| POST | `/transactions/{id}/void` | Batalkan transaksi |
| GET | `/summary?range=7d` | Data ringkasan |

### Kontrak

`POST /auth/login`
```json
// request
{ "merchantId": "warung-maju", "pin": "123456" }
// 200
{ "token": "mock-jwt", "expiresIn": 3600 }
// 401
{ "error": { "code": "INVALID_CREDENTIALS", "message": "ID merchant atau PIN salah" } }
```

`POST /transactions` (header `Idempotency-Key: <uuid>`)
```json
// request
{ "amount": 125000, "brand": "Visa", "last4": "4821" }
// 201
{ "id": "CU8F2A1", "amount": 125000, "brand": "Visa", "last4": "4821",
  "status": "SUCCESS", "createdAt": "2026-11-09T09:41:00+07:00" }
// 200 (ditolak, bukan error HTTP)
{ "id": "CU6B20E", "status": "DECLINED", "reason": "LIMIT_EXCEEDED" }
```

`GET /transactions` → `{ "items": [ ... ], "page": 1, "hasMore": true }`
`POST /transactions/{id}/void` → transaksi dengan `status: "VOIDED"` (hanya dari `SUCCESS`; selain itu `409`).

### Perilaku mock yang wajib ada
- Latensi acak 400–1200 ms.
- Nominal **> 5.000.000** → `DECLINED` (`LIMIT_EXCEEDED`).
- Idempotency-Key yang sama → kembalikan respons yang sama, **jangan buat transaksi ganda**.
- Sesekali (±1 dari 15 request, bisa dimatikan lewat konfigurasi) simulasikan timeout atau `503` agar penanganan error teruji.
- Token mock kedaluwarsa → `401`; app harus logout otomatis atau refresh sesuai pola auth yang ada.

---

## 8. Aturan teknis

### 8.1 Controller pembayaran
Satu controller (atau pola setara di project) memegang state mesin pembayaran di bagian 3. Transisi state hanya lewat method controller, bukan dari widget. Tombol bayar harus kebal dari **double-tap** (guard state + idempotency key yang dibuat sekali per percobaan).

### 8.2 Keamanan
- Token hanya di `flutter_secure_storage`.
- PAN penuh tidak pernah disimpan, dikirim ke API, ditampilkan, maupun di-log. API hanya menerima brand dan last4.
- Tidak ada `print`/log yang memuat data kartu. Pakai logger project dan pastikan tidak mencetak payload sensitif.
- HTTPS saja untuk server mock yang di-deploy.
- Aktifkan `FLAG_SECURE` pada layar Tap, Proses, dan Hasil.

### 8.3 Edge case yang harus ditangani
NFC mati; perangkat tanpa NFC; kartu terlepas di tengah pembacaan; kartu tidak didukung; tombol bayar ditekan dua kali; tidak ada internet; request timeout; token kedaluwarsa; layar berputar atau app masuk background di tengah transaksi (batalkan sesi NFC dengan rapi); pengguna menekan back saat Proses (jangan meninggalkan transaksi menggantung).

### 8.4 Alasan gagal pada layar Hasil
`LIMIT_EXCEEDED` → "Limit kartu terlampaui. Coba kartu lain atau kurangi nominal."; error NFC → pesan dari tabel 6.7; jaringan → "Tidak ada koneksi. Transaksi belum diproses, coba lagi."

---

## 9. Testing dan kualitas

Minimal:
- Unit test **parser TLV** (data nyata dari PPSE/FCI, nested constructed tag, length bentuk panjang, data rusak).
- Unit test `maskPan`, `brandFromAid`, parser Track 2.
- Unit test controller pembayaran: alur sukses, ditolak, error NFC, double-tap, void.
- Satu–dua widget test (keypad nominal, tampilan hasil sukses/gagal).
- `flutter analyze` bersih dan format sesuai aturan lint project.

---

## 10. Yang harus ada di README

Singkat dan jujur:
- Arsitektur singkat + diagram alur pembayaran.
- Cara menjalankan (termasuk mock server dan mode simulasi).
- **Keterbatasan:** ini prototipe; tidak memproses pembayaran sungguhan; tidak memakai kernel EMV tersertifikasi; NFC hanya Android.
- Rencana jika menjadi produk: sertifikasi PCI, kernel EMV tersertifikasi, device attestation, certificate pinning, dukungan iOS lewat jalur resmi Apple.

---

## 11. Urutan pengerjaan

1. **Pelajari project** (struktur, theme, routing, HTTP client, binding). Tulis ringkasan 5–10 baris tentang konvensi yang kamu temukan.
2. **Theme dan komponen dasar** dari bagian 4: warna, tipografi, tombol, field, chip, baris transaksi, tag status, bottom nav, `BrandWordmark`.
3. **Auth**: Splash, Login, penyimpanan token, mock API login.
4. **Beranda dan Riwayat**: repository transaksi (fake dulu), list, filter, pagination, detail sheet.
5. **Nominal**: keypad, format Rupiah.
6. **NFC**: interface `CardReader`, `SimulatedCardReader`, parser TLV + test, lalu `NativeCardReader` + Kotlin bridge.
7. **Tap, Proses, Hasil**: mesin state pembayaran, animasi, error mapping, ke mock API.
8. **Void, Ringkasan, Pengaturan, dark mode.**
9. **Polish**: state kosong/error, aksesibilitas, `FLAG_SECURE`, README.

Setelah setiap tahap: `flutter analyze` + test lulus, lalu lanjut.

---

## 12. Laporan akhir yang diharapkan

Setelah selesai, berikan:
1. Daftar file yang dibuat/diubah.
2. Package baru (jika ada) beserta alasannya.
3. Asumsi yang kamu ambil.
4. Hal yang belum dikerjakan atau perlu diverifikasi di perangkat fisik (khususnya NFC dengan kartu nyata).
