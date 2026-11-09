import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/transaction_model.dart';
import '../../utilities/colors.dart';
import '../../utilities/constants.dart';
import '../../utilities/helper.dart';
import '../../utilities/typography.dart';
import '../../widgets/brand_wordmark.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/status_badge.dart';

class ReceiptPage extends StatefulWidget {
  final TransactionModel transaction;

  const ReceiptPage({super.key, required this.transaction});

  static void open(TransactionModel transaction) {
    Get.to(
      () => ReceiptPage(transaction: transaction),
      transition: Transition.rightToLeft,
      duration: AppConstants.animDuration,
    );
  }

  @override
  State<ReceiptPage> createState() => _ReceiptPageState();
}

class _ReceiptPageState extends State<ReceiptPage> {
  final GlobalKey _receiptKey = GlobalKey();
  bool _isExporting = false;

  Future<void> _shareReceiptImage() async {
    if (_isExporting) return;
    setState(() => _isExporting = true);

    try {
      final boundary =
          _receiptKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        Helper.showToast('Gagal memproses gambar struk');
        return;
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        Helper.showToast('Gagal membuat file struk');
        return;
      }

      final pngBytes = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/struk_${widget.transaction.id}.png').create();
      await file.writeAsBytes(pngBytes);

      await SharePlus.instance.share(
        ShareParams(
          text: 'Struk Transaksi ${widget.transaction.id} - cashUPay',
          subject: 'Bukti Pembayaran cashUPay',
          files: [XFile(file.path, mimeType: 'image/png')],
        ),
      );
    } catch (e) {
      Helper.showToast('Terjadi kesalahan saat membagikan: $e');
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tx = widget.transaction;
    final isSuccess = tx.status == TransactionStatus.success;

    return Scaffold(
      backgroundColor: AppColors.ground,
      appBar: AppBar(
        backgroundColor: AppColors.ground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.ink, size: 20),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: const Text(
          'Struk Pembayaran',
          style: AppTypography.sectionTitle,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: AppColors.ink, size: 22),
            onPressed: _shareReceiptImage,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.screenPadding,
            vertical: 14,
          ),
          child: Column(
            children: [
              // Ticket Shaped Physical Receipt Widget wrapped in RepaintBoundary for capture
              RepaintBoundary(
                key: _receiptKey,
                child: CustomPaint(
                  painter: _TicketShadowPainter(),
                  child: ClipPath(
                    clipper: _TicketClipper(),
                    child: Container(
                      width: double.infinity,
                      color: AppColors.surface,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Top jagged / sawtooth tear decorative edge
                          const _SawtoothHeader(),

                          // Upper Section: Merchant Header
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24, 20, 24, 18),
                            child: Column(
                              children: [
                                const BrandWordmark(fontSize: 22),
                                const SizedBox(height: 6),
                                const Text(
                                  'Warung Maju • SoftPOS Merchant',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.muted,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Ruko Garden Shopping Arcade Blok B08 BA',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 10,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.muted,
                                  ),
                                ),
                                const SizedBox(height: 18),

                                // Amount & Status
                                Text(
                                  Helper.formatRupiah(tx.amount),
                                  style: AppTypography.amountResult.copyWith(fontSize: 34),
                                ),
                                const SizedBox(height: 8),
                                StatusBadge(status: tx.status),
                              ],
                            ),
                          ),

                          // Perforated Tear Line with Semicircle Notches
                          const _TicketPerforation(),

                          // Lower Section: Breakdown details
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
                            child: Column(
                              children: [
                                _detailRow('Nomor Referensi', tx.id, isCopyable: true),
                                const SizedBox(height: 12),
                                _detailRow('Tanggal & Waktu', Helper.formatDateTime(tx.createdAt)),
                                const SizedBox(height: 12),
                                _detailRow(
                                  'Metode Pembayaran',
                                  tx.brand.contains('QRIS') ? 'QRIS Dinamis (ASPI)' : '${tx.brand} Contactless',
                                ),
                                const SizedBox(height: 12),
                                _detailRow('Detail Kartu / Akun', '${tx.brand} •••• ${tx.last4}'),
                                const SizedBox(height: 12),
                                _detailRow('Jenis Perangkat', 'SoftPOS Android COTS'),
                                const SizedBox(height: 12),
                                _detailRow('Terminal ID (TID)', 'TID-992014-CU'),

                                if (!isSuccess && tx.reason != null) ...[
                                  const SizedBox(height: 12),
                                  _detailRow(
                                    'Keterangan Ditolak',
                                    tx.reason!,
                                    valueColor: AppColors.danger,
                                    isBold: true,
                                  ),
                                ],

                                const SizedBox(height: 20),
                                const _DashedDivider(),
                                const SizedBox(height: 16),

                                // Barcode simulation at the bottom of ticket
                                const _TicketBarcode(),
                                const SizedBox(height: 10),
                                const Text(
                                  'Simpan bukti ini sebagai tanda terima pembayaran yang sah.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 10,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.muted,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Bottom jagged edge
                          const _SawtoothFooter(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 26),

              // Action Buttons
              CustomButton(
                text: _isExporting ? 'Menyiapkan Gambar...' : 'Kirim / Bagikan Struk',
                icon: const Icon(Icons.share_rounded, size: 20, color: Colors.white),
                enableShine: true,
                isLoading: _isExporting,
                onPressed: _shareReceiptImage,
              ),
              const SizedBox(height: 12),

              CustomButton(
                text: 'Selesai & Kembali',
                variant: ButtonVariant.secondary,
                onPressed: () => Get.back(),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(
    String label,
    String value, {
    Color? valueColor,
    bool isBold = false,
    bool isCopyable = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.muted,
          ),
        ),
        const SizedBox(width: 14),
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
                    color: valueColor ?? AppColors.ink,
                  ),
                ),
              ),
              if (isCopyable) ...[
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () => Helper.copyToClipboard(value),
                  child: const Icon(Icons.copy_rounded, size: 14, color: AppColors.accent),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Custom Clipper for authentic ticket / receipt shape with side notches
class _TicketClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const notchRadius = 14.0;
    const notchYRatio = 0.38; // Posisi perforasi di tengah atas
    final notchY = size.height * notchYRatio;

    final path = Path()
      ..moveTo(0, 12)
      ..quadraticBezierTo(0, 0, 12, 0)
      ..lineTo(size.width - 12, 0)
      ..quadraticBezierTo(size.width, 0, size.width, 12)
      // Right side down to right notch
      ..lineTo(size.width, notchY - notchRadius)
      ..arcToPoint(
        Offset(size.width, notchY + notchRadius),
        radius: const Radius.circular(notchRadius),
        clockwise: false,
      )
      ..lineTo(size.width, size.height - 12)
      ..quadraticBezierTo(size.width, size.height, size.width - 12, size.height)
      ..lineTo(12, size.height)
      ..quadraticBezierTo(0, size.height, 0, size.height - 12)
      // Left side up to left notch
      ..lineTo(0, notchY + notchRadius)
      ..arcToPoint(
        Offset(0, notchY - notchRadius),
        radius: const Radius.circular(notchRadius),
        clockwise: false,
      )
      ..close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _TicketShadowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.06)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    final path = _TicketClipper().getClip(size);
    canvas.drawPath(path.shift(const Offset(0, 4)), shadowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Perforated Dotted Line with Side Cutout Indicators
class _TicketPerforation extends StatelessWidget {
  const _TicketPerforation();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.constrainWidth() - 36;
        const dashWidth = 6.0;
        const dashSpace = 4.0;
        final dashCount = (boxWidth / (dashWidth + dashSpace)).floor();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(dashCount, (_) {
              return Container(
                width: dashWidth,
                height: 1.5,
                color: AppColors.line,
              );
            }),
          ),
        );
      },
    );
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 4.0;
        const dashSpace = 3.0;
        final dashCount = (boxWidth / (dashWidth + dashSpace)).floor();

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(dashCount, (_) {
            return Container(
              width: dashWidth,
              height: 1,
              color: AppColors.line,
            );
          }),
        );
      },
    );
  }
}

/// Simulated Barcode Lines at Bottom of Struk
class _TicketBarcode extends StatelessWidget {
  const _TicketBarcode();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(42, (index) {
        final isThick = (index * 7) % 3 == 0;
        final isGap = (index * 11) % 5 == 0;
        return Container(
          width: isGap ? 2 : (isThick ? 3 : 1.5),
          height: 34,
          margin: const EdgeInsets.symmetric(horizontal: 1.2),
          color: isGap ? Colors.transparent : AppColors.ink.withValues(alpha: 0.85),
        );
      }),
    );
  }
}

/// Top Sawtooth / Tear Edge
class _SawtoothHeader extends StatelessWidget {
  const _SawtoothHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 4,
      decoration: const BoxDecoration(
        color: AppColors.accent,
      ),
    );
  }
}

/// Bottom Sawtooth / Tear Edge
class _SawtoothFooter extends StatelessWidget {
  const _SawtoothFooter();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 4,
      decoration: const BoxDecoration(
        color: AppColors.ink,
      ),
    );
  }
}
