import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/mesh_item.dart';

class EccoQuotationTable extends StatelessWidget {
  final List<MeshItem> cartItems;
  final MeshItem draftItem;
  final QuotationHeader header;
  final Function(String id)? onDeleteItem;
  final Function(String id, double newUnitPrice)? onUnitPriceChanged;
  final bool isExportMode;

  const EccoQuotationTable({
    super.key,
    required this.cartItems,
    required this.draftItem,
    required this.header,
    this.onDeleteItem,
    this.onUnitPriceChanged,
    this.isExportMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd/MM/yyyy hh:mm a').format(header.date);
    final rawItems = cartItems.isNotEmpty
        ? cartItems
        : (draftItem.quantity > 0 ? [draftItem] : <MeshItem>[]);
    final itemsToDisplay = List<MeshItem>.from(rawItems)
      ..sort((a, b) {
        final orderMap = {MeshGrade.gradeA: 1, MeshGrade.gradeB: 2, MeshGrade.gradeDA: 3};
        final orderA = orderMap[a.grade] ?? 99;
        final orderB = orderMap[b.grade] ?? 99;
        if (orderA != orderB) {
          return orderA.compareTo(orderB);
        }
        return a.size.compareTo(b.size);
      });
    final grandTotal = itemsToDisplay.fold(0.0, (sum, item) => sum + item.totalPrice);
    final showActionColumn = !isExportMode && cartItems.isNotEmpty && onDeleteItem != null;

    final tableWidget = Table(
      defaultColumnWidth: const IntrinsicColumnWidth(),
      border: TableBorder.all(color: Colors.black, width: 1.5),
      children: [
        // Header Row
        TableRow(
          decoration: const BoxDecoration(color: Colors.white),
          children: [
            _buildCell('Fabric Reference No', isHeader: true),
            _buildCell('MS145: 2014', isHeader: true),
            _buildCell('List Price (RM)\nper Sq. m', isHeader: true),
            _buildCell('kg/m²', isHeader: true),
            _buildCell('Qty - PCS', isHeader: true),
            _buildCell('Unit Price\n(RM/PC)', isHeader: true),
            _buildCell('Total (RM)', isHeader: true),
            if (showActionColumn)
              _buildCell('Action', isHeader: true),
          ],
        ),

        // Empty Table Fallback Row
        if (itemsToDisplay.isEmpty)
          TableRow(
            decoration: const BoxDecoration(color: Color(0xFFFFF0F5)),
            children: [
              _buildCell('No items in quotation', isBold: true),
              _buildCell('-'),
              _buildCell('-'),
              _buildCell('-'),
              _buildCell('0'),
              _buildCell('0.00'),
              _buildCell('0.00', isBold: true),
              if (showActionColumn)
                _buildCell(''),
            ],
          ),

        // Item Rows
        for (var item in itemsToDisplay)
          TableRow(
            decoration: const BoxDecoration(
              color: Color(0xFFFFF0F5), // Soft pink background matching official spec
            ),
            children: [
              _buildCell('${item.fabricRefNo}\n(${item.length}m x ${item.width}m)'),
              _buildCell(item.ms145Code),
              _buildCell(item.listPriceRatePerM2.toStringAsFixed(2)),
              _buildCell(item.unitWeightKgPerM2.toStringAsFixed(2)),
              _buildCell('${item.quantity}'),
              isExportMode
                  ? Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black26),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item.finalUnitPrice.toStringAsFixed(2),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    )
                  : _buildEditableUnitPriceCell(item, context),
              _buildCell(
                item.totalPrice.toStringAsFixed(2),
                isBold: true,
              ),
              if (showActionColumn)
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                    onPressed: () => onDeleteItem!(item.id),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                ),
            ],
          ),

        // Grand Total Row
        TableRow(
          decoration: const BoxDecoration(
            color: Color(0xFFE0FFFF), // Light cyan total bar
          ),
          children: [
            _buildCell('Total', isHeader: true, colSpanText: true),
            _buildCell(''),
            _buildCell(''),
            _buildCell(''),
            _buildCell(''),
            _buildCell(''),
            _buildCell(
              grandTotal.toStringAsFixed(2),
              isHeader: true,
              isBold: true,
            ),
            if (showActionColumn)
              _buildCell(''),
          ],
        ),
      ],
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 2.5),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 16,
            offset: Offset(0, 4),
          )
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Official Header Title & Logo
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Image.asset(
                    'assets/images/ecco_steel_logo.png',
                    height: 68,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'ecco_logo.png',
                        height: 68,
                        fit: BoxFit.contain,
                        errorBuilder: (ctx, err, stack) {
                          return const Text(
                            'ECCO STEEL',
                            style: TextStyle(
                              fontFamily: 'Arial',
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.black26, style: BorderStyle.solid),
                bottom: BorderSide(color: Colors.black26, style: BorderStyle.solid),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'date: $dateStr',
                  style: const TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  'sales person: ${header.salesPerson.isEmpty ? '-' : header.salesPerson}',
                  style: const TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Quotation Table (Scrollable in interactive view, unclipped in export mode)
          if (isExportMode)
            SizedBox(
              width: 720,
              child: tableWidget,
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: tableWidget,
            ),

          const SizedBox(height: 14),

          // Official Terms Footer
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Brand: ECCO',
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              Text(
                'Term: ${header.paymentTerm.label}',
                style: const TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              Text(
                'Validity: ${header.validityDays} ${header.validityDays == 1 ? "day" : "days"}, subjected to our final confirmation',
                style: const TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCell(
    String text, {
    bool isHeader = false,
    bool isBold = false,
    bool colSpanText = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Arial',
          fontSize: isHeader ? 12 : 12.5,
          fontWeight: isHeader || isBold ? FontWeight.w800 : FontWeight.w500,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildEditableUnitPriceCell(MeshItem item, BuildContext context) {
    final controller = TextEditingController(
      text: item.finalUnitPrice.toStringAsFixed(2),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: SizedBox(
        width: 80,
        child: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Arial',
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
          decoration: const InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF0284C7), width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black26, width: 1.0),
            ),
          ),
          onSubmitted: (value) {
            final parsed = double.tryParse(value);
            if (parsed != null && onUnitPriceChanged != null) {
              onUnitPriceChanged!(item.id, parsed);
            }
          },
        ),
      ),
    );
  }
}
