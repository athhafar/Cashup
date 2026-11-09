import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/payment_controller.dart';
import '../../models/product_model.dart';
import '../../routes/route_name.dart';
import '../../utilities/colors.dart';
import '../../utilities/constants.dart';
import '../../utilities/helper.dart';
import '../../utilities/typography.dart';
import '../../widgets/keypad_widget.dart';
import 'split_bill_sheet.dart';

class NominalPage extends StatelessWidget {
  const NominalPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PaymentController());

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.ink, size: 20),
          onPressed: () {
            controller.clearAmount();
            Get.back();
          },
        ),
        centerTitle: true,
        title: Obx(() {
          final isKasir = controller.posMode.value == PosMode.kasir;
          return Text(
            isKasir ? 'Katalog Kasir' : 'Nominal Pembayaran',
            style: AppTypography.sectionTitle,
          );
        }),
        actions: [
          Obx(() {
            final isKasir = controller.posMode.value == PosMode.kasir;
            if (isKasir && controller.cartTotalQuantity > 0) {
              return TextButton.icon(
                onPressed: controller.clearCart,
                icon: const Icon(Icons.delete_sweep_outlined, size: 18, color: AppColors.danger),
                label: const Text(
                  'Reset',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.danger,
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Mode Switcher: [ TRANSAKSI ] vs [ KASIR ]
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.screenPadding,
                4,
                AppConstants.screenPadding,
                8,
              ),
              child: _PosModeSwitcher(controller: controller),
            ),

            // Content based on active mode
            Expanded(
              child: Obx(() {
                if (controller.posMode.value == PosMode.kasir) {
                  return _ProductCatalogView(controller: controller);
                }
                return _KeypadView(controller: controller);
              }),
            ),
          ],
        ),
      ),
    );
  }
}

/// Segmented Pill Switcher inspired by Cashlez Layout
class _PosModeSwitcher extends StatelessWidget {
  final PaymentController controller;

