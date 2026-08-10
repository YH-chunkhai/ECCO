import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/mesh_item.dart';
import '../providers/quotation_provider.dart';
import '../services/mesh_calculator.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_keypad.dart';
import '../widgets/progress_header.dart';

class WizardScreen extends StatelessWidget {
  const WizardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<QuotationProvider>();
    final isDark = provider.isDarkMode;
    final step = provider.currentStep;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x4D38BDF8),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  )
                ],
              ),
              child: const Icon(Icons.grid_on_rounded,
                  color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ECCO Steel PWA',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'OFFICIAL QUOTATION GENERATOR',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? AppTheme.textDarkMuted
                        : AppTheme.textLightMuted,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () => provider.goToStep(7),
                tooltip: 'View Quotation Table',
              ),
              if (provider.cartItems.isNotEmpty)
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                      gradient: AppTheme.amberGradient,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${provider.cartItems.length}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: Icon(
                isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
            onPressed: () => provider.toggleTheme(),
            tooltip: 'Toggle Theme',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: ProgressHeader(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  children: [
                    if (step == 1) _buildStep1Grade(context, provider, isDark),
                    if (step == 2) _buildStep2Size(context, provider, isDark),
                    if (step == 3)
                      _buildStep3Dimensions(context, provider, isDark),
                    if (step == 4)
                      _buildStep4Discounts(context, provider, isDark),
                    if (step == 5)
                      _buildStep5Quantity(context, provider, isDark),
                    if (step == 6) _buildStep6Terms(context, provider, isDark),
                  ],
                ),
              ),
            ),
            _buildStickyBottomDock(context, provider, isDark),
          ],
        ),
      ),
    );
  }

  // STEP 1: CHOOSE GRADE
  Widget _buildStep1Grade(
      BuildContext context, QuotationProvider provider, bool isDark) {
    return _buildCardWrapper(
      title: '1. Choose Mesh Grade',
      badge: 'Step 1',
      isDark: isDark,
      child: Column(
        children: MeshGrade.values.map((grade) {
          final isSelected = provider.selectedGrade == grade;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: InkWell(
              onTap: () => provider.setGrade(grade),
              borderRadius: BorderRadius.circular(16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  gradient: isSelected ? AppTheme.primaryGradient : null,
                  color: isSelected
                      ? null
                      : (isDark ? AppTheme.inputDark : AppTheme.inputLight),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : (isDark ? AppTheme.borderDark : AppTheme.borderLight),
                    width: 1.5,
                  ),
                  boxShadow: isSelected
                      ? const [
                          BoxShadow(
                            color: Color(0x4D38BDF8),
                            blurRadius: 16,
                            offset: Offset(0, 6),
                          )
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      grade.label,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: isSelected
                            ? Colors.white
                            : (isDark
                                ? AppTheme.textDarkMain
                                : AppTheme.textLightMain),
                      ),
                    ),
                    Text(
                      grade.subLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? Colors.white70
                            : (isDark
                                ? AppTheme.textDarkMuted
                                : AppTheme.textLightMuted),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // STEP 2: SELECT SIZE
  Widget _buildStep2Size(
      BuildContext context, QuotationProvider provider, bool isDark) {
    final List<int> sizes = provider.selectedGrade == MeshGrade.gradeB
        ? [5, 6, 7, 8, 9, 10, 11, 12, 13]
        : [4, 5, 6, 7, 8, 9, 10, 11, 12, 13];

    return _buildCardWrapper(
      title: '2. Select Mesh Size',
      badge: '${provider.selectedGrade.label} Selected',
      isDark: isDark,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1.4,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: sizes.length,
        itemBuilder: (context, index) {
          final size = sizes[index];
          final isSelected = provider.selectedSize == size;
          final codeStr = '${provider.selectedGrade.code}$size';
          final ms145Str = MeshCalculator.getMs145Code(provider.selectedGrade, size);

          return InkWell(
            onTap: () => provider.setSize(size),
            borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                gradient: isSelected ? AppTheme.primaryGradient : null,
                color: isSelected
                    ? null
                    : (isDark ? AppTheme.inputDark : AppTheme.inputLight),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : (isDark ? AppTheme.borderDark : AppTheme.borderLight),
                  width: 1.5,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                codeStr,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: isSelected
                      ? Colors.white
                      : (isDark
                          ? AppTheme.textDarkMain
                          : AppTheme.textLightMain),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // STEP 3: SHEET DIMENSIONS
  Widget _buildStep3Dimensions(
      BuildContext context, QuotationProvider provider, bool isDark) {
    return _buildCardWrapper(
      title: '3. Sheet Dimensions (L × W)',
      badge: '${provider.selectedGrade.code}${provider.selectedSize} Selected',
      isDark: isDark,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildChoiceButton(
                  title: '6.0m × 2.2m\n(Standard)',
                  isActive: !provider.isCustomDimension,
                  onTap: () => provider.setDimMode(false),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildChoiceButton(
                  title: 'Custom\nDimension',
                  isActive: provider.isCustomDimension,
                  onTap: () => provider.setDimMode(true),
                  isDark: isDark,
                ),
              ),
            ],
          ),
          if (provider.isCustomDimension) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _buildInputCardBox(
                    label: 'Length (m)',
                    value: '${provider.lengthStr}m',
                    isActive: provider.activeDimField == 'length',
                    onTap: () => provider.setActiveDimField('length'),
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildInputCardBox(
                    label: 'Width (m)',
                    value: '${provider.widthStr}m',
                    isActive: provider.activeDimField == 'width',
                    onTap: () => provider.setActiveDimField('width'),
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Editing ${provider.activeDimField.toUpperCase()} — tap numbers to type',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            CustomKeypad(
              onKeyPress: (key) => provider.pressDimKey(key),
              isDark: isDark,
            ),
          ],
          const SizedBox(height: 14),
          _buildSummaryBox(
            isDark: isDark,
            rows: [
              _SummaryRow('Calculated Sheet Area',
                  '${provider.currentArea.toStringAsFixed(2)} m²'),
              _SummaryRow('Base Price / Piece',
                  'RM ${provider.currentBaseUnitPrice.toStringAsFixed(2)}',
                  isHighlight: true),
            ],
          ),
        ],
      ),
    );
  }

  // STEP 4: SEQUENTIAL DISCOUNTS
  Widget _buildStep4Discounts(
      BuildContext context, QuotationProvider provider, bool isDark) {
    return _buildCardWrapper(
      title: '4. Sequential Dual Discounts',
      badge: 'Base: RM ${provider.currentBaseUnitPrice.toStringAsFixed(2)}',
      isDark: isDark,
      borderColor: const Color(0x66C084FC),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildInputCardBox(
                  label: '1st Discount',
                  value: '${provider.disc1Str} %',
                  isActive: provider.activeDiscField == 'disc1',
                  accentColor: AppTheme.accentPurple,
                  onTap: () => provider.setActiveDiscField('disc1'),
                  isDark: isDark,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  '+',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.accentPurple,
                  ),
                ),
              ),
              Expanded(
                child: _buildInputCardBox(
                  label: '2nd Discount',
                  value: '${provider.disc2Str} %',
                  isActive: provider.activeDiscField == 'disc2',
                  accentColor: AppTheme.accentPurple,
                  onTap: () => provider.setActiveDiscField('disc2'),
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Editing ${provider.activeDiscField == "disc1" ? "1ST DISCOUNT" : "2ND DISCOUNT"} — tap numbers to type',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppTheme.accentPurple,
            ),
          ),
          const SizedBox(height: 12),
          CustomKeypad(
            onKeyPress: (key) => provider.pressDiscKey(key),
            isDark: isDark,
          ),
          const SizedBox(height: 14),
          _buildSummaryBox(
            isDark: isDark,
            rows: [
              _SummaryRow(
                'Final Unit Net Price',
                'RM ${provider.currentFinalUnitPrice.toStringAsFixed(2)}',
                isHighlight: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // STEP 5: ORDER QUANTITY
  Widget _buildStep5Quantity(
      BuildContext context, QuotationProvider provider, bool isDark) {
    return _buildCardWrapper(
      title: '5. Order Quantity',
      badge: 'RM ${provider.currentFinalUnitPrice.toStringAsFixed(2)} / pc',
      isDark: isDark,
      borderColor: const Color(0x66F59E0B),
      child: Column(
        children: [
          _buildInputCardBox(
            label: 'Order Quantity (Sheets)',
            value: '${provider.qtyStr} SHEETS',
            isActive: true,
            accentColor: AppTheme.accentAmber,
            onTap: () {},
            isDark: isDark,
          ),
          const SizedBox(height: 14),
          CustomKeypad(
            onKeyPress: (key) => provider.pressQtyKey(key),
            showDoubleZero: true,
            isDark: isDark,
          ),
          const SizedBox(height: 14),
          _buildSummaryBox(
            isDark: isDark,
            rows: [
              _SummaryRow(
                'Item Total Price',
                'RM ${provider.currentTotalPrice.toStringAsFixed(2)}',
                isHighlight: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // STEP 6: REMARKS & TERMS
  Widget _buildStep6Terms(
      BuildContext context, QuotationProvider provider, bool isDark) {
    return _buildCardWrapper(
      title: '6. Quotation Remarks & Terms',
      badge: 'Header & Footer',
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sales Person Name',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppTheme.primary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            onChanged: (val) => provider.setSalesPerson(val),
            decoration: InputDecoration(
              hintText: 'e.g. Chong / Alex',
              hintStyle: TextStyle(
                color:
                    isDark ? AppTheme.textDarkMuted : AppTheme.textLightMuted,
              ),
              filled: true,
              fillColor: isDark ? AppTheme.inputDark : AppTheme.inputLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                ),
              ),
            ),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),

          // Brand Fixed Display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.inputDark : AppTheme.inputLight,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Brand:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                ),
                Text(
                  'ECCO (Fixed)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Payment Term Buttons
          const Text(
            'Payment Term',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppTheme.primary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: PaymentTerm.values.map((term) {
              final isSelected = provider.header.paymentTerm == term;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: _buildChoiceButton(
                    title: term.label,
                    isActive: isSelected,
                    onTap: () => provider.setPaymentTerm(term),
                    isDark: isDark,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),

          // Validity Preset Buttons
          const Text(
            'Validity Period',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppTheme.primary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [1, 3, 7, 14, '-N/A-'].map((days) {
              final isSelected = provider.header.validityDays == days;
              final label = days == '-N/A-' ? '-N/A-' : '${days}d';
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  child: _buildChoiceButton(
                    title: label,
                    isActive: isSelected,
                    onTap: () => provider.setValidityDays(days),
                    isDark: isDark,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // BOTTOM STICKY DOCK
  Widget _buildStickyBottomDock(
      BuildContext context, QuotationProvider provider, bool isDark) {
    final step = provider.currentStep;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xF20B1329) : const Color(0xF2FFFFFF),
        border: Border(
          top: BorderSide(
            color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
            width: 1.5,
          ),
        ),
      ),
      child: Row(
        children: [
          if (step > 1)
            Expanded(
              flex: 1,
              child: ElevatedButton(
                onPressed: () => provider.previousStep(),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isDark ? AppTheme.inputDark : AppTheme.inputLight,
                  foregroundColor: isDark ? Colors.white : Colors.black,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color:
                          isDark ? AppTheme.borderDark : AppTheme.borderLight,
                    ),
                  ),
                ),
                child: const Text('Back',
                    style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ),
          if (step > 1) const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                gradient: step == 6
                    ? AppTheme.amberGradient
                    : AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x330284C7),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    if (step < 6) {
                      provider.nextStep();
                    } else if (step == 6) {
                      provider.addItemToCart();
                      provider.goToStep(7);
                    }
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      step == 6 ? '➕ Add to Quotation Table' : 'Next Step',
                      style: TextStyle(
                        color: step == 6 ? Colors.black : Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // HELPER CONTAINER WRAPPER
  Widget _buildCardWrapper({
    required String title,
    required String badge,
    required bool isDark,
    required Widget child,
    Color? borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: borderColor ??
              (isDark ? AppTheme.borderDark : AppTheme.borderLight),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 16,
            offset: Offset(0, 6),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color:
                      isDark ? AppTheme.textDarkMuted : AppTheme.textLightMuted,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0x2638BDF8),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildChoiceButton({
    required String title,
    required bool isActive,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            gradient: isActive ? AppTheme.primaryGradient : null,
            color: isActive
                ? null
                : (isDark ? AppTheme.inputDark : AppTheme.inputLight),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isActive
                  ? Colors.transparent
                  : (isDark ? AppTheme.borderDark : AppTheme.borderLight),
              width: 1.5,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: isActive
                  ? Colors.white
                  : (isDark ? AppTheme.textDarkMain : AppTheme.textLightMain),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputCardBox({
    required String label,
    required String value,
    required bool isActive,
    required VoidCallback onTap,
    required bool isDark,
    Color accentColor = AppTheme.primary,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isActive
                ? accentColor.withValues(alpha: 0.12)
                : (isDark ? AppTheme.inputDark : AppTheme.inputLight),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isActive
                  ? accentColor
                  : (isDark ? AppTheme.borderDark : AppTheme.borderLight),
              width: 2.0,
            ),
          ),
          child: Column(
            children: [
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color:
                      isDark ? AppTheme.textDarkMuted : AppTheme.textLightMuted,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: accentColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryBox({
    required bool isDark,
    required List<_SummaryRow> rows,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.inputDark : AppTheme.inputLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
        ),
      ),
      child: Column(
        children: rows.map((r) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  r.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppTheme.textDarkMuted
                        : AppTheme.textLightMuted,
                  ),
                ),
                Text(
                  r.value,
                  style: TextStyle(
                    fontSize: r.isHighlight ? 15 : 13,
                    fontWeight:
                        r.isHighlight ? FontWeight.w900 : FontWeight.w700,
                    color: r.isHighlight
                        ? AppTheme.primary
                        : (isDark
                            ? AppTheme.textDarkMain
                            : AppTheme.textLightMain),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SummaryRow {
  final String label;
  final String value;
  final bool isHighlight;
  _SummaryRow(this.label, this.value, {this.isHighlight = false});
}
