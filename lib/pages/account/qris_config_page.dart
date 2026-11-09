import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controllers/settings_controller.dart';
import '../../services/qris_service.dart';
import '../../utilities/colors.dart';
import '../../utilities/constants.dart';
import '../../utilities/typography.dart';
import '../../widgets/custom_button.dart';

class QrisConfigPage extends StatefulWidget {
  const QrisConfigPage({super.key});

  @override
  State<QrisConfigPage> createState() => _QrisConfigPageState();
}

class _QrisConfigPageState extends State<QrisConfigPage> {
  final _settingsController = Get.find<SettingsController>();
  late final TextEditingController _textController;
  QrisValidationResult? _validationResult;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: _settingsController.customQris.value);
    if (_textController.text.isNotEmpty) {
      _validationResult = QrisService.validateQris(_textController.text);
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _validateInput(String text) {
    if (text.trim().isEmpty) {
      setState(() => _validationResult = null);
      return;
    }
    setState(() {
      _validationResult = QrisService.validateQris(text);
    });
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null && data!.text!.isNotEmpty) {
      _textController.text = data.text!;
      _validateInput(data.text!);
    }
  }

  void _save() {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      Get.snackbar(
        'Perhatian',
        'Silakan masukkan payload QRIS atau gunakan tombol Reset Demo',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.ink,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    final success = _settingsController.saveCustomQris(text);
    if (success) {
      Get.back();
    }
  }

  void _reset() {
    _textController.clear();
    setState(() => _validationResult = null);
    _settingsController.resetQrisToDefault();
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final isCustomActive = _settingsController.hasCustomQris;

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
          'Konfigurasi QRIS Merchant',
          style: AppTypography.sectionTitle,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.accent.withAlpha(20),
                  borderRadius: BorderRadius.circular(AppConstants.radiusCard),
                  border: Border.all(color: AppColors.accent.withAlpha(60)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.hub_outlined, color: AppColors.accent, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          'Routing Bank & E-Wallet Asli',
                          style: AppTypography.sectionTitle.copyWith(
                            color: AppColors.accent,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Dengan memasukkan string QRIS statis toko Anda (dari GoPay Usaha, BCA Merchant, Permata QR, ShopeePay, DANA Bisnis, dll.), aplikasi ini akan otomatis mengubahnya menjadi QRIS Dinamis ber-nominal dengan checksum CRC16 resmi.\n\nPembayaran dari pelanggan akan langsung ditransfer ke rekening bank asli Anda.',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: AppColors.ink,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Step-by-step Guide
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppConstants.radiusCard),
                  border: Border.all(color: AppColors.line),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Cara Mendapatkan String QRIS Toko Anda:',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildStepRow(
                      number: '1',
                      title: 'Buka Stiker QRIS Merchant Anda',
                      description: 'Di aplikasi GoPay Merchant, Permata QR, Livin Merchant, BCA, atau stiker fisik toko.',
                    ),
                    const SizedBox(height: 8),
                    _buildStepRow(
                      number: '2',
                      title: 'Scan Menggunakan Google Lens / QR Reader',
                      description: 'Buka kamera HP atau Google Lens, scan QR tersebut, lalu salin (copy) teks string hasilnya.',
                    ),
                    const SizedBox(height: 8),
                    _buildStepRow(
                      number: '3',
                      title: 'Tempel (Paste) di Kolom Bawah',
                      description: 'String QRIS diawali dengan "000201010211...". Tekan tombol Simpan.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Form Input
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'String QRIS Statis Merchant',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.muted,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _pasteFromClipboard,
                    icon: const Icon(Icons.paste_rounded, size: 16, color: AppColors.accent),
                    label: const Text(
                      'Tempel',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              TextFormField(
                controller: _textController,
                maxLines: 4,
                onChanged: _validateInput,
                style: const TextStyle(
                  fontFamily: 'Courier',
                  fontSize: 12,
                  color: AppColors.ink,
                ),
                decoration: InputDecoration(
                  hintText: 'Contoh: 00020101021126610014ID.LINKAJA.WWW...',
                  hintStyle: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: AppColors.muted,
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radius),
                    borderSide: const BorderSide(color: AppColors.line),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radius),
                    borderSide: const BorderSide(color: AppColors.line),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radius),
                    borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Live Validation & Parsed Data Card
              if (_validationResult != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _validationResult!.isValid ? AppColors.successBg : AppColors.dangerBg,
                    borderRadius: BorderRadius.circular(AppConstants.radius),
                    border: Border.all(
                      color: _validationResult!.isValid ? AppColors.success : AppColors.danger,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _validationResult!.isValid
                                ? Icons.check_circle_rounded
                                : Icons.error_outline_rounded,
                            size: 18,
                            color: _validationResult!.isValid
                                ? AppColors.success
                                : AppColors.danger,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _validationResult!.isValid
                                ? 'Format QRIS Terverifikasi Valid'
                                : 'Format QRIS Tidak Sesuai',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _validationResult!.isValid
                                  ? AppColors.successText
                                  : AppColors.danger,
                            ),
                          ),
                        ],
                      ),
                      if (_validationResult!.isValid) ...[
                        const SizedBox(height: 8),
                        const Divider(height: 1, color: AppColors.line),
                        const SizedBox(height: 8),
                        _buildParsedDetail(
                          'Nama Merchant:',
                          _validationResult!.merchantName ?? '-',
                        ),
                        const SizedBox(height: 4),
                        _buildParsedDetail(
                          'Kota:',
                          _validationResult!.merchantCity ?? '-',
                        ),
                        if (_validationResult!.nmid != null) ...[
                          const SizedBox(height: 4),
                          _buildParsedDetail(
                            'NMID / ID:',
                            _validationResult!.nmid!,
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Action Buttons
              CustomButton(
                text: 'Simpan QRIS Merchant',
                onPressed: _save,
                icon: const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
              ),
              const SizedBox(height: 12),

              if (isCustomActive)
                CustomButton(
                  text: 'Kembalikan ke Mode Demo',
                  variant: ButtonVariant.secondary,
                  onPressed: _reset,
                  icon: const Icon(Icons.restart_alt_rounded, color: AppColors.ink, size: 20),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepRow({
    required String number,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: AppColors.ink,
            borderRadius: BorderRadius.circular(11),
          ),
          alignment: Alignment.center,
          child: Text(
            number,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  color: AppColors.muted,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildParsedDetail(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.muted,
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
        ),
      ],
    );
  }
}