  const _PosModeSwitcher({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final mode = controller.posMode.value;
      final cartCount = controller.cartTotalQuantity;

      return Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.ground,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.line),
        ),
        child: Row(
          children: [
            // Mode Transaksi (Manual Nominal Keypad)
            Expanded(
              child: GestureDetector(
                onTap: () => controller.setPosMode(PosMode.transaksi),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: mode == PosMode.transaksi ? AppColors.ink : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: mode == PosMode.transaksi
                        ? [
                            BoxShadow(
                              color: AppColors.ink.withAlpha(40),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.dialpad_rounded,
                        size: 16,
                        color: mode == PosMode.transaksi ? Colors.white : AppColors.muted,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'TRANSAKSI',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: mode == PosMode.transaksi ? Colors.white : AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Mode Kasir (Katalog Produk & Keranjang)
            Expanded(
              child: GestureDetector(
                onTap: () => controller.setPosMode(PosMode.kasir),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: mode == PosMode.kasir ? AppColors.ink : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: mode == PosMode.kasir
                        ? [
                            BoxShadow(
                              color: AppColors.ink.withAlpha(40),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.storefront_rounded,
                        size: 16,
                        color: mode == PosMode.kasir ? Colors.white : AppColors.muted,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'KASIR',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: mode == PosMode.kasir ? Colors.white : AppColors.muted,
                        ),
                      ),
                      if (cartCount > 0) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$cartCount',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

/// View A: Manual Nominal Keypad
class _KeypadView extends StatelessWidget {
  final PaymentController controller;

  const _KeypadView({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.screenPadding),
      child: Column(
        children: [
          const SizedBox(height: 8),
          const Text(
            'Jumlah pembayaran',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 10),

          // Animated pulsating large amount
          Obx(() {
            final amt = controller.rawAmount.value;
            final isPulsing = controller.isAmountPulsing.value;
            final formatted = Helper.formatRupiah(amt);

            return AnimatedScale(
              scale: isPulsing ? 1.04 : 1.0,
              duration: const Duration(milliseconds: 110),
              curve: Curves.easeOut,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  formatted,
                  style: AppTypography.amountBig.copyWith(
                    color: amt == 0 ? AppColors.muted.withAlpha(128) : AppColors.ink,
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 14),

          // Quick Amount Chips
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _QuickChip(
                label: 'Rp 25 rb',
                onTap: () => controller.addQuickAmount(25000),
              ),
              const SizedBox(width: 8),
              _QuickChip(
                label: 'Rp 50 rb',
                onTap: () => controller.addQuickAmount(50000),
              ),
              const SizedBox(width: 8),
              _QuickChip(
                label: 'Rp 100 rb',
                onTap: () => controller.addQuickAmount(100000),
              ),
            ],
          ),

          // SoftPOS Limit Warning Banner (Regulasi Bank Indonesia: Max 1 Juta No-PIN)
          Obx(() {
            final amt = controller.rawAmount.value;
            if (amt <= 1000000) return const SizedBox.shrink();

            return Container(
              margin: const EdgeInsets.only(top: 14),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.warningBg,
                borderRadius: BorderRadius.circular(AppConstants.radius),
                border: Border.all(color: AppColors.warning.withAlpha(80)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppColors.warning, size: 18),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Limit tap kartu tanpa PIN max Rp 1.000.000 (Regulasi BI).',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.warning,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.ink,
                            side: const BorderSide(color: AppColors.ink),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 6),
                          ),
                          icon: const Icon(Icons.qr_code_scanner, size: 16),
                          label: const Text(
                            'Pakai QRIS',
                            style: TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w700),
                          ),
                          onPressed: () => Get.toNamed(RouteName.qris, arguments: amt),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.accent,
                            side: const BorderSide(color: AppColors.accent),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 6),
                          ),
                          icon: const Icon(Icons.call_split_rounded, size: 16),
                          label: const Text(
                            'Split Bill',
                            style: TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w700),
                          ),
                          onPressed: () => SplitBillSheet.show(context, amt),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
          const Spacer(),

          // Custom 3x4 Keypad
          KeypadWidget(
            onKeyPress: controller.appendDigit,
            onDeletePress: controller.deleteDigit,
          ),
          const SizedBox(height: 16),

          // Dual Action Buttons: Debit/Credit vs QRIS
          _DualPaymentButtons(controller: controller),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

/// View B: Product Catalog (Kasir Mode)
class _ProductCatalogView extends StatelessWidget {
  final PaymentController controller;

  const _ProductCatalogView({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Category Horizontal Selector
        Container(
          height: 40,
          margin: const EdgeInsets.only(bottom: 8),
          child: Obx(() {
            final activeCat = controller.selectedCategory.value;
            return ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.screenPadding),
              itemCount: controller.categories.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = controller.categories[index];
                final isSelected = cat == activeCat;

                return GestureDetector(
                  onTap: () => controller.selectedCategory.value = cat,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.ink : AppColors.ground,
                      borderRadius: BorderRadius.circular(AppConstants.radiusTag),
                      border: Border.all(
                        color: isSelected ? AppColors.ink : AppColors.line,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      cat,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? Colors.white : AppColors.muted,
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        ),

        // Product Grid View
        Expanded(
          child: Obx(() {
            final list = controller.filteredProducts;
            return GridView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.screenPadding,
                vertical: 6,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.82,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final product = list[index];
                return _ProductCard(
                  product: product,
                  controller: controller,
                );
              },
            );
          }),
        ),

        // Bottom Sticky Checkout Bar
        _CartCheckoutBar(controller: controller),
      ],
    );
  }
}

/// Individual Product Card in the Catalog
class _ProductCard extends StatelessWidget {
  final ProductModel product;
  final PaymentController controller;

  const _ProductCard({
    required this.product,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final qty = controller.getProductQuantity(product.id);
      final isSelected = qty > 0;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.radiusCard),
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.line,
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.accent.withAlpha(20),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon thumbnail with product accent color
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: product.color.withAlpha(25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Icon(product.icon, color: product.color, size: 24),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.ground,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    product.category,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: AppColors.muted,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),

            // Product Name
            Text(
              product.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 4),

            // Price Tag
            Text(
              Helper.formatRupiah(product.price),
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: 10),

            // Quantity Control
            if (qty == 0)
              SizedBox(
                width: double.infinity,
                height: 32,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.ground,
                    foregroundColor: AppColors.ink,
                    elevation: 0,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: AppColors.line),
                    ),
                  ),
                  icon: const Icon(Icons.add, size: 14),
                  label: const Text(
                    'Tambah',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  onPressed: () => controller.addToCart(product),
                ),
              )
            else
              Container(
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.accent.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.accent),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, size: 14, color: AppColors.accent),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 28),
                      onPressed: () => controller.removeFromCart(product),
                    ),
                    Text(
                      '$qty',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.accent,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, size: 14, color: AppColors.accent),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 28),
                      onPressed: () => controller.addToCart(product),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    });
  }
}

/// Bottom Sticky Cart Bar in Kasir Mode
class _CartCheckoutBar extends StatelessWidget {
  final PaymentController controller;

  const _CartCheckoutBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final totalAmt = controller.cartTotalAmount;
      final itemCount = controller.cartTotalQuantity;
      final isLimitExceeded = totalAmt > 1000000;

      return Container(
        padding: const EdgeInsets.fromLTRB(
          AppConstants.screenPadding,
          12,
          AppConstants.screenPadding,
          12,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: const Border(top: BorderSide(color: AppColors.line)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(12),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Cart Summary Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.ink,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 16),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$itemCount Item Dipilih',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.muted,
                          ),
                        ),
                        Text(
                          Helper.formatRupiah(totalAmt),
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (itemCount > 0)
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      padding: EdgeInsets.zero,
                    ),
                    icon: const Icon(Icons.clear, size: 14),
                    label: const Text(
                      'Kosongkan',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: controller.clearCart,
                  ),
              ],
            ),
            const SizedBox(height: 10),

            // Limit warning if exceeded
            if (isLimitExceeded) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.warningBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, size: 14, color: AppColors.warning),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Total belanja > Rp 1.000.000. Disarankan gunakan QRIS.',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.warning,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Dual Option Payment Buttons
            _DualPaymentButtons(controller: controller),
          ],
        ),
      );
    });
  }
}

/// Dual Action Buttons (Debit/Credit vs QRIS)
class _DualPaymentButtons extends StatelessWidget {
  final PaymentController controller;

  const _DualPaymentButtons({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final amt = controller.rawAmount.value;
      final isLimitExceeded = amt > 1000000;
      final canPay = amt > 0;

      return Row(
        children: [
          // Left Option: Tap Debit / Kredit
          Expanded(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: !canPay
                    ? AppColors.ink.withAlpha(60)
                    : isLimitExceeded
                        ? AppColors.ink.withAlpha(90)
                        : AppColors.ink,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radius),
                ),
              ),
              icon: const Icon(Icons.contactless_outlined, size: 18),
              label: Text(
                isLimitExceeded ? 'Tap (>1Jt Limit)' : 'Debit / Kredit',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: canPay ? controller.startPaymentFlow : null,
            ),
          ),
          const SizedBox(width: 10),

          // Right Option: QRIS Pay
          Expanded(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: !canPay
                    ? AppColors.ground
                    : isLimitExceeded
                        ? AppColors.accent
                        : AppColors.ground,
                foregroundColor: !canPay
                    ? AppColors.muted
                    : isLimitExceeded
                        ? Colors.white
                        : AppColors.ink,
                elevation: isLimitExceeded ? 3 : 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radius),
                  side: BorderSide(
                    color: !canPay
                        ? AppColors.line
                        : isLimitExceeded
                            ? AppColors.accent
                            : AppColors.line,
                  ),
                ),
              ),
              icon: const Icon(Icons.qr_code_scanner_rounded, size: 18),
              label: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'QRIS',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (isLimitExceeded) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(60),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Bebas PIN',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              onPressed: canPay ? () => Get.toNamed(RouteName.qris, arguments: amt) : null,
            ),
          ),
        ],
      );
    });
  }
}

class _QuickChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.ground,
      borderRadius: BorderRadius.circular(AppConstants.radius),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppConstants.radius),
        onTap: onTap,
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.radius),
            border: Border.all(color: AppColors.line),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
        ),
      ),
    );
  }
}
